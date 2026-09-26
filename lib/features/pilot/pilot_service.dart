import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/models.dart';
import '../../data/repositories/academic_history_repository.dart';
import '../../data/repositories/academic_repository.dart';
import '../../data/repositories/intervention_repository.dart';
import '../../data/repositories/prediction_repository.dart';
import '../../data/services/providers.dart';
import '../analytics/analytics_service.dart';
import '../prediction/engine/model_bundle.dart';
import 'engine/pilot_evaluation.dart';

final pilotServiceProvider = Provider<PilotService>((ref) {
  return PilotService(
    academic: ref.watch(academicRepositoryProvider),
    history: ref.watch(academicHistoryRepositoryProvider),
    predictions: ref.watch(predictionRepositoryProvider),
    interventions: ref.watch(interventionRepositoryProvider),
    analytics: ref.watch(analyticsServiceProvider),
  );
});

/// Builds the pilot evaluation from everything recorded in the app.
/// Admin only: it spans every section.
class PilotService {
  final AcademicRepository academic;
  final AcademicHistoryRepository history;
  final PredictionRepository predictions;
  final InterventionRepository interventions;
  final AnalyticsService analytics;

  PilotService({
    required this.academic,
    required this.history,
    required this.predictions,
    required this.interventions,
    required this.analytics,
  });

  Future<PilotReport> evaluate(AppUser user, {bool includeTestModels = false, DateTime? now}) async {
    if (user.role != UserRole.admin) throw StateError('Only administrators can view the pilot evaluation.');

    final students = await academic.getStudents();
    final ids = [for (final s in students) s.id];
    final histories = {for (final h in await history.getHistoriesForStudents(ids)) h.student.id: h};
    final noHistory = histories.values
        .where((h) => h.semesterResults.isEmpty && h.subjectResults.isEmpty && h.attendanceSummaries.isEmpty)
        .length;
    final notes = await interventions.forStudents(ids);
    final levels = <String, double>{};
    for (final m in await predictions.getModels()) {
      final level = ModelBundle.parse(m.bundleJson).intervalLevel;
      if (level != null) levels[m.id] = level;
    }

    return PilotEvaluator.evaluate(
      predictions: await predictions.getAllPredictions(),
      histories: histories,
      sectionLabels: {for (final s in await analytics.visibleSections(user)) s.section.id: s.label},
      interventions: notes.map((k, v) => MapEntry(k, [for (final e in v) e.intervention])),
      imports: await history.getImportBatches(),
      studentsTotal: students.length,
      studentsWithoutHistory: noHistory,
      intervalLevels: levels,
      includeTestModels: includeTestModels,
      now: now,
    );
  }
}
