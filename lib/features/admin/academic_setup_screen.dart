import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/models.dart';
import '../../data/services/providers.dart';
import '../../core/widgets/responsive_scaffold.dart';

class AcademicSetupScreen extends ConsumerStatefulWidget {
  const AcademicSetupScreen({super.key});

  @override
  ConsumerState<AcademicSetupScreen> createState() => _AcademicSetupScreenState();
}

class _AcademicSetupScreenState extends ConsumerState<AcademicSetupScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _formKey = GlobalKey<FormState>();

  // Fetch lists
  List<Course> _courses = [];
  List<Branch> _branches = [];
  List<Semester> _semesters = [];
  List<Section> _sections = [];
  bool _isLoading = true;

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
    final courses = await repo.getCourses();
    final branches = await repo.getBranches();
    final semesters = await repo.getSemesters();
    final sections = await repo.getSections();
    if (mounted) {
      setState(() {
        _courses = courses;
        _branches = branches;
        _semesters = semesters;
        _sections = sections;
        _isLoading = false;
      });
    }
  }

  // Course Actions
  void _addCourseDialog() {
    final nameController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Course'),
        content: Form(
          key: _formKey,
          child: TextFormField(
            controller: nameController,
            decoration: const InputDecoration(labelText: 'Course Name'),
            validator: (v) => v == null || v.isEmpty ? 'Enter course name' : null,
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              if (_formKey.currentState!.validate()) {
                final newCourse = Course(
                  id: 'c_${DateTime.now().millisecondsSinceEpoch}',
                  name: nameController.text,
                );
                await ref.read(academicRepositoryProvider).addCourse(newCourse);
                Navigator.pop(context);
                _loadData();
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  // Branch Actions
  void _addBranchDialog() {
    final nameController = TextEditingController();
    String? selectedCourseId = _courses.isNotEmpty ? _courses.first.id : null;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) => AlertDialog(
          title: const Text('Add Branch'),
          content: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  isExpanded: true,
                  value: selectedCourseId,
                  items: _courses
                      .map((c) => DropdownMenuItem(value: c.id, child: Text(c.name)))
                      .toList(),
                  onChanged: (val) => setStateDialog(() => selectedCourseId = val),
                  decoration: const InputDecoration(labelText: 'Parent Course'),
                  validator: (v) => v == null ? 'Select parent course' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Branch Name'),
                  validator: (v) => v == null || v.isEmpty ? 'Enter branch name' : null,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () async {
                if (_formKey.currentState!.validate() && selectedCourseId != null) {
                  final newBranch = Branch(
                    id: 'b_${DateTime.now().millisecondsSinceEpoch}',
                    courseId: selectedCourseId!,
                    name: nameController.text,
                  );
                  await ref.read(academicRepositoryProvider).addBranch(newBranch);
                  Navigator.pop(context);
                  _loadData();
                }
              },
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }

  // Semester Actions
  void _addSemesterDialog() {
    final numberController = TextEditingController();
    String? selectedBranchId = _branches.isNotEmpty ? _branches.first.id : null;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) => AlertDialog(
          title: const Text('Add Semester'),
          content: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  isExpanded: true,
                  value: selectedBranchId,
                  items: _branches
                      .map((b) => DropdownMenuItem(value: b.id, child: Text(b.name)))
                      .toList(),
                  onChanged: (val) => setStateDialog(() => selectedBranchId = val),
                  decoration: const InputDecoration(labelText: 'Parent Branch'),
                  validator: (v) => v == null ? 'Select parent branch' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: numberController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Semester Number'),
                  validator: (v) => v == null || int.tryParse(v) == null ? 'Enter valid number' : null,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () async {
                if (_formKey.currentState!.validate() && selectedBranchId != null) {
                  final newSem = Semester(
                    id: 'sem_${DateTime.now().millisecondsSinceEpoch}',
                    branchId: selectedBranchId!,
                    semesterNumber: int.parse(numberController.text),
                  );
                  await ref.read(academicRepositoryProvider).addSemester(newSem);
                  Navigator.pop(context);
                  _loadData();
                }
              },
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }

  // Section Actions
  void _addSectionDialog() {
    final nameController = TextEditingController();
    String? selectedSemesterId = _semesters.isNotEmpty ? _semesters.first.id : null;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) => AlertDialog(
          title: const Text('Add Section'),
          content: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  isExpanded: true,
                  value: selectedSemesterId,
                  items: _semesters.map((s) {
                    final b = _branches.firstWhere((br) => br.id == s.branchId, orElse: () => Branch(id: '', courseId: '', name: 'Unknown'));
                    return DropdownMenuItem(
                      value: s.id,
                      child: Text('${b.name} - Sem ${s.semesterNumber}'),
                    );
                  }).toList(),
                  onChanged: (val) => setStateDialog(() => selectedSemesterId = val),
                  decoration: const InputDecoration(labelText: 'Parent Semester'),
                  validator: (v) => v == null ? 'Select parent semester' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Section Name (e.g. Section A)'),
                  validator: (v) => v == null || v.isEmpty ? 'Enter section name' : null,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () async {
                if (_formKey.currentState!.validate() && selectedSemesterId != null) {
                  final newSec = Section(
                    id: 'sec_${DateTime.now().millisecondsSinceEpoch}',
                    semesterId: selectedSemesterId!,
                    name: nameController.text,
                  );
                  await ref.read(academicRepositoryProvider).addSection(newSec);
                  Navigator.pop(context);
                  _loadData();
                }
              },
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDesktop = MediaQuery.of(context).size.width > 960;

    if (_isLoading) {
      return ResponsiveScaffold(
        title: 'Academic Setup',
        currentPath: '/admin/academic',
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return ResponsiveScaffold(
      title: 'Academic Setup',
      currentPath: '/admin/academic',
      bottom: isDesktop
          ? null
          : TabBar(
              controller: _tabController,
              tabs: const [
                Tab(text: 'Courses'),
                Tab(text: 'Branches'),
                Tab(text: 'Semesters'),
                Tab(text: 'Sections'),
              ],
            ),
      body: isDesktop
          ? _buildDesktopLayout()
          : TabBarView(
              controller: _tabController,
              children: [
                _buildList(
            items: _courses,
            title: 'Course',
            onAdd: _addCourseDialog,
            onDelete: (id) async {
              await ref.read(academicRepositoryProvider).deleteCourse(id);
              _loadData();
            },
            labelBuilder: (c) => c.name,
          ),
          _buildList(
            items: _branches,
            title: 'Branch',
            onAdd: _addBranchDialog,
            onDelete: (id) async {
              await ref.read(academicRepositoryProvider).deleteBranch(id);
              _loadData();
            },
            labelBuilder: (b) {
              final c = _courses.firstWhere((co) => co.id == b.courseId, orElse: () => Course(id: '', name: 'Unknown'));
              return '${b.name} (${c.name})';
            },
          ),
          _buildList(
            items: _semesters,
            title: 'Semester',
            onAdd: _addSemesterDialog,
            onDelete: (id) async {
              await ref.read(academicRepositoryProvider).deleteSemester(id);
              _loadData();
            },
            labelBuilder: (s) {
              final b = _branches.firstWhere((br) => br.id == s.branchId, orElse: () => Branch(id: '', courseId: '', name: 'Unknown'));
              return '${b.name} - Semester ${s.semesterNumber}';
            },
          ),
          _buildList(
            items: _sections,
            title: 'Section',
            onAdd: _addSectionDialog,
            onDelete: (id) async {
              await ref.read(academicRepositoryProvider).deleteSection(id);
              _loadData();
            },
            labelBuilder: (sec) {
              final s = _semesters.firstWhere((sem) => sem.id == sec.semesterId, orElse: () => Semester(id: '', branchId: '', semesterNumber: 0));
              final b = _branches.firstWhere((br) => br.id == s.branchId, orElse: () => Branch(id: '', courseId: '', name: 'Unknown'));
              return '${b.name} - Sem ${s.semesterNumber} (${sec.name})';
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopLayout() {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(24.0),
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
                      'Academic Setup Console',
                      style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Configure your academic structure: courses, branches, semesters, and sections.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ),
              IconButton.filledTonal(
                onPressed: _loadData,
                icon: const Icon(Icons.refresh),
                tooltip: 'Refresh Data',
              ),
            ],
          ),
          const SizedBox(height: 24),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      Expanded(
                        child: _buildDesktopCardList(
                          items: _courses,
                          title: 'Course',
                          onAdd: _addCourseDialog,
                          onDelete: (id) async {
                            await ref.read(academicRepositoryProvider).deleteCourse(id);
                            _loadData();
                          },
                          labelBuilder: (c) => c.name,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Expanded(
                        child: _buildDesktopCardList(
                          items: _semesters,
                          title: 'Semester',
                          onAdd: _addSemesterDialog,
                          onDelete: (id) async {
                            await ref.read(academicRepositoryProvider).deleteSemester(id);
                            _loadData();
                          },
                          labelBuilder: (s) {
                            final b = _branches.firstWhere((br) => br.id == s.branchId, orElse: () => Branch(id: '', courseId: '', name: 'Unknown'));
                            return '${b.name} - Semester ${s.semesterNumber}';
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    children: [
                      Expanded(
                        child: _buildDesktopCardList(
                          items: _branches,
                          title: 'Branch',
                          onAdd: _addBranchDialog,
                          onDelete: (id) async {
                            await ref.read(academicRepositoryProvider).deleteBranch(id);
                            _loadData();
                          },
                          labelBuilder: (b) {
                            final c = _courses.firstWhere((co) => co.id == b.courseId, orElse: () => Course(id: '', name: 'Unknown'));
                            return '${b.name} (${c.name})';
                          },
                        ),
                      ),
                      const SizedBox(height: 16),
                      Expanded(
                        child: _buildDesktopCardList(
                          items: _sections,
                          title: 'Section',
                          onAdd: _addSectionDialog,
                          onDelete: (id) async {
                            await ref.read(academicRepositoryProvider).deleteSection(id);
                            _loadData();
                          },
                          labelBuilder: (sec) {
                            final s = _semesters.firstWhere((sem) => sem.id == sec.semesterId, orElse: () => Semester(id: '', branchId: '', semesterNumber: 0));
                            final b = _branches.firstWhere((br) => br.id == s.branchId, orElse: () => Branch(id: '', courseId: '', name: 'Unknown'));
                            return '${b.name} - Sem ${s.semesterNumber} (${sec.name})';
                          },
                        ),
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

  Widget _buildDesktopCardList<T>({
    required List<T> items,
    required String title,
    required VoidCallback onAdd,
    required Future<void> Function(String id) onDelete,
    required String Function(T item) labelBuilder,
  }) {
    final theme = Theme.of(context);
    return Card(
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${title}s (${items.length})',
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                IconButton.filledTonal(
                  onPressed: onAdd,
                  icon: const Icon(Icons.add, size: 18),
                  tooltip: 'Add $title',
                ),
              ],
            ),
            const SizedBox(height: 12),
            Expanded(
              child: items.isEmpty
                  ? Center(
                      child: Text(
                        'No ${title}s added yet.',
                        style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.5)),
                      ),
                    )
                  : ListView.builder(
                      itemCount: items.length,
                      itemBuilder: (context, idx) {
                        final item = items[idx];
                        final id = (item as dynamic).id as String;
                        return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: Material(
                            color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            clipBehavior: Clip.antiAlias,
                            child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                            title: Text(
                              labelBuilder(item),
                              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                            ),
                            trailing: IconButton(
                              icon: Icon(Icons.delete_outline_rounded, color: theme.colorScheme.error, size: 20),
                              onPressed: () => onDelete(id),
                            ),
                          ),
                        ),
                      );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildList<T>({
    required List<T> items,
    required String title,
    required VoidCallback onAdd,
    required Future<void> Function(String id) onDelete,
    required String Function(T item) labelBuilder,
  }) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Available ${title}s (${items.length})',
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(120, 44),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: onAdd,
                icon: const Icon(Icons.add, size: 18),
                label: Text('Add $title'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: items.isEmpty
                ? Center(
                    child: Text(
                      'No ${title}s added yet.',
                      style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.5)),
                    ),
                  )
                : ListView.builder(
                    itemCount: items.length,
                    itemBuilder: (context, idx) {
                      final item = items[idx];
                      final id = (item as dynamic).id as String;
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          title: Text(
                            labelBuilder(item),
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          trailing: IconButton(
                            icon: Icon(Icons.delete_outline_rounded, color: theme.colorScheme.error),
                            onPressed: () => onDelete(id),
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
