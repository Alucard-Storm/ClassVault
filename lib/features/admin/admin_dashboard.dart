import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../auth/auth_provider.dart';
import '../../data/models/models.dart';
import '../../data/services/providers.dart';
import '../../core/widgets/responsive_scaffold.dart';

class AdminDashboard extends ConsumerWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final user = ref.watch(authStateProvider).valueOrNull;

    final academicRepo = ref.watch(academicRepositoryProvider);
    final attendanceRepo = ref.watch(attendanceRepositoryProvider);

    final mediaQuery = MediaQuery.of(context);
    final isDesktop = mediaQuery.size.width > 960;

    return ResponsiveScaffold(
      title: 'Admin Portal',
      currentPath: '/admin',
      body: FutureBuilder(
        future: Future.wait([
          academicRepo.getStudents(),
          academicRepo.getFaculty(),
          academicRepo.getSubjects(),
          attendanceRepo.getSessions(),
          academicRepo.getSections(),
          academicRepo.getSemesters(),
          academicRepo.getBranches(),
          attendanceRepo.getSessions().then((sessions) async {
            final List<AttendanceRecord> allRecords = [];
            for (final s in sessions) {
              final recs = await attendanceRepo.getAttendanceRecords(s.id);
              allRecords.addAll(recs);
            }
            return allRecords;
          }),
        ]),
        builder: (context, AsyncSnapshot<List<dynamic>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final students = snapshot.data?[0] as List<Student>? ?? [];
          final facultyList = snapshot.data?[1] as List<Faculty>? ?? [];
          final subjects = snapshot.data?[2] as List<Subject>? ?? [];
          final sessions = snapshot.data?[3] as List<AttendanceSession>? ?? [];
          final sections = snapshot.data?[4] as List<Section>? ?? [];
          final semesters = snapshot.data?[5] as List<Semester>? ?? [];
          final branches = snapshot.data?[6] as List<Branch>? ?? [];
          final allRecords = snapshot.data?[7] as List<AttendanceRecord>? ?? [];

          final studentsCount = students.length;
          final facultyCount = facultyList.length;
          final subjectsCount = subjects.length;

          // Calculate defaulters
          int defaultersCount = 0;
          final List<Map<String, dynamic>> dynamicDefaulters = [];
          for (final student in students) {
            final studentSessions = sessions.where((s) => s.sectionId == student.sectionId).toList();
            if (studentSessions.isEmpty) continue;

            final studentRecords = allRecords.where((r) => r.studentId == student.id).toList();
            final presentCount = studentRecords.where((r) => r.status == 'present').length;
            final double pct = (presentCount / studentSessions.length) * 100;

            if (pct < 80.0) {
              defaultersCount++;
              
              final sec = sections.firstWhere((s) => s.id == student.sectionId, orElse: () => Section(id: '', semesterId: '', name: 'Unknown'));
              final sem = semesters.firstWhere((s) => s.id == sec.semesterId, orElse: () => Semester(id: '', branchId: '', semesterNumber: 0));
              final b = branches.firstWhere((br) => br.id == sem.branchId, orElse: () => Branch(id: '', courseId: '', name: 'Unknown'));
              
              dynamicDefaulters.add({
                'name': student.name,
                'roll': student.rollNumber,
                'class': '${b.name} - Sem ${sem.semesterNumber} (${sec.name})',
                'pct': pct,
              });
            }
          }

          // Calculate attendance today / most recent
          double attendanceToday = 87.0; // Default fallback
          String attendanceTodayTrend = '↓ 2.3% yesterday';
          Color attendanceTodayTrendColor = const Color(0xFFEF4444);
          
          if (sessions.isNotEmpty) {
            final mostRecentSession = sessions.reduce((a, b) => a.date.isAfter(b.date) ? a : b);
            final sessionRecords = allRecords.where((r) => r.sessionId == mostRecentSession.id).toList();
            if (sessionRecords.isNotEmpty) {
              final presentCount = sessionRecords.where((r) => r.status == 'present').length;
              attendanceToday = (presentCount / sessionRecords.length) * 100;
              final otherSessions = sessions.where((s) => s.id != mostRecentSession.id).toList();
              if (otherSessions.isNotEmpty) {
                final prevSession = otherSessions.reduce((a, b) => a.date.isAfter(b.date) ? a : b);
                final prevRecords = allRecords.where((r) => r.sessionId == prevSession.id).toList();
                if (prevRecords.isNotEmpty) {
                  final prevPresent = prevRecords.where((r) => r.status == 'present').length;
                  final prevPct = (prevPresent / prevRecords.length) * 100;
                  final diff = attendanceToday - prevPct;
                  if (diff >= 0) {
                    attendanceTodayTrend = '↑ ${diff.toStringAsFixed(1)}% yesterday';
                    attendanceTodayTrendColor = const Color(0xFF10B981);
                  } else {
                    attendanceTodayTrend = '↓ ${diff.abs().toStringAsFixed(1)}% yesterday';
                    attendanceTodayTrendColor = const Color(0xFFEF4444);
                  }
                }
              }
            }
          }

          // Sort sessions descending by date
          final recentSessions = List<AttendanceSession>.from(sessions);
          recentSessions.sort((a, b) => b.date.compareTo(a.date));

          if (isDesktop) {
            // Desktop Layout
            return SingleChildScrollView(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Welcome Banner
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Control Panel Dashboard',
                            style: theme.textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Real-time overview of college attendance analytics and records.',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurface.withOpacity(0.6),
                            ),
                          ),
                        ],
                      ),
                      Text(
                        DateFormat('EEEE, MMMM dd, yyyy').format(DateTime.now()),
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),

                  // Metrics Cards Row
                  Row(
                    children: [
                      Expanded(
                        child: _buildMetricCard(
                          context,
                          title: 'Total Students',
                          value: NumberFormat('#,###').format(studentsCount),
                          icon: Icons.group_outlined,
                          color: const Color(0xFF4C5DF4),
                          trendText: '↑ 8.5% this month',
                          trendColor: const Color(0xFF10B981),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildMetricCard(
                          context,
                          title: 'Total Faculty',
                          value: '$facultyCount',
                          icon: Icons.badge_outlined,
                          color: const Color(0xFF0D9488),
                          trendText: '↑ 3.1% this month',
                          trendColor: const Color(0xFF10B981),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildMetricCard(
                          context,
                          title: 'Total Subjects',
                          value: '$subjectsCount',
                          icon: Icons.auto_stories_outlined,
                          color: const Color(0xFF3B82F6),
                          trendText: '↑ 2.4% this month',
                          trendColor: const Color(0xFF10B981),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildMetricCard(
                          context,
                          title: 'Attendance Today',
                          value: '${attendanceToday.toStringAsFixed(0)}%',
                          icon: Icons.calendar_today_outlined,
                          color: const Color(0xFFF59E0B),
                          trendText: attendanceTodayTrend,
                          trendColor: attendanceTodayTrendColor,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildMetricCard(
                          context,
                          title: 'Defaulters',
                          value: '$defaultersCount', 
                          icon: Icons.gpp_bad_outlined,
                          color: const Color(0xFFEF4444),
                          trendText: defaultersCount > 0 ? 'Action required' : 'All clear',
                          trendColor: defaultersCount > 0 ? const Color(0xFFEF4444) : const Color(0xFF10B981),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),

                  // Main Two-Column Analytics Layout
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Left Column: Chart & Recent Activity
                      Expanded(
                        flex: 3,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _buildAttendanceChart(theme, sessions, allRecords),
                            const SizedBox(height: 24),
                            _buildRecentSessionsCard(theme, recentSessions, subjects, sections, semesters, branches),
                          ],
                        ),
                      ),
                      const SizedBox(width: 24),

                      // Right Column: Defaulters & Faculty Load
                      Expanded(
                        flex: 2,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _buildDefaulterWatchlistCard(theme, dynamicDefaulters),
                            const SizedBox(height: 24),
                            _buildFacultyLoadCard(theme, facultyList, sessions),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          } else {
            // Mobile Layout (original layout with metrics and launcher grid)
            return SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome, ${user?.name ?? "Administrator"}',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Manage academic settings, student lists, faculty, and view analytics.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                  const SizedBox(height: 24),

                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.5,
                    children: [
                      _buildMetricCard(
                        context,
                        title: 'Students',
                        value: '$studentsCount',
                        icon: Icons.people_rounded,
                        color: const Color(0xFF4C5DF4),
                      ),
                      _buildMetricCard(
                        context,
                        title: 'Faculty',
                        value: '$facultyCount',
                        icon: Icons.school_rounded,
                        color: const Color(0xFF0D9488),
                      ),
                      _buildMetricCard(
                        context,
                        title: 'Subjects',
                        value: '$subjectsCount',
                        icon: Icons.book_rounded,
                        color: const Color(0xFF3B82F6),
                      ),
                      _buildMetricCard(
                        context,
                        title: 'Attendance Today',
                        value: '${attendanceToday.toStringAsFixed(0)}%',
                        icon: Icons.calendar_today_outlined,
                        color: const Color(0xFFF59E0B),
                      ),
                      _buildMetricCard(
                        context,
                        title: 'Defaulters',
                        value: '$defaultersCount',
                        icon: Icons.warning_amber_rounded,
                        color: const Color(0xFFEF4444),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),

                  Text(
                    'Administrative Modules',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),

                  GridView.count(
                    crossAxisCount: 1,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 2.2,
                    children: [
                      _buildMenuCard(
                        context,
                        title: 'Academic Setup',
                        description: 'Manage Courses, Branches, Semesters, and Sections.',
                        icon: Icons.account_tree_rounded,
                        route: '/admin/academic',
                      ),
                      _buildMenuCard(
                        context,
                        title: 'Subjects Management',
                        description: 'View, add, edit, and map subjects to classes.',
                        icon: Icons.library_books_rounded,
                        route: '/admin/subjects',
                      ),
                      _buildMenuCard(
                        context,
                        title: 'Faculty & Assignments',
                        description: 'Manage teachers and map them to class subjects.',
                        icon: Icons.badge_rounded,
                        route: '/admin/faculty',
                      ),
                      _buildMenuCard(
                        context,
                        title: 'Student Directory',
                        description: 'CRUD student profiles and batch import CSV lists.',
                        icon: Icons.face_rounded,
                        route: '/admin/students',
                      ),
                      _buildMenuCard(
                        context,
                        title: 'Semester Promotion',
                        description: 'Promote student batches to the next semester.',
                        icon: Icons.upgrade_rounded,
                        route: '/admin/promotion',
                      ),
                      _buildMenuCard(
                        context,
                        title: 'Analytics & Reports',
                        description: 'View defaulters, subject reports, and export logs.',
                        icon: Icons.analytics_rounded,
                        route: '/reports',
                      ),
                    ],
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }

  Widget _buildAttendanceChart(ThemeData theme, List<AttendanceSession> sessions, List<AttendanceRecord> allRecords) {
    // Group sessions by date and calculate average attendance for the last 5 distinct dates
    final Map<DateTime, List<double>> dailyPercentages = {};
    for (final s in sessions) {
      final date = DateTime(s.date.year, s.date.month, s.date.day);
      final sessionRecords = allRecords.where((r) => r.sessionId == s.id).toList();
      if (sessionRecords.isEmpty) continue;
      
      final presentCount = sessionRecords.where((r) => r.status == 'present').length;
      final pct = (presentCount / sessionRecords.length) * 100;
      
      dailyPercentages.putIfAbsent(date, () => []).add(pct);
    }
    
    final sortedDates = dailyPercentages.keys.toList()..sort();
    final last5Dates = sortedDates.length > 5 ? sortedDates.sublist(sortedDates.length - 5) : sortedDates;
    
    final List<String> days = [];
    final List<double> percentages = [];
    
    for (final date in last5Dates) {
      final pcts = dailyPercentages[date]!;
      final avgPct = pcts.reduce((a, b) => a + b) / pcts.length;
      days.add(DateFormat('E').format(date));
      percentages.add(avgPct);
    }
    
    while (days.length < 5) {
      final dummyDays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri'];
      final dummyPct = [88.0, 92.0, 84.0, 79.0, 94.0];
      final idx = days.length;
      days.add(dummyDays[idx]);
      percentages.add(dummyPct[idx]);
    }

    final double avgPercentage = percentages.isNotEmpty
        ? percentages.reduce((a, b) => a + b) / percentages.length
        : 87.4;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Weekly Attendance Analytics',
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Average: ${avgPercentage.toStringAsFixed(1)}%',
                    style: TextStyle(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            SizedBox(
              height: 200,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: List.generate(days.length, (idx) {
                  final day = days[idx];
                  final pct = percentages[idx];
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        '${pct.toStringAsFixed(0)}%',
                        style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: theme.colorScheme.primary),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        width: 38,
                        height: 140 * (pct / 100),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(8),
                            topRight: Radius.circular(8),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        day,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                    ],
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentSessionsCard(
    ThemeData theme,
    List<AttendanceSession> sessions,
    List<Subject> subjects,
    List<Section> sections,
    List<Semester> semesters,
    List<Branch> branches,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Recent Lecture Sessions Conducted',
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            if (sessions.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 24.0),
                child: Center(child: Text('No attendance sessions conducted yet.')),
              )
            else
              Table(
                columnWidths: const {
                  0: FlexColumnWidth(2),
                  1: FlexColumnWidth(2),
                  2: FlexColumnWidth(1.5),
                  3: FlexColumnWidth(1.5),
                  4: FixedColumnWidth(100),
                },
                children: [
                  TableRow(
                    decoration: BoxDecoration(
                      border: Border(bottom: BorderSide(color: theme.dividerColor, width: 1.5)),
                    ),
                    children: const [
                      Padding(padding: EdgeInsets.symmetric(vertical: 10), child: Text('Class Section', style: TextStyle(fontWeight: FontWeight.bold))),
                      Padding(padding: EdgeInsets.symmetric(vertical: 10), child: Text('Subject', style: TextStyle(fontWeight: FontWeight.bold))),
                      Padding(padding: EdgeInsets.symmetric(vertical: 10), child: Text('Date', style: TextStyle(fontWeight: FontWeight.bold))),
                      Padding(padding: EdgeInsets.symmetric(vertical: 10), child: Text('Time Slot', style: TextStyle(fontWeight: FontWeight.bold))),
                      Padding(padding: EdgeInsets.symmetric(vertical: 10), child: Text('Status', style: TextStyle(fontWeight: FontWeight.bold))),
                    ],
                  ),
                  ...sessions.take(5).map((s) {
                    final sub = subjects.firstWhere((sb) => sb.id == s.subjectId, orElse: () => Subject(id: '', code: 'UNK', name: 'Unknown'));
                    final sec = sections.firstWhere((sc) => sc.id == s.sectionId, orElse: () => Section(id: '', semesterId: '', name: 'Unknown'));
                    final sem = semesters.firstWhere((se) => se.id == sec.semesterId, orElse: () => Semester(id: '', branchId: '', semesterNumber: 0));
                    final b = branches.firstWhere((br) => br.id == sem.branchId, orElse: () => Branch(id: '', courseId: '', name: 'Unknown'));

                    final formattedDate = DateFormat('MMM dd, yyyy').format(s.date);

                    return TableRow(
                      decoration: BoxDecoration(
                        border: Border(bottom: BorderSide(color: theme.dividerColor.withOpacity(0.4))),
                      ),
                      children: [
                        Padding(padding: const EdgeInsets.symmetric(vertical: 12), child: Text('${b.name} - Sem ${sem.semesterNumber} (${sec.name})')),
                        Padding(padding: const EdgeInsets.symmetric(vertical: 12), child: Text(sub.name)),
                        Padding(padding: const EdgeInsets.symmetric(vertical: 12), child: Text(formattedDate)),
                        Padding(padding: const EdgeInsets.symmetric(vertical: 12), child: Text('${s.startTime}')),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: Container(
                            alignment: Alignment.center,
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.green.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'Submitted',
                              style: TextStyle(color: Colors.green, fontSize: 10, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ],
                    );
                  }),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDefaulterWatchlistCard(
    ThemeData theme,
    List<Map<String, dynamic>> defaulters,
  ) {
    if (defaulters.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.check_circle_outline_rounded, color: Color(0xFF10B981), size: 48),
              const SizedBox(height: 12),
              Text(
                'All Students On Track',
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                'Every student attendance is above 80% threshold.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.5),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.warning_amber_rounded, color: theme.colorScheme.error, size: 22),
                const SizedBox(width: 8),
                Text(
                  'Defaulter Watchlist (<80%)',
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: defaulters.length,
              separatorBuilder: (context, idx) => Divider(color: theme.dividerColor.withOpacity(0.4)),
              itemBuilder: (context, idx) {
                final d = defaulters[idx];
                final pct = d['pct'] as double;
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(d['name'] as String, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('Roll: ${d['roll']} | ${d['class']}'),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.error.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${pct.toStringAsFixed(1)}%',
                      style: TextStyle(
                        color: theme.colorScheme.error,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFacultyLoadCard(ThemeData theme, List<Faculty> faculty, List<AttendanceSession> sessions) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Faculty Deliveries',
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: faculty.length > 3 ? 3 : faculty.length,
              separatorBuilder: (context, idx) => Divider(color: theme.dividerColor.withOpacity(0.4)),
              itemBuilder: (context, idx) {
                final f = faculty[idx];
                final count = sessions.where((s) => s.facultyId == f.id).length;

                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: CircleAvatar(
                    backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
                    child: Text(f.name[0].toUpperCase(), style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.bold)),
                  ),
                  title: Text(f.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  subtitle: Text('ID: ${f.employeeId}'),
                  trailing: Text(
                    '$count Lectures',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricCard(
    BuildContext context, {
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    String? trendText,
    Color? trendColor,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
      ),
      color: isDark ? const Color(0xFF1E293B) : Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: isDark ? Colors.white70 : const Color(0xFF64748B),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : const Color(0xFF0F172A),
                    ),
                  ),
                  if (trendText != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      trendText,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: trendColor ?? (isDark ? Colors.white60 : const Color(0xFF64748B)),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuCard(
    BuildContext context, {
    required String title,
    required String description,
    required IconData icon,
    required String route,
  }) {
    final theme = Theme.of(context);
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => context.go(route),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: theme.colorScheme.primary, size: 28),
              ),
              const Spacer(),
              Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
