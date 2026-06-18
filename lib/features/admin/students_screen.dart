import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../data/models/models.dart';
import '../../data/services/providers.dart';
import '../../core/widgets/responsive_scaffold.dart';

class StudentsScreen extends ConsumerStatefulWidget {
  const StudentsScreen({super.key});

  @override
  ConsumerState<StudentsScreen> createState() => _StudentsScreenState();
}

class _StudentsScreenState extends ConsumerState<StudentsScreen> {
  final _formKey = GlobalKey<FormState>();

  List<Student> _students = [];
  List<Section> _sections = [];
  List<Semester> _semesters = [];
  List<Branch> _branches = [];
  String? _selectedSectionFilter;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
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
  }

  void _addStudentDialog() {
    final rollController = TextEditingController();
    final nameController = TextEditingController();
    String? selectedSectionId = _selectedSectionFilter ?? (_sections.isNotEmpty ? _sections.first.id : null);

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) => AlertDialog(
          title: const Text('Add Student Profile'),
          content: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  value: selectedSectionId,
                  items: _sections.map((sec) {
                    final sem = _semesters.firstWhere((s) => s.id == sec.semesterId, orElse: () => Semester(id: '', branchId: '', semesterNumber: 0));
                    final b = _branches.firstWhere((br) => br.id == sem.branchId, orElse: () => Branch(id: '', courseId: '', name: 'Unknown'));
                    return DropdownMenuItem(
                      value: sec.id,
                      child: Text('${b.name} - Sem ${sem.semesterNumber} (${sec.name})'),
                    );
                  }).toList(),
                  onChanged: (val) => setStateDialog(() => selectedSectionId = val),
                  decoration: const InputDecoration(labelText: 'Class Section'),
                  validator: (v) => v == null ? 'Select section' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: rollController,
                  decoration: const InputDecoration(labelText: 'Roll Number (e.g. 101)'),
                  validator: (v) => v == null || v.isEmpty ? 'Enter Roll Number' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Student Name'),
                  validator: (v) => v == null || v.isEmpty ? 'Enter Name' : null,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () async {
                if (_formKey.currentState!.validate() && selectedSectionId != null) {
                  // Check duplicate roll number in same section
                  final hasDuplicate = _students.any(
                    (s) => s.sectionId == selectedSectionId && 
                           s.rollNumber.trim() == rollController.text.trim(),
                  );
                  if (hasDuplicate) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Roll Number already exists in this section!'), backgroundColor: Color(0xFFEF4444)),
                    );
                    return;
                  }

                  final newStudent = Student(
                    id: 'stud_${DateTime.now().millisecondsSinceEpoch}',
                    rollNumber: rollController.text.trim(),
                    name: nameController.text.trim(),
                    sectionId: selectedSectionId!,
                  );
                  await ref.read(academicRepositoryProvider).addStudent(newStudent);
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
    final isDesktop = MediaQuery.of(context).size.width > 900;

    final filteredStudents = _selectedSectionFilter == null
        ? _students
        : _students.where((s) => s.sectionId == _selectedSectionFilter).toList();

    return ResponsiveScaffold(
      title: 'Student Directory',
      currentPath: '/admin/students',
      actions: [
        TextButton.icon(
          icon: const Icon(Icons.upload_file_rounded),
          label: const Text('Bulk Import'),
          onPressed: () => context.go('/admin/students/import'),
        ),
        const SizedBox(width: 8),
      ],
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Filter Section
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          isExpanded: true,
                          value: _selectedSectionFilter,
                          hint: const Text('Filter by Class Section (Show All)'),
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
                  ),
                  const SizedBox(height: 20),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Students (${filteredStudents.length})',
                        style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(120, 44),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        onPressed: _addStudentDialog,
                        icon: const Icon(Icons.person_add_rounded, size: 18),
                        label: const Text('Add Student'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  if (filteredStudents.isEmpty)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 40.0),
                        child: Text(
                          'No students registered under the selected filter.',
                          style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.5)),
                        ),
                      ),
                    )
                  else if (isDesktop)
                    // Desktop Table Layout
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Table(
                          columnWidths: const {
                            0: FixedColumnWidth(150),
                            1: FlexColumnWidth(3),
                            2: FlexColumnWidth(4),
                            3: FixedColumnWidth(80),
                          },
                          children: [
                            TableRow(
                              decoration: BoxDecoration(
                                border: Border(bottom: BorderSide(color: theme.dividerColor, width: 1.5)),
                              ),
                              children: const [
                                Padding(padding: EdgeInsets.symmetric(vertical: 10), child: Text('Roll Number', style: TextStyle(fontWeight: FontWeight.bold))),
                                Padding(padding: EdgeInsets.symmetric(vertical: 10), child: Text('Student Name', style: TextStyle(fontWeight: FontWeight.bold))),
                                Padding(padding: EdgeInsets.symmetric(vertical: 10), child: Text('Class Section', style: TextStyle(fontWeight: FontWeight.bold))),
                                Padding(padding: EdgeInsets.symmetric(vertical: 10), child: Text('Actions', style: TextStyle(fontWeight: FontWeight.bold))),
                              ],
                            ),
                            ...filteredStudents.map((s) {
                              final sec = _sections.firstWhere((se) => se.id == s.sectionId, orElse: () => Section(id: '', semesterId: '', name: 'Unknown Section'));
                              final sem = _semesters.firstWhere((se) => se.id == sec.semesterId, orElse: () => Semester(id: '', branchId: '', semesterNumber: 0));
                              final b = _branches.firstWhere((br) => br.id == sem.branchId, orElse: () => Branch(id: '', courseId: '', name: 'Unknown'));
                              return TableRow(
                                decoration: BoxDecoration(
                                  border: Border(bottom: BorderSide(color: theme.dividerColor.withOpacity(0.4))),
                                ),
                                children: [
                                  Padding(padding: const EdgeInsets.symmetric(vertical: 12), child: Text(s.rollNumber)),
                                  Padding(padding: const EdgeInsets.symmetric(vertical: 12), child: Text(s.name, style: const TextStyle(fontWeight: FontWeight.bold))),
                                  Padding(padding: const EdgeInsets.symmetric(vertical: 12), child: Text('${b.name} - Sem ${sem.semesterNumber} (${sec.name})')),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 8),
                                    child: IconButton(
                                      icon: Icon(Icons.delete_outline_rounded, color: theme.colorScheme.error),
                                      onPressed: () async {
                                        await ref.read(academicRepositoryProvider).deleteStudent(s.id);
                                        _loadData();
                                      },
                                    ),
                                  ),
                                ],
                              );
                            }),
                          ],
                        ),
                      ),
                    )
                  else
                    // Mobile Card Layout
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: filteredStudents.length,
                      itemBuilder: (context, idx) {
                        final s = filteredStudents[idx];
                        final sec = _sections.firstWhere((se) => se.id == s.sectionId, orElse: () => Section(id: '', semesterId: '', name: 'Unknown Section'));
                        final sem = _semesters.firstWhere((se) => se.id == sec.semesterId, orElse: () => Semester(id: '', branchId: '', semesterNumber: 0));
                        final b = _branches.firstWhere((br) => br.id == sem.branchId, orElse: () => Branch(id: '', courseId: '', name: 'Unknown'));

                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
                              child: Text(
                                s.rollNumber,
                                style: TextStyle(
                                  color: theme.colorScheme.primary,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            title: Text(s.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Text('${b.name} - Sem ${sem.semesterNumber} (${sec.name})'),
                            trailing: IconButton(
                              icon: Icon(Icons.delete_outline_rounded, color: theme.colorScheme.error),
                              onPressed: () async {
                                await ref.read(academicRepositoryProvider).deleteStudent(s.id);
                                _loadData();
                              },
                            ),
                          ),
                        );
                      },
                    ),
                ],
              ),
            ),
    );
  }
}
