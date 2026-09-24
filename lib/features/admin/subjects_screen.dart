import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
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
import '../../core/theme/app_tokens.dart';

class SubjectsScreen extends ConsumerStatefulWidget {
  const SubjectsScreen({super.key});

  @override
  ConsumerState<SubjectsScreen> createState() => _SubjectsScreenState();
}

class _SubjectsScreenState extends ConsumerState<SubjectsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  List<Subject> _subjects = [];
  List<SubjectMapping> _mappings = [];
  List<Section> _sections = [];
  List<Semester> _semesters = [];
  List<Branch> _branches = [];
  bool _isLoading = true;
  Object? _error;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
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
      final subjects = await repo.getSubjects();
      final mappings = await repo.getSubjectMappings();
      final sections = await repo.getSections();
      final semesters = await repo.getSemesters();
      final branches = await repo.getBranches();

      if (mounted) {
        setState(() {
          _subjects = subjects;
          _mappings = mappings;
          _sections = sections;
          _semesters = semesters;
          _branches = branches;
          _isLoading = false;
        });
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

  void _addSubjectDialog() {
    final formKey = GlobalKey<FormState>();
    final codeController = TextEditingController();
    final nameController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AppFormDialog(
        title: 'Add Subject',
        icon: Icons.menu_book_rounded,
        confirmLabel: 'Add',
        child: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: codeController,
                decoration: const InputDecoration(labelText: 'Subject Code (e.g. CS601)'),
                validator: (v) => v == null || v.isEmpty ? 'Enter subject code' : null,
              ),
              const SizedBox(height: AppSpacing.lg),
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Subject Name (e.g. DBMS)'),
                validator: (v) => v == null || v.isEmpty ? 'Enter subject name' : null,
              ),
            ],
          ),
        ),
        onConfirm: () async {
          if (formKey.currentState!.validate()) {
            final newSub = Subject(
              id: 'sub_${DateTime.now().millisecondsSinceEpoch}',
              code: codeController.text.toUpperCase().trim(),
              name: nameController.text.trim(),
            );
            await ref.read(academicRepositoryProvider).addSubject(newSub);
            if (context.mounted) Navigator.pop(context);
            _loadData();
          }
        },
      ),
    ).whenComplete(() {
      codeController.dispose();
      nameController.dispose();
    });
  }

  void _addMappingDialog() {
    final formKey = GlobalKey<FormState>();
    String? selectedSectionId = _sections.isNotEmpty ? _sections.first.id : null;
    String? selectedSubjectId = _subjects.isNotEmpty ? _subjects.first.id : null;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) => AppFormDialog(
          title: 'Map Subject to Class',
          icon: Icons.link_rounded,
          confirmLabel: 'Map',
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  isExpanded: true,
                  value: selectedSectionId,
                  items: _sections.map((sec) {
                    final sem = _semesters.firstWhere((s) => s.id == sec.semesterId, orElse: () => Semester(id: '', branchId: '', semesterNumber: 0));
                    final b = _branches.firstWhere((br) => br.id == sem.branchId, orElse: () => Branch(id: '', courseId: '', name: 'Unknown'));
                    return DropdownMenuItem(
                      value: sec.id,
                      child: Text('${b.name} - Sem ${sem.semesterNumber} (${sec.name})', overflow: TextOverflow.ellipsis),
                    );
                  }).toList(),
                  onChanged: (val) => setStateDialog(() => selectedSectionId = val),
                  decoration: const InputDecoration(labelText: 'Target Class/Section'),
                  validator: (v) => v == null ? 'Select class/section' : null,
                ),
                const SizedBox(height: AppSpacing.lg),
                DropdownButtonFormField<String>(
                  isExpanded: true,
                  value: selectedSubjectId,
                  items: _subjects
                      .map((sub) => DropdownMenuItem(value: sub.id, child: Text('[${sub.code}] ${sub.name}', overflow: TextOverflow.ellipsis)))
                      .toList(),
                  onChanged: (val) => setStateDialog(() => selectedSubjectId = val),
                  decoration: const InputDecoration(labelText: 'Subject'),
                  validator: (v) => v == null ? 'Select subject' : null,
                ),
              ],
            ),
          ),
          onConfirm: () async {
            if (formKey.currentState!.validate() && selectedSectionId != null && selectedSubjectId != null) {
              // Check if already mapped
              final exists = _mappings.any((m) => m.sectionId == selectedSectionId && m.subjectId == selectedSubjectId);
              if (exists) {
                AppSnackBar.error(context, 'This mapping already exists!');
                return;
              }

              final newMap = SubjectMapping(
                id: 'map_${DateTime.now().millisecondsSinceEpoch}',
                sectionId: selectedSectionId!,
                subjectId: selectedSubjectId!,
              );
              await ref.read(academicRepositoryProvider).addSubjectMapping(newMap);
              if (context.mounted) Navigator.pop(context);
              _loadData();
            }
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > AppBreakpoints.desktop;

    if (_isLoading) {
      return ResponsiveScaffold(
        title: 'Subjects Catalog',
        currentPath: '/admin/subjects',
        body: const Padding(
          padding: EdgeInsets.all(24.0),
          child: Row(children: [
            Expanded(child: SkeletonCard(height: 400)),
            SizedBox(width: 16),
            Expanded(child: SkeletonCard(height: 400)),
          ]),
        ),
      );
    }

    if (_error != null) {
      final theme = Theme.of(context);
      return ResponsiveScaffold(
        title: 'Subjects Catalog',
        currentPath: '/admin/subjects',
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline_rounded, size: 64, color: theme.colorScheme.error),
              const SizedBox(height: AppSpacing.lg),
              Text('Failed to load subjects catalog', style: theme.textTheme.titleMedium),
              const SizedBox(height: AppSpacing.sm),
              ElevatedButton(onPressed: _loadData, child: const Text('Retry')),
            ],
          ),
        ),
      );
    }

    return ResponsiveScaffold(
      title: 'Subjects Catalog',
      currentPath: '/admin/subjects',
      bottom: isDesktop
          ? null
          : TabBar(
              controller: _tabController,
              tabs: const [
                Tab(text: 'Subjects Catalog'),
                Tab(text: 'Class Subject Mappings'),
              ],
            ),
      body: isDesktop
          ? _buildDesktopLayout()
          : TabBarView(
              controller: _tabController,
              children: [
                _buildSubjectsPane(compact: false),
                _buildMappingsPane(compact: false),
              ],
            ),
    );
  }

  Widget _buildDesktopLayout() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ConsoleHeader(
            title: 'Subjects & Mappings Console',
            subtitle: 'Manage your subjects library and map them to class sections.',
            onRefresh: _loadData,
          ).animate().fadeIn(duration: 250.ms).slideY(begin: -0.05, curve: Curves.easeOut),
          const SizedBox(height: AppSpacing.xl),
          Expanded(
            child: ResponsiveTwoPane.flex(
              left: _buildSubjectsPane(compact: true),
              right: _buildMappingsPane(compact: true),
              leftFlex: 1,
              rightFlex: 1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubjectsPane({required bool compact}) {
    final theme = Theme.of(context);
    final list = _subjects.isEmpty
        ? const EmptyState(
            icon: Icons.menu_book_outlined,
            title: 'No subjects yet',
            message: 'Add a subject to build your catalog.',
          )
        : ListView.separated(
            itemCount: _subjects.length,
            separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sm),
            itemBuilder: (context, idx) {
              final sub = _subjects[idx];
              return EntityListTile(
                title: sub.name,
                subtitle: sub.code,
                leadingIcon: Icons.menu_book_rounded,
                trailing: IconButton(
                  icon: Icon(Icons.delete_outline_rounded, color: theme.colorScheme.error, size: 20),
                  tooltip: 'Delete ${sub.name}',
                  onPressed: () async {
                    await ref.read(academicRepositoryProvider).deleteSubject(sub.id);
                    _loadData();
                  },
                ),
              ).animate().fadeIn(duration: 200.ms, delay: (idx * 30).ms);
            },
          );

    final header = Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Subjects Catalog (${_subjects.length})',
          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        compact
            ? IconButton.filledTonal(
                onPressed: _addSubjectDialog,
                icon: const Icon(Icons.add, size: 18),
                tooltip: 'Add Subject',
              )
            : ElevatedButton.icon(
                onPressed: _addSubjectDialog,
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Add Subject'),
              ),
      ],
    );

    if (!compact) {
      return Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [header, const SizedBox(height: AppSpacing.lg), Expanded(child: list)],
        ),
      );
    }

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
          children: [header, const SizedBox(height: AppSpacing.md), Expanded(child: list)],
        ),
      ),
    );
  }

  Widget _buildMappingsPane({required bool compact}) {
    final theme = Theme.of(context);
    final list = _mappings.isEmpty
        ? const EmptyState(
            icon: Icons.link_off_rounded,
            title: 'No mappings yet',
            message: 'Map a subject to a class section to get started.',
          )
        : ListView.separated(
            itemCount: _mappings.length,
            separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sm),
            itemBuilder: (context, idx) {
              final map = _mappings[idx];
              final sub = _subjects.firstWhere((s) => s.id == map.subjectId, orElse: () => Subject(id: '', code: 'UNK', name: 'Unknown Subject'));
              final sec = _sections.firstWhere((se) => se.id == map.sectionId, orElse: () => Section(id: '', semesterId: '', name: 'Unknown Section'));
              final sem = _semesters.firstWhere((s) => s.id == sec.semesterId, orElse: () => Semester(id: '', branchId: '', semesterNumber: 0));
              final b = _branches.firstWhere((br) => br.id == sem.branchId, orElse: () => Branch(id: '', courseId: '', name: 'Unknown'));
              return EntityListTile(
                title: '${b.name} - Sem ${sem.semesterNumber} (${sec.name})',
                subtitle: '${sub.code}: ${sub.name}',
                leadingIcon: Icons.link_rounded,
                trailing: IconButton(
                  icon: Icon(Icons.delete_outline_rounded, color: theme.colorScheme.error, size: 20),
                  tooltip: 'Remove mapping',
                  onPressed: () async {
                    await ref.read(academicRepositoryProvider).deleteSubjectMapping(map.id);
                    _loadData();
                  },
                ),
              ).animate().fadeIn(duration: 200.ms, delay: (idx * 30).ms);
            },
          );

    final header = Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Class Mappings (${_mappings.length})',
          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        compact
            ? IconButton.filledTonal(
                onPressed: _addMappingDialog,
                icon: const Icon(Icons.link, size: 18),
                tooltip: 'Create Mapping',
              )
            : ElevatedButton.icon(
                onPressed: _addMappingDialog,
                icon: const Icon(Icons.link, size: 18),
                label: const Text('Create Mapping'),
              ),
      ],
    );

    if (!compact) {
      return Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [header, const SizedBox(height: AppSpacing.lg), Expanded(child: list)],
        ),
      );
    }

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
          children: [header, const SizedBox(height: AppSpacing.md), Expanded(child: list)],
        ),
      ),
    );
  }
}
