import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../data/models/models.dart';
import '../../features/auth/auth_provider.dart';
import '../../features/auth/login_screen.dart';
import '../../features/admin/admin_dashboard.dart';
import '../../features/admin/academic_setup_screen.dart';
import '../../features/admin/subjects_screen.dart';
import '../../features/admin/faculty_screen.dart';
import '../../features/admin/faculty_assignment_screen.dart';
import '../../features/admin/students_screen.dart';
import '../../features/admin/student_import_screen.dart';
import '../../features/admin/semester_promotion_screen.dart';
import '../../features/faculty/faculty_dashboard.dart';
import '../../features/faculty/mark_attendance_screen.dart';
import '../../features/faculty/edit_attendance_screen.dart';
import '../../features/student/student_dashboard.dart';
import '../../features/reports/reports_dashboard.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: '/login',
    redirect: (context, state) {
      final userValue = authState.valueOrNull;
      final loggingIn = state.uri.path == '/login';

      if (authState.isLoading) return null;

      if (userValue == null) {
        return loggingIn ? null : '/login';
      }

      if (loggingIn) {
        switch (userValue.role) {
          case UserRole.admin:
            return '/admin';
          case UserRole.faculty:
            return '/faculty';
          case UserRole.student:
            return '/student';
        }
      }

      // Role check
      final path = state.uri.path;
      if (path.startsWith('/admin') && userValue.role != UserRole.admin) {
        return '/login';
      }
      if (path.startsWith('/faculty') && userValue.role != UserRole.faculty) {
        return '/login';
      }
      if (path.startsWith('/student') && userValue.role != UserRole.student) {
        return '/login';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      // Admin Routes
      GoRoute(
        path: '/admin',
        builder: (context, state) => const AdminDashboard(),
        routes: [
          GoRoute(
            path: 'academic',
            builder: (context, state) => const AcademicSetupScreen(),
          ),
          GoRoute(
            path: 'subjects',
            builder: (context, state) => const SubjectsScreen(),
          ),
          GoRoute(
            path: 'faculty',
            builder: (context, state) => const FacultyScreen(),
          ),
          GoRoute(
            path: 'faculty-assignment',
            builder: (context, state) => const FacultyAssignmentScreen(),
          ),
          GoRoute(
            path: 'students',
            builder: (context, state) => const StudentsScreen(),
            routes: [
              GoRoute(
                path: 'import',
                builder: (context, state) => const StudentImportScreen(),
              ),
            ],
          ),
          GoRoute(
            path: 'promotion',
            builder: (context, state) => const SemesterPromotionScreen(),
          ),
        ],
      ),
      // Faculty Routes
      GoRoute(
        path: '/faculty',
        builder: (context, state) => const FacultyDashboard(),
        routes: [
          GoRoute(
            path: 'mark-attendance',
            builder: (context, state) => const MarkAttendanceScreen(),
          ),
          GoRoute(
            path: 'edit-attendance',
            builder: (context, state) => const EditAttendanceScreen(),
          ),
        ],
      ),
      // Student Routes
      GoRoute(
        path: '/student',
        builder: (context, state) => const StudentDashboard(),
      ),
      // Reports Route
      GoRoute(
        path: '/reports',
        builder: (context, state) => const ReportsDashboard(),
      ),
    ],
  );
});
