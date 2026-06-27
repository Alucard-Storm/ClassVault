import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/auth_repository.dart';
import '../repositories/academic_repository.dart';
import '../repositories/attendance_repository.dart';
import 'local_auth_service.dart';
import 'local_academic_service.dart';
import 'local_attendance_service.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return LocalAuthService();
});

final academicRepositoryProvider = Provider<AcademicRepository>((ref) {
  return LocalAcademicService();
});

final attendanceRepositoryProvider = Provider<AttendanceRepository>((ref) {
  return LocalAttendanceService();
});

final themeModeProvider = StateProvider<ThemeMode>((ref) => ThemeMode.light);

final defaulterCountProvider = FutureProvider<int>((ref) async {
  final academicRepo = ref.read(academicRepositoryProvider);
  final attendanceRepo = ref.read(attendanceRepositoryProvider);

  final results = await Future.wait([
    academicRepo.getStudents(),
    attendanceRepo.getSessions(),
    attendanceRepo.getAllAttendanceRecords(),
  ]);

  final students = results[0] as List;
  final sessions = results[1] as List;
  final allRecords = results[2] as List;

  int count = 0;
  for (final student in students) {
    final studentSessions =
        sessions.where((s) => s.sectionId == student.sectionId).toList();
    if (studentSessions.isEmpty) continue;
    final sessionIds = {for (final s in studentSessions) s.id};
    final presentCount = allRecords
        .where((r) =>
            r.studentId == student.id &&
            sessionIds.contains(r.sessionId) &&
            r.status == 'present')
        .length;
    final pct = (presentCount / studentSessions.length) * 100;
    if (pct < 80.0) count++;
  }
  return count;
});
