import 'package:drift/drift.dart';

import '../database/app_database.dart';
import '../models/models.dart';
import '../repositories/attendance_repository.dart';

class DriftAttendanceService implements AttendanceRepository {
  final AppDatabase _db;

  DriftAttendanceService(this._db);

  @override
  Future<List<AttendanceSession>> getSessions() => _db.select(_db.attendanceSessions).get();

  @override
  Future<List<AttendanceSession>> getSessionsByFaculty(String facultyId) =>
      (_db.select(_db.attendanceSessions)..where((t) => t.facultyId.equals(facultyId))).get();

  @override
  Future<List<AttendanceSession>> getSessionsBySection(String sectionId) =>
      (_db.select(_db.attendanceSessions)..where((t) => t.sectionId.equals(sectionId))).get();

  @override
  Future<void> addSession(AttendanceSession session, List<AttendanceRecord> records) {
    return _db.transaction(() async {
      await _db.into(_db.attendanceSessions).insert(session.toInsertable());
      await _db.batch((b) => b.insertAll(
            _db.attendanceRecords,
            records.map((r) => r.toInsertable()),
          ));
    });
  }

  @override
  Future<void> updateSession(AttendanceSession session) =>
      _db.update(_db.attendanceSessions).replace(session.toInsertable());

  @override
  Future<void> deleteSession(String id) =>
      // Records cascade via the foreign key.
      (_db.delete(_db.attendanceSessions)..where((t) => t.id.equals(id))).go();

  @override
  Future<List<AttendanceRecord>> getAllAttendanceRecords() => _db.select(_db.attendanceRecords).get();

  @override
  Future<List<AttendanceRecord>> getAttendanceRecords(String sessionId) =>
      (_db.select(_db.attendanceRecords)..where((t) => t.sessionId.equals(sessionId))).get();

  @override
  Future<List<AttendanceRecord>> getAttendanceRecordsForStudent(String studentId) =>
      (_db.select(_db.attendanceRecords)..where((t) => t.studentId.equals(studentId))).get();

  @override
  Future<void> updateAttendanceRecords(List<AttendanceRecord> records) {
    return _db.transaction(() async {
      for (final record in records) {
        // (sessionId, studentId) is unique, so an existing mark is replaced
        // regardless of the incoming record's id.
        await _db.into(_db.attendanceRecords).insert(
              record.toInsertable(),
              onConflict: DoUpdate(
                (_) => AttendanceRecordsCompanion(status: Value(record.status)),
                target: [_db.attendanceRecords.sessionId, _db.attendanceRecords.studentId],
              ),
            );
      }
    });
  }
}
