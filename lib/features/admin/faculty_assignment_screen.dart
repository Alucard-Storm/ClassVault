import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/models.dart';
import '../../data/services/providers.dart';
import '../../core/widgets/responsive_scaffold.dart';

class FacultyAssignmentScreen extends ConsumerStatefulWidget {
  const FacultyAssignmentScreen({super.key});

  @override
  ConsumerState<FacultyAssignmentScreen> createState() => _FacultyAssignmentScreenState();
}

class _FacultyAssignmentScreenState extends ConsumerState<FacultyAssignmentScreen> {
  final _formKey = GlobalKey<FormState>();

  List<FacultyAssignment> _assignments = [];
  List<Faculty> _facultyList = [];
  List<SubjectMapping> _mappings = [];
  List<Subject> _subjects = [];
  List<Section> _sections = [];
  List<Semester> _semesters = [];
  List<Branch> _branches = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final repo = ref.read(academicRepositoryProvider);
    final assignments = await repo.getFacultyAssignments();
    final facultyList = await repo.getFaculty();
    final mappings = await repo.getSubjectMappings();
    final subjects = await repo.getSubjects();
    final sections = await repo.getSections();
    final semesters = await repo.getSemesters();
    final branches = await repo.getBranches();

    if (mounted) {
      setState(() {
        _assignments = assignments;
        _facultyList = facultyList;
        _mappings = mappings;
        _subjects = subjects;
        _sections = sections;
        _semesters = semesters;
        _branches = branches;
        _isLoading = false;
      });
    }
  }

  void _addAssignmentDialog() {
    String? selectedFacultyId = _facultyList.isNotEmpty ? _facultyList.first.id : null;
    String? selectedMappingId = _mappings.isNotEmpty ? _mappings.first.id : null;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) => AlertDialog(
          title: const Text('Assign Faculty to Class'),
          content: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  isExpanded: true,
                  value: selectedFacultyId,
                  items: _facultyList
                      .map((f) => DropdownMenuItem(value: f.id, child: Text(f.name)))
                      .toList(),
                  onChanged: (val) => setStateDialog(() => selectedFacultyId = val),
                  decoration: const InputDecoration(labelText: 'Faculty Member'),
                  validator: (v) => v == null ? 'Select faculty' : null,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  isExpanded: true,
                  value: selectedMappingId,
                  items: _mappings.map((map) {
                    final sub = _subjects.firstWhere((s) => s.id == map.subjectId, orElse: () => Subject(id: '', code: 'UNK', name: 'Unknown Subject'));
                    final sec = _sections.firstWhere((se) => se.id == map.sectionId, orElse: () => Section(id: '', semesterId: '', name: 'Unknown Section'));
                    final sem = _semesters.firstWhere((s) => s.id == sec.semesterId, orElse: () => Semester(id: '', branchId: '', semesterNumber: 0));
                    final b = _branches.firstWhere((br) => br.id == sem.branchId, orElse: () => Branch(id: '', courseId: '', name: 'Unknown'));
                    return DropdownMenuItem(
                      value: map.id,
                      child: Text(
                        '${b.name} - Sem ${sem.semesterNumber} (${sec.name}) ➔ ${sub.name}',
                        overflow: TextOverflow.ellipsis,
                      ),
                    );
                  }).toList(),
                  onChanged: (val) => setStateDialog(() => selectedMappingId = val),
                  decoration: const InputDecoration(labelText: 'Class Subject Mapping'),
                  validator: (v) => v == null ? 'Select mapping' : null,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () async {
                if (_formKey.currentState!.validate() && selectedFacultyId != null && selectedMappingId != null) {
                  // Check duplicate assignment
                  final exists = _assignments.any((a) => a.facultyId == selectedFacultyId && a.subjectMappingId == selectedMappingId);
                  if (exists) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('This assignment already exists!'), backgroundColor: Color(0xFFEF4444)),
                    );
                    return;
                  }

                  final newAssignment = FacultyAssignment(
                    id: 'fa_${DateTime.now().millisecondsSinceEpoch}',
                    facultyId: selectedFacultyId!,
                    subjectMappingId: selectedMappingId!,
                  );
                  await ref.read(academicRepositoryProvider).addFacultyAssignment(newAssignment);
                  Navigator.pop(context);
                  _loadData();
                }
              },
              child: const Text('Assign'),
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
        title: 'Faculty Assignments',
        currentPath: '/admin/faculty-assignment',
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return ResponsiveScaffold(
      title: 'Faculty Assignments',
      currentPath: '/admin/faculty-assignment',
      body: isDesktop
          ? _buildDesktopLayout()
          : Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Assigned Faculty-Classes (${_assignments.length})',
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(120, 44),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: _addAssignmentDialog,
                  icon: const Icon(Icons.add_link_rounded, size: 18),
                  label: const Text('Create Assignment'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _assignments.isEmpty
                  ? Center(
                      child: Text(
                        'No faculty assignments registered yet.',
                        style: TextStyle(color: theme.colorScheme.onSurface.withValues(alpha: 0.5)),
                      ),
                    )
                  : ListView.builder(
                      itemCount: _assignments.length,
                      itemBuilder: (context, idx) {
                        final fa = _assignments[idx];
                        final faculty = _facultyList.firstWhere((f) => f.id == fa.facultyId, orElse: () => Faculty(id: '', employeeId: '', name: 'Unknown', email: ''));
                        final map = _mappings.firstWhere((m) => m.id == fa.subjectMappingId, orElse: () => SubjectMapping(id: '', sectionId: '', subjectId: ''));
                        final sub = _subjects.firstWhere((s) => s.id == map.subjectId, orElse: () => Subject(id: '', code: 'UNK', name: 'Unknown Subject'));
                        final sec = _sections.firstWhere((se) => se.id == map.sectionId, orElse: () => Section(id: '', semesterId: '', name: 'Unknown Section'));
                        final sem = _semesters.firstWhere((s) => s.id == sec.semesterId, orElse: () => Semester(id: '', branchId: '', semesterNumber: 0));
                        final b = _branches.firstWhere((br) => br.id == sem.branchId, orElse: () => Branch(id: '', courseId: '', name: 'Unknown'));

                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.1),
                              child: Icon(Icons.school_rounded, color: theme.colorScheme.primary),
                            ),
                            title: Text(
                              faculty.name,
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text(
                              'Class: ${b.name} - Sem ${sem.semesterNumber} (${sec.name})\nSubject: [${sub.code}] ${sub.name}',
                            ),
                            isThreeLine: true,
                            trailing: IconButton(
                              icon: Icon(Icons.delete_outline_rounded, color: theme.colorScheme.error),
                              onPressed: () async {
                                await ref.read(academicRepositoryProvider).deleteFacultyAssignment(fa.id);
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
                      'Faculty Assignments Console',
                      style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Map faculty members to class subject mappings.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  IconButton.filledTonal(
                    onPressed: _loadData,
                    icon: const Icon(Icons.refresh),
                    tooltip: 'Refresh Data',
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(120, 48),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    onPressed: _addAssignmentDialog,
                    icon: const Icon(Icons.add_link_rounded, size: 18),
                    label: const Text('Create Assignment'),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          Expanded(
            child: Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: theme.dividerColor.withValues(alpha: 0.15)),
              ),
              child: _assignments.isEmpty
                  ? Center(
                      child: Text(
                        'No faculty assignments registered yet.',
                        style: TextStyle(color: theme.colorScheme.onSurface.withValues(alpha: 0.5)),
                      ),
                    )
                  : SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Table(
                          columnWidths: const {
                            0: FlexColumnWidth(2), // Employee ID
                            1: FlexColumnWidth(3), // Faculty Name
                            2: FlexColumnWidth(4), // Class Section
                            3: FlexColumnWidth(4), // Mapped Subject
                            4: FixedColumnWidth(100), // Actions
                          },
                          defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                          children: [
                            TableRow(
                              decoration: BoxDecoration(
                                border: Border(bottom: BorderSide(color: theme.dividerColor.withValues(alpha: 0.15), width: 2)),
                              ),
                              children: [
                                _buildTableHeaderCell('Employee ID'),
                                _buildTableHeaderCell('Faculty Name'),
                                _buildTableHeaderCell('Class Section'),
                                _buildTableHeaderCell('Subject'),
                                _buildTableHeaderCell('Actions', alignRight: true),
                              ],
                            ),
                            ..._assignments.map((fa) {
                              final faculty = _facultyList.firstWhere((f) => f.id == fa.facultyId, orElse: () => Faculty(id: '', employeeId: 'N/A', name: 'Unknown', email: ''));
                              final map = _mappings.firstWhere((m) => m.id == fa.subjectMappingId, orElse: () => SubjectMapping(id: '', sectionId: '', subjectId: ''));
                              final sub = _subjects.firstWhere((s) => s.id == map.subjectId, orElse: () => Subject(id: '', code: 'UNK', name: 'Unknown Subject'));
                              final sec = _sections.firstWhere((se) => se.id == map.sectionId, orElse: () => Section(id: '', semesterId: '', name: 'Unknown Section'));
                              final sem = _semesters.firstWhere((s) => s.id == sec.semesterId, orElse: () => Semester(id: '', branchId: '', semesterNumber: 0));
                              final b = _branches.firstWhere((br) => br.id == sem.branchId, orElse: () => Branch(id: '', courseId: '', name: 'Unknown'));

                              return TableRow(
                                decoration: BoxDecoration(
                                  border: Border(bottom: BorderSide(color: theme.dividerColor.withValues(alpha: 0.15))),
                                ),
                                children: [
                                  _buildTableCell(faculty.employeeId),
                                  _buildTableCell(faculty.name, bold: true),
                                  _buildTableCell('${b.name} - Sem ${sem.semesterNumber} (${sec.name})'),
                                  _buildTableCell('[${sub.code}] ${sub.name}'),
                                  TableCell(
                                    child: Align(
                                      alignment: Alignment.centerRight,
                                      child: IconButton(
                                        icon: Icon(Icons.delete_outline_rounded, color: theme.colorScheme.error),
                                        onPressed: () async {
                                          await ref.read(academicRepositoryProvider).deleteFacultyAssignment(fa.id);
                                          _loadData();
                                        },
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
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTableHeaderCell(String text, {bool alignRight = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 8.0),
      child: Text(
        text,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
        textAlign: alignRight ? TextAlign.right : TextAlign.left,
      ),
    );
  }

  Widget _buildTableCell(String text, {bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 8.0),
      child: Text(
        text,
        style: TextStyle(
          fontWeight: bold ? FontWeight.w600 : FontWeight.normal,
          fontSize: 13,
        ),
      ),
    );
  }
}
