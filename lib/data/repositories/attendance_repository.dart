import '../models/models.dart';

abstract class AttendanceRepository {
  // Session
  Future<List<AttendanceSession>> getSessions();
  Future<List<AttendanceSession>> getSessionsByFaculty(String facultyId);
  Future<List<AttendanceSession>> getSessionsBySection(String sectionId);
  Future<void> addSession(AttendanceSession session, List<AttendanceRecord> records);
  Future<void> updateSession(AttendanceSession session);
  Future<void> deleteSession(String id);

  // Attendance Records
  Future<List<AttendanceRecord>> getAllAttendanceRecords();
  Future<List<AttendanceRecord>> getAttendanceRecords(String sessionId);
  Future<List<AttendanceRecord>> getAttendanceRecordsForStudent(String studentId);
  Future<void> updateAttendanceRecords(List<AttendanceRecord> records);
}
