/// A single committed import. Every imported history record points back to
/// its batch so an import can be audited or rolled back as a unit.
class ImportBatch {
  final String id;
  final String fileName;
  final DateTime importedAt;
  final String? importedBy; // AppUser uid
  final int recordCount;
  final String? notes;

  ImportBatch({
    required this.id,
    required this.fileName,
    required this.importedAt,
    this.importedBy,
    required this.recordCount,
    this.notes,
  });

  factory ImportBatch.fromJson(Map<String, dynamic> json) {
    return ImportBatch(
      id: json['id'] as String,
      fileName: json['fileName'] as String,
      importedAt: DateTime.parse(json['importedAt'] as String),
      importedBy: json['importedBy'] as String?,
      recordCount: json['recordCount'] as int,
      notes: json['notes'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fileName': fileName,
      'importedAt': importedAt.toIso8601String(),
      'importedBy': importedBy,
      'recordCount': recordCount,
      'notes': notes,
    };
  }

  ImportBatch copyWith({
    String? id,
    String? fileName,
    DateTime? importedAt,
    String? importedBy,
    int? recordCount,
    String? notes,
  }) {
    return ImportBatch(
      id: id ?? this.id,
      fileName: fileName ?? this.fileName,
      importedAt: importedAt ?? this.importedAt,
      importedBy: importedBy ?? this.importedBy,
      recordCount: recordCount ?? this.recordCount,
      notes: notes ?? this.notes,
    );
  }
}
