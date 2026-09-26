import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../auth/auth_provider.dart';
import '../../data/models/models.dart';
import '../../data/services/providers.dart';
import '../../core/widgets/responsive_scaffold.dart';
import '../../core/widgets/skeleton_loaders.dart';
import '../../core/widgets/entity_list_tile.dart';
import '../../core/widgets/student_attendance_tile.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/stat_card.dart';
import '../../core/widgets/app_snackbar.dart';
import '../../core/widgets/responsive_two_pane.dart';
import '../../core/theme/app_color_scheme.dart';
import '../../core/theme/app_tokens.dart';

class EditAttendanceScreen extends ConsumerStatefulWidget {
  const EditAttendanceScreen({super.key});

  @override
  ConsumerState<EditAttendanceScreen> createState() => _EditAttendanceScreenState();
}

class _EditAttendanceScreenState extends ConsumerState<EditAttendanceScreen> {
  bool _isLoading = true;
  bool _isLoadingRoster = false;

  // Session selector state
  List<AttendanceSession> _sessions = [];
  List<Subject> _subjects = [];
  List<Section> _sections = [];
  List<Semester> _semesters = [];
  List<Branch> _branches = [];

  AttendanceSession? _selectedSession;

  // Roster editing state
  List<Student> _roster = [];
  List<AttendanceRecord> _records = [];
  final Map<String, String> _attendanceMap = {}; // studentId -> status ('present'|'absent')

  @override
  void initState() {
    super.initState();
    _loadSessions();
  }

  Future<void> _loadSessions() async {
    setState(() => _isLoading = true);
    final user = ref.read(authStateProvider).valueOrNull;
    final facultyId = user?.associatedId ?? '';

    final repo = ref.read(academicRepositoryProvider);
    final attendanceRepo = ref.read(attendanceRepositoryProvider);

    final sessions = await attendanceRepo.getSessionsByFaculty(facultyId);
    final subjects = await repo.getSubjects();
    final sections = await repo.getSections();
    final semesters = await repo.getSemesters();
    final branches = await repo.getBranches();

    // Sort sessions descending by date
    sessions.sort((a, b) => b.date.compareTo(a.date));

    setState(() {
      _sessions = sessions;
      _subjects = subjects;
      _sections = sections;
      _semesters = semesters;
      _branches = branches;
      _isLoading = false;
    });
  }

  Future<void> _loadRoster(AttendanceSession session) async {
    setState(() {
      _selectedSession = session;
      _isLoadingRoster = true;
    });
    final repo = ref.read(academicRepositoryProvider);
    final attendanceRepo = ref.read(attendanceRepositoryProvider);

    final students = await repo.getStudentsBySection(session.sectionId);
    final records = await attendanceRepo.getAttendanceRecords(session.id);

    setState(() {
      _roster = students;
      _records = records;

      _attendanceMap.clear();
      // Initialize map
      for (var student in _roster) {
        final rec = _records.firstWhere((r) => r.studentId == student.id,
            orElse: () => AttendanceRecord(id: '', sessionId: '', studentId: '', status: 'present'));
        _attendanceMap[student.id] = rec.status;
      }
      _isLoadingRoster = false;
    });
  }

  Future<void> _updateAttendance() async {
    if (_selectedSession == null) return;
    setState(() => _isLoadingRoster = true);

    final List<AttendanceRecord> updatedRecords = [];
    _attendanceMap.forEach((studentId, status) {
      final existing = _records.firstWhere(
        (r) => r.studentId == studentId,
        orElse: () => AttendanceRecord(id: '', sessionId: '', studentId: '', status: ''),
      );

      updatedRecords.add(
        AttendanceRecord(
          id: existing.id.isNotEmpty ? existing.id : 'rec_${DateTime.now().millisecondsSinceEpoch}_$studentId',
          sessionId: _selectedSession!.id,
          studentId: studentId,
          status: status,
        ),
      );
    });

    final attendanceRepo = ref.read(attendanceRepositoryProvider);
    await attendanceRepo.updateAttendanceRecords(updatedRecords);

    setState(() {
      _selectedSession = null;
      _roster.clear();
      _records.clear();
      _attendanceMap.clear();
      _isLoadingRoster = false;
    });

    await _loadSessions();

    if (mounted) {
      AppSnackBar.success(context, 'Attendance records updated successfully!');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > AppBreakpoints.desktop;

    if (_isLoading) {
      return const ResponsiveScaffold(
        title: 'Edit Attendance',
        currentPath: '/faculty/edit-attendance',
        body: Padding(
          padding: EdgeInsets.all(AppSpacing.lg),
          child: Column(
            children: [
              SkeletonListItem(hasTrailing: true),
              SkeletonListItem(hasTrailing: true),
              SkeletonListItem(hasTrailing: true),
              SkeletonListItem(hasTrailing: true),
            ],
          ),
        ),
      );
    }

    return ResponsiveScaffold(
      title: isDesktop ? 'Edit Attendance' : (_selectedSession == null ? 'Edit Past Sessions' : 'Update Attendance'),
      currentPath: '/faculty/edit-attendance',
      leading: (!isDesktop && _selectedSession != null)
          ? IconButton(
              icon: const Icon(Icons.arrow_back_rounded),
              tooltip: 'Back',
              onPressed: () => setState(() => _selectedSession = null),
            )
          : null,
      body: isDesktop
          ? _buildDesktopLayout()
          : (_selectedSession == null ? _buildSessionsList() : _buildRosterEditor()),
    );
  }

  Widget _buildSessionsList() {
    if (_sessions.isEmpty) {
      return const EmptyState(
        icon: Icons.history_toggle_off_rounded,
        title: 'No prior sessions',
        message: 'Attendance sessions you conduct will show up here for editing.',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(AppSpacing.lg),
      itemCount: _sessions.length,
      itemBuilder: (context, idx) {
        final session = _sessions[idx];
        final sub = _subjects.firstWhere((s) => s.id == session.subjectId, orElse: () => Subject(id: '', code: 'UNK', name: 'Unknown Subject'));
        final sec = _sections.firstWhere((s) => s.id == session.sectionId, orElse: () => Section(id: '', semesterId: '', name: 'Unknown Section'));
        final sem = _semesters.firstWhere((s) => s.id == sec.semesterId, orElse: () => Semester(id: '', branchId: '', semesterNumber: 0));
        final b = _branches.firstWhere((br) => br.id == sem.branchId, orElse: () => Branch(id: '', courseId: '', name: 'Unknown'));

        final formattedDate = DateFormat('MMM dd, yyyy').format(session.date);

        return Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.md),
          child: EntityListTile(
            leadingIcon: Icons.history_rounded,
            title: '${b.name} - Sem ${sem.semesterNumber} (${sec.name})',
            subtitle: '${sub.name} · $formattedDate · ${session.startTime}-${session.endTime}',
            trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
            onTap: () => _loadRoster(session),
          ),
        ).animate().fadeIn(delay: (idx * 20).ms, duration: AppMotion.entrance);
      },
    );
  }

  Widget _buildRosterEditor() {
    final theme = Theme.of(context);
    final absenteesCount = _attendanceMap.values.where((v) => v == 'absent').length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          color: theme.colorScheme.primary.withValues(alpha: 0.08),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl, vertical: AppSpacing.lg),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total Students: ${_roster.length}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                'Absentees: $absenteesCount',
                style: TextStyle(color: theme.appColors.danger, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        Expanded(
          child: _isLoadingRoster
              ? ListView.builder(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  itemCount: 6,
                  itemBuilder: (_, _) => const Padding(
                    padding: EdgeInsets.only(bottom: AppSpacing.sm),
                    child: SkeletonListItem(hasTrailing: true),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  itemCount: _roster.length,
                  itemBuilder: (context, idx) {
                    final student = _roster[idx];
                    final status = _attendanceMap[student.id] ?? 'present';
                    return StudentAttendanceTile(
                      name: student.name,
                      rollNumber: student.rollNumber,
                      isPresent: status == 'present',
                      onChanged: (value) => setState(
                          () => _attendanceMap[student.id] = value ? 'present' : 'absent'),
                    ).animate().fadeIn(delay: (idx * 15).ms, duration: AppMotion.entrance);
                  },
                ),
        ),
        Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: ElevatedButton(
            onPressed: _updateAttendance,
            child: const Text('Save Changes'),
          ),
        ),
      ],
    );
  }

  Widget _buildDesktopLayout() {
    final theme = Theme.of(context);
    final absenteesCount = _attendanceMap.values.where((v) => v == 'absent').length;

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.xl),
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
                      'Edit Attendance Console',
                      style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'Select a past session on the left to modify its student records.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton.filledTonal(
                onPressed: _loadSessions,
                icon: const Icon(Icons.refresh),
                tooltip: 'Refresh Sessions',
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          Expanded(
            child: ResponsiveTwoPane(
              left: _buildSessionsListCard(theme),
              right: _buildDetailPanelCard(theme, absenteesCount),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSessionsListCard(ThemeData theme) {
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
            Text(
              'Past Attendance Sessions (${_sessions.length})',
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: AppSpacing.md),
            Expanded(
              child: _sessions.isEmpty
                  ? const EmptyState(
                      icon: Icons.history_toggle_off_rounded,
                      title: 'No prior sessions',
                      message: 'Sessions you conduct will show up here.',
                    )
                  : ListView.builder(
                      itemCount: _sessions.length,
                      itemBuilder: (context, idx) {
                        final session = _sessions[idx];
                        final sub = _subjects.firstWhere((s) => s.id == session.subjectId, orElse: () => Subject(id: '', code: 'UNK', name: 'Unknown Subject'));
                        final sec = _sections.firstWhere((s) => s.id == session.sectionId, orElse: () => Section(id: '', semesterId: '', name: 'Unknown Section'));
                        final sem = _semesters.firstWhere((s) => s.id == sec.semesterId, orElse: () => Semester(id: '', branchId: '', semesterNumber: 0));
                        final b = _branches.firstWhere((br) => br.id == sem.branchId, orElse: () => Branch(id: '', courseId: '', name: 'Unknown'));

                        final formattedDate = DateFormat('MMM dd, yyyy').format(session.date);
                        final isSelected = _selectedSession?.id == session.id;

                        return Padding(
                          padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                          child: EntityListTile(
                            selected: isSelected,
                            title: '${b.name} - Sem ${sem.semesterNumber} (${sec.name})',
                            subtitle: '${sub.name} · $formattedDate',
                            leadingIcon: Icons.history_rounded,
                            onTap: () => _loadRoster(session),
                          ),
                        ).animate().fadeIn(delay: (idx * 20).ms, duration: AppMotion.entrance);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailPanelCard(ThemeData theme, int absenteesCount) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.card),
        side: BorderSide(color: theme.dividerColor.withValues(alpha: 0.15)),
      ),
      child: _selectedSession == null
          ? const EmptyState(
              icon: Icons.fact_check_outlined,
              title: 'No session selected',
              message: 'Select a past session from the list to edit its records.',
            )
          : Padding(
              padding: const EdgeInsets.all(AppSpacing.xl - AppSpacing.xs),
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
                              'Session Details',
                              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Session ID: ${_selectedSession!.id}',
                              style: TextStyle(fontSize: 11, color: theme.colorScheme.onSurfaceVariant),
                            ),
                          ],
                        ),
                      ),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.appColors.success,
                          foregroundColor: Colors.white,
                          minimumSize: const Size(120, 44),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.control)),
                        ),
                        onPressed: _updateAttendance,
                        icon: const Icon(Icons.check_rounded, size: 18),
                        label: const Text('Save Changes'),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Row(
                    children: [
                      Expanded(
                        child: StatCard(
                          icon: Icons.people_outline_rounded,
                          label: 'Absentees',
                          value: '$absenteesCount',
                          color: theme.appColors.danger,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: StatCard(
                          icon: Icons.edit_note_rounded,
                          label: 'Status',
                          value: 'Editable',
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  const Divider(),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    'Student Records Checklist',
                    style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Expanded(
                    child: _isLoadingRoster
                        ? ListView.builder(
                            itemCount: 6,
                            itemBuilder: (_, _) => const Padding(
                              padding: EdgeInsets.only(bottom: AppSpacing.sm),
                              child: SkeletonListItem(hasTrailing: true),
                            ),
                          )
                        : ListView.builder(
                            itemCount: _roster.length,
                            itemBuilder: (context, idx) {
                              final student = _roster[idx];
                              final status = _attendanceMap[student.id] ?? 'present';
                              return StudentAttendanceTile(
                                name: student.name,
                                rollNumber: student.rollNumber,
                                isPresent: status == 'present',
                                onChanged: (value) => setState(() =>
                                    _attendanceMap[student.id] = value ? 'present' : 'absent'),
                              ).animate().fadeIn(delay: (idx * 15).ms, duration: AppMotion.entrance);
                            },
                          ),
                  ),
                ],
              ),
            ),
    );
  }
}
