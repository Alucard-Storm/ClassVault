import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../data/models/models.dart';
import '../../data/services/providers.dart';
import '../../core/widgets/responsive_scaffold.dart';

class FacultyScreen extends ConsumerStatefulWidget {
  const FacultyScreen({super.key});

  @override
  ConsumerState<FacultyScreen> createState() => _FacultyScreenState();
}

class _FacultyScreenState extends ConsumerState<FacultyScreen> {
  final _formKey = GlobalKey<FormState>();
  List<Faculty> _facultyList = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final repo = ref.read(academicRepositoryProvider);
    final list = await repo.getFaculty();
    if (mounted) {
      setState(() {
        _facultyList = list;
        _isLoading = false;
      });
    }
  }

  void _addFacultyDialog() {
    final empIdController = TextEditingController();
    final nameController = TextEditingController();
    final emailController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Faculty Profile'),
        content: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: empIdController,
                decoration: const InputDecoration(labelText: 'Employee ID (e.g. EMP105)'),
                validator: (v) => v == null || v.isEmpty ? 'Enter Employee ID' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Full Name'),
                validator: (v) => v == null || v.isEmpty ? 'Enter Name' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: emailController,
                decoration: const InputDecoration(labelText: 'Email Address'),
                keyboardType: TextInputType.emailAddress,
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Enter Email';
                  if (!v.contains('@')) return 'Enter valid Email';
                  return null;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              if (_formKey.currentState!.validate()) {
                final newFaculty = Faculty(
                  id: 'fac_${DateTime.now().millisecondsSinceEpoch}',
                  employeeId: empIdController.text.toUpperCase().trim(),
                  name: nameController.text.trim(),
                  email: emailController.text.toLowerCase().trim(),
                );
                await ref.read(academicRepositoryProvider).addFaculty(newFaculty);
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDesktop = MediaQuery.of(context).size.width > 900;

    return ResponsiveScaffold(
      title: 'Faculty Management',
      currentPath: '/admin/faculty',
      actions: [
        TextButton.icon(
          icon: const Icon(Icons.assignment_ind_rounded),
          label: const Text('Faculty Assignments'),
          onPressed: () => context.go('/admin/faculty-assignment'),
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Faculty Members (${_facultyList.length})',
                        style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(120, 44),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        onPressed: _addFacultyDialog,
                        icon: const Icon(Icons.person_add_alt_1_rounded, size: 18),
                        label: const Text('Add Faculty'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (_facultyList.isEmpty)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 40.0),
                        child: Text(
                          'No faculty profiles registered.',
                          style: TextStyle(color: theme.colorScheme.onSurface.withValues(alpha: 0.5)),
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
                                Padding(padding: EdgeInsets.symmetric(vertical: 10), child: Text('Employee ID', style: TextStyle(fontWeight: FontWeight.bold))),
                                Padding(padding: EdgeInsets.symmetric(vertical: 10), child: Text('Full Name', style: TextStyle(fontWeight: FontWeight.bold))),
                                Padding(padding: EdgeInsets.symmetric(vertical: 10), child: Text('Email Address', style: TextStyle(fontWeight: FontWeight.bold))),
                                Padding(padding: EdgeInsets.symmetric(vertical: 10), child: Text('Actions', style: TextStyle(fontWeight: FontWeight.bold))),
                              ],
                            ),
                            ..._facultyList.map((f) => TableRow(
                              decoration: BoxDecoration(
                                border: Border(bottom: BorderSide(color: theme.dividerColor.withValues(alpha: 0.4))),
                              ),
                              children: [
                                Padding(padding: const EdgeInsets.symmetric(vertical: 12), child: Text(f.employeeId)),
                                Padding(padding: const EdgeInsets.symmetric(vertical: 12), child: Text(f.name, style: const TextStyle(fontWeight: FontWeight.bold))),
                                Padding(padding: const EdgeInsets.symmetric(vertical: 12), child: Text(f.email)),
                                Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 8),
                                  child: IconButton(
                                    icon: Icon(Icons.delete_outline_rounded, color: theme.colorScheme.error),
                                    onPressed: () async {
                                      await ref.read(academicRepositoryProvider).deleteFaculty(f.id);
                                      _loadData();
                                    },
                                  ),
                                ),
                              ],
                            )),
                          ],
                        ),
                      ),
                    )
                  else
                    // Mobile List Layout
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _facultyList.length,
                      itemBuilder: (context, idx) {
                        final f = _facultyList[idx];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.1),
                              child: Text(
                                f.name.isNotEmpty ? f.name[0].toUpperCase() : '?',
                                style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.bold),
                              ),
                            ),
                            title: Text(f.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Text('ID: ${f.employeeId} | ${f.email}'),
                            trailing: IconButton(
                              icon: Icon(Icons.delete_outline_rounded, color: theme.colorScheme.error),
                              onPressed: () async {
                                await ref.read(academicRepositoryProvider).deleteFaculty(f.id);
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
