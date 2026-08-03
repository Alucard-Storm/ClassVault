import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../auth/auth_provider.dart';
import '../../data/models/models.dart';
import '../../data/services/providers.dart';
import '../../core/widgets/responsive_scaffold.dart';

class FacultyDashboard extends ConsumerStatefulWidget {
  const FacultyDashboard({super.key});

  @override
  ConsumerState<FacultyDashboard> createState() => _FacultyDashboardState();
}

class _FacultyDashboardState extends ConsumerState<FacultyDashboard> {
  List<FacultyAssignment> _assignments = [];
  List<SubjectMapping> _mappings = [];
  List<Subject> _subjects = [];
  List<Section> _sections = [];
  List<Semester> _semesters = [];
  List<Branch> _branches = [];
  List<AttendanceSession> _sessionsConducted = [];
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
      final facultyId = user?.associatedId ?? 'fac_1';
      final academicRepo = ref.read(academicRepositoryProvider);
      final attendanceRepo = ref.read(attendanceRepositoryProvider);

      final results = await Future.wait([
        academicRepo.getFacultyAssignments(),
        academicRepo.getSubjectMappings(),
        academicRepo.getSubjects(),
        academicRepo.getSections(),
        academicRepo.getSemesters(),
        academicRepo.getBranches(),
        attendanceRepo.getSessionsByFaculty(facultyId),
      ]);

      final allAssignments = results[0] as List<FacultyAssignment>;
      final facultyId2 = user?.associatedId ?? 'fac_1';
      setState(() {
        _assignments = allAssignments.where((a) => a.facultyId == facultyId2).toList();
        _mappings = results[1] as List<SubjectMapping>;
        _subjects = results[2] as List<Subject>;
        _sections = results[3] as List<Section>;
        _semesters = results[4] as List<Semester>;
        _branches = results[5] as List<Branch>;
        _sessionsConducted = results[6] as List<AttendanceSession>;
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
    final isDesktop = MediaQuery.of(context).size.width > 960;

    if (_isLoading) {
      return const ResponsiveScaffold(
        title: 'Faculty Portal',
        currentPath: '/faculty',
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null) {
      return ResponsiveScaffold(
        title: 'Faculty Portal',
        currentPath: '/faculty',
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline_rounded, size: 64, color: theme.colorScheme.error),
              const SizedBox(height: 16),
              Text('Failed to load dashboard data', style: theme.textTheme.titleMedium),
              const SizedBox(height: 8),
              ElevatedButton(onPressed: _load, child: const Text('Retry')),
            ],
          ),
        ),
      );
    }

    if (isDesktop) {
      return ResponsiveScaffold(
        title: 'Faculty Portal',
        currentPath: '/faculty',
        body: _buildDesktopLayout(context, user),
      );
    }

    return ResponsiveScaffold(
      title: 'Faculty Portal',
      currentPath: '/faculty',
      body: RefreshIndicator(
        onRefresh: _load,
        child: _buildMobileLayout(context, theme, user),
      ),
    );
  }

  Widget _buildMobileLayout(BuildContext context, ThemeData theme, dynamic user) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Welcome, ${user?.name ?? "Faculty Member"}',
            style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          Text(
            'Mark lecture attendance, view histories, and extract reports.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(child: _buildMetricCard(theme, 'Assigned Classes', '${_assignments.length}')),
              const SizedBox(width: 16),
              Expanded(
                  child: _buildMetricCard(
                      theme, 'Lectures Conducted', '${_sessionsConducted.length}')),
            ],
          ),
          const SizedBox(height: 28),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(60),
                    backgroundColor: theme.colorScheme.primary,
                  ),
                  onPressed: () => context.go('/faculty/mark-attendance'),
                  icon: const Icon(Icons.add_task_rounded),
                  label: const Text('Mark Attendance'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(60),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () => context.go('/faculty/edit-attendance'),
                  icon: const Icon(Icons.edit_note_rounded),
                  label: const Text('Edit Sessions'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          Text('My Assigned Classes & Subjects',
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          if (_assignments.isEmpty)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Center(
                  child: Text(
                    'No classes assigned to you.',
                    style: TextStyle(color: theme.colorScheme.onSurface.withValues(alpha: 0.5)),
                  ),
                ),
              ),
            )
          else
            ...List.generate(_assignments.length, (idx) => _buildAssignmentCard(theme, idx)),
        ],
      ),
    );
  }

  Widget _buildDesktopLayout(BuildContext context, dynamic user) {
    final theme = Theme.of(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Welcome, ${user?.name ?? "Faculty Member"}',
            style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          Text(
            'Mark lecture attendance, view histories, and extract reports.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 24),
          LayoutBuilder(
            builder: (context, constraints) {
              final leftColumn = Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                          child: _buildMetricCard(theme, 'Assigned Classes', '${_assignments.length}',
                              elevated: true)),
                      const SizedBox(width: 16),
                      Expanded(
                          child: _buildMetricCard(
                              theme, 'Lectures Conducted', '${_sessionsConducted.length}',
                              elevated: true)),
                    ],
                  ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.15, end: 0),
                  const SizedBox(height: 28),
                  Text('My Assigned Classes & Subjects',
                      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  if (_assignments.isEmpty)
                    Card(
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(color: theme.dividerColor.withValues(alpha: 0.15)),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Center(
                          child: Text(
                            'No classes assigned to you.',
                            style: TextStyle(
                                color: theme.colorScheme.onSurface.withValues(alpha: 0.5)),
                          ),
                        ),
                      ),
                    )
                  else
                    ...List.generate(
                      _assignments.length,
                      (idx) => _buildAssignmentCard(theme, idx, elevated: true)
                          .animate()
                          .fadeIn(delay: (200 + idx * 80).ms, duration: 400.ms)
                          .slideY(begin: 0.1, end: 0),
                    ),
                ],
              );

              final rightColumn = Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: theme.dividerColor.withValues(alpha: 0.15)),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text('Quick Actions',
                          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size.fromHeight(60),
                          backgroundColor: theme.colorScheme.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: () => context.go('/faculty/mark-attendance'),
                        icon: const Icon(Icons.add_task_rounded),
                        label: const Text('Mark Attendance'),
                      ),
                      const SizedBox(height: 12),
                      OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size.fromHeight(60),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: () => context.go('/faculty/edit-attendance'),
                        icon: const Icon(Icons.edit_note_rounded),
                        label: const Text('Edit Past Sessions'),
                      ),
                    ],
                  ),
                ),
              ).animate().fadeIn(delay: 350.ms, duration: 500.ms);

              if (constraints.maxWidth < 1100) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    leftColumn,
                    const SizedBox(height: 24),
                    rightColumn,
                  ],
                );
              }
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 3, child: leftColumn),
                  const SizedBox(width: 24),
                  Expanded(flex: 2, child: rightColumn),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard(ThemeData theme, String label, String value, {bool elevated = false}) {
    return Card(
      elevation: 0,
      shape: elevated
          ? RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: theme.dividerColor.withValues(alpha: 0.15)),
            )
          : null,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: theme.textTheme.bodySmall
                    ?.copyWith(color: theme.colorScheme.onSurface.withValues(alpha: 0.5))),
            const SizedBox(height: 4),
            Text(value,
                style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildAssignmentCard(ThemeData theme, int idx, {bool elevated = false}) {
    final fa = _assignments[idx];
    final map = _mappings.firstWhere((m) => m.id == fa.subjectMappingId,
        orElse: () => SubjectMapping(id: '', sectionId: '', subjectId: ''));
    final sub = _subjects.firstWhere((s) => s.id == map.subjectId,
        orElse: () => Subject(id: '', code: 'UNK', name: 'Unknown Subject'));
    final sec = _sections.firstWhere((s) => s.id == map.sectionId,
        orElse: () => Section(id: '', semesterId: '', name: 'Unknown Section'));
    final sem = _semesters.firstWhere((s) => s.id == sec.semesterId,
        orElse: () => Semester(id: '', branchId: '', semesterNumber: 0));
    final b = _branches.firstWhere((br) => br.id == sem.branchId,
        orElse: () => Branch(id: '', courseId: '', name: 'Unknown'));

    return Card(
      elevation: 0,
      shape: elevated
          ? RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: theme.dividerColor.withValues(alpha: 0.15)),
            )
          : null,
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.1),
          child: Icon(Icons.school_rounded, color: theme.colorScheme.primary),
        ),
        title: Text(
          '${b.name} - Sem ${sem.semesterNumber} (${sec.name})',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text('[${sub.code}] ${sub.name}'),
      ),
    );
  }
}
