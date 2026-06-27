import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/models.dart';
import '../../data/services/providers.dart';
import '../../core/widgets/responsive_scaffold.dart';

class ReportsDashboard extends ConsumerStatefulWidget {
  const ReportsDashboard({super.key});

  @override
  ConsumerState<ReportsDashboard> createState() => _ReportsDashboardState();
}

class _ReportsDashboardState extends ConsumerState<ReportsDashboard> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = true;

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
  double _defaulterThreshold = 80.0;

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
    setState(() => _isLoading = true);
    final repo = ref.read(academicRepositoryProvider);
    final attendanceRepo = ref.read(attendanceRepositoryProvider);

    final students = await repo.getStudents();
    final faculty = await repo.getFaculty();
    final subjects = await repo.getSubjects();
    final sections = await repo.getSections();
    final semesters = await repo.getSemesters();
    final branches = await repo.getBranches();
    final sessions = await attendanceRepo.getSessions();

    // Fetch all attendance records for all sessions
    final List<AttendanceRecord> allRecords = [];
    for (final s in sessions) {
      final recs = await attendanceRepo.getAttendanceRecords(s.id);
      allRecords.addAll(recs);
    }

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
    if (_isLoading) {
      return ResponsiveScaffold(
        title: 'Analytics & Reports',
        currentPath: '/reports',
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return ResponsiveScaffold(
      title: 'Analytics & Reports',
      currentPath: '/reports',
      body: Column(
        children: [
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
    final isDesktop = MediaQuery.of(context).size.width > 960;

    final defaulters = _students.where((s) {
      final pct = allAttendance[s.id] ?? 0.0;
      return pct < _defaulterThreshold;
    }).toList();

    Widget thresholdCard() {
      return Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: theme.dividerColor.withValues(alpha: 0.15)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Defaulters Filter',
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              const Text('Select an attendance threshold below which students are flagged as defaulters:'),
              const SizedBox(height: 12),
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
              const SizedBox(height: 20),
              if (isDesktop) ...[
                const Divider(),
                const SizedBox(height: 12),
                _buildReportStatTile(theme, 'Flagged Students', '${defaulters.length}', const Color(0xFFEF4444)),
                const SizedBox(height: 12),
                _buildReportStatTile(
                  theme,
                  'Overall Safe',
                  '${_students.length - defaulters.length} / ${_students.length}',
                  const Color(0xFF10B981),
                ),
              ],
            ],
          ),
        ),
      );
    }

    if (isDesktop) {
      return Padding(
        padding: const EdgeInsets.all(24.0),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final defaultersCard = Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: theme.dividerColor.withValues(alpha: 0.15)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Flagged Defaulter Roster',
                          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          'Threshold: <$_defaulterThreshold%',
                          style: TextStyle(
                            color: theme.colorScheme.error,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: defaulters.isEmpty
                          ? Center(
                              child: Text(
                                'No students match the defaulter threshold!',
                                style: TextStyle(color: theme.colorScheme.onSurface.withValues(alpha: 0.5)),
                              ),
                            )
                          : SingleChildScrollView(
                              child: Table(
                                columnWidths: const {
                                  0: FixedColumnWidth(100),
                                  1: FlexColumnWidth(3),
                                  2: FlexColumnWidth(4),
                                  3: FixedColumnWidth(100),
                                },
                                children: [
                                  TableRow(
                                    decoration: BoxDecoration(
                                      border: Border(bottom: BorderSide(color: theme.dividerColor, width: 1.5)),
                                    ),
                                    children: const [
                                      Padding(padding: EdgeInsets.symmetric(vertical: 10), child: Text('Roll No', style: TextStyle(fontWeight: FontWeight.bold))),
                                      Padding(padding: EdgeInsets.symmetric(vertical: 10), child: Text('Student Name', style: TextStyle(fontWeight: FontWeight.bold))),
                                      Padding(padding: EdgeInsets.symmetric(vertical: 10), child: Text('Class Section', style: TextStyle(fontWeight: FontWeight.bold))),
                                      Padding(padding: EdgeInsets.symmetric(vertical: 10), child: Text('Attendance', style: TextStyle(fontWeight: FontWeight.bold))),
                                    ],
                                  ),
                                  ...defaulters.map((s) {
                                    final pct = allAttendance[s.id] ?? 0.0;
                                    final sec = _sections.firstWhere((se) => se.id == s.sectionId, orElse: () => Section(id: '', semesterId: '', name: 'Unknown'));
                                    final sem = _semesters.firstWhere((se) => se.id == sec.semesterId, orElse: () => Semester(id: '', branchId: '', semesterNumber: 0));
                                    final b = _branches.firstWhere((br) => br.id == sem.branchId, orElse: () => Branch(id: '', courseId: '', name: 'Unknown'));
                                    return TableRow(
                                      decoration: BoxDecoration(
                                        border: Border(bottom: BorderSide(color: theme.dividerColor.withValues(alpha: 0.4))),
                                      ),
                                      children: [
                                        Padding(padding: const EdgeInsets.symmetric(vertical: 12), child: Text(s.rollNumber)),
                                        Padding(padding: const EdgeInsets.symmetric(vertical: 12), child: Text(s.name, style: const TextStyle(fontWeight: FontWeight.bold))),
                                        Padding(padding: const EdgeInsets.symmetric(vertical: 12), child: Text('${b.name} - Sem ${sem.semesterNumber} (${sec.name})')),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(vertical: 12),
                                          child: Text(
                                            '${pct.toStringAsFixed(1)}%',
                                            style: TextStyle(
                                              color: theme.colorScheme.error,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ],
                                    );
                                  }),
                                ],
                              ),
                            ),
                    ),
                  ],
                ),
              ),
            );

            if (constraints.maxWidth < 1100) {
              return SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    thresholdCard(),
                    const SizedBox(height: 24),
                    SizedBox(
                      height: 500,
                      child: defaultersCard,
                    ),
                  ],
                ),
              );
            } else {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 3,
                    child: defaultersCard,
                  ),
                  const SizedBox(width: 24),
                  SizedBox(
                    width: 320,
                    child: thresholdCard(),
                  ),
                ],
              );
            }
          },
        ),
      );
    }

    // Mobile fallback (original layout with slight enhancements)
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          thresholdCard(),
          const SizedBox(height: 16),
          Text(
            'Defaulters List (${defaulters.length} students found)',
            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: defaulters.isEmpty
                ? Center(
                    child: Text(
                      'No students match the defaulter threshold!',
                      style: TextStyle(color: theme.colorScheme.onSurface.withValues(alpha: 0.5)),
                    ),
                  )
                : ListView.builder(
                    itemCount: defaulters.length,
                    itemBuilder: (context, idx) {
                      final s = defaulters[idx];
                      final pct = allAttendance[s.id] ?? 0.0;
                      final sec = _sections.firstWhere((se) => se.id == s.sectionId, orElse: () => Section(id: '', semesterId: '', name: 'Unknown'));
                      final sem = _semesters.firstWhere((se) => se.id == sec.semesterId, orElse: () => Semester(id: '', branchId: '', semesterNumber: 0));
                      final b = _branches.firstWhere((br) => br.id == sem.branchId, orElse: () => Branch(id: '', courseId: '', name: 'Unknown'));

                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: theme.colorScheme.error.withValues(alpha: 0.1),
                            child: Text(
                              '${pct.toStringAsFixed(0)}%',
                              style: TextStyle(color: theme.colorScheme.error, fontWeight: FontWeight.bold, fontSize: 11),
                            ),
                          ),
                          title: Text(s.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text('Roll: ${s.rollNumber} | ${b.name} - Sem ${sem.semesterNumber} (${sec.name})'),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildReportStatTile(ThemeData theme, String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.15)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
          Text(
            value,
            style: TextStyle(fontWeight: FontWeight.bold, color: color, fontSize: 15),
          ),
        ],
      ),
    );
  }

  Widget _buildSubjectReport() {
    final theme = Theme.of(context);
    final isDesktop = MediaQuery.of(context).size.width > 960;

    if (_selectedSubjectId == null) {
      return const Center(child: Text('No subjects added.'));
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
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: theme.dividerColor.withValues(alpha: 0.15)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Subject Filter',
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                isExpanded: true,
                value: _selectedSubjectId,
                decoration: const InputDecoration(
                  labelText: 'Select Subject',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                items: _subjects
                    .map((s) => DropdownMenuItem(value: s.id, child: Text('[${s.code}] ${s.name}', overflow: TextOverflow.ellipsis)))
                    .toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _selectedSubjectId = val);
                },
              ),
              const SizedBox(height: 20),
              if (isDesktop) ...[
                const Divider(),
                const SizedBox(height: 12),
                _buildReportStatTile(
                  theme,
                  'Classes Conducted',
                  '$totalConducted',
                  theme.colorScheme.primary,
                ),
                const SizedBox(height: 12),
                _buildReportStatTile(
                  theme,
                  'Enrolled Mapped Students',
                  '${conductedCount.length}',
                  Colors.blueGrey,
                ),
              ],
            ],
          ),
        ),
      );
    }

    if (isDesktop) {
      return Padding(
        padding: const EdgeInsets.all(24.0),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final tableCard = Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: theme.dividerColor.withValues(alpha: 0.15)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Roster Attendance Analysis',
                      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: conductedCount.isEmpty
                          ? Center(
                              child: Text(
                                'No attendance logs recorded for this subject.',
                                style: TextStyle(color: theme.colorScheme.onSurface.withValues(alpha: 0.5)),
                              ),
                            )
                          : SingleChildScrollView(
                              child: Table(
                                columnWidths: const {
                                  0: FixedColumnWidth(100),
                                  1: FlexColumnWidth(3),
                                  2: FixedColumnWidth(180),
                                  3: FixedColumnWidth(100),
                                },
                                children: [
                                  TableRow(
                                    decoration: BoxDecoration(
                                      border: Border(bottom: BorderSide(color: theme.dividerColor, width: 1.5)),
                                    ),
                                    children: const [
                                      Padding(padding: EdgeInsets.symmetric(vertical: 10), child: Text('Roll No', style: TextStyle(fontWeight: FontWeight.bold))),
                                      Padding(padding: EdgeInsets.symmetric(vertical: 10), child: Text('Student Name', style: TextStyle(fontWeight: FontWeight.bold))),
                                      Padding(padding: EdgeInsets.symmetric(vertical: 10), child: Text('Attendance Log', style: TextStyle(fontWeight: FontWeight.bold))),
                                      Padding(padding: EdgeInsets.symmetric(vertical: 10), child: Text('Percentage', style: TextStyle(fontWeight: FontWeight.bold))),
                                    ],
                                  ),
                                  ...conductedCount.keys.map((studentId) {
                                    final student = _students.firstWhere((s) => s.id == studentId, orElse: () => Student(id: '', rollNumber: '', name: 'Unknown', sectionId: ''));
                                     final present = presenceCount[studentId] ?? 0;
                                     final conducted = conductedCount[studentId] ?? 0;
                                     final double pct = conducted > 0 ? (present / conducted) * 100 : 0.0;
                                     final isSafe = pct >= _defaulterThreshold;

                                    return TableRow(
                                      decoration: BoxDecoration(
                                        border: Border(bottom: BorderSide(color: theme.dividerColor.withValues(alpha: 0.4))),
                                      ),
                                      children: [
                                        Padding(padding: const EdgeInsets.symmetric(vertical: 12), child: Text(student.rollNumber)),
                                        Padding(padding: const EdgeInsets.symmetric(vertical: 12), child: Text(student.name, style: const TextStyle(fontWeight: FontWeight.bold))),
                                        Padding(padding: const EdgeInsets.symmetric(vertical: 12), child: Text('Attended $present / $conducted lectures')),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(vertical: 12),
                                          child: Text(
                                            '${pct.toStringAsFixed(1)}%',
                                            style: TextStyle(
                                              color: isSafe ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ],
                                    );
                                  }),
                                ],
                              ),
                            ),
                    ),
                  ],
                ),
              ),
            );

            if (constraints.maxWidth < 1100) {
              return SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    filterCard(),
                    const SizedBox(height: 24),
                    SizedBox(
                      height: 500,
                      child: tableCard,
                    ),
                  ],
                ),
              );
            } else {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 320,
                    child: filterCard(),
                  ),
                  const SizedBox(width: 24),
                  Expanded(
                    child: tableCard,
                  ),
                ],
              );
            }
          },
        ),
      );
    }

    // Mobile layout
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          filterCard(),
          const SizedBox(height: 16),
          Text(
            'Total Classes Conducted: $totalConducted',
            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: conductedCount.isEmpty
                ? Center(
                    child: Text(
                      'No attendance logs recorded for this subject.',
                      style: TextStyle(color: theme.colorScheme.onSurface.withValues(alpha: 0.5)),
                    ),
                  )
                : ListView.builder(
                    itemCount: conductedCount.length,
                    itemBuilder: (context, idx) {
                      final studentId = conductedCount.keys.elementAt(idx);
                      final student = _students.firstWhere((s) => s.id == studentId, orElse: () => Student(id: '', rollNumber: '', name: 'Unknown', sectionId: ''));
                      final present = presenceCount[studentId] ?? 0;
                      final conducted = conductedCount[studentId] ?? 0;
                      final double pct = conducted > 0 ? (present / conducted) * 100 : 0.0;

                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          title: Text(student.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text('Roll Number: ${student.rollNumber} | Attended $present / $conducted lectures'),
                          trailing: Text(
                            '${pct.toStringAsFixed(0)}%',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: pct >= _defaulterThreshold ? const Color(0xFF10B981) : const Color(0xFFEF4444),
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
  }

  Widget _buildStudentReport() {
    final theme = Theme.of(context);
    final isDesktop = MediaQuery.of(context).size.width > 960;

    if (_selectedStudentId == null) {
      return const Center(child: Text('No students registered.'));
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
    final double overallPct = studentSessions.isNotEmpty ? (totalAttended / studentSessions.length) * 100 : 100.0;

    Widget selectorCard() {
      final sec = _sections.firstWhere((se) => se.id == student.sectionId, orElse: () => Section(id: '', semesterId: '', name: 'Unknown'));
      final sem = _semesters.firstWhere((se) => se.id == sec.semesterId, orElse: () => Semester(id: '', branchId: '', semesterNumber: 0));
      final b = _branches.firstWhere((br) => br.id == sem.branchId, orElse: () => Branch(id: '', courseId: '', name: 'Unknown'));

      return Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: theme.dividerColor.withValues(alpha: 0.15)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Student Lookup',
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                isExpanded: true,
                value: _selectedStudentId,
                decoration: const InputDecoration(
                  labelText: 'Select Student',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                items: _students
                    .map((s) => DropdownMenuItem(value: s.id, child: Text('${s.name} (${s.rollNumber})', overflow: TextOverflow.ellipsis)))
                    .toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _selectedStudentId = val);
                },
              ),
              const SizedBox(height: 24),
              const Divider(),
              const SizedBox(height: 12),
              Text('Academic Details', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              _buildReportDetailRow('Roll Number', student.rollNumber),
              const SizedBox(height: 8),
              _buildReportDetailRow('Class Section', '${b.name} - Sem ${sem.semesterNumber} (${sec.name})'),
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 12),
              _buildReportStatTile(
                theme,
                'Overall Attendance',
                '${overallPct.toStringAsFixed(1)}%',
                overallPct >= _defaulterThreshold ? const Color(0xFF10B981) : const Color(0xFFEF4444),
              ),
            ],
          ),
        ),
      );
    }

    if (isDesktop) {
      return Padding(
        padding: const EdgeInsets.all(24.0),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final reportCard = Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: theme.dividerColor.withValues(alpha: 0.15)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Subject-wise Report Card',
                      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: subjectGroup.isEmpty
                          ? Center(
                              child: Text(
                                'No classes conducted for this student\'s section.',
                                style: TextStyle(color: theme.colorScheme.onSurface.withValues(alpha: 0.5)),
                              ),
                            )
                          : ListView.builder(
                              itemCount: subjectGroup.length,
                              itemBuilder: (context, idx) {
                                final subId = subjectGroup.keys.elementAt(idx);
                                final subSessions = subjectGroup[subId]!;
                                final sub = _subjects.firstWhere((s) => s.id == subId, orElse: () => Subject(id: '', code: 'UNK', name: 'Unknown'));

                                final conducted = subSessions.length;
                                int attended = 0;
                                for (final sess in subSessions) {
                                  final rec = studentRecords.firstWhere(
                                    (r) => r.sessionId == sess.id,
                                    orElse: () => AttendanceRecord(id: '', sessionId: '', studentId: '', status: 'absent'),
                                  );
                                  if (rec.status == 'present') attended++;
                                }

                                final double pct = conducted > 0 ? (attended / conducted) * 100 : 0.0;
                                final isSafe = pct >= _defaulterThreshold;

                                return Container(
                                  margin: const EdgeInsets.only(bottom: 16),
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: theme.dividerColor.withValues(alpha: 0.06)),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.stretch,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Text(
                                              sub.name,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                            ),
                                          ),
                                          const SizedBox(width: 16),
                                          Text(
                                            '${pct.toStringAsFixed(0)}%',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: isSafe ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 10),
                                      LinearProgressIndicator(
                                        value: pct / 100,
                                        minHeight: 6,
                                        borderRadius: BorderRadius.circular(3),
                                        backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.1),
                                        valueColor: AlwaysStoppedAnimation<Color>(
                                          isSafe ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text('Attended $attended / $conducted classes', style: TextStyle(color: theme.colorScheme.onSurface.withValues(alpha: 0.5), fontSize: 11)),
                                    ],
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),
            );

            if (constraints.maxWidth < 1100) {
              return SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    selectorCard(),
                    const SizedBox(height: 24),
                    SizedBox(
                      height: 500,
                      child: reportCard,
                    ),
                  ],
                ),
              );
            } else {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 320,
                    child: selectorCard(),
                  ),
                  const SizedBox(width: 24),
                  Expanded(
                    child: reportCard,
                  ),
                ],
              );
            }
          },
        ),
      );
    }

    // Mobile Layout
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          selectorCard(),
          const SizedBox(height: 16),
          Text(
            'Subject-wise Report Card',
            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: subjectGroup.isEmpty
                ? Center(
                    child: Text(
                      'No classes conducted for this student\'s section.',
                      style: TextStyle(color: theme.colorScheme.onSurface.withValues(alpha: 0.5)),
                    ),
                  )
                : ListView.builder(
                    itemCount: subjectGroup.length,
                    itemBuilder: (context, idx) {
                      final subId = subjectGroup.keys.elementAt(idx);
                      final subSessions = subjectGroup[subId]!;
                      final sub = _subjects.firstWhere((s) => s.id == subId, orElse: () => Subject(id: '', code: 'UNK', name: 'Unknown'));

                      final conducted = subSessions.length;
                      int attended = 0;
                      for (final sess in subSessions) {
                        final rec = studentRecords.firstWhere(
                          (r) => r.sessionId == sess.id,
                          orElse: () => AttendanceRecord(id: '', sessionId: '', studentId: '', status: 'absent'),
                        );
                        if (rec.status == 'present') attended++;
                      }

                      final double pct = conducted > 0 ? (attended / conducted) * 100 : 0.0;

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
                                  Text(sub.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                                  Text(
                                    '${pct.toStringAsFixed(0)}%',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: pct >= _defaulterThreshold ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              LinearProgressIndicator(
                                value: pct / 100,
                                minHeight: 6,
                                backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.1),
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  pct >= _defaulterThreshold ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text('Attended $attended / $conducted classes', style: TextStyle(color: theme.colorScheme.onSurface.withValues(alpha: 0.5), fontSize: 11)),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
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
    final isDesktop = MediaQuery.of(context).size.width > 960;

    if (_faculty.isEmpty) {
      return Center(
        child: Text(
          'No faculty members registered.',
          style: TextStyle(color: theme.colorScheme.onSurface.withValues(alpha: 0.5)),
        ),
      );
    }

    if (isDesktop) {
      return Padding(
        padding: const EdgeInsets.all(24.0),
        child: Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: theme.dividerColor.withValues(alpha: 0.15)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Faculty Teaching Activity Summary',
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: SingleChildScrollView(
                    child: Table(
                      columnWidths: const {
                        0: FixedColumnWidth(150),
                        1: FlexColumnWidth(3),
                        2: FlexColumnWidth(4),
                        3: FixedColumnWidth(150),
                      },
                      children: [
                        TableRow(
                          decoration: BoxDecoration(
                            border: Border(bottom: BorderSide(color: theme.dividerColor, width: 1.5)),
                          ),
                          children: const [
                            Padding(padding: EdgeInsets.symmetric(vertical: 10), child: Text('Employee ID', style: TextStyle(fontWeight: FontWeight.bold))),
                            Padding(padding: EdgeInsets.symmetric(vertical: 10), child: Text('Faculty Name', style: TextStyle(fontWeight: FontWeight.bold))),
                            Padding(padding: EdgeInsets.symmetric(vertical: 10), child: Text('Email Address', style: TextStyle(fontWeight: FontWeight.bold))),
                            Padding(padding: EdgeInsets.symmetric(vertical: 10), child: Text('Lectures Conducted', style: TextStyle(fontWeight: FontWeight.bold))),
                          ],
                        ),
                        ..._faculty.map((f) {
                          final conductedCount = _sessions.where((s) => s.facultyId == f.id).length;
                          return TableRow(
                            decoration: BoxDecoration(
                              border: Border(bottom: BorderSide(color: theme.dividerColor.withValues(alpha: 0.4))),
                            ),
                            children: [
                              Padding(padding: const EdgeInsets.symmetric(vertical: 12), child: Text(f.employeeId)),
                              Padding(padding: const EdgeInsets.symmetric(vertical: 12), child: Text(f.name, style: const TextStyle(fontWeight: FontWeight.bold))),
                              Padding(padding: const EdgeInsets.symmetric(vertical: 12), child: Text(f.email)),
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                child: Text(
                                  '$conductedCount Lectures',
                                  style: TextStyle(
                                    color: theme.colorScheme.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          );
                        }),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // Mobile layout
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Faculty Teaching Activity Summary',
            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: _faculty.length,
              itemBuilder: (context, idx) {
                final f = _faculty[idx];
                final conductedCount = _sessions.where((s) => s.facultyId == f.id).length;

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.1),
                      child: Icon(Icons.school_rounded, color: theme.colorScheme.primary),
                    ),
                    title: Text(f.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('Email: ${f.email}'),
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '$conductedCount Lectures',
                        style: TextStyle(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                        ),
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
  }
}

