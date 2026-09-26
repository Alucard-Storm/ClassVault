import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/models.dart';
import '../../data/repositories/academic_history_repository.dart';
import '../../data/repositories/academic_repository.dart';
import '../../data/repositories/attendance_repository.dart';
import '../../data/services/providers.dart';
import 'engine/student_analytics.dart';

final analyticsServiceProvider = Provider<AnalyticsService>((ref) {
  return AnalyticsService(
    academic: ref.watch(academicRepositoryProvider),
    attendance: ref.watch(attendanceRepositoryProvider),
    history: ref.watch(academicHistoryRepositoryProvider),
  );
});

/// A section with a readable label, e.g. "CSE · Sem 5 · Section A".
class SectionOption {
  final Section section;
  final String label;
  final int semesterNumber;
  const SectionOption(this.section, this.label, this.semesterNumber);
}

/// Loads academic history plus in-app attendance and runs the analytics
/// engine. Access is scoped: admins see every section, faculty only the
/// sections they are assigned to, students none.
class AnalyticsService {
  final AcademicRepository academic;
  final AttendanceRepository attendance;
  final AcademicHistoryRepository history;

  AnalyticsService({required this.academic, required this.attendance, required this.history});

  Future<List<SectionOption>> visibleSections(AppUser user) async {
    if (user.role == UserRole.student) return const [];

    final results = await Future.wait([
      academic.getSections(),
      academic.getSemesters(),
      academic.getBranches(),
      academic.getSubjectMappings(),
      academic.getFacultyAssignments(),
    ]);
    var sections = results[0] as List<Section>;
    final semesters = {for (final s in results[1] as List<Semester>) s.id: s};
    final branches = {for (final b in results[2] as List<Branch>) b.id: b};

    if (user.role == UserRole.faculty) {
      final mappings = {for (final m in results[3] as List<SubjectMapping>) m.id: m};
      final assigned = {
        for (final a in results[4] as List<FacultyAssignment>)
          if (a.facultyId == user.associatedId) mappings[a.subjectMappingId]?.sectionId,
      };
      sections = sections.where((s) => assigned.contains(s.id)).toList();
    }

    final options = [
      for (final s in sections)
        () {
          final sem = semesters[s.semesterId];
          final branch = sem == null ? null : branches[sem.branchId];
          return SectionOption(
            s,
            '${branch?.name ?? 'Unknown'} · Sem ${sem?.semesterNumber ?? '?'} · ${s.name}',
            sem?.semesterNumber ?? 0,
          );
        }(),
    ]..sort((a, b) => a.label.compareTo(b.label));
    return options;
  }

  Future<List<StudentAnalytics>> forSection(SectionOption option) async {
    final students = await academic.getStudentsBySection(option.section.id);
    final histories = await history.getHistoriesForStudents([for (final s in students) s.id]);
    final live = await _liveAttendance(option.section.id);

    final analytics = [
      for (final h in histories)
        StudentAnalyticsEngine.compute(
          h,
          sessionAttendance: live(h, option.semesterNumber),
        ),
    ]..sort((a, b) => a.student.rollNumber.compareTo(b.student.rollNumber));
    return analytics;
  }

  /// Analytics for one student, or null if not found or not visible to [user].
  Future<StudentAnalytics?> forStudent(String studentId, AppUser user) async {
    final h = await history.getStudentHistory(studentId);
    if (h == null) return null;

    final sections = await visibleSections(user);
    final option = sections.where((o) => o.section.id == h.student.sectionId).firstOrNull;
    if (option == null) return null;

    final live = await _liveAttendance(option.section.id);
    return StudentAnalyticsEngine.compute(h, sessionAttendance: live(h, option.semesterNumber));
  }

  /// Returns a function computing session-based attendance for a student in
  /// [sectionId], loading the section's sessions and records once.
  Future<List<SubjectAttendance> Function(StudentAcademicHistory, int)> _liveAttendance(
    String sectionId,
  ) async {
    final sessions = await attendance.getSessionsBySection(sectionId);
    final sessionIds = {for (final s in sessions) s.id};
    final records = sessions.isEmpty
        ? const <AttendanceRecord>[]
        : (await attendance.getAllAttendanceRecords()).where((r) => sessionIds.contains(r.sessionId)).toList();
    final subjectNames = {for (final s in await academic.getSubjects()) s.id: s.name};

    return (StudentAcademicHistory h, int sectionSemester) {
      if (sessions.isEmpty) return const <SubjectAttendance>[];
      final current = h.enrollments.where((e) => e.isCurrent).lastOrNull;
      return StudentAnalyticsEngine.attendanceFromSessions(
        studentId: h.student.id,
        semester: current?.semesterNumber ?? sectionSemester,
        sectionSessions: sessions,
        records: records,
        subjectNames: subjectNames,
      );
    };
  }
}
