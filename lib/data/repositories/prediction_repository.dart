import '../models/models.dart';

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

  /// Most recent prediction per student for [task].
  Future<Map<String, PredictionRecord>> getLatestPredictions(List<String> studentIds, String task);
}
