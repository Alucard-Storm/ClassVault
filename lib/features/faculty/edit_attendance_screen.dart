import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../auth/auth_provider.dart';
import '../../data/models/models.dart';
import '../../data/services/providers.dart';
import '../../core/widgets/responsive_scaffold.dart';

class EditAttendanceScreen extends ConsumerStatefulWidget {
  const EditAttendanceScreen({super.key});

  @override
  ConsumerState<EditAttendanceScreen> createState() => _EditAttendanceScreenState();
}

class _EditAttendanceScreenState extends ConsumerState<EditAttendanceScreen> {
  bool _isLoading = true;

  // Session selector state
  List<AttendanceSession> _sessions = [];
  List<Subject> _subjects = [];
  List<Section> _sections = [];
  List<Semester> _semesters = [];
  List<Branch> _branches = [];

  AttendanceSession? _selectedSession;

  // Roster editing state
  List<Student> _roster = [];
  List<AttendanceRecord> _records = [];
  final Map<String, String> _attendanceMap = {}; // studentId -> status ('present'|'absent')

  @override
  void initState() {
    super.initState();
    _loadSessions();
  }

  Future<void> _loadSessions() async {
    setState(() => _isLoading = true);
    final user = ref.read(authStateProvider).valueOrNull;
    final facultyId = user?.associatedId ?? 'fac_1';

    final repo = ref.read(academicRepositoryProvider);
    final attendanceRepo = ref.read(attendanceRepositoryProvider);

    final sessions = await attendanceRepo.getSessionsByFaculty(facultyId);
    final subjects = await repo.getSubjects();
    final sections = await repo.getSections();
    final semesters = await repo.getSemesters();
    final branches = await repo.getBranches();

    // Sort sessions descending by date
    sessions.sort((a, b) => b.date.compareTo(a.date));

    setState(() {
      _sessions = sessions;
      _subjects = subjects;
      _sections = sections;
      _semesters = semesters;
      _branches = branches;
      _isLoading = false;
    });
  }

  Future<void> _loadRoster(AttendanceSession session) async {
    setState(() => _isLoading = true);
    final repo = ref.read(academicRepositoryProvider);
    final attendanceRepo = ref.read(attendanceRepositoryProvider);

    final students = await repo.getStudentsBySection(session.sectionId);
    final records = await attendanceRepo.getAttendanceRecords(session.id);

    setState(() {
      _selectedSession = session;
      _roster = students;
      _records = records;

      _attendanceMap.clear();
      // Initialize map
      for (var student in _roster) {
        final rec = _records.firstWhere((r) => r.studentId == student.id, orElse: () => AttendanceRecord(id: '', sessionId: '', studentId: '', status: 'present'));
        _attendanceMap[student.id] = rec.status;
      }
      _isLoading = false;
    });
  }

  Future<void> _updateAttendance() async {
    if (_selectedSession == null) return;
    setState(() => _isLoading = true);

    final List<AttendanceRecord> updatedRecords = [];
    _attendanceMap.forEach((studentId, status) {
      final existing = _records.firstWhere(
        (r) => r.studentId == studentId,
        orElse: () => AttendanceRecord(id: '', sessionId: '', studentId: '', status: ''),
      );

      updatedRecords.add(
        AttendanceRecord(
          id: existing.id.isNotEmpty ? existing.id : 'rec_${DateTime.now().millisecondsSinceEpoch}_$studentId',
          sessionId: _selectedSession!.id,
          studentId: studentId,
          status: status,
        ),
      );
    });

    final attendanceRepo = ref.read(attendanceRepositoryProvider);
    await attendanceRepo.updateAttendanceRecords(updatedRecords);

    setState(() {
      _selectedSession = null;
      _roster.clear();
      _records.clear();
      _attendanceMap.clear();
    });

    await _loadSessions();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Attendance records updated successfully!'), backgroundColor: Color(0xFF10B981)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDesktop = MediaQuery.of(context).size.width > 960;

    if (_isLoading) {
      return ResponsiveScaffold(
        title: 'Edit Attendance',
        currentPath: '/faculty/edit-attendance',
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return ResponsiveScaffold(
      title: isDesktop ? 'Edit Attendance' : (_selectedSession == null ? 'Edit Past Sessions' : 'Update Attendance'),
      currentPath: '/faculty/edit-attendance',
      leading: (!isDesktop && _selectedSession != null)
          ? IconButton(
              icon: const Icon(Icons.arrow_back_rounded),
              onPressed: () => setState(() => _selectedSession = null),
            )
          : null,
      body: isDesktop
          ? _buildDesktopLayout()
          : (_selectedSession == null ? _buildSessionsList() : _buildRosterEditor()),
    );
  }

  Widget _buildSessionsList() {
    final theme = Theme.of(context);
    if (_sessions.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Text(
            'No prior attendance sessions found.',
            style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.5)),
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _sessions.length,
      itemBuilder: (context, idx) {
        final session = _sessions[idx];
        final sub = _subjects.firstWhere((s) => s.id == session.subjectId, orElse: () => Subject(id: '', code: 'UNK', name: 'Unknown Subject'));
        final sec = _sections.firstWhere((s) => s.id == session.sectionId, orElse: () => Section(id: '', semesterId: '', name: 'Unknown Section'));
        final sem = _semesters.firstWhere((s) => s.id == sec.semesterId, orElse: () => Semester(id: '', branchId: '', semesterNumber: 0));
        final b = _branches.firstWhere((br) => br.id == sem.branchId, orElse: () => Branch(id: '', courseId: '', name: 'Unknown'));

        final formattedDate = DateFormat('MMM dd, yyyy').format(session.date);

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
              child: Icon(Icons.history_rounded, color: theme.colorScheme.primary),
            ),
            title: Text(
              '${b.name} - Sem ${sem.semesterNumber} (${sec.name})',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text('${sub.name}\n$formattedDate | ${session.startTime} - ${session.endTime}'),
            isThreeLine: true,
            trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
            onTap: () => _loadRoster(session),
          ),
        );
      },
    );
  }

  Widget _buildRosterEditor() {
    final theme = Theme.of(context);
    final absenteesCount = _attendanceMap.values.where((v) => v == 'absent').length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          color: theme.colorScheme.primary.withOpacity(0.08),
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total Students: ${_roster.length}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                'Absentees: $absenteesCount',
                style: TextStyle(color: theme.colorScheme.error, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _roster.length,
            itemBuilder: (context, idx) {
              final student = _roster[idx];
              final status = _attendanceMap[student.id] ?? 'present';
              final isPresent = status == 'present';

              return Card(
                color: isPresent ? null : theme.colorScheme.errorContainer.withOpacity(0.15),
                margin: const EdgeInsets.only(bottom: 10),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: isPresent ? theme.colorScheme.primary.withOpacity(0.1) : theme.colorScheme.error.withOpacity(0.1),
                    child: Text(
                      student.rollNumber,
                      style: TextStyle(
                        color: isPresent ? theme.colorScheme.primary : theme.colorScheme.error,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  title: Text(
                    student.name,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      decoration: isPresent ? null : TextDecoration.lineThrough,
                    ),
                  ),
                  trailing: Checkbox(
                    activeColor: theme.colorScheme.primary,
                    checkColor: Colors.white,
                    value: isPresent,
                    onChanged: (val) {
                      setState(() {
                        _attendanceMap[student.id] = (val ?? true) ? 'present' : 'absent';
                      });
                    },
                  ),
                ),
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(24.0),
          child: ElevatedButton(
            onPressed: _updateAttendance,
            child: const Text('Save Changes'),
          ),
        ),
      ],
    );
  }

  Widget _buildDesktopLayout() {
    final theme = Theme.of(context);
    final absenteesCount = _attendanceMap.values.where((v) => v == 'absent').length;

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
                      'Edit Attendance Console',
                      style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Select a past session on the left to modify its student records.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ),
              IconButton.filledTonal(
                onPressed: _loadSessions,
                icon: const Icon(Icons.refresh),
                tooltip: 'Refresh Sessions',
              ),
            ],
          ),
          const SizedBox(height: 24),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final sessionsListCard = Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: theme.dividerColor.withOpacity(0.08)),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'Past Attendance Sessions (${_sessions.length})',
                          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 12),
                        Expanded(
                          child: _sessions.isEmpty
                              ? Center(
                                  child: Text(
                                    'No prior sessions found.',
                                    style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.5)),
                                  ),
                                )
                              : ListView.builder(
                                  itemCount: _sessions.length,
                                  itemBuilder: (context, idx) {
                                    final session = _sessions[idx];
                                    final sub = _subjects.firstWhere((s) => s.id == session.subjectId, orElse: () => Subject(id: '', code: 'UNK', name: 'Unknown Subject'));
                                    final sec = _sections.firstWhere((s) => s.id == session.sectionId, orElse: () => Section(id: '', semesterId: '', name: 'Unknown Section'));
                                    final sem = _semesters.firstWhere((s) => s.id == sec.semesterId, orElse: () => Semester(id: '', branchId: '', semesterNumber: 0));
                                    final b = _branches.firstWhere((br) => br.id == sem.branchId, orElse: () => Branch(id: '', courseId: '', name: 'Unknown'));

                                    final formattedDate = DateFormat('MMM dd, yyyy').format(session.date);
                                    final isSelected = _selectedSession?.id == session.id;

                                    return Container(
                                      margin: const EdgeInsets.only(bottom: 8),
                                      child: Material(
                                        color: isSelected
                                            ? theme.colorScheme.primaryContainer.withOpacity(0.2)
                                            : theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(8),
                                          side: isSelected
                                              ? BorderSide(color: theme.colorScheme.primary.withOpacity(0.3))
                                              : BorderSide.none,
                                        ),
                                        clipBehavior: Clip.antiAlias,
                                        child: ListTile(
                                          title: Text(
                                            '${b.name} - Sem ${sem.semesterNumber} (${sec.name})',
                                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                          ),
                                          subtitle: Text(
                                            '${sub.name}\n$formattedDate | ${session.startTime}',
                                            style: const TextStyle(fontSize: 11),
                                          ),
                                          onTap: () => _loadRoster(session),
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

                final detailPanelCard = Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: theme.dividerColor.withOpacity(0.08)),
                  ),
                  child: _selectedSession == null
                      ? Center(
                          child: Text(
                            'Select a past session from the list to edit records.',
                            style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.5)),
                          ),
                        )
                      : Padding(
                          padding: const EdgeInsets.all(20.0),
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
                                          'Session Details',
                                          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          'Session ID: ${_selectedSession!.id}',
                                          style: TextStyle(fontSize: 11, color: theme.colorScheme.onSurface.withOpacity(0.4)),
                                        ),
                                      ],
                                    ),
                                  ),
                                  ElevatedButton.icon(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF10B981),
                                      foregroundColor: Colors.white,
                                      minimumSize: const Size(120, 44),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                    ),
                                    onPressed: _updateAttendance,
                                    icon: const Icon(Icons.check_rounded, size: 18),
                                    label: const Text('Save Changes'),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  Expanded(
                                    child: Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFEF4444).withOpacity(0.08),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Row(
                                        children: [
                                          const Icon(Icons.people_outline_rounded, color: Color(0xFFEF4444)),
                                          const SizedBox(width: 8),
                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              const Text('Absentees', style: TextStyle(fontSize: 10, color: Color(0xFFEF4444))),
                                              Text('$absenteesCount students', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFFEF4444))),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF3B82F6).withOpacity(0.08),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Row(
                                        children: [
                                          const Icon(Icons.edit_note_rounded, color: Color(0xFF3B82F6)),
                                          const SizedBox(width: 8),
                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              const Text('Status', style: TextStyle(fontSize: 10, color: Color(0xFF3B82F6))),
                                              const Text('Editable Log', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF3B82F6))),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              const Divider(),
                              const SizedBox(height: 12),
                              Text(
                                'Student Records Checklist',
                                style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 12),
                              Expanded(
                                child: ListView.builder(
                                  itemCount: _roster.length,
                                  itemBuilder: (context, idx) {
                                    final student = _roster[idx];
                                    final status = _attendanceMap[student.id] ?? 'present';
                                    final isPresent = status == 'present';

                                    return InkWell(
                                      onTap: () {
                                        setState(() {
                                          _attendanceMap[student.id] = isPresent ? 'absent' : 'present';
                                        });
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                        decoration: BoxDecoration(
                                          border: Border(bottom: BorderSide(color: theme.dividerColor.withOpacity(0.04))),
                                        ),
                                        child: Row(
                                          children: [
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    student.name,
                                                    maxLines: 1,
                                                    overflow: TextOverflow.ellipsis,
                                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                                  ),
                                                  Text(
                                                    'Roll: ${student.rollNumber}',
                                                    style: TextStyle(
                                                      fontSize: 10,
                                                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Icon(
                                              isPresent ? Icons.check_circle_rounded : Icons.cancel_rounded,
                                              color: isPresent ? theme.colorScheme.primary : theme.colorScheme.error,
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
                );

                if (constraints.maxWidth < 1100) {
                  return SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        SizedBox(
                          height: 400,
                          child: sessionsListCard,
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          height: 600,
                          child: detailPanelCard,
                        ),
                      ],
                    ),
                  );
                } else {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 380,
                        child: sessionsListCard,
                      ),
                      const SizedBox(width: 24),
                      Expanded(
                        child: detailPanelCard,
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

