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
import '../../features/academic_import/academic_import_screen.dart';
import '../../features/prediction/prediction_models_screen.dart';
import '../../features/faculty/faculty_dashboard.dart';
import '../../features/faculty/mark_attendance_screen.dart';
import '../../features/faculty/edit_attendance_screen.dart';
import '../../features/student/student_dashboard.dart';
import '../../features/reports/reports_dashboard.dart';
import '../../features/analytics/class_analytics_screen.dart';
import '../../features/analytics/student_insights_screen.dart';

/// Route guard: where a request for [path] should go instead, or null to
/// allow it. Pure so the access rules can be tested without rendering.
String? appRedirect({required AppUser? user, required bool isLoading, required String path}) {
  if (isLoading) return null;

  final loggingIn = path == '/login';
  if (user == null) {
    return loggingIn ? null : '/login';
  }

  if (loggingIn) {
    switch (user.role) {
      case UserRole.admin:
        return '/admin';
      case UserRole.faculty:
        return '/faculty';
      case UserRole.student:
        return '/student';
    }
  }

  // Role check
  if (path.startsWith('/admin') && user.role != UserRole.admin) {
    return '/login';
  }
  if (path.startsWith('/faculty') && user.role != UserRole.faculty) {
    return '/login';
  }
  if (path.startsWith('/student') && user.role != UserRole.student) {
    return '/login';
  }
  // Analytics signals are for staff; they are not shown to students.
  if (path.startsWith('/analytics') && user.role == UserRole.student) {
    return '/student';
  }

  return null;
}

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: '/login',
    redirect: (context, state) => appRedirect(
      user: authState.valueOrNull,
      isLoading: authState.isLoading,
      path: state.uri.path,
    ),
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
          GoRoute(
            path: 'academic-import',
            builder: (context, state) => const AcademicImportScreen(),
          ),
          GoRoute(
            path: 'models',
            builder: (context, state) => const PredictionModelsScreen(),
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
      // Academic analytics (admin + faculty)
      GoRoute(
        path: '/analytics',
        builder: (context, state) => const ClassAnalyticsScreen(),
        routes: [
          GoRoute(
            path: 'student/:id',
            builder: (context, state) => StudentInsightsScreen(studentId: state.pathParameters['id']!),
          ),
        ],
      ),
    ],
  );
});
