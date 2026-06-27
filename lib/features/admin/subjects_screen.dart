import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/models.dart';
import '../../data/services/providers.dart';
import '../../core/widgets/responsive_scaffold.dart';

class SubjectsScreen extends ConsumerStatefulWidget {
  const SubjectsScreen({super.key});

  @override
  ConsumerState<SubjectsScreen> createState() => _SubjectsScreenState();
}

class _SubjectsScreenState extends ConsumerState<SubjectsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _formKey = GlobalKey<FormState>();

  List<Subject> _subjects = [];
  List<SubjectMapping> _mappings = [];
  List<Section> _sections = [];
  List<Semester> _semesters = [];
  List<Branch> _branches = [];
  bool _isLoading = true;

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
    setState(() => _isLoading = true);
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
  }

  void _addSubjectDialog() {
    final codeController = TextEditingController();
    final nameController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Subject'),
        content: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: codeController,
                decoration: const InputDecoration(labelText: 'Subject Code (e.g. CS601)'),
                validator: (v) => v == null || v.isEmpty ? 'Enter subject code' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Subject Name (e.g. DBMS)'),
                validator: (v) => v == null || v.isEmpty ? 'Enter subject name' : null,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              if (_formKey.currentState!.validate()) {
                final newSub = Subject(
                  id: 'sub_${DateTime.now().millisecondsSinceEpoch}',
                  code: codeController.text.toUpperCase().trim(),
                  name: nameController.text.trim(),
                );
                await ref.read(academicRepositoryProvider).addSubject(newSub);
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

  void _addMappingDialog() {
    String? selectedSectionId = _sections.isNotEmpty ? _sections.first.id : null;
    String? selectedSubjectId = _subjects.isNotEmpty ? _subjects.first.id : null;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) => AlertDialog(
          title: const Text('Map Subject to Class'),
          content: Form(
            key: _formKey,
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
                const SizedBox(height: 16),
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
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () async {
                if (_formKey.currentState!.validate() && selectedSectionId != null && selectedSubjectId != null) {
                  // Check if already mapped
                  final exists = _mappings.any((m) => m.sectionId == selectedSectionId && m.subjectId == selectedSubjectId);
                  if (exists) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('This mapping already exists!'), backgroundColor: Color(0xFFEF4444)),
                    );
                    return;
                  }

                  final newMap = SubjectMapping(
                    id: 'map_${DateTime.now().millisecondsSinceEpoch}',
                    sectionId: selectedSectionId!,
                    subjectId: selectedSubjectId!,
                  );
                  await ref.read(academicRepositoryProvider).addSubjectMapping(newMap);
                  Navigator.pop(context);
                  _loadData();
                }
              },
              child: const Text('Map'),
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
        title: 'Subjects Catalog',
        currentPath: '/admin/subjects',
        body: const Center(child: CircularProgressIndicator()),
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
                // Catalog Tab
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'All Subjects (${_subjects.length})',
                      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(120, 44),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      onPressed: _addSubjectDialog,
                      icon: const Icon(Icons.add, size: 18),
                      label: const Text('Add Subject'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: _subjects.isEmpty
                      ? Center(
                          child: Text(
                            'No subjects found. Add a subject first.',
                            style: TextStyle(color: theme.colorScheme.onSurface.withValues(alpha: 0.5)),
                          ),
                        )
                      : ListView.builder(
                          itemCount: _subjects.length,
                          itemBuilder: (context, idx) {
                            final sub = _subjects[idx];
                            return Card(
                              margin: const EdgeInsets.only(bottom: 12),
                              child: ListTile(
                                title: Text(
                                  sub.name,
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                                subtitle: Text(sub.code),
                                trailing: IconButton(
                                  icon: Icon(Icons.delete_outline_rounded, color: theme.colorScheme.error),
                                  onPressed: () async {
                                    await ref.read(academicRepositoryProvider).deleteSubject(sub.id);
                                    _loadData();
                                  },
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
          // Mappings Tab
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Class Mappings (${_mappings.length})',
                      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(120, 44),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      onPressed: _addMappingDialog,
                      icon: const Icon(Icons.link, size: 18),
                      label: const Text('Create Mapping'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: _mappings.isEmpty
                      ? Center(
                          child: Text(
                            'No subject mappings configured.',
                            style: TextStyle(color: theme.colorScheme.onSurface.withValues(alpha: 0.5)),
                          ),
                        )
                      : ListView.builder(
                          itemCount: _mappings.length,
                          itemBuilder: (context, idx) {
                            final map = _mappings[idx];
                            final sub = _subjects.firstWhere((s) => s.id == map.subjectId, orElse: () => Subject(id: '', code: 'UNK', name: 'Unknown Subject'));
                            final sec = _sections.firstWhere((se) => se.id == map.sectionId, orElse: () => Section(id: '', semesterId: '', name: 'Unknown Section'));
                            final sem = _semesters.firstWhere((s) => s.id == sec.semesterId, orElse: () => Semester(id: '', branchId: '', semesterNumber: 0));
                            final b = _branches.firstWhere((br) => br.id == sem.branchId, orElse: () => Branch(id: '', courseId: '', name: 'Unknown'));

                            return Card(
                              margin: const EdgeInsets.only(bottom: 12),
                              child: ListTile(
                                title: Text(
                                  '${b.name} - Sem ${sem.semesterNumber} (${sec.name})',
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                                subtitle: Text('${sub.code}: ${sub.name}'),
                                trailing: IconButton(
                                  icon: Icon(Icons.delete_outline_rounded, color: theme.colorScheme.error),
                                  onPressed: () async {
                                    await ref.read(academicRepositoryProvider).deleteSubjectMapping(map.id);
                                    _loadData();
                                  },
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
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
                      'Subjects & Mappings Console',
                      style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Manage your subjects library and map them to class sections.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
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
            child: LayoutBuilder(
              builder: (context, constraints) {
                final catalogCard = Card(
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
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Subjects Catalog (${_subjects.length})',
                              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            IconButton.filledTonal(
                              onPressed: _addSubjectDialog,
                              icon: const Icon(Icons.add, size: 18),
                              tooltip: 'Add Subject',
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Expanded(
                          child: _subjects.isEmpty
                              ? Center(
                                  child: Text(
                                    'No subjects added yet.',
                                    style: TextStyle(color: theme.colorScheme.onSurface.withValues(alpha: 0.5)),
                                  ),
                                )
                              : ListView.builder(
                                  itemCount: _subjects.length,
                                  itemBuilder: (context, idx) {
                                    final sub = _subjects[idx];
                                    return Container(
                                      margin: const EdgeInsets.only(bottom: 8),
                                      child: Material(
                                        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        clipBehavior: Clip.antiAlias,
                                        child: ListTile(
                                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                                          title: Text(
                                            sub.name,
                                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                          ),
                                          subtitle: Text(
                                            sub.code,
                                            style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurface.withValues(alpha: 0.6)),
                                          ),
                                          trailing: IconButton(
                                            icon: Icon(Icons.delete_outline_rounded, color: theme.colorScheme.error, size: 20),
                                            onPressed: () async {
                                              await ref.read(academicRepositoryProvider).deleteSubject(sub.id);
                                              _loadData();
                                            },
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

                final mappingsCard = Card(
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
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Class Mappings (${_mappings.length})',
                              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            IconButton.filledTonal(
                              onPressed: _addMappingDialog,
                              icon: const Icon(Icons.link, size: 18),
                              tooltip: 'Create Mapping',
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Expanded(
                          child: _mappings.isEmpty
                              ? Center(
                                  child: Text(
                                    'No mappings registered yet.',
                                    style: TextStyle(color: theme.colorScheme.onSurface.withValues(alpha: 0.5)),
                                  ),
                                )
                              : ListView.builder(
                                  itemCount: _mappings.length,
                                  itemBuilder: (context, idx) {
                                    final map = _mappings[idx];
                                    final sub = _subjects.firstWhere((s) => s.id == map.subjectId, orElse: () => Subject(id: '', code: 'UNK', name: 'Unknown Subject'));
                                    final sec = _sections.firstWhere((se) => se.id == map.sectionId, orElse: () => Section(id: '', semesterId: '', name: 'Unknown Section'));
                                    final sem = _semesters.firstWhere((s) => s.id == sec.semesterId, orElse: () => Semester(id: '', branchId: '', semesterNumber: 0));
                                    final b = _branches.firstWhere((br) => br.id == sem.branchId, orElse: () => Branch(id: '', courseId: '', name: 'Unknown'));

                                    return Container(
                                      margin: const EdgeInsets.only(bottom: 8),
                                      child: Material(
                                        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        clipBehavior: Clip.antiAlias,
                                        child: ListTile(
                                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                                          title: Text(
                                            '${b.name} - Sem ${sem.semesterNumber} (${sec.name})',
                                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                          ),
                                          subtitle: Text(
                                            '${sub.code}: ${sub.name}',
                                            style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurface.withValues(alpha: 0.6)),
                                          ),
                                          trailing: IconButton(
                                            icon: Icon(Icons.delete_outline_rounded, color: theme.colorScheme.error, size: 20),
                                            onPressed: () async {
                                              await ref.read(academicRepositoryProvider).deleteSubjectMapping(map.id);
                                              _loadData();
                                            },
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

                if (constraints.maxWidth < 1100) {
                  return SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        SizedBox(
                          height: 400,
                          child: catalogCard,
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          height: 400,
                          child: mappingsCard,
                        ),
                      ],
                    ),
                  );
                } else {
                  return Row(
                    children: [
                      Expanded(
                        child: catalogCard,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: mappingsCard,
                      ),
                    ],
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}

