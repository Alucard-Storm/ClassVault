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

  @override
  Future<List<StudentAcademicHistory>> getHistoriesForStudents(List<String> studentIds) async {
    if (studentIds.isEmpty) return const [];
    final ids = studentIds.toSet().toList();

    Map<String, List<T>> byStudent<T>(List<T> rows, String Function(T) studentOf) {
      final map = <String, List<T>>{};
      for (final r in rows) {
        map.putIfAbsent(studentOf(r), () => []).add(r);
      }
      return map;
    }

    final students = await (_db.select(_db.students)..where((t) => t.id.isIn(ids))).get();
    final enrollments = byStudent(
      await (_db.select(_db.studentEnrollments)
            ..where((t) => t.studentId.isIn(ids))
            ..orderBy([(t) => OrderingTerm.asc(t.startedAt)]))
          .get(),
      (r) => r.studentId,
    );
    final school = byStudent(
      await (_db.select(_db.schoolResults)..where((t) => t.studentId.isIn(ids))).get(),
      (r) => r.studentId,
    );
    final semester = byStudent(
      await (_db.select(_db.semesterResults)
            ..where((t) => t.studentId.isIn(ids))
            ..orderBy([(t) => OrderingTerm.asc(t.semesterNumber)]))
          .get(),
      (r) => r.studentId,
    );
    final subject = byStudent(
      await (_db.select(_db.subjectResults)..where((t) => t.studentId.isIn(ids))).get(),
      (r) => r.studentId,
    );
    final attendance = byStudent(
      await (_db.select(_db.attendanceSummaries)..where((t) => t.studentId.isIn(ids))).get(),
      (r) => r.studentId,
    );
    final assessments = byStudent(
      await (_db.select(_db.assessments)..where((t) => t.studentId.isIn(ids))).get(),
      (r) => r.studentId,
    );

    return [
      for (final s in students)
        StudentAcademicHistory(
          student: s,
          enrollments: enrollments[s.id] ?? const [],
          schoolResults: school[s.id] ?? const [],
          semesterResults: semester[s.id] ?? const [],
          subjectResults: subject[s.id] ?? const [],
          attendanceSummaries: attendance[s.id] ?? const [],
          assessments: assessments[s.id] ?? const [],
        ),
    ];
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
  Future<void> commitImport({
    required ImportBatch batch,
    List<SchoolResult> schoolResults = const [],
    List<SemesterResult> semesterResults = const [],
    List<SubjectResult> subjectResults = const [],
    List<AttendanceSummary> attendanceSummaries = const [],
    List<Assessment> assessments = const [],
  }) {
    return _db.transaction(() async {
      await createImportBatch(batch);
      await upsertSchoolResults([for (final r in schoolResults) r.copyWith(importBatchId: batch.id)]);
      await upsertSemesterResults([for (final r in semesterResults) r.copyWith(importBatchId: batch.id)]);
      await upsertSubjectResults([for (final r in subjectResults) r.copyWith(importBatchId: batch.id)]);
      await upsertAttendanceSummaries(
          [for (final r in attendanceSummaries) r.copyWith(importBatchId: batch.id)]);

      final newAssessments = <Assessment>[];
      for (final a in assessments) {
        if (!await _assessmentExists(a)) newAssessments.add(a.copyWith(importBatchId: batch.id));
      }
      await addAssessments(newAssessments);
    });
  }

  Future<bool> _assessmentExists(Assessment a) async {
    final query = _db.select(_db.assessments)
      ..where((t) =>
          t.studentId.equals(a.studentId) &
          t.semesterNumber.equals(a.semesterNumber) &
          t.subjectName.equals(a.subjectName) &
          t.assessmentType.equals(a.assessmentType) &
          t.score.equals(a.score) &
          t.maxScore.equals(a.maxScore) &
          (a.title == null ? t.title.isNull() : t.title.equals(a.title!)) &
          (a.assessedOn == null ? t.assessedOn.isNull() : t.assessedOn.equals(a.assessedOn!)))
      ..limit(1);
    return await query.getSingleOrNull() != null;
  }

  @override
  Future<void> deleteImportBatch(String id) =>
      // Records carrying this importBatchId cascade via foreign keys.
      (_db.delete(_db.importBatches)..where((t) => t.id.equals(id))).go();
}
