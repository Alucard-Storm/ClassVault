/// A single committed import. Every imported history record points back to
/// its batch so an import can be audited or rolled back as a unit.
class ImportBatch {
  final String id;
  final String fileName;
  final DateTime importedAt;
  final String? importedBy; // AppUser uid
  final int recordCount;
  final String? notes;

  /// Data-quality counts from validation (null for imports before v4).
  final int? rejectedRows;
  final int? warningCount;

  ImportBatch({
    required this.id,
    required this.fileName,
    required this.importedAt,
    this.importedBy,
    required this.recordCount,
    this.notes,
    this.rejectedRows,
    this.warningCount,
  });

  factory ImportBatch.fromJson(Map<String, dynamic> json) {
    return ImportBatch(
      id: json['id'] as String,
      fileName: json['fileName'] as String,
      importedAt: DateTime.parse(json['importedAt'] as String),
      importedBy: json['importedBy'] as String?,
      recordCount: json['recordCount'] as int,
      notes: json['notes'] as String?,
      rejectedRows: json['rejectedRows'] as int?,
      warningCount: json['warningCount'] as int?,
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
      'rejectedRows': rejectedRows,
      'warningCount': warningCount,
    };
  }

  ImportBatch copyWith({
    String? id,
    String? fileName,
    DateTime? importedAt,
    String? importedBy,
    int? recordCount,
    String? notes,
    int? rejectedRows,
    int? warningCount,
  }) {
    return ImportBatch(
      id: id ?? this.id,
      fileName: fileName ?? this.fileName,
      importedAt: importedAt ?? this.importedAt,
      importedBy: importedBy ?? this.importedBy,
      recordCount: recordCount ?? this.recordCount,
      notes: notes ?? this.notes,
      rejectedRows: rejectedRows ?? this.rejectedRows,
      warningCount: warningCount ?? this.warningCount,
    );
  }
}
