import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../data/models/models.dart';
import '../../data/services/providers.dart';
import '../../core/widgets/responsive_scaffold.dart';
import '../../core/widgets/console_header.dart';
import '../../core/widgets/entity_list_tile.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/app_dialogs.dart';
import '../../core/widgets/app_snackbar.dart';
import '../../core/widgets/skeleton_loaders.dart';
import '../../core/widgets/responsive_two_pane.dart';
import '../../core/theme/app_color_scheme.dart';
import '../../core/theme/app_tokens.dart';

class SemesterPromotionScreen extends ConsumerStatefulWidget {
  const SemesterPromotionScreen({super.key});

  @override
  ConsumerState<SemesterPromotionScreen> createState() => _SemesterPromotionScreenState();
}

class _SemesterPromotionScreenState extends ConsumerState<SemesterPromotionScreen> {
  String? _sourceSectionId;
  String? _destSectionId;

  List<Section> _sections = [];
  List<Semester> _semesters = [];
  List<Branch> _branches = [];
  List<Student> _sourceStudents = [];
  bool _isLoading = true;
  Object? _error;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final repo = ref.read(academicRepositoryProvider);
      final sections = await repo.getSections();
      final semesters = await repo.getSemesters();
      final branches = await repo.getBranches();

      setState(() {
        _sections = sections;
        _semesters = semesters;
        _branches = branches;
        _isLoading = false;
      });

      if (_sections.isNotEmpty) {
        _sourceSectionId = _sections.first.id;
        _loadSourceStudents();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e;
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _loadSourceStudents() async {
    if (_sourceSectionId == null) return;
    setState(() => _isLoading = true);
    final repo = ref.read(academicRepositoryProvider);
    final list = await repo.getStudentsBySection(_sourceSectionId!);
    setState(() {
      _sourceStudents = list;
      _isLoading = false;
    });
  }

  void _promoteBatch() async {
    if (_sourceSectionId == null || _destSectionId == null) {
      AppSnackBar.error(context, 'Please select both source and destination sections!');
      return;
    }

    if (_sourceSectionId == _destSectionId) {
      AppSnackBar.error(context, 'Source and Destination sections cannot be the same!');
      return;
    }

    final confirm = await AppConfirmDialog.show(
      context,
      title: 'Confirm Batch Promotion',
      message: 'Are you sure you want to promote ${_sourceStudents.length} students to the selected destination section?',
      confirmLabel: 'Promote',
      icon: Icons.upgrade_rounded,
    );

    if (confirm) {
      setState(() => _isLoading = true);
      final repo = ref.read(academicRepositoryProvider);
      await repo.promoteStudents(_sourceSectionId!, _destSectionId!);
      if (mounted) {
        AppSnackBar.success(context, 'Batch promotion completed successfully!');
        context.go('/admin');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_isLoading) {
      return ResponsiveScaffold(
        title: 'Semester Promotion',
        currentPath: '/admin/promotion',
        body: const Padding(padding: EdgeInsets.all(24.0), child: SkeletonCard(height: 400)),
      );
    }

    if (_error != null) {
      return ResponsiveScaffold(
        title: 'Semester Promotion',
        currentPath: '/admin/promotion',
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline_rounded, size: 64, color: theme.colorScheme.error),
              const SizedBox(height: AppSpacing.lg),
              Text('Failed to load promotion data', style: theme.textTheme.titleMedium),
              const SizedBox(height: AppSpacing.sm),
              ElevatedButton(onPressed: _loadData, child: const Text('Retry')),
            ],
          ),
        ),
      );
    }

    return ResponsiveScaffold(
      title: 'Semester Promotion',
      currentPath: '/admin/promotion',
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ConsoleHeader(
              title: 'Semester Promotion Console',
              subtitle: 'Promote students in batch from a source semester/section to a destination semester/section.',
            ).animate().fadeIn(duration: 250.ms).slideY(begin: -0.05, curve: Curves.easeOut),
            const SizedBox(height: AppSpacing.xl),
            Expanded(
              child: ResponsiveTwoPane(
                left: _buildSelectorPanel(theme),
                right: _buildRosterPanel(theme),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectorPanel(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.card),
            side: BorderSide(color: theme.dividerColor.withValues(alpha: 0.15)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Select Promotion Path',
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: AppSpacing.lg),
                DropdownButtonFormField<String>(
                  isExpanded: true,
                  value: _sourceSectionId,
                  decoration: const InputDecoration(labelText: 'Source Section (Current Class)'),
                  items: _sections.map((sec) {
                    final sem = _semesters.firstWhere((s) => s.id == sec.semesterId, orElse: () => Semester(id: '', branchId: '', semesterNumber: 0));
                    final b = _branches.firstWhere((br) => br.id == sem.branchId, orElse: () => Branch(id: '', courseId: '', name: 'Unknown'));
                    return DropdownMenuItem(
                      value: sec.id,
                      child: Text('${b.name} - Sem ${sem.semesterNumber} (${sec.name})', overflow: TextOverflow.ellipsis),
                    );
                  }).toList(),
                  onChanged: (val) {
                    setState(() {
                      _sourceSectionId = val;
                    });
                    _loadSourceStudents();
                  },
                ),
                const SizedBox(height: AppSpacing.lg),
                DropdownButtonFormField<String>(
                  isExpanded: true,
                  value: _destSectionId,
                  decoration: const InputDecoration(labelText: 'Destination Section (New Class)'),
                  items: _sections.map((sec) {
                    final sem = _semesters.firstWhere((s) => s.id == sec.semesterId, orElse: () => Semester(id: '', branchId: '', semesterNumber: 0));
                    final b = _branches.firstWhere((br) => br.id == sem.branchId, orElse: () => Branch(id: '', courseId: '', name: 'Unknown'));
                    return DropdownMenuItem(
                      value: sec.id,
                      child: Text('${b.name} - Sem ${sem.semesterNumber} (${sec.name})', overflow: TextOverflow.ellipsis),
                    );
                  }).toList(),
                  onChanged: (val) {
                    setState(() {
                      _destSectionId = val;
                    });
                  },
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        if (_sourceStudents.isNotEmpty)
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.appColors.success,
              foregroundColor: Colors.white,
              minimumSize: const Size.fromHeight(56),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.card)),
            ),
            onPressed: _promoteBatch,
            icon: const Icon(Icons.upgrade_rounded),
            label: const Text('Promote Batch Now'),
          ),
      ],
    );
  }

  Widget _buildRosterPanel(ThemeData theme) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.card),
        side: BorderSide(color: theme.dividerColor.withValues(alpha: 0.15)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Students in Source Section (${_sourceStudents.length})',
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: AppSpacing.lg),
            Expanded(
              child: _sourceStudents.isEmpty
                  ? const EmptyState(
                      icon: Icons.groups_outlined,
                      title: 'No students found',
                      message: 'The selected source section has no students yet.',
                    )
                  : ListView.separated(
                      itemCount: _sourceStudents.length,
                      separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sm),
                      itemBuilder: (context, idx) {
                        final student = _sourceStudents[idx];
                        return EntityListTile(
                          title: student.name,
                          subtitle: 'Roll No: ${student.rollNumber}',
                          leadingText: student.rollNumber,
                        ).animate().fadeIn(duration: 200.ms, delay: (idx * 20).ms);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
