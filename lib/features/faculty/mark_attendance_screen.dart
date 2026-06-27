import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../auth/auth_provider.dart';
import '../../data/models/models.dart';
import '../../data/services/providers.dart';
import '../../core/widgets/responsive_scaffold.dart';

class MarkAttendanceScreen extends ConsumerStatefulWidget {
  const MarkAttendanceScreen({super.key});

  @override
  ConsumerState<MarkAttendanceScreen> createState() => _MarkAttendanceScreenState();
}

class _MarkAttendanceScreenState extends ConsumerState<MarkAttendanceScreen> {
  final _formKey = GlobalKey<FormState>();
  final _searchController = TextEditingController();

  int _currentStep = 0;
  bool _isLoading = true;
  bool _isLoadingRoster = false;
  String _searchQuery = '';

  String? _selectedAssignmentId;
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _startTime = const TimeOfDay(hour: 10, minute: 0);
  TimeOfDay _endTime = const TimeOfDay(hour: 11, minute: 0);

  List<FacultyAssignment> _assignments = [];
  List<SubjectMapping> _mappings = [];
  List<Subject> _subjects = [];
  List<Section> _sections = [];
  List<Semester> _semesters = [];
  List<Branch> _branches = [];

  List<Student> _roster = [];
  final Map<String, bool> _attendanceState = {};

  List<Student> get _filteredRoster {
    if (_searchQuery.isEmpty) return _roster;
    final q = _searchQuery.toLowerCase();
    return _roster.where((s) =>
        s.name.toLowerCase().contains(q) ||
        s.rollNumber.toLowerCase().contains(q)).toList();
  }

  @override
  void initState() {
    super.initState();
    _loadSetupData();
    _searchController.addListener(() {
      setState(() => _searchQuery = _searchController.text);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadSetupData() async {
    setState(() => _isLoading = true);
    final user = ref.read(authStateProvider).valueOrNull;
    final facultyId = user?.associatedId ?? 'fac_1';

    final repo = ref.read(academicRepositoryProvider);
    final allAssignments = await repo.getFacultyAssignments();
    final mappings = await repo.getSubjectMappings();
    final subjects = await repo.getSubjects();
    final sections = await repo.getSections();
    final semesters = await repo.getSemesters();
    final branches = await repo.getBranches();

    final facultyAssignments = allAssignments.where((a) => a.facultyId == facultyId).toList();

    setState(() {
      _assignments = facultyAssignments;
      _mappings = mappings;
      _subjects = subjects;
      _sections = sections;
      _semesters = semesters;
      _branches = branches;
      if (_assignments.isNotEmpty) {
        _selectedAssignmentId = _assignments.first.id;
      }
      _isLoading = false;
    });

    if (_selectedAssignmentId != null) {
      _onAssignmentChanged(_selectedAssignmentId);
    }
  }

  Future<void> _onAssignmentChanged(String? val) async {
    if (val == null) return;
    setState(() {
      _selectedAssignmentId = val;
      _isLoadingRoster = true;
    });

    final assignment = _assignments.firstWhere((a) => a.id == val);
    final mapping = _mappings.firstWhere((m) => m.id == assignment.subjectMappingId);

    final repo = ref.read(academicRepositoryProvider);
    final students = await repo.getStudentsBySection(mapping.sectionId);

    setState(() {
      _roster = students;
      _attendanceState.clear();
      for (var student in _roster) {
        _attendanceState[student.id] = true;
      }
      _isLoadingRoster = false;
    });
  }

  void _markAll(bool present) {
    setState(() {
      for (var student in _roster) {
        _attendanceState[student.id] = present;
      }
    });
  }

  void _proceedToRoster() {
    if (_formKey.currentState!.validate() && _selectedAssignmentId != null) {
      setState(() => _currentStep = 1);
    }
  }

  Future<void> _saveAttendance() async {
    final presentCount = _attendanceState.values.where((v) => v).length;
    final absenteesCount = _attendanceState.values.where((v) => !v).length;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirm Submission'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('You are about to submit attendance for this session.'),
            const SizedBox(height: 16),
            Row(
              children: [
                const Icon(Icons.check_circle_rounded, color: Color(0xFF10B981), size: 18),
                const SizedBox(width: 8),
                Text('Present: $presentCount students'),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.cancel_rounded, color: Color(0xFFEF4444), size: 18),
                const SizedBox(width: 8),
                Text('Absent: $absenteesCount students'),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Submit'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _isLoading = true);

    final assignment = _assignments.firstWhere((a) => a.id == _selectedAssignmentId);
    final mapping = _mappings.firstWhere((m) => m.id == assignment.subjectMappingId);
    final user = ref.read(authStateProvider).valueOrNull;

    final sessionId = 'sess_${DateTime.now().millisecondsSinceEpoch}';

    final session = AttendanceSession(
      id: sessionId,
      facultyId: user?.associatedId ?? 'fac_1',
      subjectId: mapping.subjectId,
      sectionId: mapping.sectionId,
      date: _selectedDate,
      startTime: _startTime.format(context),
      endTime: _endTime.format(context),
    );

    final List<AttendanceRecord> records = [];
    _attendanceState.forEach((studentId, isPresent) {
      records.add(
        AttendanceRecord(
          id: 'rec_${DateTime.now().millisecondsSinceEpoch}_$studentId',
          sessionId: sessionId,
          studentId: studentId,
          status: isPresent ? 'present' : 'absent',
        ),
      );
    });

    final attendanceRepo = ref.read(attendanceRepositoryProvider);
    await attendanceRepo.addSession(session, records);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Attendance recorded successfully!'),
          backgroundColor: Color(0xFF10B981),
        ),
      );
      context.go('/faculty');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 960;

    if (_isLoading) {
      return ResponsiveScaffold(
        title: 'Mark Attendance',
        currentPath: '/faculty/mark-attendance',
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return ResponsiveScaffold(
      title: isDesktop ? 'Mark Attendance' : (_currentStep == 0 ? 'Lecture Details' : 'Student Roster'),
      currentPath: '/faculty/mark-attendance',
      leading: (!isDesktop && _currentStep == 1)
          ? IconButton(
              icon: const Icon(Icons.arrow_back_rounded),
              onPressed: () => setState(() => _currentStep = 0),
            )
          : null,
      body: isDesktop
          ? _buildDesktopLayout()
          : (_currentStep == 0 ? _buildStep1() : _buildStep2()),
    );
  }

  Widget _buildStep1() {
    final theme = Theme.of(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Select Class & Subject',
                        style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    _assignments.isEmpty
                        ? Text(
                            'No classes assigned. Please ask your administrator.',
                            style: TextStyle(color: theme.colorScheme.error),
                          )
                        : DropdownButtonFormField<String>(
                            isExpanded: true,
                            value: _selectedAssignmentId,
                            decoration: const InputDecoration(labelText: 'Class / Subject'),
                            items: _assignments.map((fa) {
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
                              return DropdownMenuItem(
                                value: fa.id,
                                child: Text(
                                  '${b.name} - Sem ${sem.semesterNumber} (${sec.name}) ➔ ${sub.name}',
                                  overflow: TextOverflow.ellipsis,
                                ),
                              );
                            }).toList(),
                            onChanged: (val) {
                              setState(() => _selectedAssignmentId = val);
                              _onAssignmentChanged(val);
                            },
                          ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            _buildDateTimeCard(),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _assignments.isEmpty ? null : _proceedToRoster,
              child: const Text('Proceed to Attendance Sheet'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep2() {
    final theme = Theme.of(context);
    final filtered = _filteredRoster;
    final absenteesCount = _attendanceState.values.where((v) => !v).length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          color: theme.colorScheme.primary.withValues(alpha: 0.08),
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Total: ${_roster.length} students',
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  Text('Absent: $absenteesCount',
                      style: TextStyle(color: theme.colorScheme.error, fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF10B981),
                        side: const BorderSide(color: Color(0xFF10B981)),
                        padding: const EdgeInsets.symmetric(vertical: 8),
                      ),
                      onPressed: () => _markAll(true),
                      icon: const Icon(Icons.check_circle_outline_rounded, size: 16),
                      label: const Text('All Present', style: TextStyle(fontSize: 12)),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: theme.colorScheme.error,
                        side: BorderSide(color: theme.colorScheme.error),
                        padding: const EdgeInsets.symmetric(vertical: 8),
                      ),
                      onPressed: () => _markAll(false),
                      icon: const Icon(Icons.cancel_outlined, size: 16),
                      label: const Text('All Absent', style: TextStyle(fontSize: 12)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search by name or roll number...',
                  prefixIcon: const Icon(Icons.search_rounded, size: 18),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear_rounded, size: 16),
                          onPressed: () {
                            _searchController.clear();
                            setState(() => _searchQuery = '');
                          },
                        )
                      : null,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  filled: true,
                  fillColor: theme.colorScheme.surface,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: theme.dividerColor),
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: _isLoadingRoster
              ? const Center(child: CircularProgressIndicator())
              : _roster.isEmpty
                  ? Center(
                      child: Text(
                        'No students enrolled in this section.',
                        style: TextStyle(color: theme.colorScheme.onSurface.withValues(alpha: 0.5)),
                      ),
                    )
                  : filtered.isEmpty
                      ? Center(
                          child: Text(
                            'No students match "$_searchQuery".',
                            style: TextStyle(color: theme.colorScheme.onSurface.withValues(alpha: 0.5)),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(12),
                          itemCount: filtered.length,
                          itemBuilder: (context, idx) {
                            final student = filtered[idx];
                            final isPresent = _attendanceState[student.id] ?? true;

                            return Card(
                              color: isPresent
                                  ? null
                                  : theme.colorScheme.errorContainer.withValues(alpha: 0.12),
                              margin: const EdgeInsets.only(bottom: 8),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: isPresent
                                      ? theme.colorScheme.primary.withValues(alpha: 0.1)
                                      : theme.colorScheme.error.withValues(alpha: 0.1),
                                  child: Text(
                                    student.rollNumber,
                                    style: TextStyle(
                                      color: isPresent
                                          ? theme.colorScheme.primary
                                          : theme.colorScheme.error,
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                title: Text(
                                  student.name,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: isPresent
                                        ? null
                                        : theme.colorScheme.onSurface.withValues(alpha: 0.5),
                                  ),
                                ),
                                trailing: Checkbox(
                                  activeColor: theme.colorScheme.primary,
                                  checkColor: Colors.white,
                                  value: isPresent,
                                  onChanged: (val) {
                                    setState(() {
                                      _attendanceState[student.id] = val ?? true;
                                    });
                                  },
                                ),
                                onTap: () {
                                  setState(() {
                                    _attendanceState[student.id] = !isPresent;
                                  });
                                },
                              ),
                            );
                          },
                        ),
        ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: ElevatedButton(
            onPressed: _saveAttendance,
            child: const Text('Submit Attendance'),
          ),
        ),
      ],
    );
  }

  Widget _buildDesktopLayout() {
    final theme = Theme.of(context);
    final filtered = _filteredRoster;
    final absenteesCount = _attendanceState.values.where((v) => !v).length;

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Mark Attendance Console',
            style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            'Select lecture details and mark absentees below.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 380,
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Card(
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(color: theme.dividerColor.withValues(alpha: 0.15)),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Lecture Class & Subject',
                                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                                const SizedBox(height: 12),
                                _assignments.isEmpty
                                    ? Text(
                                        'No classes assigned. Please ask your administrator.',
                                        style: TextStyle(color: theme.colorScheme.error),
                                      )
                                    : DropdownButtonFormField<String>(
                                        isExpanded: true,
                                        value: _selectedAssignmentId,
                                        decoration: const InputDecoration(labelText: 'Class / Subject'),
                                        items: _assignments.map((fa) {
                                          final map = _mappings.firstWhere(
                                              (m) => m.id == fa.subjectMappingId,
                                              orElse: () =>
                                                  SubjectMapping(id: '', sectionId: '', subjectId: ''));
                                          final sub = _subjects.firstWhere((s) => s.id == map.subjectId,
                                              orElse: () =>
                                                  Subject(id: '', code: 'UNK', name: 'Unknown Subject'));
                                          final sec = _sections.firstWhere((s) => s.id == map.sectionId,
                                              orElse: () => Section(
                                                  id: '', semesterId: '', name: 'Unknown Section'));
                                          final sem = _semesters.firstWhere(
                                              (s) => s.id == sec.semesterId,
                                              orElse: () =>
                                                  Semester(id: '', branchId: '', semesterNumber: 0));
                                          final b = _branches.firstWhere((br) => br.id == sem.branchId,
                                              orElse: () =>
                                                  Branch(id: '', courseId: '', name: 'Unknown'));
                                          return DropdownMenuItem(
                                            value: fa.id,
                                            child: Text(
                                              '${b.name} - Sem ${sem.semesterNumber} (${sec.name}) ➔ ${sub.name}',
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          );
                                        }).toList(),
                                        onChanged: _onAssignmentChanged,
                                      ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildDateTimeCard(),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: theme.colorScheme.primary,
                            foregroundColor: Colors.white,
                            minimumSize: const Size.fromHeight(56),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          onPressed: _assignments.isEmpty ? null : _saveAttendance,
                          icon: const Icon(Icons.check_circle_outline_rounded),
                          label: const Text('Submit Attendance'),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 24),
                Expanded(
                  child: Card(
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
                                'Student Roster (${_roster.length} enrolled)',
                                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                              ),
                              Text(
                                'Absent: $absenteesCount',
                                style: TextStyle(
                                    color: theme.colorScheme.error, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton.icon(
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: const Color(0xFF10B981),
                                    side: const BorderSide(color: Color(0xFF10B981)),
                                    padding: const EdgeInsets.symmetric(vertical: 8),
                                  ),
                                  onPressed: () => _markAll(true),
                                  icon: const Icon(Icons.check_circle_outline_rounded, size: 16),
                                  label: const Text('All Present', style: TextStyle(fontSize: 12)),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: OutlinedButton.icon(
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: theme.colorScheme.error,
                                    side: BorderSide(color: theme.colorScheme.error),
                                    padding: const EdgeInsets.symmetric(vertical: 8),
                                  ),
                                  onPressed: () => _markAll(false),
                                  icon: const Icon(Icons.cancel_outlined, size: 16),
                                  label: const Text('All Absent', style: TextStyle(fontSize: 12)),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          TextField(
                            controller: _searchController,
                            decoration: InputDecoration(
                              hintText: 'Search by name or roll number...',
                              prefixIcon: const Icon(Icons.search_rounded, size: 18),
                              suffixIcon: _searchQuery.isNotEmpty
                                  ? IconButton(
                                      icon: const Icon(Icons.clear_rounded, size: 16),
                                      onPressed: () {
                                        _searchController.clear();
                                        setState(() => _searchQuery = '');
                                      },
                                    )
                                  : null,
                              contentPadding:
                                  const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                              isDense: true,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Expanded(
                            child: _isLoadingRoster
                                ? const Center(child: CircularProgressIndicator())
                                : _roster.isEmpty
                                    ? Center(
                                        child: Text(
                                          'No students found in the target class section.',
                                          style: TextStyle(
                                              color:
                                                  theme.colorScheme.onSurface.withValues(alpha: 0.5)),
                                        ),
                                      )
                                    : filtered.isEmpty
                                        ? Center(
                                            child: Text(
                                              'No students match "$_searchQuery".',
                                              style: TextStyle(
                                                  color: theme.colorScheme.onSurface
                                                      .withValues(alpha: 0.5)),
                                            ),
                                          )
                                        : GridView.builder(
                                            gridDelegate:
                                                const SliverGridDelegateWithMaxCrossAxisExtent(
                                              maxCrossAxisExtent: 180,
                                              mainAxisSpacing: 10,
                                              crossAxisSpacing: 10,
                                              childAspectRatio: 2.2,
                                            ),
                                            itemCount: filtered.length,
                                            itemBuilder: (context, idx) {
                                              final student = filtered[idx];
                                              final isPresent =
                                                  _attendanceState[student.id] ?? true;
                                              return InkWell(
                                                onTap: () {
                                                  setState(() {
                                                    _attendanceState[student.id] = !isPresent;
                                                  });
                                                },
                                                borderRadius: BorderRadius.circular(8),
                                                child: Container(
                                                  padding: const EdgeInsets.symmetric(
                                                      horizontal: 12, vertical: 8),
                                                  decoration: BoxDecoration(
                                                    color: isPresent
                                                        ? theme.colorScheme.primaryContainer
                                                            .withValues(alpha: 0.15)
                                                        : theme.colorScheme.errorContainer
                                                            .withValues(alpha: 0.15),
                                                    border: Border.all(
                                                      color: isPresent
                                                          ? theme.colorScheme.primary
                                                              .withValues(alpha: 0.2)
                                                          : theme.colorScheme.error
                                                              .withValues(alpha: 0.2),
                                                    ),
                                                    borderRadius: BorderRadius.circular(8),
                                                  ),
                                                  child: Row(
                                                    children: [
                                                      Expanded(
                                                        child: Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment.start,
                                                          mainAxisAlignment:
                                                              MainAxisAlignment.center,
                                                          children: [
                                                            Text(
                                                              student.name,
                                                              maxLines: 1,
                                                              overflow: TextOverflow.ellipsis,
                                                              style: TextStyle(
                                                                fontWeight: FontWeight.bold,
                                                                fontSize: 13,
                                                                color: isPresent
                                                                    ? null
                                                                    : theme.colorScheme.onSurface
                                                                        .withValues(alpha: 0.5),
                                                              ),
                                                            ),
                                                            Text(
                                                              'Roll: ${student.rollNumber}',
                                                              style: TextStyle(
                                                                fontSize: 10,
                                                                color: theme.colorScheme.onSurface
                                                                    .withValues(alpha: 0.6),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                      Icon(
                                                        isPresent
                                                            ? Icons.check_circle_rounded
                                                            : Icons.cancel_rounded,
                                                        color: isPresent
                                                            ? theme.colorScheme.primary
                                                            : theme.colorScheme.error,
                                                        size: 20,
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              );
                                            },
                                          ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateTimeCard() {
    final theme = Theme.of(context);
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: theme.dividerColor.withValues(alpha: 0.15)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Date & Time Slot',
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.calendar_month_rounded),
              title: Text(DateFormat('EEEE, dd MMMM yyyy').format(_selectedDate)),
              trailing: TextButton(
                onPressed: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: _selectedDate,
                    firstDate: DateTime.now().subtract(const Duration(days: 30)),
                    lastDate: DateTime.now(),
                  );
                  if (date != null) setState(() => _selectedDate = date);
                },
                child: const Text('Change'),
              ),
            ),
            const Divider(),
            Row(
              children: [
                Expanded(child: _buildTimeTile('Start Time', _startTime, (t) => _startTime = t)),
                const SizedBox(width: 16),
                Expanded(child: _buildTimeTile('End Time', _endTime, (t) => _endTime = t)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeTile(String label, TimeOfDay time, void Function(TimeOfDay) onPick) {
    return InkWell(
      onTap: () async {
        final picked = await showTimePicker(context: context, initialTime: time);
        if (picked != null) setState(() => onPick(picked));
      },
      borderRadius: BorderRadius.circular(6),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(fontSize: 12)),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.access_time_rounded, size: 16),
                const SizedBox(width: 4),
                Text(time.format(context), style: const TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
