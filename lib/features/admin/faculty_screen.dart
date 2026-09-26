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
import '../../core/utils/validators.dart';
import '../../core/theme/app_tokens.dart';

class FacultyScreen extends ConsumerStatefulWidget {
  const FacultyScreen({super.key});

  @override
  ConsumerState<FacultyScreen> createState() => _FacultyScreenState();
}

class _FacultyScreenState extends ConsumerState<FacultyScreen> {
  List<Faculty> _facultyList = [];
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
      final list = await repo.getFaculty();
      if (mounted) {
        setState(() {
          _facultyList = list;
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

  void _addFacultyDialog() {
    final formKey = GlobalKey<FormState>();
    final empIdController = TextEditingController();
    final nameController = TextEditingController();
    final emailController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AppFormDialog(
        title: 'Add Faculty Profile',
        icon: Icons.person_add_alt_1_rounded,
        confirmLabel: 'Add',
        child: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: empIdController,
                decoration: const InputDecoration(labelText: 'Employee ID (e.g. EMP105)'),
                validator: (v) => v == null || v.isEmpty ? 'Enter Employee ID' : null,
              ),
              const SizedBox(height: AppSpacing.lg),
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Full Name'),
                validator: (v) => v == null || v.isEmpty ? 'Enter Name' : null,
              ),
              const SizedBox(height: AppSpacing.lg),
              TextFormField(
                controller: emailController,
                decoration: const InputDecoration(labelText: 'Email Address'),
                keyboardType: TextInputType.emailAddress,
                validator: Validators.email,
              ),
            ],
          ),
        ),
        onConfirm: () async {
          if (formKey.currentState!.validate()) {
            final newFaculty = Faculty(
              id: 'fac_${DateTime.now().millisecondsSinceEpoch}',
              employeeId: empIdController.text.toUpperCase().trim(),
              name: nameController.text.trim(),
              email: emailController.text.toLowerCase().trim(),
            );
            try {
              await ref.read(academicRepositoryProvider).addFaculty(newFaculty);
            } catch (e) {
              // Employee ID and login email must be unique.
              if (context.mounted) AppSnackBar.error(context, 'Could not add faculty: $e');
              return;
            }
            if (context.mounted) Navigator.pop(context);
            _loadData();
          }
        },
      ),
    ).whenComplete(() {
      empIdController.dispose();
      nameController.dispose();
      emailController.dispose();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDesktop = MediaQuery.of(context).size.width > AppBreakpoints.desktop;

    if (_isLoading) {
      return ResponsiveScaffold(
        title: 'Faculty Management',
        currentPath: '/admin/faculty',
        body: const Padding(padding: EdgeInsets.all(24.0), child: SkeletonCard(height: 400)),
      );
    }

    if (_error != null) {
      return ResponsiveScaffold(
        title: 'Faculty Management',
        currentPath: '/admin/faculty',
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline_rounded, size: 64, color: theme.colorScheme.error),
              const SizedBox(height: AppSpacing.lg),
              Text('Failed to load faculty directory', style: theme.textTheme.titleMedium),
              const SizedBox(height: AppSpacing.sm),
              ElevatedButton(onPressed: _loadData, child: const Text('Retry')),
            ],
          ),
        ),
      );
    }

    return ResponsiveScaffold(
      title: 'Faculty Management',
      currentPath: '/admin/faculty',
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ConsoleHeader(
              title: 'Faculty Directory',
              subtitle: 'Manage faculty profiles and jump to their class assignments.',
              onRefresh: isDesktop ? _loadData : null,
              actionLabel: 'Add Faculty',
              actionIcon: Icons.person_add_alt_1_rounded,
              onAction: _addFacultyDialog,
            ).animate().fadeIn(duration: 250.ms).slideY(begin: -0.05, curve: Curves.easeOut),
            const SizedBox(height: AppSpacing.md),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                icon: const Icon(Icons.assignment_ind_rounded, size: 18),
                label: const Text('View Faculty Assignments'),
                onPressed: () => context.go('/admin/faculty-assignment'),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Expanded(
              child: SingleChildScrollView(
                child: AppDataTable(
                  isDesktop: isDesktop,
                  columns: const ['Employee ID', 'Full Name', 'Email Address', ''],
                  columnFlex: const [2, 3, 4, 1],
                  emptyIcon: Icons.badge_outlined,
                  emptyTitle: 'No faculty yet',
                  emptyMessage: 'Add a faculty profile to get started.',
                  rows: _facultyList.map((f) {
                    final deleteButton = IconButton(
                      icon: Icon(Icons.delete_outline_rounded, color: theme.colorScheme.error),
                      tooltip: 'Delete ${f.name}',
                      onPressed: () async {
                        await ref.read(academicRepositoryProvider).deleteFaculty(f.id);
                        _loadData();
                      },
                    );
                    return AppDataRow(
                      mobileTitle: f.name,
                      mobileSubtitle: 'ID: ${f.employeeId} · ${f.email}',
                      mobileLeadingText: f.name,
                      mobileTrailing: deleteButton,
                      cells: [
                        Text(f.employeeId),
                        Text(f.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                        Text(f.email),
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
