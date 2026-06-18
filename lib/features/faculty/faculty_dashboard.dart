import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../auth/auth_provider.dart';
import '../../data/models/models.dart';
import '../../data/services/providers.dart';
import '../../core/widgets/responsive_scaffold.dart';

class FacultyDashboard extends ConsumerWidget {
  const FacultyDashboard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final user = ref.watch(authStateProvider).valueOrNull;
    final facultyId = user?.associatedId ?? 'fac_1';

    final academicRepo = ref.watch(academicRepositoryProvider);
    final attendanceRepo = ref.watch(attendanceRepositoryProvider);

    return ResponsiveScaffold(
      title: 'Faculty Portal',
      currentPath: '/faculty',
      body: FutureBuilder(
        future: Future.wait([
          academicRepo.getFacultyAssignments(),
          academicRepo.getSubjectMappings(),
          academicRepo.getSubjects(),
          academicRepo.getSections(),
          academicRepo.getSemesters(),
          academicRepo.getBranches(),
          attendanceRepo.getSessionsByFaculty(facultyId),
        ]),
        builder: (context, AsyncSnapshot<List<dynamic>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final assignments = snapshot.data?[0] as List<FacultyAssignment>? ?? [];
          final mappings = snapshot.data?[1] as List<SubjectMapping>? ?? [];
          final subjects = snapshot.data?[2] as List<Subject>? ?? [];
          final sections = snapshot.data?[3] as List<Section>? ?? [];
          final semesters = snapshot.data?[4] as List<Semester>? ?? [];
          final branches = snapshot.data?[5] as List<Branch>? ?? [];
          final sessionsConducted = snapshot.data?[6] as List<AttendanceSession>? ?? [];

          // Filter assignments matching current faculty
          final facultyAssignments = assignments.where((a) => a.facultyId == facultyId).toList();

          final isDesktop = MediaQuery.of(context).size.width > 960;

          if (isDesktop) {
            return _buildDesktopLayout(context, user, facultyAssignments, sessionsConducted, mappings, subjects, sections, semesters, branches);
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Welcome card
                Text(
                  'Welcome, ${user?.name ?? "Faculty Member"}',
                  style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                Text(
                  'Mark lecture attendance, view histories, and extract reports.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
                const SizedBox(height: 24),

                // Metrics Row
                Row(
                  children: [
                    Expanded(
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Assigned Classes', style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurface.withOpacity(0.5))),
                              const SizedBox(height: 4),
                              Text('${facultyAssignments.length}', style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Lectures Conducted', style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurface.withOpacity(0.5))),
                              const SizedBox(height: 4),
                              Text('${sessionsConducted.length}', style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 28),

                // Primary Quick Actions
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size.fromHeight(60),
                          backgroundColor: theme.colorScheme.primary,
                        ),
                        onPressed: () => context.go('/faculty/mark-attendance'),
                        icon: const Icon(Icons.add_task_rounded),
                        label: const Text('Mark Attendance'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size.fromHeight(60),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: () => context.go('/faculty/edit-attendance'),
                        icon: const Icon(Icons.edit_note_rounded),
                        label: const Text('Edit Past Sessions'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                // Assigned Classes List
                Text(
                  'My Assigned Classes & Subjects',
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),

                if (facultyAssignments.isEmpty)
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Center(
                        child: Text(
                          'No classes assigned to you.',
                          style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.5)),
                        ),
                      ),
                    ),
                  )
                else
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: facultyAssignments.length,
                    itemBuilder: (context, idx) {
                      final fa = facultyAssignments[idx];
                      final map = mappings.firstWhere((m) => m.id == fa.subjectMappingId, orElse: () => SubjectMapping(id: '', sectionId: '', subjectId: ''));
                      final sub = subjects.firstWhere((s) => s.id == map.subjectId, orElse: () => Subject(id: '', code: 'UNK', name: 'Unknown Subject'));
                      final sec = sections.firstWhere((s) => s.id == map.sectionId, orElse: () => Section(id: '', semesterId: '', name: 'Unknown Section'));
                      final sem = semesters.firstWhere((s) => s.id == sec.semesterId, orElse: () => Semester(id: '', branchId: '', semesterNumber: 0));
                      final b = branches.firstWhere((br) => br.id == sem.branchId, orElse: () => Branch(id: '', courseId: '', name: 'Unknown'));

                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
                            child: Icon(Icons.school_rounded, color: theme.colorScheme.primary),
                          ),
                          title: Text(
                            '${b.name} - Sem ${sem.semesterNumber} (${sec.name})',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text('[${sub.code}] ${sub.name}'),
                        ),
                      );
                    },
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildDesktopLayout(
    BuildContext context,
    dynamic user,
    List<FacultyAssignment> facultyAssignments,
    List<AttendanceSession> sessionsConducted,
    List<SubjectMapping> mappings,
    List<Subject> subjects,
    List<Section> sections,
    List<Semester> semesters,
    List<Branch> branches,
  ) {
    final theme = Theme.of(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Welcome Header
          Text(
            'Welcome, ${user?.name ?? "Faculty Member"}',
            style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          Text(
            'Mark lecture attendance, view histories, and extract reports.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left Column: Metrics and Class List
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Metrics Row
                    Row(
                      children: [
                        Expanded(
                          child: Card(
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: BorderSide(color: theme.dividerColor.withOpacity(0.08)),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Assigned Classes', style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurface.withOpacity(0.5))),
                                  const SizedBox(height: 4),
                                  Text('${facultyAssignments.length}', style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Card(
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: BorderSide(color: theme.dividerColor.withOpacity(0.08)),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Lectures Conducted', style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurface.withOpacity(0.5))),
                                  const SizedBox(height: 4),
                                  Text('${sessionsConducted.length}', style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 28),
                    // Assigned Classes List
                    Text(
                      'My Assigned Classes & Subjects',
                      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    if (facultyAssignments.isEmpty)
                      Card(
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(color: theme.dividerColor.withOpacity(0.08)),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Center(
                            child: Text(
                              'No classes assigned to you.',
                              style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.5)),
                            ),
                          ),
                        ),
                      )
                    else
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: facultyAssignments.length,
                        itemBuilder: (context, idx) {
                          final fa = facultyAssignments[idx];
                          final map = mappings.firstWhere((m) => m.id == fa.subjectMappingId, orElse: () => SubjectMapping(id: '', sectionId: '', subjectId: ''));
                          final sub = subjects.firstWhere((s) => s.id == map.subjectId, orElse: () => Subject(id: '', code: 'UNK', name: 'Unknown Subject'));
                          final sec = sections.firstWhere((s) => s.id == map.sectionId, orElse: () => Section(id: '', semesterId: '', name: 'Unknown Section'));
                          final sem = semesters.firstWhere((s) => s.id == sec.semesterId, orElse: () => Semester(id: '', branchId: '', semesterNumber: 0));
                          final b = branches.firstWhere((br) => br.id == sem.branchId, orElse: () => Branch(id: '', courseId: '', name: 'Unknown'));

                          return Card(
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: BorderSide(color: theme.dividerColor.withOpacity(0.08)),
                            ),
                            margin: const EdgeInsets.only(bottom: 12),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
                                child: Icon(Icons.school_rounded, color: theme.colorScheme.primary),
                              ),
                              title: Text(
                                '${b.name} - Sem ${sem.semesterNumber} (${sec.name})',
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              subtitle: Text('[${sub.code}] ${sub.name}'),
                            ),
                          );
                        },
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 24),
              // Right Column: Quick Actions
              Expanded(
                flex: 2,
                child: Card(
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
                        Text(
                          'Quick Actions',
                          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size.fromHeight(60),
                            backgroundColor: theme.colorScheme.primary,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          onPressed: () => context.go('/faculty/mark-attendance'),
                          icon: const Icon(Icons.add_task_rounded),
                          label: const Text('Mark Attendance'),
                        ),
                        const SizedBox(height: 12),
                        OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size.fromHeight(60),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          onPressed: () => context.go('/faculty/edit-attendance'),
                          icon: const Icon(Icons.edit_note_rounded),
                          label: const Text('Edit Past Sessions'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

