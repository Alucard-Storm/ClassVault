import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../auth/auth_provider.dart';
import '../../data/models/models.dart';
import '../../data/services/providers.dart';
import '../../core/widgets/responsive_scaffold.dart';
import '../../core/widgets/skeleton_loaders.dart';
import '../../core/widgets/app_dialogs.dart';
import '../../core/widgets/app_snackbar.dart';
import '../../core/widgets/student_attendance_tile.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/theme/app_color_scheme.dart';
import '../../core/theme/app_tokens.dart';

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
    final facultyId = user?.associatedId ?? '';

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

    final confirmed = await AppConfirmDialog.show(
      context,
      title: 'Confirm Submission',
      message: 'You are about to submit attendance for this session.\n\n'
          'Present: $presentCount students\n'
          'Absent: $absenteesCount students',
      confirmLabel: 'Submit',
      icon: Icons.task_alt_rounded,
    );

    if (!confirmed || !mounted) return;

    setState(() => _isLoading = true);

    final assignment = _assignments.firstWhere((a) => a.id == _selectedAssignmentId);
    final mapping = _mappings.firstWhere((m) => m.id == assignment.subjectMappingId);
    final user = ref.read(authStateProvider).valueOrNull;

    final sessionId = 'sess_${DateTime.now().millisecondsSinceEpoch}';

    final session = AttendanceSession(
      id: sessionId,
      facultyId: user?.associatedId ?? '',
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
      AppSnackBar.success(context, 'Attendance recorded successfully!');
      context.go('/faculty');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 960;

    if (_isLoading) {
      return const ResponsiveScaffold(
        title: 'Mark Attendance',
        currentPath: '/faculty/mark-attendance',
        body: Padding(
          padding: EdgeInsets.all(AppSpacing.xl),
          child: Column(
            children: [
              SkeletonCard(height: 160),
              SizedBox(height: AppSpacing.lg),
              SkeletonCard(height: 180),
            ],
          ),
        ),
      );
    }

    return ResponsiveScaffold(
      title: isDesktop ? 'Mark Attendance' : (_currentStep == 0 ? 'Lecture Details' : 'Student Roster'),
      currentPath: '/faculty/mark-attendance',
      leading: (!isDesktop && _currentStep == 1)
          ? IconButton(
              icon: const Icon(Icons.arrow_back_rounded),
              tooltip: 'Back',
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
                        ? const EmptyState(
                            icon: Icons.class_outlined,
                            title: 'No classes assigned',
                            message: 'Please ask your administrator to assign you a class.',
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
            ).animate().fadeIn(duration: AppMotion.entrance).slideY(begin: 0.06, curve: Curves.easeOut),
            const SizedBox(height: AppSpacing.lg),
            _buildDateTimeCard()
                .animate()
                .fadeIn(delay: AppMotion.stagger, duration: AppMotion.entrance)
                .slideY(begin: 0.06, curve: Curves.easeOut),
            const SizedBox(height: AppSpacing.xl),
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
              _buildBulkActionButtons(theme),
              const SizedBox(height: 8),
              _buildSearchField(theme),
            ],
          ),
        ),
        Expanded(
          child: _isLoadingRoster
              ? ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: 6,
                  itemBuilder: (_, _) => const Padding(
                    padding: EdgeInsets.only(bottom: AppSpacing.sm),
                    child: SkeletonListItem(hasTrailing: true),
                  ),
                )
              : _roster.isEmpty
                  ? const EmptyState(
                      icon: Icons.groups_outlined,
                      title: 'No students enrolled',
                      message: 'This section has no enrolled students yet.',
                    )
                  : filtered.isEmpty
                      ? EmptyState(
                          icon: Icons.search_off_rounded,
                          title: 'No matches',
                          message: 'No students match "$_searchQuery".',
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(12),
                          itemCount: filtered.length,
                          itemBuilder: (context, idx) {
                            final student = filtered[idx];
                            final isPresent = _attendanceState[student.id] ?? true;
                            return StudentAttendanceTile(
                              name: student.name,
                              rollNumber: student.rollNumber,
                              isPresent: isPresent,
                              onChanged: (value) =>
                                  setState(() => _attendanceState[student.id] = value),
                            ).animate().fadeIn(
                                delay: (idx * 15).ms, duration: AppMotion.entrance);
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

  Widget _buildBulkActionButtons(ThemeData theme) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              foregroundColor: theme.appColors.success,
              side: BorderSide(color: theme.appColors.success),
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
              foregroundColor: theme.appColors.danger,
              side: BorderSide(color: theme.appColors.danger),
              padding: const EdgeInsets.symmetric(vertical: 8),
            ),
            onPressed: () => _markAll(false),
            icon: const Icon(Icons.cancel_outlined, size: 16),
            label: const Text('All Absent', style: TextStyle(fontSize: 12)),
          ),
        ),
      ],
    );
  }

  Widget _buildSearchField(ThemeData theme, {bool dense = false}) {
    return TextField(
      controller: _searchController,
      decoration: InputDecoration(
        hintText: 'Search by name or roll number...',
        prefixIcon: const Icon(Icons.search_rounded, size: 18),
        suffixIcon: _searchQuery.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.clear_rounded, size: 16),
                tooltip: 'Clear search',
                onPressed: () {
                  _searchController.clear();
                  setState(() => _searchQuery = '');
                },
              )
            : null,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        isDense: dense,
      ),
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
              color: theme.colorScheme.onSurfaceVariant,
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
                                    ? const EmptyState(
                                        icon: Icons.class_outlined,
                                        title: 'No classes assigned',
                                        message: 'Please ask your administrator to assign you a class.',
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
                            foregroundColor: theme.colorScheme.onPrimary,
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
                                    color: theme.appColors.danger, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          _buildBulkActionButtons(theme),
                          const SizedBox(height: 10),
                          _buildSearchField(theme, dense: true),
                          const SizedBox(height: 12),
                          Expanded(
                            child: _isLoadingRoster
                                ? ListView.builder(
                                    itemCount: 6,
                                    itemBuilder: (_, _) => const Padding(
                                      padding: EdgeInsets.only(bottom: AppSpacing.sm),
                                      child: SkeletonListItem(hasTrailing: true),
                                    ),
                                  )
                                : _roster.isEmpty
                                    ? const EmptyState(
                                        icon: Icons.groups_outlined,
                                        title: 'No students enrolled',
                                        message: 'This section has no enrolled students yet.',
                                      )
                                    : filtered.isEmpty
                                        ? EmptyState(
                                            icon: Icons.search_off_rounded,
                                            title: 'No matches',
                                            message: 'No students match "$_searchQuery".',
                                          )
                                        : ListView.builder(
                                            itemCount: filtered.length,
                                            itemBuilder: (context, idx) {
                                              final student = filtered[idx];
                                              final isPresent =
                                                  _attendanceState[student.id] ?? true;
                                              return StudentAttendanceTile(
                                                name: student.name,
                                                rollNumber: student.rollNumber,
                                                isPresent: isPresent,
                                                onChanged: (value) => setState(
                                                    () => _attendanceState[student.id] = value),
                                              ).animate().fadeIn(
                                                  delay: (idx * 15).ms,
                                                  duration: AppMotion.entrance);
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
