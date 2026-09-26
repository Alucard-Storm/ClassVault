/// A single scored assessment (quiz, mid-term, lab, assignment, ...).
class Assessment {
  final String id;
  final String studentId;
  final int semesterNumber;
  final String? subjectId;
  final String subjectName;
  final String assessmentType; // e.g. 'quiz' | 'midterm' | 'lab' | 'assignment'
  final String? title;
  final double score;
  final double maxScore;
  final DateTime? assessedOn;
  final String? importBatchId;

  Assessment({
    required this.id,
    required this.studentId,
    required this.semesterNumber,
    this.subjectId,
    required this.subjectName,
    required this.assessmentType,
    this.title,
    required this.score,
    required this.maxScore,
    this.assessedOn,
    this.importBatchId,
  });

  factory Assessment.fromJson(Map<String, dynamic> json) {
    return Assessment(
      id: json['id'] as String,
      studentId: json['studentId'] as String,
      semesterNumber: json['semesterNumber'] as int,
      subjectId: json['subjectId'] as String?,
      subjectName: json['subjectName'] as String,
      assessmentType: json['assessmentType'] as String,
      title: json['title'] as String?,
      score: (json['score'] as num).toDouble(),
      maxScore: (json['maxScore'] as num).toDouble(),
      assessedOn: json['assessedOn'] == null ? null : DateTime.parse(json['assessedOn'] as String),
      importBatchId: json['importBatchId'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'studentId': studentId,
      'semesterNumber': semesterNumber,
      'subjectId': subjectId,
      'subjectName': subjectName,
      'assessmentType': assessmentType,
      'title': title,
      'score': score,
      'maxScore': maxScore,
      'assessedOn': assessedOn?.toIso8601String(),
      'importBatchId': importBatchId,
    };
  }

  Assessment copyWith({
    String? id,
    String? studentId,
    int? semesterNumber,
    String? subjectId,
    String? subjectName,
    String? assessmentType,
    String? title,
    double? score,
    double? maxScore,
    DateTime? assessedOn,
    String? importBatchId,
  }) {
    return Assessment(
      id: id ?? this.id,
      studentId: studentId ?? this.studentId,
      semesterNumber: semesterNumber ?? this.semesterNumber,
      subjectId: subjectId ?? this.subjectId,
      subjectName: subjectName ?? this.subjectName,
      assessmentType: assessmentType ?? this.assessmentType,
      title: title ?? this.title,
      score: score ?? this.score,
      maxScore: maxScore ?? this.maxScore,
      assessedOn: assessedOn ?? this.assessedOn,
      importBatchId: importBatchId ?? this.importBatchId,
    );
  }
}
