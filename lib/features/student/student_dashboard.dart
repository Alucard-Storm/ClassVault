import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../auth/auth_provider.dart';
import '../../data/models/models.dart';
import '../../data/services/providers.dart';
import '../../core/widgets/responsive_scaffold.dart';
import '../../core/widgets/skeleton_loaders.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/responsive_two_pane.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_color_scheme.dart';
import '../../core/theme/app_tokens.dart';

class StudentDashboard extends ConsumerStatefulWidget {
  const StudentDashboard({super.key});

  @override
  ConsumerState<StudentDashboard> createState() => _StudentDashboardState();
}

class _StudentDashboardState extends ConsumerState<StudentDashboard> {
  List<Student> _students = [];
  List<Section> _sections = [];
  List<Semester> _semesters = [];
  List<Branch> _branches = [];
  List<Subject> _subjects = [];
  List<AttendanceSession> _allSessions = [];
  List<AttendanceRecord> _myRecords = [];
  List<SubjectMapping> _subjectMappings = [];
  bool _isLoading = true;
  Object? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final user = ref.read(authStateProvider).valueOrNull;
      final studentId = user?.associatedId ?? '';
      final academicRepo = ref.read(academicRepositoryProvider);
      final attendanceRepo = ref.read(attendanceRepositoryProvider);

      final results = await Future.wait([
        academicRepo.getStudents(),
        academicRepo.getSections(),
        academicRepo.getSemesters(),
        academicRepo.getBranches(),
        academicRepo.getSubjects(),
        attendanceRepo.getSessions(),
        attendanceRepo.getAttendanceRecordsForStudent(studentId),
        academicRepo.getSubjectMappings(),
      ]);

      setState(() {
        _students = results[0] as List<Student>;
        _sections = results[1] as List<Section>;
        _semesters = results[2] as List<Semester>;
        _branches = results[3] as List<Branch>;
        _subjects = results[4] as List<Subject>;
        _allSessions = results[5] as List<AttendanceSession>;
        _myRecords = results[6] as List<AttendanceRecord>;
        _subjectMappings = results[7] as List<SubjectMapping>;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final user = ref.watch(authStateProvider).valueOrNull;
    final studentId = user?.associatedId ?? '';

    if (_isLoading) {
      return const ResponsiveScaffold(
        title: 'Student Portal',
        currentPath: '/student',
        body: SkeletonDashboard(),
      );
    }

    if (_error != null) {
      return ResponsiveScaffold(
        title: 'Student Portal',
        currentPath: '/student',
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline_rounded, size: 64, color: theme.colorScheme.error),
              const SizedBox(height: AppSpacing.lg),
              Text('Failed to load your data', style: theme.textTheme.titleMedium),
              const SizedBox(height: AppSpacing.sm),
              ElevatedButton(onPressed: _load, child: const Text('Retry')),
            ],
          ),
        ),
      );
    }

    final student = _students.firstWhere(
      (s) => s.id == studentId,
      orElse: () => Student(id: '', rollNumber: '', name: 'Unknown Student', sectionId: ''),
    );

    if (student.id.isEmpty) {
      return const ResponsiveScaffold(
        title: 'Student Portal',
        currentPath: '/student',
        body: Center(child: Text('Error: Student profile not found.')),
      );
    }

    final sec = _sections.firstWhere((s) => s.id == student.sectionId,
        orElse: () => Section(id: '', semesterId: '', name: 'Unknown'));
    final sem = _semesters.firstWhere((s) => s.id == sec.semesterId,
        orElse: () => Semester(id: '', branchId: '', semesterNumber: 0));
    final b = _branches.firstWhere((br) => br.id == sem.branchId,
        orElse: () => Branch(id: '', courseId: '', name: 'Unknown'));

    final classSessions = _allSessions.where((s) => s.sectionId == student.sectionId).toList();
    final totalConducted = classSessions.length;
    final totalAttended = _myRecords.where((r) => r.status == 'present').length;
    final double overallPercentage =
        totalConducted > 0 ? (totalAttended / totalConducted) * 100 : 0.0;

    // "Can still miss" calculation: how many more can be missed and stay above threshold
    final canMissMore = totalConducted > 0
        ? ((totalAttended - AppConstants.minAttendanceThreshold / 100 * totalConducted) /
                (AppConstants.minAttendanceThreshold / 100))
            .floor()
            .clamp(0, 9999)
        : 0;

    // Trend: compare last 5 sessions vs previous 5
    final sortedSessions = List<AttendanceSession>.from(classSessions)
      ..sort((a, b) => b.date.compareTo(a.date));
    double? trendDelta;
    if (sortedSessions.length >= 6) {
      double recentPct = 0;
      for (var i = 0; i < 5; i++) {
        final r = _myRecords.firstWhere((r) => r.sessionId == sortedSessions[i].id,
            orElse: () => AttendanceRecord(id: '', sessionId: '', studentId: '', status: 'absent'));
        if (r.status == 'present') recentPct++;
      }
      double prevPct = 0;
      for (var i = 5; i < (sortedSessions.length < 10 ? sortedSessions.length : 10); i++) {
        final r = _myRecords.firstWhere((r) => r.sessionId == sortedSessions[i].id,
            orElse: () => AttendanceRecord(id: '', sessionId: '', studentId: '', status: 'absent'));
        if (r.status == 'present') prevPct++;
      }
      final prevCount = (sortedSessions.length < 10 ? sortedSessions.length : 10) - 5;
      if (prevCount > 0) {
        trendDelta = (recentPct / 5 - prevPct / prevCount) * 100;
      }
    }

    final classMappings = _subjectMappings.where((m) => m.sectionId == student.sectionId).toList();
    final Map<String, Map<String, int>> subjectStats = {};
    for (final mapping in classMappings) {
      subjectStats[mapping.subjectId] = {'conducted': 0, 'attended': 0};
    }
    for (final sess in classSessions) {
      subjectStats.putIfAbsent(sess.subjectId, () => {'conducted': 0, 'attended': 0});
      subjectStats[sess.subjectId]!['conducted'] = subjectStats[sess.subjectId]!['conducted']! + 1;
      final record = _myRecords.firstWhere(
        (r) => r.sessionId == sess.id,
        orElse: () => AttendanceRecord(id: '', sessionId: '', studentId: '', status: 'absent'),
      );
      if (record.status == 'present') {
        subjectStats[sess.subjectId]!['attended'] = subjectStats[sess.subjectId]!['attended']! + 1;
      }
    }

    final isDesktop = MediaQuery.of(context).size.width > AppBreakpoints.desktop;

    return ResponsiveScaffold(
      title: 'Student Portal',
      currentPath: '/student',
      body: RefreshIndicator(
        onRefresh: _load,
        child: isDesktop
            ? _buildDesktopLayout(context, student, b, sem, sec, totalAttended, totalConducted,
                overallPercentage, canMissMore, trendDelta, subjectStats, sortedSessions)
            : _buildMobileLayout(context, student, b, sem, sec, totalAttended, totalConducted,
                overallPercentage, canMissMore, trendDelta, subjectStats, sortedSessions),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme, Student student, Branch b, Semester sem, Section sec) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Welcome, ${student.name}',
          style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        Text(
          'Class: ${b.name} - Sem ${sem.semesterNumber} (${sec.name}) | Roll No: ${student.rollNumber}',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    ).animate().fadeIn(duration: AppMotion.entrance);
  }

  Widget _buildMobileLayout(
    BuildContext context,
    Student student,
    Branch b,
    Semester sem,
    Section sec,
    int totalAttended,
    int totalConducted,
    double overallPercentage,
    int canMissMore,
    double? trendDelta,
    Map<String, Map<String, int>> subjectStats,
    List<AttendanceSession> sortedSessions,
  ) {
    final theme = Theme.of(context);
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(theme, student, b, sem, sec),
          const SizedBox(height: AppSpacing.xl),
          _buildOverallCard(theme, totalAttended, totalConducted, overallPercentage, canMissMore,
                  trendDelta)
              .animate()
              .fadeIn(delay: AppMotion.stagger, duration: AppMotion.entrance)
              .slideY(begin: 0.06, curve: Curves.easeOut),
          const SizedBox(height: AppSpacing.xxl - AppSpacing.xs),
          Text('Subject-wise Breakdown',
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: AppSpacing.md),
          if (subjectStats.isEmpty)
            const EmptyState(
              icon: Icons.menu_book_outlined,
              title: 'No lectures yet',
              message: 'No lectures conducted for your class yet.',
            )
          else
            ...subjectStats.entries.toList().asMap().entries.map((e) => _buildSubjectCard(
                    theme, e.value.key, e.value.value, margin: const EdgeInsets.only(bottom: AppSpacing.md))
                .animate()
                .fadeIn(delay: ((e.key + 2) * AppMotion.stagger.inMilliseconds).ms,
                    duration: AppMotion.entrance)
                .slideY(begin: 0.06, curve: Curves.easeOut)),
          const SizedBox(height: AppSpacing.xxl - AppSpacing.xs),
          Text('Recent Activity History',
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: AppSpacing.md),
          _buildRecentActivity(theme, sortedSessions, limit: 5),
        ],
      ),
    );
  }

  Widget _buildDesktopLayout(
    BuildContext context,
    Student student,
    Branch b,
    Semester sem,
    Section sec,
    int totalAttended,
    int totalConducted,
    double overallPercentage,
    int canMissMore,
    double? trendDelta,
    Map<String, Map<String, int>> subjectStats,
    List<AttendanceSession> sortedSessions,
  ) {
    final theme = Theme.of(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(theme, student, b, sem, sec),
          const SizedBox(height: AppSpacing.xl),
          ResponsiveTwoPane.flex(
            left: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildOverallCard(theme, totalAttended, totalConducted, overallPercentage,
                        canMissMore, trendDelta)
                    .animate()
                    .fadeIn(duration: 450.ms)
                    .scale(begin: const Offset(0.96, 0.96), end: const Offset(1, 1)),
                const SizedBox(height: AppSpacing.xxl - AppSpacing.xs),
                Text('Subject-wise Breakdown',
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: AppSpacing.md),
                if (subjectStats.isEmpty)
                  Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.card),
                      side: BorderSide(color: theme.dividerColor.withValues(alpha: 0.15)),
                    ),
                    child: const EmptyState(
                      icon: Icons.menu_book_outlined,
                      title: 'No lectures yet',
                      message: 'No lectures conducted for your class yet.',
                    ),
                  )
                else
                  ...subjectStats.entries.toList().asMap().entries.map((mapEntry) {
                    final idx = mapEntry.key;
                    final entry = mapEntry.value;
                    return _buildSubjectCard(
                      theme,
                      entry.key,
                      entry.value,
                      elevated: true,
                      margin: const EdgeInsets.only(bottom: AppSpacing.md),
                    )
                        .animate()
                        .fadeIn(delay: (200 + idx * 80).ms, duration: 400.ms)
                        .slideY(begin: 0.1, end: 0);
                  }),
              ],
            ),
            right: Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.card),
                side: BorderSide(color: theme.dividerColor.withValues(alpha: 0.15)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.xl - AppSpacing.xs),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text('Recent Activity History',
                        style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: AppSpacing.lg),
                    _buildRecentActivity(theme, sortedSessions, limit: 8, compact: true),
                  ],
                ),
              ),
            ).animate().fadeIn(delay: 350.ms, duration: 500.ms),
          ),
        ],
      ),
    );
  }

  Widget _buildOverallCard(
    ThemeData theme,
    int totalAttended,
    int totalConducted,
    double overallPercentage,
    int canMissMore,
    double? trendDelta,
  ) {
    final isOnTrack = overallPercentage >= AppConstants.minAttendanceThreshold;
    final ringColor = isOnTrack ? theme.appColors.success : theme.appColors.danger;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.card),
        side: BorderSide(color: theme.dividerColor.withValues(alpha: 0.15)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Row(
          children: [
            _buildAttendanceRing(theme, overallPercentage, ringColor),
            const SizedBox(width: AppSpacing.xl),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Overall Attendance',
                      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    'Attended $totalAttended out of $totalConducted sessions.',
                    style: TextStyle(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 6),
                  if (isOnTrack)
                    Row(
                      children: [
                        Icon(Icons.check_circle_outline_rounded,
                            size: 14, color: theme.appColors.success),
                        const SizedBox(width: 4),
                        Text(
                          canMissMore > 0
                              ? 'On Track — can miss $canMissMore more'
                              : 'On Track! Attendance is good.',
                          style: TextStyle(
                              color: theme.appColors.success, fontSize: 11, fontWeight: FontWeight.bold),
                        ),
                      ],
                    )
                  else
                    Row(
                      children: [
                        Icon(Icons.warning_amber_rounded, size: 14, color: theme.appColors.danger),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            'Low Attendance! Min ${AppConstants.minAttendanceThreshold.toInt()}% required.',
                            style: TextStyle(
                                color: theme.appColors.danger,
                                fontSize: 11,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  if (trendDelta != null) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          trendDelta >= 0 ? Icons.trending_up_rounded : Icons.trending_down_rounded,
                          size: 14,
                          color: trendDelta >= 0 ? theme.appColors.success : theme.appColors.danger,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${trendDelta >= 0 ? '+' : ''}${trendDelta.toStringAsFixed(0)}% vs previous 5 classes',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: trendDelta >= 0 ? theme.appColors.success : theme.appColors.danger,
                          ),
                        ),
                      ],
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

  /// A real donut chart (fl_chart) for the overall percentage, replacing a
  /// plain `CircularProgressIndicator` repurposed as a faux ring.
  Widget _buildAttendanceRing(ThemeData theme, double percentage, Color color) {
    final clamped = percentage.clamp(0, 100).toDouble();
    return SizedBox(
      height: 90,
      width: 90,
      child: Stack(
        fit: StackFit.expand,
        children: [
          PieChart(
            PieChartData(
              startDegreeOffset: -90,
              sectionsSpace: 0,
              centerSpaceRadius: 32,
              sections: [
                PieChartSectionData(
                  value: clamped,
                  color: color,
                  showTitle: false,
                  radius: 13,
                ),
                PieChartSectionData(
                  value: 100 - clamped,
                  color: theme.colorScheme.primary.withValues(alpha: 0.1),
                  showTitle: false,
                  radius: 13,
                ),
              ],
            ),
          ),
          Center(
            child: Text(
              '${percentage.toStringAsFixed(1)}%',
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubjectCard(
    ThemeData theme,
    String subjectId,
    Map<String, int> stats, {
    bool elevated = false,
    EdgeInsets? margin,
  }) {
    final sub = _subjects.firstWhere(
      (s) => s.id == subjectId,
      orElse: () => Subject(id: '', code: 'UNK', name: 'Unknown'),
    );
    final double pct =
        stats['conducted']! > 0 ? (stats['attended']! / stats['conducted']!) * 100 : 100.0;
    final isSafe = pct >= AppConstants.minAttendanceThreshold;
    final statusColor = isSafe ? theme.appColors.success : theme.appColors.danger;

    return Card(
      elevation: 0,
      shape: elevated
          ? RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.card),
              side: BorderSide(color: theme.dividerColor.withValues(alpha: 0.15)),
            )
          : null,
      margin: margin,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        sub.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                      Text(
                        '[${sub.code}]',
                        style: TextStyle(
                          fontSize: 11,
                          color: theme.colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.lg),
                Text(
                  '${pct.toStringAsFixed(0)}%',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: statusColor),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            LinearProgressIndicator(
              value: pct / 100,
              minHeight: 8,
              borderRadius: BorderRadius.circular(4),
              backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.1),
              valueColor: AlwaysStoppedAnimation<Color>(statusColor),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Attended ${stats['attended']} / ${stats['conducted']} classes',
              style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentActivity(
    ThemeData theme,
    List<AttendanceSession> sessions, {
    int limit = 5,
    bool compact = false,
  }) {
    if (sessions.isEmpty) {
      return const EmptyState(
        icon: Icons.event_note_outlined,
        title: 'No activity yet',
        message: 'No recent attendance markings.',
      );
    }

    final items = sessions.take(limit).toList();
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      separatorBuilder: (_, _) => const Divider(height: 1),
      itemBuilder: (context, idx) {
        final sess = items[idx];
        final sub = _subjects.firstWhere(
          (s) => s.id == sess.subjectId,
          orElse: () => Subject(id: '', code: 'UNK', name: 'Unknown'),
        );
        final rec = _myRecords.firstWhere(
          (r) => r.sessionId == sess.id,
          orElse: () =>
              AttendanceRecord(id: '', sessionId: '', studentId: '', status: 'absent'),
        );
        final isPresent = rec.status == 'present';
        final statusColor = isPresent ? theme.appColors.success : theme.appColors.danger;
        final dateStr = DateFormat('MMM dd, yyyy').format(sess.date);

        return ListTile(
          contentPadding: compact ? EdgeInsets.zero : null,
          title: Text(sub.name,
              style: TextStyle(
                  fontWeight: FontWeight.bold, fontSize: compact ? 13 : 14)),
          subtitle: Text('$dateStr | ${sess.startTime}',
              style: TextStyle(fontSize: compact ? 11 : 12)),
          trailing: Container(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 4),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              isPresent ? 'PRESENT' : 'ABSENT',
              style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.bold),
            ),
          ),
        );
      },
    );
  }
}
