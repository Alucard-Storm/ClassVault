import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../auth/auth_provider.dart';
import '../../data/models/models.dart';
import '../../data/services/providers.dart';
import '../../core/widgets/responsive_scaffold.dart';

class StudentDashboard extends ConsumerWidget {
  const StudentDashboard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final user = ref.watch(authStateProvider).valueOrNull;
    final studentId = user?.associatedId ?? 'stud_1';

    final academicRepo = ref.watch(academicRepositoryProvider);
    final attendanceRepo = ref.watch(attendanceRepositoryProvider);

    return ResponsiveScaffold(
      title: 'Student Portal',
      currentPath: '/student',
      body: FutureBuilder(
        future: Future.wait([
          academicRepo.getStudents(),
          academicRepo.getSections(),
          academicRepo.getSemesters(),
          academicRepo.getBranches(),
          academicRepo.getSubjects(),
          attendanceRepo.getSessions(),
          attendanceRepo.getAttendanceRecordsForStudent(studentId),
        ]),
        builder: (context, AsyncSnapshot<List<dynamic>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final students = snapshot.data?[0] as List<Student>? ?? [];
          final sections = snapshot.data?[1] as List<Section>? ?? [];
          final semesters = snapshot.data?[2] as List<Semester>? ?? [];
          final branches = snapshot.data?[3] as List<Branch>? ?? [];
          final subjects = snapshot.data?[4] as List<Subject>? ?? [];
          final allSessions = snapshot.data?[5] as List<AttendanceSession>? ?? [];
          final myRecords = snapshot.data?[6] as List<AttendanceRecord>? ?? [];

          // Find student profile details
          final student = students.firstWhere((s) => s.id == studentId, orElse: () => Student(id: '', rollNumber: '', name: 'Unknown Student', sectionId: ''));
          if (student.id.isEmpty) {
            return const Center(child: Text('Error: Student profile not found.'));
          }

          final sec = sections.firstWhere((s) => s.id == student.sectionId, orElse: () => Section(id: '', semesterId: '', name: 'Unknown Section'));
          final sem = semesters.firstWhere((s) => s.id == sec.semesterId, orElse: () => Semester(id: '', branchId: '', semesterNumber: 0));
          final b = branches.firstWhere((br) => br.id == sem.branchId, orElse: () => Branch(id: '', courseId: '', name: 'Unknown'));

          // Filter sessions conducted for student's section
          final classSessions = allSessions.where((s) => s.sectionId == student.sectionId).toList();

          // Calculate overall statistics
          final totalConducted = classSessions.length;
          final totalAttended = myRecords.where((r) => r.status == 'present').length;
          final double overallPercentage = totalConducted > 0 ? (totalAttended / totalConducted) * 100 : 0.0;

          // Subject-wise stats calculation
          final Map<String, Map<String, int>> subjectStats = {}; // subjectId -> { 'conducted': 0, 'attended': 0 }

          // Initialize subject stats for subjects mapped to class
          for (final sess in classSessions) {
            subjectStats.putIfAbsent(sess.subjectId, () => {'conducted': 0, 'attended': 0});
            subjectStats[sess.subjectId]!['conducted'] = subjectStats[sess.subjectId]!['conducted']! + 1;

            final record = myRecords.firstWhere((r) => r.sessionId == sess.id, orElse: () => AttendanceRecord(id: '', sessionId: '', studentId: '', status: 'absent'));
            if (record.status == 'present') {
              subjectStats[sess.subjectId]!['attended'] = subjectStats[sess.subjectId]!['attended']! + 1;
            }
          }

          // Sort recent activities
          classSessions.sort((a, b) => b.date.compareTo(a.date));

          final isDesktop = MediaQuery.of(context).size.width > 960;

          if (isDesktop) {
            return _buildDesktopLayout(context, theme, student, b, sem, sec, totalAttended, totalConducted, overallPercentage, subjectStats, subjects, classSessions, myRecords);
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Welcome header
                Text(
                  'Welcome, ${student.name}',
                  style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                Text(
                  'Class: ${b.name} - Sem ${sem.semesterNumber} (${sec.name}) | Roll No: ${student.rollNumber}',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
                const SizedBox(height: 24),

                // Overall Attendance Circular Progress Indicator
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Row(
                      children: [
                        SizedBox(
                          height: 90,
                          width: 90,
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              CircularProgressIndicator(
                                value: overallPercentage / 100,
                                strokeWidth: 10,
                                backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  overallPercentage >= 75 ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                                ),
                              ),
                              Center(
                                child: Text(
                                  '${overallPercentage.toStringAsFixed(1)}%',
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 24),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Overall Attendance',
                                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Attended $totalAttended out of $totalConducted total sessions conducted.',
                                style: TextStyle(
                                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                                  fontSize: 13,
                                ),
                              ),
                              const SizedBox(height: 8),
                              if (overallPercentage < 75)
                                Row(
                                  children: [
                                    Icon(Icons.warning_amber_rounded, size: 16, color: theme.colorScheme.error),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Low Attendance! Minimum 75% required.',
                                      style: TextStyle(color: theme.colorScheme.error, fontSize: 11, fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                )
                              else
                                const Row(
                                  children: [
                                    Icon(Icons.check_circle_outline_rounded, size: 16, color: Color(0xFF10B981)),
                                    SizedBox(width: 4),
                                    Text(
                                      'On Track! Attendance is good.',
                                      style: TextStyle(color: Color(0xFF10B981), fontSize: 11, fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 28),

                // Subject-wise breakdown
                Text(
                  'Subject-wise Breakdown',
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),

                if (subjectStats.isEmpty)
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Center(
                        child: Text(
                          'No lectures conducted for your class yet.',
                          style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.5)),
                        ),
                      ),
                    ),
                  )
                else
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: subjectStats.length,
                    itemBuilder: (context, idx) {
                      final subId = subjectStats.keys.elementAt(idx);
                      final stats = subjectStats[subId]!;
                      final sub = subjects.firstWhere((s) => s.id == subId, orElse: () => Subject(id: '', code: 'UNK', name: 'Unknown'));
                      final double pct = stats['conducted']! > 0 ? (stats['attended']! / stats['conducted']!) * 100 : 0.0;

                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    sub.name,
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                  ),
                                  Text(
                                    '${pct.toStringAsFixed(0)}%',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: pct >= 75 ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              LinearProgressIndicator(
                                value: pct / 100,
                                minHeight: 6,
                                backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  pct >= 75 ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Attended ${stats['attended']} / ${stats['conducted']} classes',
                                style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.5), fontSize: 11),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                const SizedBox(height: 28),

                // Recent Activities
                Text(
                  'Recent Activity History',
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),

                if (classSessions.isEmpty)
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Center(
                        child: Text(
                          'No recent attendance markings.',
                          style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.5)),
                        ),
                      ),
                    ),
                  )
                else
                  Card(
                    child: ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: classSessions.length > 5 ? 5 : classSessions.length, // Show last 5
                      separatorBuilder: (context, index) => const Divider(height: 1),
                      itemBuilder: (context, idx) {
                        final sess = classSessions[idx];
                        final sub = subjects.firstWhere((s) => s.id == sess.subjectId, orElse: () => Subject(id: '', code: 'UNK', name: 'Unknown'));
                        final rec = myRecords.firstWhere((r) => r.sessionId == sess.id, orElse: () => AttendanceRecord(id: '', sessionId: '', studentId: '', status: 'absent'));
                        final isPresent = rec.status == 'present';

                        final dateStr = DateFormat('MMM dd, yyyy').format(sess.date);

                        return ListTile(
                          title: Text(sub.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text('$dateStr | ${sess.startTime}'),
                          trailing: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: isPresent ? const Color(0xFF10B981).withOpacity(0.1) : const Color(0xFFEF4444).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              isPresent ? 'PRESENT' : 'ABSENT',
                              style: TextStyle(
                                color: isPresent ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildDesktopLayout(
    BuildContext context,
    ThemeData theme,
    Student student,
    Branch b,
    Semester sem,
    Section sec,
    int totalAttended,
    int totalConducted,
    double overallPercentage,
    Map<String, Map<String, int>> subjectStats,
    List<Subject> subjects,
    List<AttendanceSession> classSessions,
    List<AttendanceRecord> myRecords,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Welcome Header
          Text(
            'Welcome, ${student.name}',
            style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          Text(
            'Class: ${b.name} - Sem ${sem.semesterNumber} (${sec.name}) | Roll No: ${student.rollNumber}',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left Column: Overall stats and Subject-wise progress
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Overall Attendance Circular Progress Indicator
                    Card(
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(color: theme.dividerColor.withOpacity(0.08)),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Row(
                          children: [
                            SizedBox(
                              height: 90,
                              width: 90,
                              child: Stack(
                                fit: StackFit.expand,
                                children: [
                                  CircularProgressIndicator(
                                    value: overallPercentage / 100,
                                    strokeWidth: 10,
                                    backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      overallPercentage >= 75 ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                                    ),
                                  ),
                                  Center(
                                    child: Text(
                                      '${overallPercentage.toStringAsFixed(1)}%',
                                      style: theme.textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 24),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Overall Attendance',
                                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Attended $totalAttended out of $totalConducted total sessions conducted.',
                                    style: TextStyle(
                                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                                      fontSize: 13,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  if (overallPercentage < 75)
                                    Row(
                                      children: [
                                        Icon(Icons.warning_amber_rounded, size: 16, color: theme.colorScheme.error),
                                        const SizedBox(width: 4),
                                        Text(
                                          'Low Attendance! Minimum 75% required.',
                                          style: TextStyle(color: theme.colorScheme.error, fontSize: 11, fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    )
                                  else
                                    const Row(
                                      children: [
                                        Icon(Icons.check_circle_outline_rounded, size: 16, color: Color(0xFF10B981)),
                                        SizedBox(width: 4),
                                        Text(
                                          'On Track! Attendance is good.',
                                          style: TextStyle(color: Color(0xFF10B981), fontSize: 11, fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),
                    // Subject-wise breakdown
                    Text(
                      'Subject-wise Breakdown',
                      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    if (subjectStats.isEmpty)
                      Card(
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(color: theme.dividerColor.withOpacity(0.08)),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Center(
                            child: Text(
                              'No lectures conducted for your class yet.',
                              style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.5)),
                            ),
                          ),
                        ),
                      )
                    else
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: subjectStats.length,
                        itemBuilder: (context, idx) {
                          final subId = subjectStats.keys.elementAt(idx);
                          final stats = subjectStats[subId]!;
                          final sub = subjects.firstWhere((s) => s.id == subId, orElse: () => Subject(id: '', code: 'UNK', name: 'Unknown'));
                          final double pct = stats['conducted']! > 0 ? (stats['attended']! / stats['conducted']!) * 100 : 0.0;

                          return Card(
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: BorderSide(color: theme.dividerColor.withOpacity(0.08)),
                            ),
                            margin: const EdgeInsets.only(bottom: 12),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        sub.name,
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                      ),
                                      Text(
                                        '${pct.toStringAsFixed(0)}%',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: pct >= 75 ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  LinearProgressIndicator(
                                    value: pct / 100,
                                    minHeight: 6,
                                    backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      pct >= 75 ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Attended ${stats['attended']} / ${stats['conducted']} classes',
                                    style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.5), fontSize: 11),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 24),
              // Right Column: Recent Activities History
              Expanded(
                flex: 2,
                child: Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: theme.dividerColor.withOpacity(0.08)),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'Recent Activity History',
                          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 16),
                        if (classSessions.isEmpty)
                          Center(
                            child: Text(
                              'No recent activities.',
                              style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.5)),
                            ),
                          )
                        else
                          ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: classSessions.length > 8 ? 8 : classSessions.length, // Show last 8
                            separatorBuilder: (context, index) => const Divider(height: 1),
                            itemBuilder: (context, idx) {
                              final sess = classSessions[idx];
                              final sub = subjects.firstWhere((s) => s.id == sess.subjectId, orElse: () => Subject(id: '', code: 'UNK', name: 'Unknown'));
                              final rec = myRecords.firstWhere((r) => r.sessionId == sess.id, orElse: () => AttendanceRecord(id: '', sessionId: '', studentId: '', status: 'absent'));
                              final isPresent = rec.status == 'present';

                              final dateStr = DateFormat('MMM dd, yyyy').format(sess.date);

                              return ListTile(
                                contentPadding: EdgeInsets.zero,
                                title: Text(sub.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                subtitle: Text('$dateStr | ${sess.startTime}', style: const TextStyle(fontSize: 11)),
                                trailing: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: isPresent ? const Color(0xFF10B981).withOpacity(0.1) : const Color(0xFFEF4444).withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    isPresent ? 'PRESENT' : 'ABSENT',
                                    style: TextStyle(
                                      color: isPresent ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
