import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/auth_repository.dart';
import '../repositories/academic_repository.dart';
import '../repositories/attendance_repository.dart';
import '../repositories/academic_history_repository.dart';
import '../database/app_database.dart';
import 'drift_auth_service.dart';
import 'drift_academic_service.dart';
import 'drift_attendance_service.dart';
import 'drift_academic_history_service.dart';
import 'drift_prediction_service.dart';
import 'drift_intervention_service.dart';
import '../repositories/intervention_repository.dart';
import '../repositories/prediction_repository.dart';

/// Single database instance for the app. Override in tests with
/// `AppDatabase(NativeDatabase.memory())`.
final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return DriftAuthService(ref.watch(appDatabaseProvider));
});

final academicRepositoryProvider = Provider<AcademicRepository>((ref) {
  return DriftAcademicService(ref.watch(appDatabaseProvider));
});

final attendanceRepositoryProvider = Provider<AttendanceRepository>((ref) {
  return DriftAttendanceService(ref.watch(appDatabaseProvider));
});

final academicHistoryRepositoryProvider = Provider<AcademicHistoryRepository>((ref) {
  return DriftAcademicHistoryService(ref.watch(appDatabaseProvider));
});

final predictionRepositoryProvider = Provider<PredictionRepository>((ref) {
  return DriftPredictionService(ref.watch(appDatabaseProvider));
});

final interventionRepositoryProvider = Provider<InterventionRepository>((ref) {
  return DriftInterventionService(ref.watch(appDatabaseProvider));
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
