import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../data/models/models.dart';
import '../../data/services/providers.dart';
import '../../core/widgets/responsive_scaffold.dart';
import '../../core/widgets/console_header.dart';
import '../../core/widgets/app_data_table.dart';
import '../../core/widgets/app_dialogs.dart';
import '../../core/widgets/app_snackbar.dart';
import '../../core/widgets/skeleton_loaders.dart';
import '../../core/theme/app_tokens.dart';

class FacultyAssignmentScreen extends ConsumerStatefulWidget {
  const FacultyAssignmentScreen({super.key});

  @override
  ConsumerState<FacultyAssignmentScreen> createState() => _FacultyAssignmentScreenState();
}

class _FacultyAssignmentScreenState extends ConsumerState<FacultyAssignmentScreen> {
  List<FacultyAssignment> _assignments = [];
  List<Faculty> _facultyList = [];
  List<SubjectMapping> _mappings = [];
  List<Subject> _subjects = [];
  List<Section> _sections = [];
  List<Semester> _semesters = [];
  List<Branch> _branches = [];
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
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e;
          _isLoading = false;
        });
      }
    }
  }

  void _addAssignmentDialog() {
    final formKey = GlobalKey<FormState>();
    String? selectedFacultyId = _facultyList.isNotEmpty ? _facultyList.first.id : null;
    String? selectedMappingId = _mappings.isNotEmpty ? _mappings.first.id : null;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) => AppFormDialog(
          title: 'Assign Faculty to Class',
          icon: Icons.add_link_rounded,
          confirmLabel: 'Assign',
          child: Form(
            key: formKey,
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
          onConfirm: () async {
            if (formKey.currentState!.validate() && selectedFacultyId != null && selectedMappingId != null) {
              // Check duplicate assignment
              final exists = _assignments.any((a) => a.facultyId == selectedFacultyId && a.subjectMappingId == selectedMappingId);
              if (exists) {
                AppSnackBar.error(context, 'This assignment already exists!');
                return;
              }

              final newAssignment = FacultyAssignment(
                id: 'fa_${DateTime.now().millisecondsSinceEpoch}',
                facultyId: selectedFacultyId!,
                subjectMappingId: selectedMappingId!,
              );
              await ref.read(academicRepositoryProvider).addFacultyAssignment(newAssignment);
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
    final theme = Theme.of(context);
    final isDesktop = MediaQuery.of(context).size.width > AppBreakpoints.desktop;

    if (_isLoading) {
      return ResponsiveScaffold(
        title: 'Faculty Assignments',
        currentPath: '/admin/faculty-assignment',
        body: const Padding(padding: EdgeInsets.all(24.0), child: SkeletonCard(height: 400)),
      );
    }

    if (_error != null) {
      return ResponsiveScaffold(
        title: 'Faculty Assignments',
        currentPath: '/admin/faculty-assignment',
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline_rounded, size: 64, color: theme.colorScheme.error),
              const SizedBox(height: AppSpacing.lg),
              Text('Failed to load faculty assignments', style: theme.textTheme.titleMedium),
              const SizedBox(height: AppSpacing.sm),
              ElevatedButton(onPressed: _loadData, child: const Text('Retry')),
            ],
          ),
        ),
      );
    }

    return ResponsiveScaffold(
      title: 'Faculty Assignments',
      currentPath: '/admin/faculty-assignment',
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ConsoleHeader(
              title: 'Faculty Assignments Console',
              subtitle: 'Map faculty members to class subject mappings.',
              onRefresh: isDesktop ? _loadData : null,
              actionLabel: 'Create Assignment',
              actionIcon: Icons.add_link_rounded,
              onAction: _addAssignmentDialog,
            ).animate().fadeIn(duration: 250.ms).slideY(begin: -0.05, curve: Curves.easeOut),
            const SizedBox(height: AppSpacing.xl),
            Expanded(
              child: AppDataTable(
                isDesktop: isDesktop,
                columns: const ['Employee ID', 'Faculty Name', 'Class Section', 'Subject', ''],
                columnFlex: const [2, 3, 4, 4, 1],
                emptyIcon: Icons.link_off_rounded,
                emptyTitle: 'No assignments yet',
                emptyMessage: 'Create an assignment to map a faculty member to a class subject.',
                rows: _assignments.map((fa) {
                  final faculty = _facultyList.firstWhere((f) => f.id == fa.facultyId, orElse: () => Faculty(id: '', employeeId: 'N/A', name: 'Unknown', email: ''));
                  final map = _mappings.firstWhere((m) => m.id == fa.subjectMappingId, orElse: () => SubjectMapping(id: '', sectionId: '', subjectId: ''));
                  final sub = _subjects.firstWhere((s) => s.id == map.subjectId, orElse: () => Subject(id: '', code: 'UNK', name: 'Unknown Subject'));
                  final sec = _sections.firstWhere((se) => se.id == map.sectionId, orElse: () => Section(id: '', semesterId: '', name: 'Unknown Section'));
                  final sem = _semesters.firstWhere((s) => s.id == sec.semesterId, orElse: () => Semester(id: '', branchId: '', semesterNumber: 0));
                  final b = _branches.firstWhere((br) => br.id == sem.branchId, orElse: () => Branch(id: '', courseId: '', name: 'Unknown'));
                  final className = '${b.name} - Sem ${sem.semesterNumber} (${sec.name})';
                  final subjectLabel = '[${sub.code}] ${sub.name}';
                  final deleteButton = IconButton(
                    icon: Icon(Icons.delete_outline_rounded, color: theme.colorScheme.error),
                    tooltip: 'Remove assignment',
                    onPressed: () async {
                      await ref.read(academicRepositoryProvider).deleteFacultyAssignment(fa.id);
                      _loadData();
                    },
                  );

                  return AppDataRow(
                    mobileTitle: faculty.name,
                    mobileSubtitle: '$className\n$subjectLabel',
                    mobileLeadingIcon: Icons.school_rounded,
                    mobileTrailing: deleteButton,
                    cells: [
                      Text(faculty.employeeId),
                      Text(faculty.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                      Text(className),
                      Text(subjectLabel),
                      Align(alignment: Alignment.centerRight, child: deleteButton),
                    ],
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
