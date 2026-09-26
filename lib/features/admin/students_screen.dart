import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../data/models/models.dart';
import '../../data/services/providers.dart';
import '../../core/widgets/responsive_scaffold.dart';
import '../../core/widgets/console_header.dart';
import '../../core/widgets/app_data_table.dart';
import '../../core/widgets/app_dialogs.dart';
import '../../core/widgets/app_snackbar.dart';
import '../../core/widgets/skeleton_loaders.dart';
import '../../core/theme/app_tokens.dart';

class StudentsScreen extends ConsumerStatefulWidget {
  const StudentsScreen({super.key});

  @override
  ConsumerState<StudentsScreen> createState() => _StudentsScreenState();
}

class _StudentsScreenState extends ConsumerState<StudentsScreen> {
  List<Student> _students = [];
  List<Section> _sections = [];
  List<Semester> _semesters = [];
  List<Branch> _branches = [];
  String? _selectedSectionFilter;
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
      final students = await repo.getStudents();
      final sections = await repo.getSections();
      final semesters = await repo.getSemesters();
      final branches = await repo.getBranches();

      if (mounted) {
        setState(() {
          _students = students;
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

  void _addStudentDialog() {
    final formKey = GlobalKey<FormState>();
    final rollController = TextEditingController();
    final nameController = TextEditingController();
    String? selectedSectionId = _selectedSectionFilter ?? (_sections.isNotEmpty ? _sections.first.id : null);

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) => AppFormDialog(
          title: 'Add Student Profile',
          icon: Icons.person_add_rounded,
          confirmLabel: 'Add',
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
                  decoration: const InputDecoration(labelText: 'Class Section'),
                  validator: (v) => v == null ? 'Select section' : null,
                ),
                const SizedBox(height: AppSpacing.lg),
                TextFormField(
                  controller: rollController,
                  decoration: const InputDecoration(labelText: 'Roll Number (e.g. 101)'),
                  validator: (v) => v == null || v.isEmpty ? 'Enter Roll Number' : null,
                ),
                const SizedBox(height: AppSpacing.lg),
                TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Student Name'),
                  validator: (v) => v == null || v.isEmpty ? 'Enter Name' : null,
                ),
              ],
            ),
          ),
          onConfirm: () async {
            if (formKey.currentState!.validate() && selectedSectionId != null) {
              // Roll numbers identify students across imports, so they are
              // unique institution-wide, not just within a section.
              final hasDuplicate = _students.any(
                (s) => s.rollNumber.trim() == rollController.text.trim(),
              );
              if (hasDuplicate) {
                AppSnackBar.error(context, 'Roll Number already exists!');
                return;
              }

              final newStudent = Student(
                id: 'stud_${DateTime.now().millisecondsSinceEpoch}',
                rollNumber: rollController.text.trim(),
                name: nameController.text.trim(),
                sectionId: selectedSectionId!,
              );
              try {
                await ref.read(academicRepositoryProvider).addStudent(newStudent);
              } catch (e) {
                if (context.mounted) AppSnackBar.error(context, 'Could not add student: $e');
                return;
              }
              if (context.mounted) Navigator.pop(context);
              _loadData();
            }
          },
        ),
      ),
    ).whenComplete(() {
      rollController.dispose();
      nameController.dispose();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDesktop = MediaQuery.of(context).size.width > AppBreakpoints.desktop;

    if (_isLoading) {
      return ResponsiveScaffold(
        title: 'Student Directory',
        currentPath: '/admin/students',
        body: const Padding(padding: EdgeInsets.all(24.0), child: SkeletonCard(height: 400)),
      );
    }

    if (_error != null) {
      return ResponsiveScaffold(
        title: 'Student Directory',
        currentPath: '/admin/students',
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline_rounded, size: 64, color: theme.colorScheme.error),
              const SizedBox(height: AppSpacing.lg),
              Text('Failed to load student directory', style: theme.textTheme.titleMedium),
              const SizedBox(height: AppSpacing.sm),
              ElevatedButton(onPressed: _loadData, child: const Text('Retry')),
            ],
          ),
        ),
      );
    }

    final filteredStudents = _selectedSectionFilter == null
        ? _students
        : _students.where((s) => s.sectionId == _selectedSectionFilter).toList();

    return ResponsiveScaffold(
      title: 'Student Directory',
      currentPath: '/admin/students',
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ConsoleHeader(
              title: 'Student Directory',
              subtitle: 'Manage student profiles, or import a class roster in bulk.',
              onRefresh: isDesktop ? _loadData : null,
              actionLabel: 'Bulk Import',
              actionIcon: Icons.upload_file_rounded,
              onAction: () => context.go('/admin/students/import'),
            ).animate().fadeIn(duration: 250.ms).slideY(begin: -0.05, curve: Curves.easeOut),
            const SizedBox(height: AppSpacing.xl),
            Card(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                child: DropdownButtonFormField<String>(
                  isExpanded: true,
                  value: _selectedSectionFilter,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: 'Filter by Class Section (Show All)',
                  ),
                  items: [
                    const DropdownMenuItem<String>(
                      value: null,
                      child: Text('All Sections'),
                    ),
                    ..._sections.map((sec) {
                      final sem = _semesters.firstWhere((s) => s.id == sec.semesterId, orElse: () => Semester(id: '', branchId: '', semesterNumber: 0));
                      final b = _branches.firstWhere((br) => br.id == sem.branchId, orElse: () => Branch(id: '', courseId: '', name: 'Unknown'));
                      return DropdownMenuItem(
                        value: sec.id,
                        child: Text('${b.name} - Sem ${sem.semesterNumber} (${sec.name})'),
                      );
                    }),
                  ],
                  onChanged: (val) {
                    setState(() {
                      _selectedSectionFilter = val;
                    });
                  },
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Students (${filteredStudents.length})',
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                ElevatedButton.icon(
                  onPressed: _addStudentDialog,
                  icon: const Icon(Icons.person_add_rounded, size: 18),
                  label: const Text('Add Student'),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            Expanded(
              child: SingleChildScrollView(
                child: AppDataTable(
                  isDesktop: isDesktop,
                  columns: const ['Roll Number', 'Student Name', 'Class Section', ''],
                  columnFlex: const [2, 3, 4, 1],
                  emptyIcon: Icons.face_outlined,
                  emptyTitle: 'No students found',
                  emptyMessage: 'No students registered under the selected filter.',
                  rows: filteredStudents.map((s) {
                    final sec = _sections.firstWhere((se) => se.id == s.sectionId, orElse: () => Section(id: '', semesterId: '', name: 'Unknown Section'));
                    final sem = _semesters.firstWhere((se) => se.id == sec.semesterId, orElse: () => Semester(id: '', branchId: '', semesterNumber: 0));
                    final b = _branches.firstWhere((br) => br.id == sem.branchId, orElse: () => Branch(id: '', courseId: '', name: 'Unknown'));
                    final className = '${b.name} - Sem ${sem.semesterNumber} (${sec.name})';
                    final deleteButton = IconButton(
                      icon: Icon(Icons.delete_outline_rounded, color: theme.colorScheme.error),
                      tooltip: 'Delete ${s.name}',
                      onPressed: () async {
                        await ref.read(academicRepositoryProvider).deleteStudent(s.id);
                        _loadData();
                      },
                    );
                    return AppDataRow(
                      mobileTitle: s.name,
                      mobileSubtitle: className,
                      mobileLeadingText: s.rollNumber,
                      mobileTrailing: deleteButton,
                      cells: [
                        Text(s.rollNumber),
                        Text(s.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                        Text(className),
                        Align(alignment: Alignment.centerRight, child: deleteButton),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
