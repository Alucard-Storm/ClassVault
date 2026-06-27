import '../models/models.dart';
import '../repositories/attendance_repository.dart';

class LocalAttendanceService implements AttendanceRepository {
  // In-Memory Attendance Database Lists
  final List<AttendanceSession> _sessions = [
    AttendanceSession(
      id: 'sess_1',
      facultyId: 'fac_1',
      subjectId: 'sub_dbms',
      sectionId: 'sec_cse_6_a',
      date: DateTime.now().subtract(const Duration(days: 3)),
      startTime: '10:00 AM',
      endTime: '11:00 AM',
    ),
    AttendanceSession(
      id: 'sess_2',
      facultyId: 'fac_1',
      subjectId: 'sub_dbms',
      sectionId: 'sec_cse_6_a',
      date: DateTime.now().subtract(const Duration(days: 2)),
      startTime: '10:00 AM',
      endTime: '11:00 AM',
    ),
    AttendanceSession(
      id: 'sess_3',
      facultyId: 'fac_1',
      subjectId: 'sub_ai',
      sectionId: 'sec_cse_6_a',
      date: DateTime.now().subtract(const Duration(days: 1)),
      startTime: '11:00 AM',
      endTime: '12:00 PM',
    ),
  ];

  final List<AttendanceRecord> _records = [
    // Session 1 records
    AttendanceRecord(id: 'r_1_1', sessionId: 'sess_1', studentId: 'stud_1', status: 'present'),
    AttendanceRecord(id: 'r_1_2', sessionId: 'sess_1', studentId: 'stud_2', status: 'present'),
    AttendanceRecord(id: 'r_1_3', sessionId: 'sess_1', studentId: 'stud_3', status: 'absent'),
    AttendanceRecord(id: 'r_1_4', sessionId: 'sess_1', studentId: 'stud_4', status: 'present'),

    // Session 2 records
    AttendanceRecord(id: 'r_2_1', sessionId: 'sess_2', studentId: 'stud_1', status: 'present'),
    AttendanceRecord(id: 'r_2_2', sessionId: 'sess_2', studentId: 'stud_2', status: 'present'),
    AttendanceRecord(id: 'r_2_3', sessionId: 'sess_2', studentId: 'stud_3', status: 'present'),
    AttendanceRecord(id: 'r_2_4', sessionId: 'sess_2', studentId: 'stud_4', status: 'present'),

    // Session 3 records
    AttendanceRecord(id: 'r_3_1', sessionId: 'sess_3', studentId: 'stud_1', status: 'present'),
    AttendanceRecord(id: 'r_3_2', sessionId: 'sess_3', studentId: 'stud_2', status: 'absent'),
    AttendanceRecord(id: 'r_3_3', sessionId: 'sess_3', studentId: 'stud_3', status: 'absent'),
    AttendanceRecord(id: 'r_3_4', sessionId: 'sess_3', studentId: 'stud_4', status: 'present'),
  ];

  @override
  Future<List<AttendanceSession>> getSessions() async => List.from(_sessions);

  @override
  Future<List<AttendanceSession>> getSessionsByFaculty(String facultyId) async {
    return _sessions.where((s) => s.facultyId == facultyId).toList();
  }

  @override
  Future<List<AttendanceSession>> getSessionsBySection(String sectionId) async {
    return _sessions.where((s) => s.sectionId == sectionId).toList();
  }

  @override
  Future<void> addSession(AttendanceSession session, List<AttendanceRecord> records) async {
    _sessions.add(session);
    _records.addAll(records);
  }

  @override
  Future<void> updateSession(AttendanceSession session) async {
    final idx = _sessions.indexWhere((s) => s.id == session.id);
    if (idx != -1) _sessions[idx] = session;
  }

  @override
  Future<void> deleteSession(String id) async {
    _sessions.removeWhere((s) => s.id == id);
    _records.removeWhere((r) => r.sessionId == id);
  }

  @override
  Future<List<AttendanceRecord>> getAllAttendanceRecords() async => List.from(_records);

  @override
  Future<List<AttendanceRecord>> getAttendanceRecords(String sessionId) async {
    return _records.where((r) => r.sessionId == sessionId).toList();
  }

  @override
  Future<List<AttendanceRecord>> getAttendanceRecordsForStudent(String studentId) async {
    return _records.where((r) => r.studentId == studentId).toList();
  }

  @override
  Future<void> updateAttendanceRecords(List<AttendanceRecord> records) async {
    for (final record in records) {
      final idx = _records.indexWhere((r) => r.id == record.id || (r.sessionId == record.sessionId && r.studentId == record.studentId));
      if (idx != -1) {
        _records[idx] = record;
      } else {
        _records.add(record);
      }
    }
  }
}
