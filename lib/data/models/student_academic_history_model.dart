import 'student_model.dart';
import 'student_enrollment_model.dart';
import 'school_result_model.dart';
import 'semester_result_model.dart';
import 'subject_result_model.dart';
import 'attendance_summary_model.dart';
import 'assessment_model.dart';

/// Read-only aggregate of everything recorded about one student's academic
/// path. Not persisted; assembled by the history repository.
class StudentAcademicHistory {
  final Student student;
  final List<StudentEnrollment> enrollments;
  final List<SchoolResult> schoolResults;
  final List<SemesterResult> semesterResults;
  final List<SubjectResult> subjectResults;
  final List<AttendanceSummary> attendanceSummaries;
  final List<Assessment> assessments;

  StudentAcademicHistory({
    required this.student,
    required this.enrollments,
    required this.schoolResults,
    required this.semesterResults,
    required this.subjectResults,
    required this.attendanceSummaries,
    required this.assessments,
  });
}
