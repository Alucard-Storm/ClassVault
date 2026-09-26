/// A faculty record about a student: a note, meeting, referral, mentoring
/// session, or a review of a prediction (agreeing or disagreeing with it).
/// Staff-only; never shown to students.
class Intervention {
  static const types = ['note', 'meeting', 'referral', 'mentoring', 'prediction_review'];

  final String id;
  final String studentId;
  final String authorId; // AppUser uid
  final String type;
  final String note;
  final String status; // 'open' | 'done'
  final DateTime? followUpOn;

  /// For prediction reviews: the prediction reviewed and the verdict.
  final String? predictionId;
  final String? reviewAssessment; // 'agree' | 'disagree'
  final DateTime createdAt;
  final DateTime updatedAt;

  Intervention({
    required this.id,
    required this.studentId,
    required this.authorId,
    required this.type,
    required this.note,
    required this.status,
    this.followUpOn,
    this.predictionId,
    this.reviewAssessment,
    required this.createdAt,
    required this.updatedAt,
  });

  bool get isOpen => status == 'open';
  bool get isReview => type == 'prediction_review';

  Intervention copyWith({String? note, String? status, DateTime? followUpOn, bool clearFollowUp = false, DateTime? updatedAt}) =>
      Intervention(
        id: id,
        studentId: studentId,
        authorId: authorId,
        type: type,
        note: note ?? this.note,
        status: status ?? this.status,
        followUpOn: clearFollowUp ? null : (followUpOn ?? this.followUpOn),
        predictionId: predictionId,
        reviewAssessment: reviewAssessment,
        createdAt: createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
}
