import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/auth_repository.dart';
import '../repositories/academic_repository.dart';
import '../repositories/attendance_repository.dart';
import 'local_auth_service.dart';
import 'local_academic_service.dart';
import 'local_attendance_service.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  // Can easily be swapped to FirebaseAuthService later
  return LocalAuthService();
});

final academicRepositoryProvider = Provider<AcademicRepository>((ref) {
  // Can easily be swapped to FirestoreAcademicService later
  return LocalAcademicService();
});

final attendanceRepositoryProvider = Provider<AttendanceRepository>((ref) {
  // Can easily be swapped to FirestoreAttendanceService later
  return LocalAttendanceService();
});
