import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:file_picker/file_picker.dart';
import 'package:csv/csv.dart';
import 'package:go_router/go_router.dart';
import '../../data/models/models.dart';
import '../../data/services/providers.dart';
import '../../core/widgets/responsive_scaffold.dart';
import '../../core/widgets/console_header.dart';
import '../../core/widgets/app_data_table.dart';
import '../../core/widgets/app_snackbar.dart';
import '../../core/widgets/skeleton_loaders.dart';
import '../../core/widgets/responsive_two_pane.dart';
import '../../core/theme/app_color_scheme.dart';
import '../../core/theme/app_tokens.dart';

class StudentImportScreen extends ConsumerStatefulWidget {
  const StudentImportScreen({super.key});

  @override
  ConsumerState<StudentImportScreen> createState() => _StudentImportScreenState();
}

class _StudentImportScreenState extends ConsumerState<StudentImportScreen> {
  String? _selectedSectionId;
  List<Section> _sections = [];
  List<Semester> _semesters = [];
  List<Branch> _branches = [];
  List<Student> _existingStudents = [];

  List<Map<String, dynamic>> _parsedRows = [];
  bool _isLoading = true;
  String? _fileName;
  bool _createAccounts = true;

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
    final students = await repo.getStudents();

    if (mounted) {
      setState(() {
        _sections = sections;
        _semesters = semesters;
        _branches = branches;
        _existingStudents = students;
        if (_sections.isNotEmpty) {
          _selectedSectionId = _sections.first.id;
        }
        _isLoading = false;
      });
    }
  }

  Future<void> _pickAndParseFile() async {
    if (_selectedSectionId == null) {
      AppSnackBar.error(context, 'Please select a target Section first!');
      return;
    }

    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['csv'],
      withData: true,
    );

    if (result == null || result.files.isEmpty) return;

    final file = result.files.first;
    setState(() {
      _fileName = file.name;
      _isLoading = true;
      _parsedRows.clear();
    });

    try {
      final bytes = file.bytes;
      if (bytes == null) throw Exception('Failed to read file bytes.');

      final csvString = utf8.decode(bytes);
      final List<List<dynamic>> csvTable = const CsvToListConverter().convert(csvString);

      if (csvTable.isEmpty) {
        throw Exception('CSV file is empty.');
      }

      // Detect header index
      final header = csvTable[0].map((e) => e.toString().toLowerCase().trim()).toList();
      final rollIdx = header.indexOf('roll number');
      final nameIdx = header.indexOf('student name');

      if (rollIdx == -1 || nameIdx == -1) {
        throw Exception('Invalid headers. CSV must contain: "Roll Number" and "Student Name"');
      }

      final List<Map<String, dynamic>> parsedList = [];
      for (int i = 1; i < csvTable.length; i++) {
        final row = csvTable[i];
        if (row.length <= rollIdx || row.length <= nameIdx) continue;

        final roll = row[rollIdx].toString().trim();
        final name = row[nameIdx].toString().trim();
        if (roll.isEmpty || name.isEmpty) continue;

        // Duplicate checks
        final existsInDb = _existingStudents.any((s) => s.rollNumber == roll);
        final existsInCsv = parsedList.any((p) => p['roll'] == roll);

        String status = 'Valid';
        if (existsInDb) {
          status = 'Duplicate (Database)';
        } else if (existsInCsv) {
          status = 'Duplicate (CSV File)';
        }

        parsedList.add({
          'roll': roll,
          'name': name,
          'status': status,
        });
      }

      setState(() {
        _parsedRows = parsedList;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        _showParsingErrorDialog(e.toString().replaceAll('Exception: ', ''));
      }
    }
  }

  void _showParsingErrorDialog(String message) {
    final theme = Theme.of(context);
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.card)),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.error.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.error_outline_rounded, color: theme.colorScheme.error),
                ),
                const SizedBox(height: AppSpacing.lg),
                Text('Parsing Error',
                    style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: AppSpacing.sm),
                Text(message,
                    style: theme.textTheme.bodyMedium
                        ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                const SizedBox(height: AppSpacing.xl),
                Align(
                  alignment: Alignment.centerRight,
                  child: FilledButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('OK'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _commitImport() async {
    final validRows = _parsedRows.where((r) => r['status'] == 'Valid').toList();
    if (validRows.isEmpty) {
      AppSnackBar.warning(context, 'No valid students to import!');
      return;
    }

    setState(() => _isLoading = true);
    final repo = ref.read(academicRepositoryProvider);
    final list = validRows.map((r) {
      return Student(
        id: 'stud_${DateTime.now().millisecondsSinceEpoch}_${r['roll']}',
        rollNumber: r['roll'] as String,
        name: r['name'] as String,
        sectionId: _selectedSectionId!,
      );
    }).toList();

    try {
      await repo.addStudentsBulk(list, createAccounts: _createAccounts);
    } catch (e) {
      // The bulk insert is transactional, so nothing was imported.
      if (mounted) {
        setState(() => _isLoading = false);
        AppSnackBar.error(context, 'Import failed, no students were added: $e');
      }
      return;
    }

    if (mounted) {
      AppSnackBar.success(
        context,
        _createAccounts
            ? 'Imported ${list.length} students with login accounts (username and password = roll number).'
            : 'Imported ${list.length} students without login accounts.',
      );
      context.go('/admin/students');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDesktop = MediaQuery.of(context).size.width > AppBreakpoints.desktop;
    final validCount = _parsedRows.where((r) => r['status'] == 'Valid').length;

    if (_isLoading) {
      return ResponsiveScaffold(
        title: 'Bulk Student Import',
        currentPath: '/admin/students/import',
        body: const Padding(padding: EdgeInsets.all(24.0), child: SkeletonCard(height: 400)),
      );
    }

    return ResponsiveScaffold(
      title: 'Bulk Student Import',
      currentPath: '/admin/students/import',
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ConsoleHeader(
              title: 'Bulk Student Import Console',
              subtitle: 'Import class rosters via CSV files directly into specific sections.',
            ).animate().fadeIn(duration: 250.ms).slideY(begin: -0.05, curve: Curves.easeOut),
            const SizedBox(height: AppSpacing.xl),
            Expanded(
              child: ResponsiveTwoPane(
                left: SingleChildScrollView(child: _buildFormPanel(theme, validCount)),
                right: _buildPreviewPanel(theme, isDesktop),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormPanel(ThemeData theme, int validCount) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.card),
            side: BorderSide(color: theme.dividerColor.withValues(alpha: 0.15)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('1. Select Target Section', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: AppSpacing.md),
                DropdownButtonFormField<String>(
                  isExpanded: true,
                  value: _selectedSectionId,
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
                      _selectedSectionId = val;
                      _parsedRows.clear();
                      _fileName = null;
                    });
                  },
                  decoration: const InputDecoration(labelText: 'Class Section'),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.card),
            side: BorderSide(color: theme.dividerColor.withValues(alpha: 0.15)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('2. Upload CSV File', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Requires headers: "Roll Number" & "Student Name".',
                  style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: 11),
                ),
                const SizedBox(height: AppSpacing.lg),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(AppRadius.control),
                        ),
                        child: Text(
                          _fileName ?? 'No file selected',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: 13, color: _fileName == null ? theme.hintColor : theme.colorScheme.onSurface),
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    ElevatedButton(
                      onPressed: _pickAndParseFile,
                      child: const Text('Browse'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        if (_parsedRows.isNotEmpty) ...[
          CheckboxListTile(
            value: _createAccounts,
            onChanged: (v) => setState(() => _createAccounts = v ?? true),
            contentPadding: EdgeInsets.zero,
            controlAffinity: ListTileControlAffinity.leading,
            title: const Text('Create login accounts for imported students'),
            subtitle: const Text('Username and initial password are the roll number.'),
          ),
          const SizedBox(height: AppSpacing.sm),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.appColors.success,
              foregroundColor: Colors.white,
              minimumSize: const Size.fromHeight(56),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.card)),
            ),
            onPressed: _commitImport,
            icon: const Icon(Icons.save_rounded),
            label: Text('Commit Valid Imports ($validCount)'),
          ),
        ],
      ],
    );
  }

  Widget _buildPreviewPanel(ThemeData theme, bool isDesktop) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.card),
        side: BorderSide(color: theme.dividerColor.withValues(alpha: 0.15)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Parsed Student Roster Preview (${_parsedRows.length} rows)',
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: AppSpacing.lg),
            Expanded(
              child: SingleChildScrollView(
                child: AppDataTable(
                  isDesktop: isDesktop,
                  columns: const ['Roll No.', 'Name', 'Status'],
                  columnFlex: const [1, 2, 2],
                  emptyIcon: Icons.upload_file_outlined,
                  emptyTitle: 'No file parsed yet',
                  emptyMessage: 'Upload a CSV file to see the parsed roster preview.',
                  rows: _parsedRows.map((row) {
                    final isValid = row['status'] == 'Valid';
                    final statusColor = isValid ? theme.appColors.success : theme.appColors.danger;
                    final statusWidget = Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isValid ? Icons.check_circle_outline_rounded : Icons.error_outline_rounded,
                          color: statusColor,
                          size: 16,
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        Flexible(
                          child: Text(row['status'] as String,
                              style: TextStyle(color: statusColor, fontSize: 12, fontWeight: FontWeight.w600)),
                        ),
                      ],
                    );
                    return AppDataRow(
                      mobileTitle: row['name'] as String,
                      mobileSubtitle: 'Roll: ${row['roll']}',
                      mobileLeadingText: row['roll'] as String,
                      mobileTrailing: statusWidget,
                      cells: [
                        Text(row['roll'] as String),
                        Text(row['name'] as String, style: const TextStyle(fontWeight: FontWeight.w600)),
                        statusWidget,
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
