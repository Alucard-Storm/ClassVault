/// Pre-admission schooling result (10th, 12th, diploma).
class SchoolResult {
  final String id;
  final String studentId;
  final String level; // '10th' | '12th' | 'diploma'
  final String? board;
  final double percentage;
  final int? passingYear;
  final String? importBatchId;

  SchoolResult({
    required this.id,
    required this.studentId,
    required this.level,
    this.board,
    required this.percentage,
    this.passingYear,
    this.importBatchId,
  });

  factory SchoolResult.fromJson(Map<String, dynamic> json) {
    return SchoolResult(
      id: json['id'] as String,
      studentId: json['studentId'] as String,
      level: json['level'] as String,
      board: json['board'] as String?,
      percentage: (json['percentage'] as num).toDouble(),
      passingYear: json['passingYear'] as int?,
      importBatchId: json['importBatchId'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'studentId': studentId,
      'level': level,
      'board': board,
      'percentage': percentage,
      'passingYear': passingYear,
      'importBatchId': importBatchId,
    };
  }

  SchoolResult copyWith({
    String? id,
    String? studentId,
    String? level,
    String? board,
    double? percentage,
    int? passingYear,
    String? importBatchId,
  }) {
    return SchoolResult(
      id: id ?? this.id,
      studentId: studentId ?? this.studentId,
      level: level ?? this.level,
      board: board ?? this.board,
      percentage: percentage ?? this.percentage,
      passingYear: passingYear ?? this.passingYear,
      importBatchId: importBatchId ?? this.importBatchId,
    );
  }
}
