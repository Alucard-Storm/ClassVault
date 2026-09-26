import '../models/models.dart';

/// Longitudinal academic records (Phase 1 of Academic Intelligence).
///
/// `upsert*` methods match on each record's natural key rather than its id —
/// (student, level), (student, semester), (student, semester, subject,
/// attempt), (student, semester, subject) — so re-importing the same
/// spreadsheet updates rows instead of duplicating them.
abstract class AcademicHistoryRepository {
  // Aggregate
  Future<StudentAcademicHistory?> getStudentHistory(String studentId);

  // Enrollment history (written by AcademicRepository add/promote)
  Future<List<StudentEnrollment>> getEnrollmentsForStudent(String studentId);

  // School results
  Future<List<SchoolResult>> getSchoolResults(String studentId);
  Future<void> upsertSchoolResults(List<SchoolResult> results);
  Future<void> deleteSchoolResult(String id);

  // Semester results
  Future<List<SemesterResult>> getSemesterResults(String studentId);
  Future<void> upsertSemesterResults(List<SemesterResult> results);
  Future<void> deleteSemesterResult(String id);

  // Subject results
  Future<List<SubjectResult>> getSubjectResults(String studentId);
  Future<void> upsertSubjectResults(List<SubjectResult> results);
  Future<void> deleteSubjectResult(String id);

  // Attendance summaries
  Future<List<AttendanceSummary>> getAttendanceSummaries(String studentId);
  Future<void> upsertAttendanceSummaries(List<AttendanceSummary> summaries);
  Future<void> deleteAttendanceSummary(String id);

  // Assessments (no natural key; always inserted)
  Future<List<Assessment>> getAssessments(String studentId);
  Future<void> addAssessments(List<Assessment> assessments);
  Future<void> deleteAssessment(String id);

  // Import batches
  Future<List<ImportBatch>> getImportBatches();
  Future<void> createImportBatch(ImportBatch batch);

  /// Rolls back an import: deletes the batch and every record it last wrote.
  Future<void> deleteImportBatch(String id);
}
