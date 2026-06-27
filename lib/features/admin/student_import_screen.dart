import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:csv/csv.dart';
import 'package:go_router/go_router.dart';
import '../../data/models/models.dart';
import '../../data/services/providers.dart';
import '../../core/widgets/responsive_scaffold.dart';

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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a target Section first!'), backgroundColor: Color(0xFFEF4444)),
      );
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
        final existsInDb = _existingStudents.any((s) => s.sectionId == _selectedSectionId && s.rollNumber == roll);
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
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Parsing Error'),
            content: Text(e.toString().replaceAll('Exception: ', '')),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK')),
            ],
          ),
        );
      }
    }
  }

  Future<void> _commitImport() async {
    final validRows = _parsedRows.where((r) => r['status'] == 'Valid').toList();
    if (validRows.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No valid students to import!'), backgroundColor: Color(0xFFF59E0B)),
      );
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

    await repo.addStudentsBulk(list);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Successfully imported ${list.length} students!'), backgroundColor: const Color(0xFF10B981)),
      );
      context.go('/admin/students');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDesktop = MediaQuery.of(context).size.width > 960;

    if (_isLoading) {
      return ResponsiveScaffold(
        title: 'Bulk Student Import',
        currentPath: '/admin/students/import',
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return ResponsiveScaffold(
      title: 'Bulk Student Import',
      currentPath: '/admin/students/import',
      body: isDesktop
          ? _buildDesktopLayout()
          : SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Step 1: Select Target Class Section', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      isExpanded: true,
                      value: _selectedSectionId,
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
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Step 2: Upload CSV File', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text(
                      'CSV columns required: "Roll Number" and "Student Name" (Header-sensitive).',
                      style: TextStyle(color: theme.colorScheme.onSurface.withValues(alpha: 0.5), fontSize: 12),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: theme.inputDecorationTheme.fillColor,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              _fileName ?? 'No file selected',
                              style: TextStyle(color: _fileName == null ? theme.hintColor : theme.colorScheme.onSurface),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size(120, 56),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          onPressed: _pickAndParseFile,
                          icon: const Icon(Icons.attach_file_rounded),
                          label: const Text('Browse'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            if (_parsedRows.isNotEmpty) ...[
              const SizedBox(height: 24),
              Text(
                'Step 3: Preview and Save',
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Card(
                child: ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _parsedRows.length,
                  separatorBuilder: (context, index) => const Divider(height: 1),
                  itemBuilder: (context, idx) {
                    final row = _parsedRows[idx];
                    final isValid = row['status'] == 'Valid';
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: isValid ? const Color(0xFF10B981).withValues(alpha: 0.1) : const Color(0xFFEF4444).withValues(alpha: 0.1),
                        child: Text(
                          row['roll'] as String,
                          style: TextStyle(
                            color: isValid ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      title: Text(row['name'] as String, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text('Status: ${row['status']}'),
                      trailing: Icon(
                        isValid ? Icons.check_circle_outline_rounded : Icons.error_outline_rounded,
                        color: isValid ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF10B981),
                  minimumSize: const Size.fromHeight(56),
                ),
                onPressed: _commitImport,
                icon: const Icon(Icons.save_rounded),
                label: Text('Commit Valid Imports (${_parsedRows.where((r) => r['status'] == 'Valid').length})'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDesktopLayout() {
    final theme = Theme.of(context);
    final validCount = _parsedRows.where((r) => r['status'] == 'Valid').length;

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Bulk Student Import Console',
            style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            'Import class rosters via CSV files directly into specific sections.',
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
                            Text('1. Select Target Section', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                            const SizedBox(height: 12),
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
                    const SizedBox(height: 16),
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
                            Text('2. Upload CSV File', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                            const SizedBox(height: 6),
                            Text(
                              'Requires headers: "Roll Number" & "Student Name".',
                              style: TextStyle(color: theme.colorScheme.onSurface.withValues(alpha: 0.5), fontSize: 11),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      _fileName ?? 'No file selected',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(fontSize: 13, color: _fileName == null ? theme.hintColor : theme.colorScheme.onSurface),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    minimumSize: const Size(90, 44),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                  ),
                                  onPressed: _pickAndParseFile,
                                  child: const Text('Browse'),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (_parsedRows.isNotEmpty)
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF10B981),
                          foregroundColor: Colors.white,
                          minimumSize: const Size.fromHeight(56),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: _commitImport,
                        icon: const Icon(Icons.save_rounded),
                        label: Text('Commit Valid Imports ($validCount)'),
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
                          'Parsed Student Roster Preview (${_parsedRows.length} rows)',
                          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 16),
                        Expanded(
                          child: _parsedRows.isEmpty
                              ? Center(
                                  child: Text(
                                    'Upload a CSV file on the left to see the parsed roster preview.',
                                    style: TextStyle(color: theme.colorScheme.onSurface.withValues(alpha: 0.5)),
                                  ),
                                )
                              : ListView.builder(
                                  itemCount: _parsedRows.length,
                                  itemBuilder: (context, idx) {
                                    final row = _parsedRows[idx];
                                    final isValid = row['status'] == 'Valid';
                                    return Container(
                                      margin: const EdgeInsets.only(bottom: 8),
                                      child: Material(
                                        color: isValid ? const Color(0xFF10B981).withValues(alpha: 0.05) : const Color(0xFFEF4444).withValues(alpha: 0.05),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(8),
                                          side: BorderSide(color: isValid ? const Color(0xFF10B981).withValues(alpha: 0.1) : const Color(0xFFEF4444).withValues(alpha: 0.1)),
                                        ),
                                        clipBehavior: Clip.antiAlias,
                                        child: ListTile(
                                          leading: CircleAvatar(
                                            backgroundColor: isValid ? const Color(0xFF10B981).withValues(alpha: 0.1) : const Color(0xFFEF4444).withValues(alpha: 0.1),
                                            child: Text(
                                              row['roll'] as String,
                                              style: TextStyle(
                                                color: isValid ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                                                fontWeight: FontWeight.bold,
                                                fontSize: 11,
                                              ),
                                            ),
                                          ),
                                          title: Text(
                                            row['name'] as String,
                                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                          ),
                                          subtitle: Text(
                                            'Status: ${row['status']}',
                                            style: TextStyle(fontSize: 12, color: isValid ? const Color(0xFF047857) : const Color(0xFFB91C1C)),
                                          ),
                                          trailing: Icon(
                                            isValid ? Icons.check_circle_outline_rounded : Icons.error_outline_rounded,
                                            color: isValid ? const Color(0xFF10B981) : const Color(0xFFEF4444),
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

