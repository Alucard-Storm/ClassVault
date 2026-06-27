import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../data/models/models.dart';
import '../../data/services/providers.dart';
import '../../core/widgets/responsive_scaffold.dart';

class SemesterPromotionScreen extends ConsumerStatefulWidget {
  const SemesterPromotionScreen({super.key});

  @override
  ConsumerState<SemesterPromotionScreen> createState() => _SemesterPromotionScreenState();
}

class _SemesterPromotionScreenState extends ConsumerState<SemesterPromotionScreen> {
  String? _sourceSectionId;
  String? _destSectionId;

  List<Section> _sections = [];
  List<Semester> _semesters = [];
  List<Branch> _branches = [];
  List<Student> _sourceStudents = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final repo = ref.read(academicRepositoryProvider);
    final sections = await repo.getSections();
    final semesters = await repo.getSemesters();
    final branches = await repo.getBranches();

    setState(() {
      _sections = sections;
      _semesters = semesters;
      _branches = branches;
      _isLoading = false;
    });

    if (_sections.isNotEmpty) {
      _sourceSectionId = _sections.first.id;
      _loadSourceStudents();
    }
  }

  Future<void> _loadSourceStudents() async {
    if (_sourceSectionId == null) return;
    setState(() => _isLoading = true);
    final repo = ref.read(academicRepositoryProvider);
    final list = await repo.getStudentsBySection(_sourceSectionId!);
    setState(() {
      _sourceStudents = list;
      _isLoading = false;
    });
  }

  void _promoteBatch() async {
    if (_sourceSectionId == null || _destSectionId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select both source and destination sections!'), backgroundColor: Color(0xFFEF4444)),
      );
      return;
    }

    if (_sourceSectionId == _destSectionId) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Source and Destination sections cannot be the same!'), backgroundColor: Color(0xFFEF4444)),
      );
      return;
    }

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Batch Promotion'),
        content: Text('Are you sure you want to promote ${_sourceStudents.length} students to the selected destination section?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF10B981), foregroundColor: Colors.white),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Promote'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      setState(() => _isLoading = true);
      final repo = ref.read(academicRepositoryProvider);
      await repo.promoteStudents(_sourceSectionId!, _destSectionId!);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Batch promotion completed successfully!'), backgroundColor: Color(0xFF10B981)),
        );
        context.go('/admin');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDesktop = MediaQuery.of(context).size.width > 960;

    if (_isLoading) {
      return ResponsiveScaffold(
        title: 'Semester Promotion',
        currentPath: '/admin/promotion',
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return ResponsiveScaffold(
      title: 'Semester Promotion',
      currentPath: '/admin/promotion',
      body: isDesktop
          ? _buildDesktopLayout()
          : SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Source & Destination Selectors
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Select Promotion Path', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      isExpanded: true,
                      value: _sourceSectionId,
                      decoration: const InputDecoration(labelText: 'Source Section (Current Class)'),
                      items: _sections.map((sec) {
                        final sem = _semesters.firstWhere((s) => s.id == sec.semesterId, orElse: () => Semester(id: '', branchId: '', semesterNumber: 0));
                        final b = _branches.firstWhere((br) => br.id == sem.branchId, orElse: () => Branch(id: '', courseId: '', name: 'Unknown'));
                        return DropdownMenuItem(
                          value: sec.id,
                          child: Text('${b.name} - Sem ${sem.semesterNumber} (${sec.name})'),
                        );
                      }).toList(),
                      onChanged: (val) {
                        setState(() {
                          _sourceSectionId = val;
                        });
                        _loadSourceStudents();
                      },
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      isExpanded: true,
                      value: _destSectionId,
                      decoration: const InputDecoration(labelText: 'Destination Section (New Class)'),
                      items: _sections.map((sec) {
                        final sem = _semesters.firstWhere((s) => s.id == sec.semesterId, orElse: () => Semester(id: '', branchId: '', semesterNumber: 0));
                        final b = _branches.firstWhere((br) => br.id == sem.branchId, orElse: () => Branch(id: '', courseId: '', name: 'Unknown'));
                        return DropdownMenuItem(
                          value: sec.id,
                          child: Text('${b.name} - Sem ${sem.semesterNumber} (${sec.name})'),
                        );
                      }).toList(),
                      onChanged: (val) {
                        setState(() {
                          _destSectionId = val;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Students in source section
            Text(
              'Students in Source Section (${_sourceStudents.length})',
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            if (_sourceStudents.isEmpty)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Center(
                    child: Text(
                      'No students found in this source section.',
                      style: TextStyle(color: theme.colorScheme.onSurface.withValues(alpha: 0.5)),
                    ),
                  ),
                ),
              )
            else ...[
              Card(
                child: ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _sourceStudents.length,
                  separatorBuilder: (context, index) => const Divider(height: 1),
                  itemBuilder: (context, idx) {
                    final student = _sourceStudents[idx];
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.1),
                        child: Text(
                          student.rollNumber,
                          style: TextStyle(color: theme.colorScheme.primary, fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                      ),
                      title: Text(student.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF10B981),
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(56),
                ),
                onPressed: _promoteBatch,
                icon: const Icon(Icons.upgrade_rounded),
                label: const Text('Promote Batch Now'),
              ),
            ],
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
          Text(
            'Semester Promotion Console',
            style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            'Promote students in batch from a source semester/section to a destination semester/section.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final leftColumn = Column(
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
                            Text(
                              'Select Promotion Path',
                              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 16),
                            DropdownButtonFormField<String>(
                              isExpanded: true,
                              value: _sourceSectionId,
                              decoration: const InputDecoration(labelText: 'Source Section (Current Class)'),
                              items: _sections.map((sec) {
                                final sem = _semesters.firstWhere((s) => s.id == sec.semesterId, orElse: () => Semester(id: '', branchId: '', semesterNumber: 0));
                                final b = _branches.firstWhere((br) => br.id == sem.branchId, orElse: () => Branch(id: '', courseId: '', name: 'Unknown'));
                                return DropdownMenuItem(
                                  value: sec.id,
                                  child: Text('${b.name} - Sem ${sem.semesterNumber} (${sec.name})', overflow: TextOverflow.ellipsis),
                                );
                              }).toList(),
                              onChanged: (val) {
                                setState(() {
                                  _sourceSectionId = val;
                                });
                                _loadSourceStudents();
                              },
                            ),
                            const SizedBox(height: 16),
                            DropdownButtonFormField<String>(
                              isExpanded: true,
                              value: _destSectionId,
                              decoration: const InputDecoration(labelText: 'Destination Section (New Class)'),
                              items: _sections.map((sec) {
                                final sem = _semesters.firstWhere((s) => s.id == sec.semesterId, orElse: () => Semester(id: '', branchId: '', semesterNumber: 0));
                                final b = _branches.firstWhere((br) => br.id == sem.branchId, orElse: () => Branch(id: '', courseId: '', name: 'Unknown'));
                                return DropdownMenuItem(
                                  value: sec.id,
                                  child: Text('${b.name} - Sem ${sem.semesterNumber} (${sec.name})', overflow: TextOverflow.ellipsis),
                                );
                              }).toList(),
                              onChanged: (val) {
                                setState(() {
                                  _destSectionId = val;
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (_sourceStudents.isNotEmpty)
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF10B981),
                          foregroundColor: Colors.white,
                          minimumSize: const Size.fromHeight(56),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: _promoteBatch,
                        icon: const Icon(Icons.upgrade_rounded),
                        label: const Text('Promote Batch Now'),
                      ),
                  ],
                );

                final rightColumn = Card(
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
                        Text(
                          'Students in Source Section (${_sourceStudents.length})',
                          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 16),
                        Expanded(
                          child: _sourceStudents.isEmpty
                              ? Center(
                                  child: Text(
                                    'No students found in the selected source section.',
                                    style: TextStyle(color: theme.colorScheme.onSurface.withValues(alpha: 0.5)),
                                  ),
                                )
                              : ListView.builder(
                                  itemCount: _sourceStudents.length,
                                  itemBuilder: (context, idx) {
                                    final student = _sourceStudents[idx];
                                    return Container(
                                      margin: const EdgeInsets.only(bottom: 8),
                                      child: Material(
                                        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        clipBehavior: Clip.antiAlias,
                                        child: ListTile(
                                          leading: CircleAvatar(
                                            backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.1),
                                            child: Text(
                                              student.rollNumber,
                                              style: TextStyle(
                                                color: theme.colorScheme.primary,
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                          title: Text(
                                            student.name,
                                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
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
                        leftColumn,
                        const SizedBox(height: 24),
                        SizedBox(
                          height: 500,
                          child: rightColumn,
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
                        child: leftColumn,
                      ),
                      const SizedBox(width: 24),
                      Expanded(
                        child: rightColumn,
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

