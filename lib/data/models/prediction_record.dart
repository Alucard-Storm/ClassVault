/// One stored prediction with everything needed to audit it later: the
/// model and feature versions, the feature values used and each feature's
/// contribution.
class PredictionRecord {
  final String id;
  final String studentId;
  final String task; // 'risk' | 'forecast'
  final String modelId;
  final String featureVersion;
  final int targetSemester;
  final double? probability;
  final String? band; // 'low' | 'moderate' | 'elevated'
  final double? value;
  final double? lower;
  final double? upper;
  final String featuresJson;
  final String contributionsJson;
  final bool synthetic;
  final DateTime generatedAt;
  final String? generatedBy;

  PredictionRecord({
    required this.id,
    required this.studentId,
    required this.task,
    required this.modelId,
    required this.featureVersion,
    required this.targetSemester,
    this.probability,
    this.band,
    this.value,
    this.lower,
    this.upper,
    required this.featuresJson,
    required this.contributionsJson,
    required this.synthetic,
    required this.generatedAt,
    this.generatedBy,
  });
}
