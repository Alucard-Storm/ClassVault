import 'package:drift/drift.dart';

import '../database/app_database.dart';
import '../models/models.dart';
import '../repositories/academic_history_repository.dart';

class DriftAcademicHistoryService implements AcademicHistoryRepository {
  final AppDatabase _db;

  DriftAcademicHistoryService(this._db);

  // Aggregate

  @override
  Future<StudentAcademicHistory?> getStudentHistory(String studentId) async {
    final student = await (_db.select(_db.students)..where((t) => t.id.equals(studentId)))
        .getSingleOrNull();
    if (student == null) return null;

    final results = await Future.wait([
      getEnrollmentsForStudent(studentId),
      getSchoolResults(studentId),
      getSemesterResults(studentId),
      getSubjectResults(studentId),
      getAttendanceSummaries(studentId),
      getAssessments(studentId),
    ]);

    return StudentAcademicHistory(
      student: student,
      enrollments: results[0] as List<StudentEnrollment>,
      schoolResults: results[1] as List<SchoolResult>,
      semesterResults: results[2] as List<SemesterResult>,
      subjectResults: results[3] as List<SubjectResult>,
      attendanceSummaries: results[4] as List<AttendanceSummary>,
      assessments: results[5] as List<Assessment>,
    );
  }

  // Enrollments

  @override
  Future<List<StudentEnrollment>> getEnrollmentsForStudent(String studentId) {
    return (_db.select(_db.studentEnrollments)
          ..where((t) => t.studentId.equals(studentId))
          ..orderBy([(t) => OrderingTerm.asc(t.startedAt)]))
        .get();
  }

  // School results

  @override
  Future<List<SchoolResult>> getSchoolResults(String studentId) {
    return (_db.select(_db.schoolResults)..where((t) => t.studentId.equals(studentId))).get();
  }

  @override
  Future<void> upsertSchoolResults(List<SchoolResult> results) {
    return _db.transaction(() async {
      for (final r in results) {
        final existing = await (_db.select(_db.schoolResults)
              ..where((t) => t.studentId.equals(r.studentId) & t.level.equals(r.level)))
            .getSingleOrNull();
        final row = existing == null ? r : r.copyWith(id: existing.id);
        await _db.into(_db.schoolResults).insertOnConflictUpdate(row.toInsertable());
      }
    });
  }

  @override
  Future<void> deleteSchoolResult(String id) =>
      (_db.delete(_db.schoolResults)..where((t) => t.id.equals(id))).go();

  // Semester results

  @override
  Future<List<SemesterResult>> getSemesterResults(String studentId) {
    return (_db.select(_db.semesterResults)
          ..where((t) => t.studentId.equals(studentId))
          ..orderBy([(t) => OrderingTerm.asc(t.semesterNumber)]))
        .get();
  }

  @override
  Future<void> upsertSemesterResults(List<SemesterResult> results) {
    return _db.transaction(() async {
      for (final r in results) {
        final existing = await (_db.select(_db.semesterResults)
              ..where((t) =>
                  t.studentId.equals(r.studentId) & t.semesterNumber.equals(r.semesterNumber)))
            .getSingleOrNull();
        final row = existing == null ? r : r.copyWith(id: existing.id);
        await _db.into(_db.semesterResults).insertOnConflictUpdate(row.toInsertable());
      }
    });
  }

  @override
  Future<void> deleteSemesterResult(String id) =>
      (_db.delete(_db.semesterResults)..where((t) => t.id.equals(id))).go();

  // Subject results

  @override
  Future<List<SubjectResult>> getSubjectResults(String studentId) {
    return (_db.select(_db.subjectResults)
          ..where((t) => t.studentId.equals(studentId))
          ..orderBy([
            (t) => OrderingTerm.asc(t.semesterNumber),
            (t) => OrderingTerm.asc(t.subjectName),
            (t) => OrderingTerm.asc(t.attempt),
          ]))
        .get();
  }

  @override
  Future<void> upsertSubjectResults(List<SubjectResult> results) {
    return _db.transaction(() async {
      for (final r in results) {
        final existing = await (_db.select(_db.subjectResults)
              ..where((t) =>
                  t.studentId.equals(r.studentId) &
                  t.semesterNumber.equals(r.semesterNumber) &
                  t.subjectName.equals(r.subjectName) &
                  t.attempt.equals(r.attempt)))
            .getSingleOrNull();
        final row = existing == null ? r : r.copyWith(id: existing.id);
        await _db.into(_db.subjectResults).insertOnConflictUpdate(row.toInsertable());
      }
    });
  }

  @override
  Future<void> deleteSubjectResult(String id) =>
      (_db.delete(_db.subjectResults)..where((t) => t.id.equals(id))).go();

  // Attendance summaries

  @override
  Future<List<AttendanceSummary>> getAttendanceSummaries(String studentId) {
    return (_db.select(_db.attendanceSummaries)
          ..where((t) => t.studentId.equals(studentId))
          ..orderBy([
            (t) => OrderingTerm.asc(t.semesterNumber),
            (t) => OrderingTerm.asc(t.subjectName),
          ]))
        .get();
  }

  @override
  Future<void> upsertAttendanceSummaries(List<AttendanceSummary> summaries) {
    return _db.transaction(() async {
      for (final s in summaries) {
        final existing = await (_db.select(_db.attendanceSummaries)
              ..where((t) =>
                  t.studentId.equals(s.studentId) &
                  t.semesterNumber.equals(s.semesterNumber) &
                  t.subjectName.equals(s.subjectName)))
            .getSingleOrNull();
        final row = existing == null ? s : s.copyWith(id: existing.id);
        await _db.into(_db.attendanceSummaries).insertOnConflictUpdate(row.toInsertable());
      }
    });
  }

  @override
  Future<void> deleteAttendanceSummary(String id) =>
      (_db.delete(_db.attendanceSummaries)..where((t) => t.id.equals(id))).go();

  // Assessments

  @override
  Future<List<Assessment>> getAssessments(String studentId) {
    return (_db.select(_db.assessments)
          ..where((t) => t.studentId.equals(studentId))
          ..orderBy([(t) => OrderingTerm.asc(t.semesterNumber)]))
        .get();
  }

  @override
  Future<void> addAssessments(List<Assessment> assessments) {
    return _db.batch((b) => b.insertAll(
          _db.assessments,
          assessments.map((a) => a.toInsertable()),
        ));
  }

  @override
  Future<void> deleteAssessment(String id) =>
      (_db.delete(_db.assessments)..where((t) => t.id.equals(id))).go();

  // Import batches

  @override
  Future<List<ImportBatch>> getImportBatches() {
    return (_db.select(_db.importBatches)
          ..orderBy([(t) => OrderingTerm.desc(t.importedAt)]))
        .get();
  }

  @override
  Future<void> createImportBatch(ImportBatch batch) =>
      _db.into(_db.importBatches).insert(batch.toInsertable());

  @override
  Future<void> deleteImportBatch(String id) =>
      // Records carrying this importBatchId cascade via foreign keys.
      (_db.delete(_db.importBatches)..where((t) => t.id.equals(id))).go();
}
