import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../auth/auth_provider.dart';
import '../../data/models/models.dart';
import '../../data/services/providers.dart';
import '../../core/widgets/responsive_scaffold.dart';
import '../../core/widgets/skeleton_loaders.dart';
import '../../core/widgets/stat_card.dart';
import '../../core/widgets/entity_list_tile.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/responsive_two_pane.dart';
import '../../core/theme/app_tokens.dart';

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
      final facultyId = user?.associatedId ?? '';
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
      final facultyId2 = user?.associatedId ?? '';
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
    final isDesktop = MediaQuery.of(context).size.width > AppBreakpoints.desktop;

    if (_isLoading) {
      return const ResponsiveScaffold(
        title: 'Faculty Portal',
        currentPath: '/faculty',
        body: SkeletonDashboard(),
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
              const SizedBox(height: AppSpacing.lg),
              Text('Failed to load dashboard data', style: theme.textTheme.titleMedium),
              const SizedBox(height: AppSpacing.sm),
              ElevatedButton(onPressed: _load, child: const Text('Retry')),
            ],
          ),
        ),
      );
    }

    return ResponsiveScaffold(
      title: 'Faculty Portal',
      currentPath: '/faculty',
      body: RefreshIndicator(
        onRefresh: _load,
        child: isDesktop
            ? _buildDesktopLayout(context, theme, user)
            : _buildMobileLayout(context, theme, user),
      ),
    );
  }

  Widget _buildMobileLayout(BuildContext context, ThemeData theme, dynamic user) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(theme, user),
          const SizedBox(height: AppSpacing.xl),
          Row(
            children: [
              Expanded(
                  child: StatCard(
                      icon: Icons.class_rounded,
                      label: 'Assigned Classes',
                      value: '${_assignments.length}')),
              const SizedBox(width: AppSpacing.lg),
              Expanded(
                  child: StatCard(
                      icon: Icons.event_available_rounded,
                      label: 'Lectures Conducted',
                      value: '${_sessionsConducted.length}')),
            ],
          ).animate().fadeIn(duration: AppMotion.entrance).slideY(begin: 0.08, curve: Curves.easeOut),
          const SizedBox(height: AppSpacing.xxl - AppSpacing.xs),
          _buildQuickActions(context, theme, stretchWidth: false),
          const SizedBox(height: AppSpacing.xxl),
          _buildAssignmentsSection(theme, staggerFrom: 0),
        ],
      ),
    );
  }

  Widget _buildDesktopLayout(BuildContext context, ThemeData theme, dynamic user) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(theme, user),
          const SizedBox(height: AppSpacing.xl),
          ResponsiveTwoPane.flex(
            left: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                        child: StatCard(
                            icon: Icons.class_rounded,
                            label: 'Assigned Classes',
                            value: '${_assignments.length}')),
                    const SizedBox(width: AppSpacing.lg),
                    Expanded(
                        child: StatCard(
                            icon: Icons.event_available_rounded,
                            label: 'Lectures Conducted',
                            value: '${_sessionsConducted.length}')),
                  ],
                ).animate().fadeIn(duration: AppMotion.entrance).slideY(begin: 0.08, curve: Curves.easeOut),
                const SizedBox(height: AppSpacing.xxl - AppSpacing.xs),
                _buildAssignmentsSection(theme, staggerFrom: 1),
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
                child: _buildQuickActions(context, theme, stretchWidth: true),
              ),
            ).animate().fadeIn(delay: 200.ms, duration: AppMotion.entrance),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(ThemeData theme, dynamic user) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Welcome, ${user?.name ?? "Faculty Member"}',
          style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        Text(
          'Mark lecture attendance, view histories, and extract reports.',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    ).animate().fadeIn(duration: AppMotion.entrance);
  }

  Widget _buildQuickActions(BuildContext context, ThemeData theme, {required bool stretchWidth}) {
    final markButton = ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        minimumSize: const Size.fromHeight(60),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.card)),
      ),
      onPressed: () => context.go('/faculty/mark-attendance'),
      icon: const Icon(Icons.add_task_rounded),
      label: const Text('Mark Attendance'),
    );
    final editButton = OutlinedButton.icon(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size.fromHeight(60),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.card)),
      ),
      onPressed: () => context.go('/faculty/edit-attendance'),
      icon: const Icon(Icons.edit_note_rounded),
      label: Text(stretchWidth ? 'Edit Past Sessions' : 'Edit Sessions'),
    );

    if (stretchWidth) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Quick Actions',
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: AppSpacing.lg),
          markButton,
          const SizedBox(height: AppSpacing.md),
          editButton,
        ],
      );
    }
    return Row(
      children: [
        Expanded(child: markButton),
        const SizedBox(width: AppSpacing.lg),
        Expanded(child: editButton),
      ],
    );
  }

  Widget _buildAssignmentsSection(ThemeData theme, {required int staggerFrom}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('My Assigned Classes & Subjects',
            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: AppSpacing.md),
        if (_assignments.isEmpty)
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.card),
              side: BorderSide(color: theme.dividerColor.withValues(alpha: 0.15)),
            ),
            child: const EmptyState(
              icon: Icons.class_outlined,
              title: 'No classes assigned yet',
              message: 'Once an admin assigns you to a class/subject mapping, it will show up here.',
            ),
          )
        else
          ...List.generate(_assignments.length, (idx) {
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

            return Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              child: EntityListTile(
                leadingIcon: Icons.school_rounded,
                title: '${b.name} - Sem ${sem.semesterNumber} (${sec.name})',
                subtitle: '[${sub.code}] ${sub.name}',
              ),
            ).animate().fadeIn(
                delay: ((staggerFrom + idx) * AppMotion.stagger.inMilliseconds).ms,
                duration: AppMotion.entrance).slideY(begin: 0.06, curve: Curves.easeOut);
          }),
      ],
    );
  }
}
