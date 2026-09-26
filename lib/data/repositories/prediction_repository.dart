import '../models/models.dart';

/// One "Generate predictions" run by one person with one model.
class PredictionRun {
  final DateTime generatedAt;
  final String? generatedBy; // user uid
  final String? generatedByName;
  final String modelId;
  final String task;
  final bool synthetic;
  final int count;

  const PredictionRun({
    required this.generatedAt,
    required this.generatedBy,
    required this.generatedByName,
    required this.modelId,
    required this.task,
    required this.synthetic,
    required this.count,
  });
}

abstract class PredictionRepository {
  // Models
  Future<List<MlModelRecord>> getModels();
  Future<void> addModel(MlModelRecord model);

  /// Makes [id] the only active model for its task (or deactivates it).
  Future<void> setActive(String id, bool active);
  Future<void> deleteModel(String id);

  // Predictions
  Future<void> addPredictions(List<PredictionRecord> predictions);
  Future<List<PredictionRecord>> getPredictionsForStudent(String studentId);

  Future<PredictionRecord?> getPrediction(String id);

  Future<List<PredictionRecord>> getAllPredictions();

  /// Number of stored predictions per model id.
  Future<Map<String, int>> countByModel();

  /// Audit log of prediction runs, newest first.
  Future<List<PredictionRun>> getActivity({int limit = 50});

  /// Most recent prediction per student for [task].
  Future<Map<String, PredictionRecord>> getLatestPredictions(List<String> studentIds, String task);
}
