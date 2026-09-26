import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/theme/app_color_scheme.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/utils/file_saver.dart';
import '../../core/utils/id_generator.dart';
import '../../core/widgets/app_data_table.dart';
import '../../core/widgets/app_dialogs.dart';
import '../../core/widgets/app_snackbar.dart';
import '../../core/widgets/console_header.dart';
import '../../core/widgets/responsive_scaffold.dart';
import '../../core/widgets/stat_card.dart';
import '../../data/models/models.dart';
import '../../data/services/providers.dart';
import '../auth/auth_provider.dart';
import 'engine/column_mapper.dart';
import 'engine/import_schema.dart';
import 'engine/import_validator.dart';
import 'engine/template_builder.dart';
import 'engine/workbook_reader.dart';

enum _Step { upload, map, preview, done }

/// Excel/CSV import of academic history: upload → map columns → validate &
/// preview → commit as one import batch that can be undone later.
class AcademicImportScreen extends ConsumerStatefulWidget {
  /// Starts at the mapping step with this workbook instead of the file
  /// picker, which widget tests cannot drive.
  @visibleForTesting
  final RawWorkbook? initialWorkbook;

  const AcademicImportScreen({super.key, this.initialWorkbook});

  @override
  ConsumerState<AcademicImportScreen> createState() => _AcademicImportScreenState();
}

class _AcademicImportScreenState extends ConsumerState<AcademicImportScreen> {
  static const _path = '/admin/academic-import';
  static const _maxIssuesShown = 500;

  _Step _step = _Step.upload;
  bool _busy = false;

  RawWorkbook? _workbook;
  Map<String, SheetMapping> _mappings = {};
  ImportPlan? _plan;
  bool _showErrors = true;

  List<ImportBatch> _batches = [];

  @override
  void initState() {
    super.initState();
    _loadBatches();
    final initial = widget.initialWorkbook;
    if (initial != null) _loadWorkbook(initial);
  }

  void _loadWorkbook(RawWorkbook workbook) {
    _workbook = workbook;
    _mappings = {for (final s in workbook.sheets) s.name: ColumnMapper.suggest(s)};
    _plan = null;
    _step = _Step.map;
  }

  Future<void> _loadBatches() async {
    final batches = await ref.read(academicHistoryRepositoryProvider).getImportBatches();
    if (mounted) setState(() => _batches = batches);
  }

  // ---------------------------------------------------------------------------
  // Actions
  // ---------------------------------------------------------------------------

  Future<void> _downloadTemplate() async {
    try {
      final saved = await saveBytesAsFile(
        fileName: TemplateBuilder.fileName,
        bytes: Uint8List.fromList(TemplateBuilder.build()),
        allowedExtensions: const ['xlsx'],
      );
      if (saved && mounted) AppSnackBar.success(context, 'Template saved.');
    } catch (e) {
      if (mounted) AppSnackBar.error(context, 'Could not save the template: $e');
    }
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['xlsx', 'csv'],
      withData: true,
    );
    if (result == null || result.files.isEmpty) return;
    final file = result.files.first;

    setState(() => _busy = true);
    try {
      final bytes = file.bytes;
      if (bytes == null) throw WorkbookReadException('Could not read the file.');
      final workbook = WorkbookReader.read(file.name, bytes);
      setState(() => _loadWorkbook(workbook));
      if (_mappings.values.every((m) => m.target == null) && mounted) {
        AppSnackBar.warning(context, 'No sheet was recognised automatically. Choose what each sheet contains.');
      }
    } catch (e) {
      if (mounted) AppSnackBar.error(context, e.toString().replaceAll('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _validate() async {
    final workbook = _workbook;
    if (workbook == null) return;
    setState(() => _busy = true);
    try {
      final academic = ref.read(academicRepositoryProvider);
      final results = await Future.wait([academic.getStudents(), academic.getSubjects()]);
      final plan = ImportValidator(
        students: results[0] as List<Student>,
        subjects: results[1] as List<Subject>,
      ).validate(workbook, _mappings);
      setState(() {
        _plan = plan;
        _showErrors = plan.errorCount > 0;
        _step = _Step.preview;
      });
    } catch (e) {
      if (mounted) AppSnackBar.error(context, 'Validation failed: $e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _commit() async {
    final plan = _plan;
    if (plan == null || plan.recordCount == 0) return;
    setState(() => _busy = true);
    try {
      await ref.read(academicHistoryRepositoryProvider).commitImport(
            batch: ImportBatch(
              id: IdGenerator.next('imp'),
              fileName: plan.fileName,
              importedAt: DateTime.now(),
              importedBy: ref.read(authStateProvider).valueOrNull?.uid,
              recordCount: plan.recordCount,
              notes: plan.summary,
            ),
            schoolResults: plan.schoolResults,
            semesterResults: plan.semesterResults,
            subjectResults: plan.subjectResults,
            attendanceSummaries: plan.attendanceSummaries,
            assessments: plan.assessments,
          );
      await _loadBatches();
      setState(() => _step = _Step.done);
    } catch (e) {
      if (mounted) AppSnackBar.error(context, 'Import failed, nothing was saved: $e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _undo(ImportBatch batch) async {
    final confirmed = await AppConfirmDialog.show(
      context,
      title: 'Undo this import?',
      message: 'Deletes the ${batch.recordCount} records "${batch.fileName}" created or last updated. '
          'Values it replaced from earlier imports are not restored.',
      confirmLabel: 'Undo Import',
      isDestructive: true,
      icon: Icons.undo_rounded,
    );
    if (!confirmed) return;
    try {
      await ref.read(academicHistoryRepositoryProvider).deleteImportBatch(batch.id);
      await _loadBatches();
      if (mounted) AppSnackBar.success(context, 'Import undone.');
    } catch (e) {
      if (mounted) AppSnackBar.error(context, 'Could not undo the import: $e');
    }
  }

  void _reset() {
    setState(() {
      _workbook = null;
      _mappings = {};
      _plan = null;
      _step = _Step.upload;
    });
  }

  void _setTarget(RawSheet sheet, ImportTarget? target) {
    setState(() {
      _mappings[sheet.name] = SheetMapping(
        target: target,
        columns: target == null ? const {} : ColumnMapper.suggestColumns(sheet, target),
      );
    });
  }

  void _setColumn(String sheetName, int column, ColumnTarget? target) {
    final mapping = _mappings[sheetName]!;
    final columns = Map<int, ColumnTarget>.of(mapping.columns);
    if (target == null) {
      columns.remove(column);
    } else {
      // A destination can only be fed by one column.
      columns.removeWhere((_, t) => t == target);
      columns[column] = target;
    }
    setState(() => _mappings[sheetName] = mapping.copyWith(columns: columns));
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ResponsiveScaffold(
      title: 'History Import',
      currentPath: _path,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ConsoleHeader(
                  title: 'Academic History Import',
                  subtitle: 'Bring in past results, marks and attendance from Excel or CSV.',
                  actionLabel: MediaQuery.of(context).size.width < 600 ? 'Template' : 'Download Template',
                  actionIcon: Icons.download_rounded,
                  onAction: _downloadTemplate,
                ).animate().fadeIn(duration: 250.ms).slideY(begin: -0.05, curve: Curves.easeOut),
                const SizedBox(height: AppSpacing.xl),
                _StepIndicator(current: _step),
                const SizedBox(height: AppSpacing.xl),
                if (_busy)
                  const Padding(
                    padding: EdgeInsets.all(AppSpacing.xxl),
                    child: Center(child: CircularProgressIndicator()),
                  )
                else
                  switch (_step) {
                    _Step.upload => _buildUpload(theme),
                    _Step.map => _buildMapping(theme),
                    _Step.preview => _buildPreview(theme),
                    _Step.done => _buildDone(theme),
                  },
                if (_step == _Step.upload || _step == _Step.done) ...[
                  const SizedBox(height: AppSpacing.xl),
                  _buildHistory(theme),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _card(ThemeData theme, {required Widget child}) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.card),
        side: BorderSide(color: theme.dividerColor.withValues(alpha: 0.15)),
      ),
      child: Padding(padding: const EdgeInsets.all(20), child: child),
    );
  }

  Widget _buildUpload(ThemeData theme) {
    return _card(
      theme,
      child: Column(
        children: [
          Icon(Icons.upload_file_rounded, size: 48, color: theme.colorScheme.primary),
          const SizedBox(height: AppSpacing.md),
          Text('Upload a workbook', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Use the ClassVault template or your own spreadsheet (.xlsx or .csv). '
            'You will confirm how columns map before anything is saved.\n'
            'Students must already exist in ClassVault; rows for unknown roll numbers are rejected.',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
          ),
          const SizedBox(height: AppSpacing.lg),
          FilledButton.icon(
            onPressed: _pickFile,
            icon: const Icon(Icons.folder_open_rounded),
            label: const Text('Choose File'),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 250.ms);
  }

  // Mapping ------------------------------------------------------------------

  Widget _buildMapping(ThemeData theme) {
    final workbook = _workbook!;
    final anySelected = _mappings.values.any((m) => m.target != null);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          '${workbook.fileName}: check what each sheet contains and where each column goes.',
          style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
        ),
        const SizedBox(height: AppSpacing.lg),
        for (final sheet in workbook.sheets) ...[
          _buildSheetMapping(theme, sheet),
          const SizedBox(height: AppSpacing.lg),
        ],
        Wrap(
          alignment: WrapAlignment.end,
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: [
            TextButton(onPressed: _reset, child: const Text('Cancel')),
            FilledButton.icon(
              onPressed: anySelected ? _validate : null,
              icon: const Icon(Icons.fact_check_rounded),
              label: const Text('Validate & Preview'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSheetMapping(ThemeData theme, RawSheet sheet) {
    final mapping = _mappings[sheet.name]!;
    final target = mapping.target;
    final rowCount = sheet.rows.where((r) => r.isNotEmpty).length;
    final missing = target == null
        ? const <ImportField>[]
        : target.requiredFields.where((f) => mapping.columnFor(f) == null).toList();

    return _card(
      theme,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Wrap(
            spacing: AppSpacing.lg,
            runSpacing: AppSpacing.sm,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(sheet.name, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                  Text('$rowCount rows · ${sheet.headers.length} columns',
                      style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                ],
              ),
              SizedBox(
                width: 280,
                child: DropdownButtonFormField<ImportTarget?>(
                  initialValue: target,
                  isExpanded: true,
                  decoration: const InputDecoration(labelText: 'This sheet contains', isDense: true),
                  items: [
                    const DropdownMenuItem(value: null, child: Text("Don't import this sheet")),
                    for (final t in ImportTarget.values)
                      DropdownMenuItem(value: t, child: Text(t.label)),
                  ],
                  onChanged: (t) => _setTarget(sheet, t),
                ),
              ),
            ],
          ),
          if (target != null) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(target.description,
                style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
            if (missing.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.sm),
              _Banner(
                color: theme.appColors.warning,
                icon: Icons.warning_amber_rounded,
                text: 'Required: ${missing.map((f) => f.label).join(', ')}. Map a column for each, '
                    'or this sheet will be skipped.',
              ),
            ],
            const SizedBox(height: AppSpacing.md),
            const Divider(height: 1),
            for (var col = 0; col < sheet.headers.length; col++)
              _buildColumnRow(theme, sheet, target, mapping, col),
          ],
        ],
      ),
    );
  }

  Widget _buildColumnRow(ThemeData theme, RawSheet sheet, ImportTarget target, SheetMapping mapping, int col) {
    final header = sheet.headers[col].isEmpty ? 'Column ${col + 1}' : sheet.headers[col];
    final samples = <String>[];
    for (var r = 0; r < sheet.rows.length && samples.length < 3; r++) {
      final v = sheet.cell(r, col);
      if (v != null) samples.add(v is DateTime ? DateFormat('yyyy-MM-dd').format(v) : '$v');
    }
    final current = mapping.columns[col];
    final options = <ColumnTarget>[
      for (final f in target.fields) ColumnTarget(f),
      if (current != null && current.semester != null) current,
    ];

    final dropdown = DropdownButtonFormField<ColumnTarget?>(
      initialValue: current,
      isExpanded: true,
      decoration: const InputDecoration(isDense: true),
      items: [
        const DropdownMenuItem(value: null, child: Text('Ignore')),
        for (final o in options) DropdownMenuItem(value: o, child: Text(o.label)),
      ],
      onChanged: (t) => _setColumn(sheet.name, col, t),
    );

    final info = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(header, style: const TextStyle(fontWeight: FontWeight.w600)),
        if (samples.isNotEmpty)
          Text(
            'e.g. ${samples.join(', ')}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
          ),
      ],
    );

    return Padding(
      // Keyed by target so the dropdown resets when the sheet target changes.
      key: ValueKey('${sheet.name}|${target.name}|$col|${current?.label}'),
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: LayoutBuilder(builder: (context, constraints) {
        if (constraints.maxWidth < 560) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [info, const SizedBox(height: AppSpacing.xs), dropdown],
          );
        }
        return Row(
          children: [
            Expanded(child: info),
            const Icon(Icons.arrow_forward_rounded, size: 18),
            const SizedBox(width: AppSpacing.md),
            SizedBox(width: 260, child: dropdown),
          ],
        );
      }),
    );
  }

  // Preview ------------------------------------------------------------------

  Widget _buildPreview(ThemeData theme) {
    final plan = _plan!;
    final isDesktop = MediaQuery.of(context).size.width > AppBreakpoints.desktop;
    final shown = plan.issues.where((i) => i.isError == _showErrors).toList();
    final errorRows = plan.sheets.fold<int>(0, (a, s) => a + s.errorRows);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Wrap(
          spacing: AppSpacing.lg,
          runSpacing: AppSpacing.lg,
          children: [
            for (final (label, value, icon, color) in [
              ('Records to import', '${plan.recordCount}', Icons.task_alt_rounded, theme.appColors.success),
              ('Rows rejected', '$errorRows', Icons.block_rounded, theme.appColors.danger),
              ('Warnings', '${plan.warningCount}', Icons.warning_amber_rounded, theme.appColors.warning),
            ])
              SizedBox(width: 240, child: StatCard(label: label, value: value, icon: icon, color: color)),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        _card(
          theme,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Sheets', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: AppSpacing.sm),
              for (final s in plan.sheets)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(
                    s.isSkipped ? Icons.block_rounded : Icons.table_chart_rounded,
                    color: s.isSkipped ? theme.appColors.danger : theme.colorScheme.primary,
                  ),
                  title: Text('${s.sheetName} → ${s.target.label}'),
                  subtitle: Text(s.isSkipped
                      ? 'Skipped: ${s.issues.firstWhere((i) => i.rowNumber == null).message}'
                      : '${s.validRows} of ${s.totalRows} rows valid · ${s.recordCount} records'),
                ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        _card(
          theme,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Wrap(
                spacing: AppSpacing.md,
                runSpacing: AppSpacing.sm,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text('Issues', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                  SegmentedButton<bool>(
                    segments: [
                      ButtonSegment(value: true, label: Text('Errors (${plan.errorCount})')),
                      ButtonSegment(value: false, label: Text('Warnings (${plan.warningCount})')),
                    ],
                    selected: {_showErrors},
                    onSelectionChanged: (s) => setState(() => _showErrors = s.first),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                _showErrors
                    ? 'Rows with errors are not imported. Fix them in the file and re-import, or import the valid rows now.'
                    : 'Warnings do not block the import.',
                style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
              ),
              const SizedBox(height: AppSpacing.md),
              AppDataTable(
                isDesktop: isDesktop,
                columns: const ['Sheet', 'Row', 'Roll No.', 'Issue'],
                columnFlex: const [2, 1, 2, 6],
                emptyIcon: Icons.check_circle_outline_rounded,
                emptyTitle: _showErrors ? 'No errors' : 'No warnings',
                rows: [
                  for (final i in shown.take(_maxIssuesShown))
                    AppDataRow(
                      mobileTitle: i.message,
                      mobileSubtitle: '${i.sheetName}${i.rowNumber == null ? '' : ' · row ${i.rowNumber}'}'
                          '${i.rollNumber == null ? '' : ' · ${i.rollNumber}'}',
                      mobileLeadingIcon: i.isError ? Icons.error_outline_rounded : Icons.warning_amber_rounded,
                      cells: [
                        Text(i.sheetName),
                        Text(i.rowNumber?.toString() ?? '—'),
                        Text(i.rollNumber ?? '—'),
                        Text(i.message),
                      ],
                    ),
                ],
              ),
              if (shown.length > _maxIssuesShown)
                Padding(
                  padding: const EdgeInsets.only(top: AppSpacing.sm),
                  child: Text('Showing the first $_maxIssuesShown of ${shown.length}.',
                      style: theme.textTheme.bodySmall),
                ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        Wrap(
          alignment: WrapAlignment.end,
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: [
            TextButton.icon(
              onPressed: () => setState(() => _step = _Step.map),
              icon: const Icon(Icons.arrow_back_rounded),
              label: const Text('Back to Mapping'),
            ),
            FilledButton.icon(
              style: FilledButton.styleFrom(backgroundColor: theme.appColors.success),
              onPressed: plan.recordCount == 0 ? null : _commit,
              icon: const Icon(Icons.save_rounded),
              label: Text('Import ${plan.recordCount} Records'),
            ),
          ],
        ),
      ],
    );
  }

  // Done & history -----------------------------------------------------------

  Widget _buildDone(ThemeData theme) {
    final plan = _plan!;
    return _card(
      theme,
      child: Column(
        children: [
          Icon(Icons.check_circle_rounded, size: 48, color: theme.appColors.success),
          const SizedBox(height: AppSpacing.md),
          Text('Imported ${plan.recordCount} records',
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: AppSpacing.xs),
          Text(plan.summary, textAlign: TextAlign.center),
          const SizedBox(height: AppSpacing.lg),
          FilledButton.icon(
            onPressed: _reset,
            icon: const Icon(Icons.upload_file_rounded),
            label: const Text('Import Another File'),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 250.ms).scaleXY(begin: 0.98, end: 1);
  }

  Widget _buildHistory(ThemeData theme) {
    final isDesktop = MediaQuery.of(context).size.width > AppBreakpoints.desktop;
    final format = DateFormat('d MMM yyyy, h:mm a');
    return _card(
      theme,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Import History', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: AppSpacing.md),
          AppDataTable(
            isDesktop: isDesktop,
            columns: const ['File', 'Imported', 'Records', 'Contents', ''],
            columnFlex: const [3, 2, 1, 4, 1],
            emptyIcon: Icons.history_rounded,
            emptyTitle: 'No imports yet',
            rows: [
              for (final b in _batches)
                AppDataRow(
                  mobileTitle: b.fileName,
                  mobileSubtitle: '${format.format(b.importedAt)} · ${b.recordCount} records',
                  mobileLeadingIcon: Icons.description_outlined,
                  mobileTrailing: _undoButton(b),
                  cells: [
                    Text(b.fileName, style: const TextStyle(fontWeight: FontWeight.w600)),
                    Text(format.format(b.importedAt)),
                    Text('${b.recordCount}'),
                    Text(b.notes ?? ''),
                    Align(alignment: Alignment.centerRight, child: _undoButton(b)),
                  ],
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _undoButton(ImportBatch b) => IconButton(
        icon: const Icon(Icons.undo_rounded),
        tooltip: 'Undo import',
        onPressed: () => _undo(b),
      );
}

class _StepIndicator extends StatelessWidget {
  final _Step current;
  const _StepIndicator({required this.current});

  static const _labels = ['Upload', 'Map Columns', 'Preview', 'Done'];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return LayoutBuilder(builder: (context, constraints) {
      // On narrow screens only the active step is labelled.
      final compact = constraints.maxWidth < 600;
      return Row(
        children: [
          for (var i = 0; i < _labels.length; i++) ...[
            if (i > 0) Expanded(child: Divider(color: theme.dividerColor)),
            _dot(theme, i, showLabel: !compact || i == current.index),
          ],
        ],
      );
    });
  }

  Widget _dot(ThemeData theme, int i, {required bool showLabel}) {
    final done = i < current.index;
    final active = i == current.index;
    final color = active || done ? theme.colorScheme.primary : theme.colorScheme.onSurfaceVariant;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        CircleAvatar(
          radius: 12,
          backgroundColor: active || done ? color : Colors.transparent,
          foregroundColor: theme.colorScheme.onPrimary,
          child: done
              ? const Icon(Icons.check_rounded, size: 14)
              : Text('${i + 1}',
                  style: TextStyle(fontSize: 12, color: active ? theme.colorScheme.onPrimary : color)),
        ),
        if (showLabel) ...[
          const SizedBox(width: AppSpacing.xs),
          Text(_labels[i],
              style: TextStyle(fontSize: 13, color: color, fontWeight: active ? FontWeight.bold : null)),
        ],
        const SizedBox(width: AppSpacing.xs),
      ],
    );
  }
}

class _Banner extends StatelessWidget {
  final Color color;
  final IconData icon;
  final String text;
  const _Banner({required this.color, required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppRadius.control),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: AppSpacing.sm),
          Expanded(child: Text(text, style: TextStyle(color: color, fontSize: 13))),
        ],
      ),
    );
  }
}
