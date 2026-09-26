import 'package:intl/intl.dart';

import '../../prediction/engine/explanation.dart';
import 'pilot_evaluation.dart';

/// Shareable Markdown version of a [PilotReport]. Contains counts and rates
/// only: individual students are listed in the app, never in the export.
class PilotReportMarkdown {
  const PilotReportMarkdown._();

  static String _pct(double? v) => v == null ? '—' : '${(v * 100).toStringAsFixed(1)}%';
  static String _n2(double? v) => v == null ? '—' : v.toStringAsFixed(2);

  static String render(PilotReport r) {
    final b = StringBuffer();
    final date = DateFormat('d MMM yyyy, h:mm a').format(r.generatedAt);
    b.writeln('# ClassVault pilot evaluation ($date)');
    b.writeln();
    b.writeln('**Verdict:** ${r.verdict.message}');
    b.writeln();
    b.writeln('Predictions are compared with what actually happened in the predicted semester, using the same '
        'definition of academic difficulty as training. For each student and semester, the latest prediction '
        'faculty saw is used. ${r.includesTestModels ? 'Includes predictions from test (synthetic) models.' : 'Test (synthetic) models are excluded.'}');
    b.writeln();
    if (r.modelsEvaluated.isNotEmpty) {
      b.writeln('Models: ${r.modelsEvaluated.entries.map((e) => '`${e.key}` (${e.value})').join(', ')}');
      b.writeln();
    }

    b.writeln('## Criteria');
    b.writeln();
    b.writeln('| Check | Result | Detail |');
    b.writeln('|---|---|---|');
    for (final c in r.checks) {
      final status = switch (c.status) {
        CheckStatus.pass => 'PASS',
        CheckStatus.fail => 'FAIL',
        CheckStatus.insufficient => 'NOT YET',
      };
      b.writeln('| ${c.name} | $status | ${c.detail} |');
    }
    b.writeln();

    final risk = r.risk;
    b.writeln('## Academic risk');
    b.writeln();
    if (risk == null) {
      b.writeln('No risk predictions have known outcomes yet.');
    } else {
      b.writeln('| Metric | Value |');
      b.writeln('|---|---|');
      b.writeln('| Predictions with outcomes | ${risk.n} (${risk.positives} had difficulty) |');
      b.writeln('| Precision at "elevated" | ${_pct(risk.precision)} |');
      b.writeln('| Recall at "elevated" | ${_pct(risk.recall)} |');
      b.writeln('| True / false positives | ${risk.tp} / ${risk.fp} |');
      b.writeln('| False / true negatives | ${risk.fn} / ${risk.tn} |');
      b.writeln('| Brier score | ${risk.brier?.toStringAsFixed(3) ?? '—'} |');
      b.writeln('| Calibration error | ${_pct(risk.calibrationError)} |');
      b.writeln();
      b.writeln('| Band | Students | Mean predicted | Observed difficulty |');
      b.writeln('|---|---|---|---|');
      for (final band in risk.byBand) {
        b.writeln('| ${band.range} | ${band.n} | ${_pct(band.meanPredicted)} | ${_pct(band.observed)} |');
      }
      b.writeln();
      b.writeln('| Section | Students | Had difficulty | Precision | Recall |');
      b.writeln('|---|---|---|---|---|');
      for (final g in risk.groups) {
        b.writeln('| ${g.group} | ${g.n} | ${g.positives} | ${_pct(g.precision)} | ${_pct(g.recall)} |');
      }
    }
    b.writeln();

    final f = r.forecast;
    b.writeln('## SGPA forecast');
    b.writeln();
    if (f == null) {
      b.writeln('No forecasts have known outcomes yet.');
    } else {
      b.writeln('| Metric | Value |');
      b.writeln('|---|---|');
      b.writeln('| Forecasts with outcomes | ${f.n} |');
      b.writeln('| Average error (MAE) | ${_n2(f.mae)} SGPA (previous-SGPA baseline ${_n2(f.baselineMae)}) |');
      b.writeln('| Inside predicted range | ${_pct(f.coverage)}${f.expectedCoverage == null ? '' : ' (promised ${_pct(f.expectedCoverage)})'} |');
      b.writeln('| Average range width | ${_n2(f.meanWidth)} SGPA |');
    }
    b.writeln();

    final rev = r.reviews;
    final e = r.engagement;
    b.writeln('## Faculty use');
    b.writeln();
    b.writeln('| Measure | Value |');
    b.writeln('|---|---|');
    b.writeln('| Predictions reviewed | ${rev.reviewed} (${rev.agreed} agreed, ${rev.disagreed} disagreed) |');
    b.writeln('| Reviews matching the outcome | ${rev.facultyMatchedOutcome} of ${rev.reviewedWithOutcome} with known outcomes |');
    b.writeln('| Disagreements where the student had no difficulty | ${rev.disagreedAndNoDifficulty} |');
    b.writeln('| Elevated signals followed up within ${PilotCriteria.followUpWindowDays} days | '
        '${e.elevatedWithTimelyNote} of ${e.elevatedSignals} |');
    b.writeln('| Notes recorded | ${e.notes} |');
    b.writeln('| Follow-ups set / done / overdue | ${e.followUpsSet} / ${e.followUpsDone} / ${e.followUpsOverdue} |');
    b.writeln();

    final q = r.dataQuality;
    b.writeln('## Data quality');
    b.writeln();
    b.writeln('- Students without any academic history: ${q.studentsWithoutHistory} of ${q.studentsTotal}');
    b.writeln('- Imports: ${q.imports.length}; ${q.importedRecords} records imported, ${q.rejectedRows} rows rejected, '
        '${q.warnings} warnings');
    final missing = q.missingInputs.take(5).toList();
    if (missing.isNotEmpty) {
      b.writeln('- Most often missing inputs at prediction time: '
          '${missing.map((m) => '${ExplanationText.label(m.feature)} ${_pct(m.rate)}').join(', ')}');
    }
    b.writeln();
    b.writeln('---');
    b.writeln('Criteria are defined in `PilotCriteria` (lib/features/pilot/engine/pilot_evaluation.dart). '
        'Individual students are listed only in the app.');
    return b.toString();
  }
}
