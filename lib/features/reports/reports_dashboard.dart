import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../data/models/models.dart';
import '../../data/services/providers.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/theme/app_color_scheme.dart';
import '../../core/widgets/responsive_scaffold.dart';
import '../../core/widgets/skeleton_loaders.dart';
import '../../core/widgets/console_header.dart';
import '../../core/widgets/stat_card.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/app_data_table.dart';
import '../../core/widgets/responsive_two_pane.dart';

class ReportsDashboard extends ConsumerStatefulWidget {
  const ReportsDashboard({super.key});

  @override
  ConsumerState<ReportsDashboard> createState() => _ReportsDashboardState();
}

class _ReportsDashboardState extends ConsumerState<ReportsDashboard> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = true;
  Object? _error;

  // Global lookups
  List<Student> _students = [];
  List<Faculty> _faculty = [];
  List<Subject> _subjects = [];
  List<Section> _sections = [];
  List<Semester> _semesters = [];
  List<Branch> _branches = [];
  List<AttendanceSession> _sessions = [];
  List<AttendanceRecord> _allRecords = [];

  // Local selection filters
  String? _selectedStudentId;
  String? _selectedSubjectId;
  double _defaulterThreshold = AppConstants.defaulterThreshold;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final repo = ref.read(academicRepositoryProvider);
      final attendanceRepo = ref.read(attendanceRepositoryProvider);

      final results = await Future.wait([
        repo.getStudents(),
        repo.getFaculty(),
        repo.getSubjects(),
        repo.getSections(),
        repo.getSemesters(),
        repo.getBranches(),
        attendanceRepo.getSessions(),
      ]);

      final students = results[0] as List<Student>;
      final faculty = results[1] as List<Faculty>;
      final subjects = results[2] as List<Subject>;
      final sections = results[3] as List<Section>;
      final semesters = results[4] as List<Semester>;
      final branches = results[5] as List<Branch>;
      final sessions = results[6] as List<AttendanceSession>;

      // Fetch attendance records for every session in parallel instead of
      // sequentially awaiting inside a loop.
      final recordLists =
          await Future.wait(sessions.map((s) => attendanceRepo.getAttendanceRecords(s.id)));
      final allRecords = recordLists.expand((r) => r).toList();

      if (!mounted) return;
      setState(() {
        _students = students;
        _faculty = faculty;
        _subjects = subjects;
        _sections = sections;
        _semesters = semesters;
        _branches = branches;
        _sessions = sessions;
        _allRecords = allRecords;

        if (_students.isNotEmpty) _selectedStudentId = _students.first.id;
        if (_subjects.isNotEmpty) _selectedSubjectId = _subjects.first.id;

        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e;
        _isLoading = false;
      });
    }
  }

  // Calculate attendance percentages for all students
  Map<String, double> _calculateAllStudentsAttendance() {
    final Map<String, double> attendanceMap = {};
    for (final student in _students) {
      final studentSessions = _sessions.where((s) => s.sectionId == student.sectionId).toList();
      if (studentSessions.isEmpty) {
        attendanceMap[student.id] = 100.0; // Assume 100 if no classes conducted
        continue;
      }
      final studentRecords = _allRecords.where((r) => r.studentId == student.id).toList();
      final presentCount = studentRecords.where((r) => r.status == 'present').length;
      attendanceMap[student.id] = (presentCount / studentSessions.length) * 100;
    }
    return attendanceMap;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_isLoading) {
      return ResponsiveScaffold(
        title: 'Analytics & Reports',
        currentPath: '/reports',
        body: RefreshIndicator(
          onRefresh: _loadData,
          child: const SkeletonDashboard(),
        ),
      );
    }

    if (_error != null) {
      return ResponsiveScaffold(
        title: 'Analytics & Reports',
        currentPath: '/reports',
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline_rounded, size: 64, color: theme.colorScheme.error),
              const SizedBox(height: AppSpacing.lg),
              Text('Failed to load report data', style: theme.textTheme.titleMedium),
              const SizedBox(height: AppSpacing.sm),
              ElevatedButton(onPressed: _loadData, child: const Text('Retry')),
            ],
          ),
        ),
      );
    }

    final isDesktop = MediaQuery.of(context).size.width > AppBreakpoints.desktop;

    return ResponsiveScaffold(
      title: 'Analytics & Reports',
      currentPath: '/reports',
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(
              isDesktop ? AppSpacing.xl : AppSpacing.lg,
              isDesktop ? AppSpacing.xl : AppSpacing.lg,
              isDesktop ? AppSpacing.xl : AppSpacing.lg,
              AppSpacing.md,
            ),
            child: ConsoleHeader(
              title: 'Analytics & Reports',
              subtitle: 'Attendance insights across the institution',
              onRefresh: _loadData,
            ),
          ),
          TabBar(
            controller: _tabController,
            tabs: const [
              Tab(text: 'Defaulters'),
              Tab(text: 'Subject Wise'),
              Tab(text: 'Student Summary'),
              Tab(text: 'Faculty Report'),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildDefaulterReport(),
                _buildSubjectReport(),
                _buildStudentReport(),
                _buildFacultyReport(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDefaulterReport() {
    final theme = Theme.of(context);
    final allAttendance = _calculateAllStudentsAttendance();
    final isDesktop = MediaQuery.of(context).size.width > AppBreakpoints.desktop;

    final defaulters = _students.where((s) {
      final pct = allAttendance[s.id] ?? 0.0;
      return pct < _defaulterThreshold;
    }).toList();

    Widget thresholdCard() {
      return Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.card),
          side: BorderSide(color: theme.dividerColor.withValues(alpha: 0.15)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Defaulters Filter',
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: AppSpacing.md),
              const Text(
                  'Select an attendance threshold below which students are flagged as defaulters:'),
              const SizedBox(height: AppSpacing.md),
              DropdownButtonFormField<double>(
                isExpanded: true,
                value: _defaulterThreshold,
                decoration: const InputDecoration(
                  labelText: 'Defaulter Threshold',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                items: const [
                  DropdownMenuItem(value: 80.0, child: Text('Below 80%')),
                  DropdownMenuItem(value: 60.0, child: Text('Below 60%')),
                  DropdownMenuItem(value: 40.0, child: Text('Below 40%')),
                ],
                onChanged: (val) {
                  if (val != null) setState(() => _defaulterThreshold = val);
                },
              ),
              const SizedBox(height: AppSpacing.xl),
              Text('Severity Breakdown',
                  style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: AppSpacing.md),
              _buildSeverityBreakdown(theme, allAttendance),
              if (isDesktop) ...[
                const SizedBox(height: AppSpacing.lg),
                const Divider(),
                const SizedBox(height: AppSpacing.md),
                StatCard(
                  label: 'Flagged Students',
                  value: '${defaulters.length}',
                  icon: Icons.flag_rounded,
                  color: theme.appColors.danger,
                ),
                const SizedBox(height: AppSpacing.md),
                StatCard(
                  label: 'Overall Safe',
                  value: '${_students.length - defaulters.length} / ${_students.length}',
                  icon: Icons.verified_rounded,
                  color: theme.appColors.success,
                ),
              ],
            ],
          ),
        ),
      ).animate().fadeIn(duration: AppMotion.entrance).slideY(begin: 0.05, end: 0, curve: Curves.easeOut);
    }

    Widget rosterCard() {
      final rows = defaulters.map((s) {
        final pct = allAttendance[s.id] ?? 0.0;
        final sec = _sections.firstWhere((se) => se.id == s.sectionId,
            orElse: () => Section(id: '', semesterId: '', name: 'Unknown'));
        final sem = _semesters.firstWhere((se) => se.id == sec.semesterId,
            orElse: () => Semester(id: '', branchId: '', semesterNumber: 0));
        final b = _branches.firstWhere((br) => br.id == sem.branchId,
            orElse: () => Branch(id: '', courseId: '', name: 'Unknown'));
        final sectionLabel = '${b.name} - Sem ${sem.semesterNumber} (${sec.name})';
        return AppDataRow(
          cells: [
            Text(s.rollNumber),
            Text(s.name, style: const TextStyle(fontWeight: FontWeight.bold)),
            Text(sectionLabel),
            Text('${pct.toStringAsFixed(1)}%',
                style: TextStyle(color: theme.appColors.danger, fontWeight: FontWeight.bold)),
          ],
          mobileTitle: s.name,
          mobileSubtitle: 'Roll: ${s.rollNumber} | $sectionLabel',
          mobileLeadingText: s.name,
          mobileTrailing: Text('${pct.toStringAsFixed(0)}%',
              style: TextStyle(color: theme.appColors.danger, fontWeight: FontWeight.bold)),
        );
      }).toList();

      return Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.card),
          side: BorderSide(color: theme.dividerColor.withValues(alpha: 0.15)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Flagged Defaulter Roster',
                      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                  Text(
                    'Threshold: <${_defaulterThreshold.toInt()}%',
                    style: TextStyle(
                        color: theme.colorScheme.error, fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              AppDataTable(
                columns: const ['Roll No', 'Student Name', 'Class Section', 'Attendance'],
                columnFlex: const [2, 3, 4, 2],
                rows: rows,
                isDesktop: isDesktop,
                emptyIcon: Icons.verified_rounded,
                emptyTitle: 'No students match the defaulter threshold',
                emptyMessage: 'Every student is currently above the selected threshold.',
              ),
            ],
          ),
        ),
      );
    }

    return SingleChildScrollView(
      padding: EdgeInsets.all(isDesktop ? AppSpacing.xl : AppSpacing.lg),
      child: isDesktop
          ? ResponsiveTwoPane(leftWidth: 320, left: thresholdCard(), right: rosterCard())
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [thresholdCard(), const SizedBox(height: AppSpacing.lg), rosterCard()],
            ),
    );
  }

  Widget _buildSeverityBreakdown(ThemeData theme, Map<String, double> allAttendance) {
    if (allAttendance.isEmpty) return const SizedBox.shrink();

    var critical = 0, atRisk = 0, belowTarget = 0, safe = 0;
    for (final pct in allAttendance.values) {
      if (pct < 40) {
        critical++;
      } else if (pct < 60) {
        atRisk++;
      } else if (pct < 80) {
        belowTarget++;
      } else {
        safe++;
      }
    }

    final bands = <(String, int, Color)>[
      ('Critical <40%', critical, theme.appColors.danger),
      ('At Risk <60%', atRisk, theme.appColors.warning),
      ('Below Target <80%', belowTarget, theme.appColors.info),
      ('On Track', safe, theme.appColors.success),
    ];

    return SizedBox(
      height: 150,
      child: Row(
        children: [
          Expanded(
            child: PieChart(
              PieChartData(
                sectionsSpace: 2,
                centerSpaceRadius: 26,
                sections: [
                  for (final band in bands)
                    if (band.$2 > 0)
                      PieChartSectionData(
                        value: band.$2.toDouble(),
                        color: band.$3,
                        radius: 38,
                        title: '${band.$2}',
                        titleStyle: const TextStyle(
                            fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                ],
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (final band in bands)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(color: band.$3, shape: BoxShape.circle),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(band.$1,
                              style: const TextStyle(fontSize: 11),
                              overflow: TextOverflow.ellipsis),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubjectReport() {
    final theme = Theme.of(context);
    final isDesktop = MediaQuery.of(context).size.width > AppBreakpoints.desktop;

    if (_subjects.isEmpty || _selectedSubjectId == null) {
      return const EmptyState(
        icon: Icons.library_books_rounded,
        title: 'No subjects added',
        message: 'Add a subject in Academic Setup before viewing subject-wise reports.',
      );
    }

    final subjectSessions = _sessions.where((s) => s.subjectId == _selectedSubjectId).toList();
    final totalConducted = subjectSessions.length;

    // Calculate students list and their attendance for selected subject
    final Map<String, int> presenceCount = {}; // studentId -> presentCount
    final Map<String, int> conductedCount = {}; // studentId -> totalConductedForStudent

    for (final session in subjectSessions) {
      final sessionStudents = _students.where((s) => s.sectionId == session.sectionId).toList();
      for (final s in sessionStudents) {
        conductedCount[s.id] = (conductedCount[s.id] ?? 0) + 1;
        final rec = _allRecords.firstWhere(
          (r) => r.sessionId == session.id && r.studentId == s.id,
          orElse: () => AttendanceRecord(id: '', sessionId: '', studentId: '', status: 'absent'),
        );
        if (rec.status == 'present') {
          presenceCount[s.id] = (presenceCount[s.id] ?? 0) + 1;
        }
      }
    }

    Widget filterCard() {
      return Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.card),
          side: BorderSide(color: theme.dividerColor.withValues(alpha: 0.15)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Subject Filter',
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: AppSpacing.md),
              DropdownButtonFormField<String>(
                isExpanded: true,
                value: _selectedSubjectId,
                decoration: const InputDecoration(
                  labelText: 'Select Subject',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                items: _subjects
                    .map((s) => DropdownMenuItem(
                        value: s.id, child: Text('[${s.code}] ${s.name}', overflow: TextOverflow.ellipsis)))
                    .toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _selectedSubjectId = val);
                },
              ),
              if (isDesktop) ...[
                const SizedBox(height: AppSpacing.xl),
                const Divider(),
                const SizedBox(height: AppSpacing.md),
                StatCard(
                  label: 'Classes Conducted',
                  value: '$totalConducted',
                  icon: Icons.event_available_rounded,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(height: AppSpacing.md),
                StatCard(
                  label: 'Enrolled Mapped Students',
                  value: '${conductedCount.length}',
                  icon: Icons.groups_rounded,
                  color: theme.appColors.info,
                ),
              ],
            ],
          ),
        ),
      ).animate().fadeIn(duration: AppMotion.entrance).slideY(begin: 0.05, end: 0, curve: Curves.easeOut);
    }

    Widget tableCard() {
      final studentStats = conductedCount.keys.map((studentId) {
        final student = _students.firstWhere((s) => s.id == studentId,
            orElse: () => Student(id: '', rollNumber: '', name: 'Unknown', sectionId: ''));
        final present = presenceCount[studentId] ?? 0;
        final conducted = conductedCount[studentId] ?? 0;
        final pct = conducted > 0 ? (present / conducted) * 100 : 0.0;
        return (student: student, present: present, conducted: conducted, pct: pct);
      }).toList();

      final rows = studentStats.map((s) {
        final isSafe = s.pct >= _defaulterThreshold;
        final color = isSafe ? theme.appColors.success : theme.appColors.danger;
        return AppDataRow(
          cells: [
            Text(s.student.rollNumber),
            Text(s.student.name, style: const TextStyle(fontWeight: FontWeight.bold)),
            Text('Attended ${s.present} / ${s.conducted} lectures'),
            Text('${s.pct.toStringAsFixed(1)}%', style: TextStyle(color: color, fontWeight: FontWeight.bold)),
          ],
          mobileTitle: s.student.name,
          mobileSubtitle: 'Roll Number: ${s.student.rollNumber} | Attended ${s.present} / ${s.conducted} lectures',
          mobileLeadingText: s.student.name,
          mobileTrailing: Text('${s.pct.toStringAsFixed(0)}%',
              style: TextStyle(fontWeight: FontWeight.bold, color: color)),
        );
      }).toList();

      return Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.card),
          side: BorderSide(color: theme.dividerColor.withValues(alpha: 0.15)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Roster Attendance Analysis',
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
              if (studentStats.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.lg),
                _buildSubjectBarChart(
                    theme, studentStats.map((s) => (label: s.student.rollNumber, pct: s.pct)).toList()),
              ],
              const SizedBox(height: AppSpacing.lg),
              AppDataTable(
                columns: const ['Roll No', 'Student Name', 'Attendance Log', 'Percentage'],
                columnFlex: const [2, 3, 4, 2],
                rows: rows,
                isDesktop: isDesktop,
                emptyIcon: Icons.event_busy_rounded,
                emptyTitle: 'No attendance logs recorded',
                emptyMessage: 'No sessions have been conducted for this subject yet.',
              ),
            ],
          ),
        ),
      );
    }

    return SingleChildScrollView(
      padding: EdgeInsets.all(isDesktop ? AppSpacing.xl : AppSpacing.lg),
      child: isDesktop
          ? ResponsiveTwoPane(leftWidth: 320, left: filterCard(), right: tableCard())
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [filterCard(), const SizedBox(height: AppSpacing.lg), tableCard()],
            ),
    );
  }

  Widget _buildSubjectBarChart(ThemeData theme, List<({String label, double pct})> data) {
    if (data.isEmpty) return const SizedBox.shrink();
    return SizedBox(
      height: 200,
      child: BarChart(
        BarChartData(
          maxY: 100,
          minY: 0,
          barGroups: [
            for (var i = 0; i < data.length; i++)
              BarChartGroupData(x: i, barRods: [
                BarChartRodData(
                  toY: data[i].pct,
                  width: 14,
                  borderRadius: BorderRadius.circular(AppRadius.control / 2),
                  color: data[i].pct >= _defaulterThreshold
                      ? theme.appColors.success
                      : theme.appColors.danger,
                ),
              ]),
          ],
          gridData: FlGridData(
            show: true,
            horizontalInterval: 20,
            drawVerticalLine: false,
            getDrawingHorizontalLine: (_) =>
                FlLine(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.4), strokeWidth: 1),
          ),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 34,
                interval: 20,
                getTitlesWidget: (value, meta) => Text('${value.toInt()}%',
                    style: TextStyle(fontSize: 10, color: theme.colorScheme.onSurfaceVariant)),
              ),
            ),
          ),
          extraLinesData: ExtraLinesData(horizontalLines: [
            HorizontalLine(
              y: _defaulterThreshold,
              color: theme.appColors.warning,
              strokeWidth: 1.5,
              dashArray: const [6, 4],
              label: HorizontalLineLabel(
                show: true,
                alignment: Alignment.topRight,
                style: TextStyle(
                    fontSize: 10, fontWeight: FontWeight.bold, color: theme.appColors.warning),
                labelResolver: (_) => '${_defaulterThreshold.toInt()}% threshold',
              ),
            ),
          ]),
          barTouchData: BarTouchData(enabled: true),
        ),
      ),
    );
  }

  Widget _buildStudentReport() {
    final theme = Theme.of(context);
    final isDesktop = MediaQuery.of(context).size.width > AppBreakpoints.desktop;

    if (_students.isEmpty || _selectedStudentId == null) {
      return const EmptyState(
        icon: Icons.face_rounded,
        title: 'No students registered',
        message: 'Add students in the Student Directory to view their attendance summary.',
      );
    }

    final student = _students.firstWhere((s) => s.id == _selectedStudentId);
    final studentSessions = _sessions.where((s) => s.sectionId == student.sectionId).toList();
    final studentRecords = _allRecords.where((r) => r.studentId == _selectedStudentId).toList();

    // Group sessions by subject
    final Map<String, List<AttendanceSession>> subjectGroup = {};
    for (final s in studentSessions) {
      subjectGroup.putIfAbsent(s.subjectId, () => []).add(s);
    }

    // Group overall attendance calculation
    int totalAttended = 0;
    for (final sess in studentSessions) {
      final rec = studentRecords.firstWhere(
        (r) => r.sessionId == sess.id,
        orElse: () => AttendanceRecord(id: '', sessionId: '', studentId: '', status: 'absent'),
      );
      if (rec.status == 'present') totalAttended++;
    }
    final double overallPct =
        studentSessions.isNotEmpty ? (totalAttended / studentSessions.length) * 100 : 100.0;
    final overallSafe = overallPct >= _defaulterThreshold;

    Widget selectorCard() {
      final sec = _sections.firstWhere((se) => se.id == student.sectionId,
          orElse: () => Section(id: '', semesterId: '', name: 'Unknown'));
      final sem = _semesters.firstWhere((se) => se.id == sec.semesterId,
          orElse: () => Semester(id: '', branchId: '', semesterNumber: 0));
      final b = _branches.firstWhere((br) => br.id == sem.branchId,
          orElse: () => Branch(id: '', courseId: '', name: 'Unknown'));

      return Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.card),
          side: BorderSide(color: theme.dividerColor.withValues(alpha: 0.15)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Student Lookup',
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: AppSpacing.md),
              DropdownButtonFormField<String>(
                isExpanded: true,
                value: _selectedStudentId,
                decoration: const InputDecoration(
                  labelText: 'Select Student',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                items: _students
                    .map((s) => DropdownMenuItem(
                        value: s.id, child: Text('${s.name} (${s.rollNumber})', overflow: TextOverflow.ellipsis)))
                    .toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _selectedStudentId = val);
                },
              ),
              const SizedBox(height: AppSpacing.xl),
              const Divider(),
              const SizedBox(height: AppSpacing.md),
              Text('Academic Details',
                  style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: AppSpacing.md),
              _buildReportDetailRow('Roll Number', student.rollNumber),
              const SizedBox(height: AppSpacing.sm),
              _buildReportDetailRow('Class Section', '${b.name} - Sem ${sem.semesterNumber} (${sec.name})'),
              const SizedBox(height: AppSpacing.lg),
              const Divider(),
              const SizedBox(height: AppSpacing.md),
              StatCard(
                label: 'Overall Attendance',
                value: '${overallPct.toStringAsFixed(1)}%',
                icon: overallSafe ? Icons.verified_rounded : Icons.warning_amber_rounded,
                color: overallSafe ? theme.appColors.success : theme.appColors.danger,
              ),
            ],
          ),
        ),
      ).animate().fadeIn(duration: AppMotion.entrance).slideY(begin: 0.05, end: 0, curve: Curves.easeOut);
    }

    Widget reportCard() {
      return Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.card),
          side: BorderSide(color: theme.dividerColor.withValues(alpha: 0.15)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Subject-wise Report Card',
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: AppSpacing.lg),
              if (subjectGroup.isEmpty)
                const EmptyState(
                  icon: Icons.event_busy_rounded,
                  title: 'No classes conducted',
                  message: 'No lectures have been conducted for this student\'s section yet.',
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: subjectGroup.length,
                  itemBuilder: (context, idx) {
                    final subId = subjectGroup.keys.elementAt(idx);
                    final subSessions = subjectGroup[subId]!;
                    final sub = _subjects.firstWhere((s) => s.id == subId,
                        orElse: () => Subject(id: '', code: 'UNK', name: 'Unknown'));

                    final conducted = subSessions.length;
                    int attended = 0;
                    for (final sess in subSessions) {
                      final rec = studentRecords.firstWhere(
                        (r) => r.sessionId == sess.id,
                        orElse: () =>
                            AttendanceRecord(id: '', sessionId: '', studentId: '', status: 'absent'),
                      );
                      if (rec.status == 'present') attended++;
                    }

                    final double pct = conducted > 0 ? (attended / conducted) * 100 : 0.0;
                    final isSafe = pct >= _defaulterThreshold;
                    final color = isSafe ? theme.appColors.success : theme.appColors.danger;

                    return Container(
                      margin: const EdgeInsets.only(bottom: AppSpacing.md),
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(AppRadius.control),
                        border: Border.all(color: theme.dividerColor.withValues(alpha: 0.06)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(sub.name,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                              ),
                              const SizedBox(width: AppSpacing.md),
                              Text('${pct.toStringAsFixed(0)}%',
                                  style: TextStyle(fontWeight: FontWeight.bold, color: color)),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          LinearProgressIndicator(
                            value: pct / 100,
                            minHeight: 6,
                            borderRadius: BorderRadius.circular(3),
                            backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.1),
                            valueColor: AlwaysStoppedAnimation<Color>(color),
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          Text('Attended $attended / $conducted classes',
                              style: TextStyle(
                                  color: theme.colorScheme.onSurfaceVariant, fontSize: 11)),
                        ],
                      ),
                    ).animate().fadeIn(
                        duration: AppMotion.entrance, delay: (idx * AppMotion.stagger.inMilliseconds).ms);
                  },
                ),
            ],
          ),
        ),
      );
    }

    return SingleChildScrollView(
      padding: EdgeInsets.all(isDesktop ? AppSpacing.xl : AppSpacing.lg),
      child: isDesktop
          ? ResponsiveTwoPane(leftWidth: 320, left: selectorCard(), right: reportCard())
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [selectorCard(), const SizedBox(height: AppSpacing.lg), reportCard()],
            ),
    );
  }

  Widget _buildReportDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
        Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildFacultyReport() {
    final theme = Theme.of(context);
    final isDesktop = MediaQuery.of(context).size.width > AppBreakpoints.desktop;

    final rows = _faculty.map((f) {
      final conducted = _sessions.where((s) => s.facultyId == f.id).length;
      return AppDataRow(
        cells: [
          Text(f.employeeId),
          Text(f.name, style: const TextStyle(fontWeight: FontWeight.bold)),
          Text(f.email),
          Text('$conducted Lectures',
              style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.bold)),
        ],
        mobileTitle: f.name,
        mobileSubtitle: 'Email: ${f.email}',
        mobileLeadingIcon: Icons.school_rounded,
        mobileTrailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(AppRadius.pill),
          ),
          child: Text(
            '$conducted Lectures',
            style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.bold, fontSize: 11),
          ),
        ),
      );
    }).toList();

    return SingleChildScrollView(
      padding: EdgeInsets.all(isDesktop ? AppSpacing.xl : AppSpacing.lg),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.card),
          side: BorderSide(color: theme.dividerColor.withValues(alpha: 0.15)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Faculty Teaching Activity Summary',
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: AppSpacing.lg),
              AppDataTable(
                columns: const ['Employee ID', 'Faculty Name', 'Email Address', 'Lectures Conducted'],
                columnFlex: const [2, 3, 4, 2],
                rows: rows,
                isDesktop: isDesktop,
                emptyIcon: Icons.badge_rounded,
                emptyTitle: 'No faculty members registered',
                emptyMessage: 'Add faculty members in the Faculty Directory to see their teaching activity here.',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
