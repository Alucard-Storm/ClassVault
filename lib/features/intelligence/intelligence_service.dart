import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/utils/id_generator.dart';
import '../../data/models/models.dart';
import '../../data/repositories/academic_repository.dart';
import '../../data/repositories/intervention_repository.dart';
import '../../data/repositories/prediction_repository.dart';
import '../../data/services/providers.dart';
import '../analytics/analytics_service.dart';
import '../prediction/engine/explanation.dart';
import '../prediction/engine/model_bundle.dart';
import 'engine/attention_queue.dart';

final intelligenceServiceProvider = Provider<IntelligenceService>((ref) {
  return IntelligenceService(
    academic: ref.watch(academicRepositoryProvider),
    analytics: ref.watch(analyticsServiceProvider),
    predictions: ref.watch(predictionRepositoryProvider),
    interventions: ref.watch(interventionRepositoryProvider),
  );
});

class AccessDeniedException implements Exception {
  @override
  String toString() => 'This student is not in one of your sections.';
}

/// Faculty-facing intelligence: the attention queue, intervention notes and
/// prediction reviews. Admins see every section; faculty only their own.
class IntelligenceService {
  final AcademicRepository academic;
  final AnalyticsService analytics;
  final PredictionRepository predictions;
  final InterventionRepository interventions;

  IntelligenceService({
    required this.academic,
    required this.analytics,
    required this.predictions,
    required this.interventions,
  });

  Future<List<QueueItem>> attentionQueue(AppUser user, {DateTime? now}) async {
    final inputs = <QueueInput>[];
    for (final section in await analytics.visibleSections(user)) {
      final students = await analytics.forSection(section);
      final ids = [for (final s in students) s.student.id];
      final risk = await predictions.getLatestPredictions(ids, ModelTask.risk.name);
      final notes = await interventions.forStudents(ids);
      for (final a in students) {
        inputs.add(QueueInput(
          analytics: a,
          sectionLabel: section.label,
          latestRisk: risk[a.student.id] == null ? null : PredictionView.of(risk[a.student.id]!),
          interventions: notes[a.student.id] ?? const [],
        ));
      }
    }
    return AttentionQueue.build(inputs, now: now);
  }

  Future<List<InterventionEntry>> interventionsFor(String studentId, AppUser user) async {
    await _checkAccess(studentId, user);
    return (await interventions.forStudents([studentId]))[studentId] ?? const [];
  }

  Future<Intervention> addNote({
    required String studentId,
    required String type,
    required String note,
    DateTime? followUpOn,
    required AppUser user,
  }) async {
    if (!Intervention.types.contains(type) || type == 'prediction_review') {
      throw ArgumentError('Unknown note type "$type".');
    }
    if (note.trim().isEmpty) throw ArgumentError('Write a note.');
    await _checkAccess(studentId, user);
    final now = DateTime.now();
    final entry = Intervention(
      id: IdGenerator.next('int'),
      studentId: studentId,
      authorId: user.uid,
      type: type,
      note: note.trim(),
      status: followUpOn == null ? 'done' : 'open',
      followUpOn: followUpOn,
      createdAt: now,
      updatedAt: now,
    );
    await interventions.add(entry);
    return entry;
  }

  Future<void> setStatus(String interventionId, String status, AppUser user) async {
    if (status != 'open' && status != 'done') throw ArgumentError('Unknown status "$status".');
    final existing = await interventions.get(interventionId);
    if (existing == null) throw StateError('Note not found.');
    await _checkAccess(existing.studentId, user);
    await interventions.update(existing.copyWith(status: status, updatedAt: DateTime.now()));
  }

  /// Records a faculty member agreeing or disagreeing with a prediction. A
  /// disagreement removes that prediction's weight from the attention queue.
  Future<Intervention> reviewPrediction({
    required String predictionId,
    required bool agree,
    required String reason,
    required AppUser user,
  }) async {
    final prediction = await predictions.getPrediction(predictionId);
    if (prediction == null) throw StateError('Prediction not found.');
    if (!agree && reason.trim().isEmpty) throw ArgumentError('Say why you disagree.');
    await _checkAccess(prediction.studentId, user);
    final now = DateTime.now();
    final entry = Intervention(
      id: IdGenerator.next('rev'),
      studentId: prediction.studentId,
      authorId: user.uid,
      type: 'prediction_review',
      note: reason.trim().isEmpty ? 'Agreed with the prediction.' : reason.trim(),
      status: 'done',
      predictionId: predictionId,
      reviewAssessment: agree ? 'agree' : 'disagree',
      createdAt: now,
      updatedAt: now,
    );
    await interventions.add(entry);
    return entry;
  }

  /// Reviews of one prediction, newest first.
  Future<List<InterventionEntry>> reviewsOf(String predictionId, String studentId, AppUser user) async {
    final all = await interventionsFor(studentId, user);
    return [
      for (final e in all)
        if (e.intervention.isReview && e.intervention.predictionId == predictionId) e,
    ];
  }

  Future<void> _checkAccess(String studentId, AppUser user) async {
    final student = (await academic.getStudents()).where((s) => s.id == studentId).firstOrNull;
    final visible = await analytics.visibleSections(user);
    if (student == null || !visible.any((s) => s.section.id == student.sectionId)) {
      throw AccessDeniedException();
    }
  }
}
