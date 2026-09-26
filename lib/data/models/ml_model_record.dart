/// A model file imported from the `ml/` pipeline, stored verbatim.
class MlModelRecord {
  final String id;
  final String task; // 'risk' | 'forecast'
  final String family;
  final String featureVersion;
  final String bundleJson;
  final bool synthetic;
  final bool recommended;
  final bool active;
  final DateTime importedAt;
  final String? importedBy;

  MlModelRecord({
    required this.id,
    required this.task,
    required this.family,
    required this.featureVersion,
    required this.bundleJson,
    required this.synthetic,
    required this.recommended,
    required this.active,
    required this.importedAt,
    this.importedBy,
  });

  MlModelRecord copyWith({bool? active}) => MlModelRecord(
        id: id,
        task: task,
        family: family,
        featureVersion: featureVersion,
        bundleJson: bundleJson,
        synthetic: synthetic,
        recommended: recommended,
        active: active ?? this.active,
        importedAt: importedAt,
        importedBy: importedBy,
      );
}
