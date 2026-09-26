import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/utils/id_generator.dart';
import '../../data/models/models.dart';
import '../../data/repositories/academic_history_repository.dart';
import '../../data/repositories/academic_repository.dart';
import '../../data/repositories/prediction_repository.dart';
import '../../data/services/providers.dart';
import '../analytics/analytics_service.dart';
import 'engine/feature_extractor.dart';
import 'engine/model_bundle.dart';
import 'engine/explanation.dart';
import 'engine/synthetic_history.dart';

export 'engine/explanation.dart' show PredictionView, ExplanationText, FeatureChange;

final predictionServiceProvider = Provider<PredictionService>((ref) {
  return PredictionService(
    academic: ref.watch(academicRepositoryProvider),
    history: ref.watch(academicHistoryRepositoryProvider),
    predictions: ref.watch(predictionRepositoryProvider),
    analytics: ref.watch(analyticsServiceProvider),
  );
});

class StoredModel {
  final MlModelRecord record;
  final ModelBundle bundle;
  const StoredModel(this.record, this.bundle);

  /// Reasons an admin must acknowledge before activating.
  List<String> get warnings => [
        if (bundle.isSynthetic) 'Trained on synthetic data: for testing the pipeline only, not for real students.',
        if (bundle.trainingSource != 'synthetic' && bundle.trainingSource != 'classvault')
          'The model file does not say what data it was trained on.',
        for (final c in bundle.checks)
          if (!c.passed) 'Failed check "${c.name}": ${c.detail}',
        if (!bundle.recommended && bundle.checks.every((c) => c.passed) && !bundle.isSynthetic)
          'The training pipeline did not recommend this model for use.',
      ];
}

class ModelActivationException implements Exception {
  final List<String> warnings;
  ModelActivationException(this.warnings);
  @override
  String toString() => 'Activation needs acknowledgement: ${warnings.join(' ')}';
}

class ModelInUseException implements Exception {
  final int predictions;
  ModelInUseException(this.predictions);
  @override
  String toString() =>
      'This model made $predictions predictions and is kept so they stay auditable. Deactivate it instead.';
}

/// Everything shown in "Why this signal?".
class PredictionExplanation {
  final PredictionView prediction;
  final Student student;

  /// The model that made the prediction (kept while it has predictions).
  final ModelBundle? model;
  final String summary;
  final List<String> suggestions;

  /// Features that have changed since the prediction was made.
  final List<FeatureChange> changes;

  /// Set when the student has moved on from the predicted semester.
  final int? currentSemester;
  final String? generatedByName;

  const PredictionExplanation({
    required this.prediction,
    required this.student,
    required this.model,
    required this.summary,
    required this.suggestions,
    required this.changes,
    required this.currentSemester,
    required this.generatedByName,
  });

  bool get isStale => changes.isNotEmpty || (currentSemester != null && currentSemester != prediction.record.targetSemester);

  /// Training-data average of a feature (from the model's preprocessing).
  double? trainingAverage(String feature) =>
      model?.inputs.where((i) => i.source == feature && !i.isMissingIndicator).firstOrNull?.mean;
}

class GenerationResult {
  final int predicted;
  final int skippedNoHistory;
  const GenerationResult(this.predicted, this.skippedNoHistory);
}

/// Training-data export, model management and prediction generation.
class PredictionService {
  final AcademicRepository academic;
  final AcademicHistoryRepository history;
  final PredictionRepository predictions;
  final AnalyticsService analytics;

  PredictionService({
    required this.academic,
    required this.history,
    required this.predictions,
    required this.analytics,
  });

  // Training data -------------------------------------------------------------

  Future<({String csv, int rows, int students})> exportTrainingData() async {
    final students = await academic.getStudents();
    final histories = await history.getHistoriesForStudents([for (final s in students) s.id]);
    return TrainingDatasetExporter.export(histories);
  }

  ({String csv, int rows, int students}) exportSyntheticTrainingData({int seed = 42}) =>
      TrainingDatasetExporter.export(SyntheticHistoryGenerator(seed: seed).generate(), dataSource: 'synthetic');

  // Models ---------------------------------------------------------------------

  Future<List<StoredModel>> models() async => [
        for (final r in await predictions.getModels()) StoredModel(r, ModelBundle.parse(r.bundleJson)),
      ];

  Future<List<StoredModel>> activeModels() async => [
        for (final m in await models())
          if (m.record.active) m,
      ];

  /// Validates and stores a model file. Throws [ModelFormatException].
  Future<StoredModel> importModel(String json, {String? importedBy}) async {
    final bundle = ModelBundle.parse(json);
    final existing = await predictions.getModels();
    if (existing.any((m) => m.id == bundle.modelId)) {
      throw ModelFormatException('Model "${bundle.modelId}" is already imported.');
    }
    final record = MlModelRecord(
      id: bundle.modelId,
      task: bundle.task.name,
      family: bundle.family,
      featureVersion: bundle.featureVersion,
      bundleJson: json,
      synthetic: bundle.isSynthetic,
      recommended: bundle.recommended,
      active: false,
      importedAt: DateTime.now(),
      importedBy: importedBy,
    );
    await predictions.addModel(record);
    return StoredModel(record, bundle);
  }

  /// Activates [model] as the only model for its task. Models with warnings
  /// (synthetic data, failed checks) need [acknowledgeWarnings].
  Future<void> activate(StoredModel model, {bool acknowledgeWarnings = false}) async {
    if (model.warnings.isNotEmpty && !acknowledgeWarnings) throw ModelActivationException(model.warnings);
    await predictions.setActive(model.record.id, true);
  }

  Future<void> deactivate(StoredModel model) => predictions.setActive(model.record.id, false);

  /// Removes a model that has never been used. Models with predictions are
  /// kept so every prediction can be traced to the model that made it.
  Future<void> delete(StoredModel model) async {
    final used = (await predictions.countByModel())[model.record.id] ?? 0;
    if (used > 0) throw ModelInUseException(used);
    await predictions.deleteModel(model.record.id);
  }

  Future<Map<String, int>> predictionCounts() => predictions.countByModel();

  Future<List<PredictionRun>> activity() => predictions.getActivity();

  // Predictions -------------------------------------------------------------------

  /// Predicts the current semester's outcome for every student in [section]
  /// with each active model, storing the results with their explanations.
  Future<GenerationResult> generateForSection(SectionOption section, AppUser user) async {
    final visible = await analytics.visibleSections(user);
    if (!visible.any((s) => s.section.id == section.section.id)) {
      throw StateError('You do not have access to this section.');
    }
    final active = await activeModels();
    if (active.isEmpty) return const GenerationResult(0, 0);

    final students = await academic.getStudentsBySection(section.section.id);
    final histories = await history.getHistoriesForStudents([for (final s in students) s.id]);
    final now = DateTime.now();
    final records = <PredictionRecord>[];
    var skipped = 0;

    for (final h in histories) {
      final current = h.enrollments.where((e) => e.isCurrent).lastOrNull;
      final target = current?.semesterNumber ?? section.semesterNumber;
      final features = FeatureExtractor.extract(h, target);
      if (features['n_prior_semesters'] == 0) {
        skipped++; // nothing to base a prediction on
        continue;
      }
      for (final m in active) {
        final out = Predictor.run(m.bundle, features);
        records.add(PredictionRecord(
          id: IdGenerator.next('pred'),
          studentId: h.student.id,
          task: m.bundle.task.name,
          modelId: m.bundle.modelId,
          featureVersion: m.bundle.featureVersion,
          targetSemester: target,
          probability: out.probability,
          band: out.band?.name,
          value: out.value,
          lower: out.lower,
          upper: out.upper,
          featuresJson: jsonEncode(features),
          contributionsJson: PredictionView.encode(out),
          synthetic: m.bundle.isSynthetic,
          generatedAt: now,
          generatedBy: user.uid,
        ));
      }
    }
    await predictions.addPredictions(records);
    return GenerationResult(histories.length - skipped, skipped);
  }

  Future<({Map<String, PredictionView> risk, Map<String, PredictionView> forecast})> latestFor(
    List<String> studentIds,
  ) async {
    final risk = await predictions.getLatestPredictions(studentIds, ModelTask.risk.name);
    final forecast = await predictions.getLatestPredictions(studentIds, ModelTask.forecast.name);
    return (
      risk: risk.map((k, v) => MapEntry(k, PredictionView.of(v))),
      forecast: forecast.map((k, v) => MapEntry(k, PredictionView.of(v))),
    );
  }

  /// Prediction history for a student in one of [user]'s sections.
  Future<List<PredictionView>> historyFor(String studentId, AppUser user) async {
    if (await _visibleStudent(studentId, user) == null) return const [];
    return [for (final r in await predictions.getPredictionsForStudent(studentId)) PredictionView.of(r)];
  }

  /// Full explanation for one prediction, or null if it does not exist or
  /// the student is not in one of [user]'s sections.
  Future<PredictionExplanation?> explain(String predictionId, AppUser user) async {
    final record = await predictions.getPrediction(predictionId);
    if (record == null) return null;
    final student = await _visibleStudent(record.studentId, user);
    if (student == null) return null;

    final view = PredictionView.of(record);
    final model = (await predictions.getModels()).where((m) => m.id == record.modelId).firstOrNull;
    final h = await history.getStudentHistory(student.id);
    final current = h?.enrollments.where((e) => e.isCurrent).lastOrNull;
    final now = h == null ? const <String, double?>{} : FeatureExtractor.extract(h, record.targetSemester);
    final runs = await predictions.getActivity(limit: 500);

    return PredictionExplanation(
      prediction: view,
      student: student,
      model: model == null ? null : ModelBundle.parse(model.bundleJson),
      summary: ExplanationText.summary(view),
      suggestions: ExplanationText.suggestions(view),
      changes: h == null ? const [] : ExplanationText.changes(view.features, now),
      currentSemester: current?.semesterNumber,
      generatedByName: runs
          .where((r) => r.generatedBy == record.generatedBy && r.generatedAt == record.generatedAt)
          .firstOrNull
          ?.generatedByName,
    );
  }

  Future<Student?> _visibleStudent(String studentId, AppUser user) async {
    final student = (await academic.getStudents()).where((s) => s.id == studentId).firstOrNull;
    final visible = await analytics.visibleSections(user);
    if (student == null || !visible.any((s) => s.section.id == student.sectionId)) return null;
    return student;
  }
}
