import 'dart:convert';

import '../../../data/models/models.dart';
import '../../prediction/engine/feature_extractor.dart';

/// Pass/fail criteria for the pilot (Phase 8). They are proposals to agree
/// with faculty before the pilot starts, kept in one place.
class PilotCriteria {
  const PilotCriteria._();

  static const minOutcomes = 30;
  static const minPositives = 10;
  static const minPrecision = 0.5; // at least half of "elevated" students had difficulty
  static const minRecall = 0.6; // at least 60% of students with difficulty were flagged
  static const maxCalibrationError = 0.10; // expected calibration error
  static const minBandRows = 5;
  static const minGroupPositives = 5;
  static const maxGroupRecallGap = 0.20;
  static const coverageTolerance = 0.10;
  static const minReviews = 10;
  static const maxDisagreementRate = 0.30;
  static const maxRejectedRowRate = 0.05;
  static const maxMissingPrevSgpa = 0.20;

  /// A note within this many days of an elevated signal counts as follow-up.
  static const followUpWindowDays = 14;
}

enum CheckStatus { pass, fail, insufficient }

class PilotCheck {
  final String name;
  final CheckStatus status;
  final String detail;
  const PilotCheck(this.name, this.status, this.detail);
}

/// A prediction paired with what actually happened.
class EvaluatedPrediction {
  final PredictionRecord record;
  final String studentName;
  final String group;
  final double? actualRisk; // 1 = difficulty, 0 = none, null = not yet known
  final double? actualSgpa;
  const EvaluatedPrediction(this.record, this.studentName, this.group, this.actualRisk, this.actualSgpa);
}

class CalibrationBin {
  final String range;
  final int n;
  final double meanPredicted;
  final double observed;
  const CalibrationBin(this.range, this.n, this.meanPredicted, this.observed);
}

class GroupMetrics {
  final String group;
  final int n;
  final int positives;
  final double? precision;
  final double? recall;
  final double? mae;
  final double? coverage;
  const GroupMetrics(this.group, this.n, this.positives, {this.precision, this.recall, this.mae, this.coverage});
}

class RiskPilotMetrics {
  final int n, positives, tp, fp, fn, tn;
  final double? precision, recall, f1, brier, calibrationError;
  final List<CalibrationBin> calibration;
  final List<CalibrationBin> byBand; // range = band name
  final List<GroupMetrics> groups;
  final List<EvaluatedPrediction> falsePositives, falseNegatives;

  const RiskPilotMetrics({
    required this.n,
    required this.positives,
    required this.tp,
    required this.fp,
    required this.fn,
    required this.tn,
    required this.precision,
    required this.recall,
    required this.f1,
    required this.brier,
    required this.calibrationError,
    required this.calibration,
    required this.byBand,
    required this.groups,
    required this.falsePositives,
    required this.falseNegatives,
  });
}

class ForecastPilotMetrics {
  final int n;
  final double? mae, baselineMae, coverage, meanWidth, expectedCoverage;
  final List<GroupMetrics> groups;
  const ForecastPilotMetrics({
    required this.n,
    required this.mae,
    required this.baselineMae,
    required this.coverage,
    required this.meanWidth,
    required this.expectedCoverage,
    required this.groups,
  });
}

class ReviewMetrics {
  final int reviewed, agreed, disagreed;

  /// Reviews of predictions whose outcome is now known, and how often the
  /// faculty view matched it (agree & difficulty, or disagree & none).
  final int reviewedWithOutcome, facultyMatchedOutcome, disagreedAndNoDifficulty;
  const ReviewMetrics({
    required this.reviewed,
    required this.agreed,
    required this.disagreed,
    required this.reviewedWithOutcome,
    required this.facultyMatchedOutcome,
    required this.disagreedAndNoDifficulty,
  });
  double? get disagreementRate => reviewed == 0 ? null : disagreed / reviewed;
}

class EngagementMetrics {
  final int notes, followUpsSet, followUpsDone, followUpsOverdue;
  final int elevatedSignals, elevatedWithTimelyNote;
  const EngagementMetrics({
    required this.notes,
    required this.followUpsSet,
    required this.followUpsDone,
    required this.followUpsOverdue,
    required this.elevatedSignals,
    required this.elevatedWithTimelyNote,
  });
}

class DataQualityMetrics {
  final int predictionsChecked;
  final List<({String feature, double rate})> missingInputs; // most missing first
  final List<ImportBatch> imports;
  final int studentsTotal, studentsWithoutHistory;
  const DataQualityMetrics({
    required this.predictionsChecked,
    required this.missingInputs,
    required this.imports,
    required this.studentsTotal,
    required this.studentsWithoutHistory,
  });

  int get importedRecords => imports.fold(0, (a, b) => a + b.recordCount);
  int get rejectedRows => imports.fold(0, (a, b) => a + (b.rejectedRows ?? 0));
  int get warnings => imports.fold(0, (a, b) => a + (b.warningCount ?? 0));
  double? get rejectedRate => importedRecords + rejectedRows == 0 ? null : rejectedRows / (importedRecords + rejectedRows);
  double missingRate(String feature) => missingInputs.where((m) => m.feature == feature).firstOrNull?.rate ?? 0;
}

enum PilotVerdict {
  continuePilot('Criteria met so far: continue the pilot with faculty oversight.'),
  keepCollecting('Not enough outcomes yet to judge the models. Keep collecting data.'),
  doNotRely('One or more criteria failed: do not rely on predictions until this is resolved.');

  final String message;
  const PilotVerdict(this.message);
}

class PilotReport {
  final DateTime generatedAt;
  final bool includesTestModels;
  final Map<String, int> modelsEvaluated; // modelId -> predictions
  final RiskPilotMetrics? risk;
  final ForecastPilotMetrics? forecast;
  final ReviewMetrics reviews;
  final EngagementMetrics engagement;
  final DataQualityMetrics dataQuality;
  final List<PilotCheck> checks;

  const PilotReport({
    required this.generatedAt,
    required this.includesTestModels,
    required this.modelsEvaluated,
    required this.risk,
    required this.forecast,
    required this.reviews,
    required this.engagement,
    required this.dataQuality,
    required this.checks,
  });

  PilotVerdict get verdict => checks.any((c) => c.status == CheckStatus.fail)
      ? PilotVerdict.doNotRely
      : checks.any((c) => c.status == CheckStatus.insufficient)
          ? PilotVerdict.keepCollecting
          : PilotVerdict.continuePilot;
}

class PilotEvaluator {
  const PilotEvaluator._();

  static PilotReport evaluate({
    required List<PredictionRecord> predictions,
    required Map<String, StudentAcademicHistory> histories,
    required Map<String, String> sectionLabels,
    required Map<String, List<Intervention>> interventions,
    required List<ImportBatch> imports,
    required int studentsTotal,
    required int studentsWithoutHistory,
    Map<String, double> intervalLevels = const {},
    bool includeTestModels = false,
    DateTime? now,
  }) {
    final today = now ?? DateTime.now();
    final used = [
      for (final p in predictions)
        if (includeTestModels || !p.synthetic) p,
    ];

    // The prediction each student last saw per task and semester.
    final latest = <String, PredictionRecord>{};
    for (final p in used) {
      final key = '${p.task}|${p.studentId}|${p.targetSemester}';
      final current = latest[key];
      if (current == null || p.generatedAt.isAfter(current.generatedAt)) latest[key] = p;
    }

    final evaluated = <EvaluatedPrediction>[];
    for (final p in latest.values) {
      final h = histories[p.studentId];
      if (h == null) continue;
      final labels = FeatureExtractor.labels(h, p.targetSemester);
      final enrollment = h.enrollments.where((e) => e.semesterNumber == p.targetSemester).lastOrNull;
      final group = sectionLabels[enrollment?.sectionId ?? h.student.sectionId] ?? 'Unknown section';
      evaluated.add(EvaluatedPrediction(p, h.student.name, group, labels.risk, labels.sgpa));
    }

    final riskRows = [for (final e in evaluated) if (e.record.task == 'risk' && e.actualRisk != null) e];
    final forecastRows = [for (final e in evaluated) if (e.record.task == 'forecast' && e.actualSgpa != null) e];

    final risk = riskRows.isEmpty ? null : _risk(riskRows);
    final forecast = forecastRows.isEmpty ? null : _forecast(forecastRows, intervalLevels);
    final reviews = _reviews(interventions, {for (final e in evaluated) e.record.id: e});
    final engagement = _engagement(interventions, [for (final p in latest.values) if (p.task == 'risk') p], today);
    final dataQuality = DataQualityMetrics(
      predictionsChecked: latest.length,
      missingInputs: _missing(latest.values.toList()),
      imports: imports,
      studentsTotal: studentsTotal,
      studentsWithoutHistory: studentsWithoutHistory,
    );

    final counts = <String, int>{};
    for (final p in latest.values) {
      counts[p.modelId] = (counts[p.modelId] ?? 0) + 1;
    }

    return PilotReport(
      generatedAt: today,
      includesTestModels: includeTestModels,
      modelsEvaluated: counts,
      risk: risk,
      forecast: forecast,
      reviews: reviews,
      engagement: engagement,
      dataQuality: dataQuality,
      checks: _checks(risk, forecast, reviews, dataQuality),
    );
  }

  // ---------------------------------------------------------------------------

  static RiskPilotMetrics _risk(List<EvaluatedPrediction> rows) {
    bool flagged(EvaluatedPrediction e) => e.record.band == 'elevated';
    bool actual(EvaluatedPrediction e) => e.actualRisk == 1;
    final tp = rows.where((e) => flagged(e) && actual(e)).length;
    final fp = rows.where((e) => flagged(e) && !actual(e)).length;
    final fn = rows.where((e) => !flagged(e) && actual(e)).length;
    final tn = rows.length - tp - fp - fn;
    final precision = tp + fp == 0 ? null : tp / (tp + fp);
    final recall = tp + fn == 0 ? null : tp / (tp + fn);
    final f1 = precision == null || recall == null || precision + recall == 0
        ? null
        : 2 * precision * recall / (precision + recall);

    final probs = [for (final e in rows) (p: e.record.probability ?? 0, y: e.actualRisk!)];
    final brier = probs.map((r) => (r.p - r.y) * (r.p - r.y)).reduce((a, b) => a + b) / probs.length;

    final bins = <CalibrationBin>[];
    var ece = 0.0;
    for (var i = 0; i < 10; i++) {
      final lo = i / 10, hi = (i + 1) / 10;
      final inBin = probs.where((r) => r.p >= lo && (i == 9 ? r.p <= hi : r.p < hi)).toList();
      if (inBin.isEmpty) continue;
      final meanP = inBin.map((r) => r.p).reduce((a, b) => a + b) / inBin.length;
      final observed = inBin.map((r) => r.y).reduce((a, b) => a + b) / inBin.length;
      bins.add(CalibrationBin('${lo.toStringAsFixed(1)}–${hi.toStringAsFixed(1)}', inBin.length, meanP, observed));
      ece += inBin.length / probs.length * (meanP - observed).abs();
    }

    final byBand = <CalibrationBin>[];
    for (final band in ['low', 'moderate', 'elevated']) {
      final inBand = rows.where((e) => e.record.band == band).toList();
      if (inBand.isEmpty) continue;
      byBand.add(CalibrationBin(
        band,
        inBand.length,
        inBand.map((e) => e.record.probability ?? 0).reduce((a, b) => a + b) / inBand.length,
        inBand.map((e) => e.actualRisk!).reduce((a, b) => a + b) / inBand.length,
      ));
    }

    final groups = <GroupMetrics>[];
    final byGroup = <String, List<EvaluatedPrediction>>{};
    for (final e in rows) {
      byGroup.putIfAbsent(e.group, () => []).add(e);
    }
    for (final entry in byGroup.entries) {
      final g = entry.value;
      final gtp = g.where((e) => flagged(e) && actual(e)).length;
      final gfp = g.where((e) => flagged(e) && !actual(e)).length;
      final gpos = g.where(actual).length;
      groups.add(GroupMetrics(
        entry.key,
        g.length,
        gpos,
        precision: gtp + gfp == 0 ? null : gtp / (gtp + gfp),
        recall: gpos == 0 ? null : gtp / gpos,
      ));
    }
    groups.sort((a, b) => a.group.compareTo(b.group));

    return RiskPilotMetrics(
      n: rows.length,
      positives: rows.where(actual).length,
      tp: tp,
      fp: fp,
      fn: fn,
      tn: tn,
      precision: precision,
      recall: recall,
      f1: f1,
      brier: brier,
      calibrationError: ece,
      calibration: bins,
      byBand: byBand,
      groups: groups,
      falsePositives: [for (final e in rows) if (flagged(e) && !actual(e)) e],
      falseNegatives: [for (final e in rows) if (!flagged(e) && actual(e)) e],
    );
  }

  static ForecastPilotMetrics _forecast(List<EvaluatedPrediction> rows, Map<String, double> levels) {
    double mae(List<EvaluatedPrediction> r) =>
        r.map((e) => (e.record.value! - e.actualSgpa!).abs()).reduce((a, b) => a + b) / r.length;
    double coverage(List<EvaluatedPrediction> r) =>
        r.where((e) => e.actualSgpa! >= e.record.lower! && e.actualSgpa! <= e.record.upper!).length / r.length;

    // Baseline: "next SGPA = previous SGPA", from the stored feature snapshot.
    final baseline = <double>[];
    for (final e in rows) {
      final prev = ((jsonDecode(e.record.featuresJson) as Map<String, dynamic>)['prev_sgpa'] as num?)?.toDouble();
      if (prev != null) baseline.add((prev - e.actualSgpa!).abs());
    }
    final expected = {for (final e in rows) levels[e.record.modelId]}.whereType<double>();

    final byGroup = <String, List<EvaluatedPrediction>>{};
    for (final e in rows) {
      byGroup.putIfAbsent(e.group, () => []).add(e);
    }
    return ForecastPilotMetrics(
      n: rows.length,
      mae: mae(rows),
      baselineMae: baseline.isEmpty ? null : baseline.reduce((a, b) => a + b) / baseline.length,
      coverage: coverage(rows),
      meanWidth: rows.map((e) => e.record.upper! - e.record.lower!).reduce((a, b) => a + b) / rows.length,
      expectedCoverage: expected.length == 1 ? expected.single : null,
      groups: [
        for (final entry in byGroup.entries)
          GroupMetrics(entry.key, entry.value.length, 0, mae: mae(entry.value), coverage: coverage(entry.value)),
      ]..sort((a, b) => a.group.compareTo(b.group)),
    );
  }

  static ReviewMetrics _reviews(Map<String, List<Intervention>> interventions, Map<String, EvaluatedPrediction> byId) {
    // Latest review per prediction.
    final latest = <String, Intervention>{};
    for (final list in interventions.values) {
      for (final i in list) {
        if (!i.isReview || i.predictionId == null) continue;
        final current = latest[i.predictionId!];
        if (current == null || i.createdAt.isAfter(current.createdAt)) latest[i.predictionId!] = i;
      }
    }
    var withOutcome = 0, matched = 0, disagreedNoDifficulty = 0;
    for (final entry in latest.entries) {
      final e = byId[entry.key];
      if (e == null || e.record.task != 'risk' || e.actualRisk == null) continue;
      withOutcome++;
      final agree = entry.value.reviewAssessment == 'agree';
      final difficulty = e.actualRisk == 1;
      if (agree == difficulty) matched++;
      if (!agree && !difficulty) disagreedNoDifficulty++;
    }
    return ReviewMetrics(
      reviewed: latest.length,
      agreed: latest.values.where((i) => i.reviewAssessment == 'agree').length,
      disagreed: latest.values.where((i) => i.reviewAssessment == 'disagree').length,
      reviewedWithOutcome: withOutcome,
      facultyMatchedOutcome: matched,
      disagreedAndNoDifficulty: disagreedNoDifficulty,
    );
  }

  static EngagementMetrics _engagement(
    Map<String, List<Intervention>> interventions,
    List<PredictionRecord> riskPredictions,
    DateTime today,
  ) {
    final notes = [
      for (final list in interventions.values)
        for (final i in list)
          if (!i.isReview) i,
    ];
    final day = DateTime(today.year, today.month, today.day);
    final elevated = [for (final p in riskPredictions) if (p.band == 'elevated') p];
    final timely = elevated.where((p) {
      final window = p.generatedAt.add(const Duration(days: PilotCriteria.followUpWindowDays));
      return (interventions[p.studentId] ?? const [])
          .any((i) => !i.isReview && !i.createdAt.isBefore(p.generatedAt) && !i.createdAt.isAfter(window));
    }).length;
    return EngagementMetrics(
      notes: notes.length,
      followUpsSet: notes.where((i) => i.followUpOn != null).length,
      followUpsDone: notes.where((i) => i.followUpOn != null && !i.isOpen).length,
      followUpsOverdue: notes.where((i) => i.isOpen && i.followUpOn != null && i.followUpOn!.isBefore(day)).length,
      elevatedSignals: elevated.length,
      elevatedWithTimelyNote: timely,
    );
  }

  static List<({String feature, double rate})> _missing(List<PredictionRecord> predictions) {
    if (predictions.isEmpty) return const [];
    final missing = <String, int>{};
    for (final p in predictions) {
      final f = jsonDecode(p.featuresJson) as Map<String, dynamic>;
      for (final name in FeatureSpec.names) {
        if (f[name] == null) missing[name] = (missing[name] ?? 0) + 1;
      }
    }
    return [
      for (final e in missing.entries) (feature: e.key, rate: e.value / predictions.length),
    ]..sort((a, b) => b.rate.compareTo(a.rate));
  }

  static String _pct(double v) => '${(v * 100).round()}%';

  static List<PilotCheck> _checks(
    RiskPilotMetrics? risk,
    ForecastPilotMetrics? forecast,
    ReviewMetrics reviews,
    DataQualityMetrics quality,
  ) {
    final checks = <PilotCheck>[];
    final enough = risk != null && risk.n >= PilotCriteria.minOutcomes && risk.positives >= PilotCriteria.minPositives;
    checks.add(PilotCheck(
      'Enough outcomes to judge',
      enough ? CheckStatus.pass : CheckStatus.insufficient,
      risk == null
          ? 'No risk predictions have known outcomes yet.'
          : '${risk.n} predictions with outcomes, ${risk.positives} with difficulty '
              '(need ${PilotCriteria.minOutcomes} and ${PilotCriteria.minPositives}).',
    ));

    CheckStatus judged(bool ok) => !enough ? CheckStatus.insufficient : (ok ? CheckStatus.pass : CheckStatus.fail);

    if (risk != null) {
      checks.add(PilotCheck(
        'Precision of "elevated"',
        judged((risk.precision ?? 0) >= PilotCriteria.minPrecision),
        risk.precision == null
            ? 'No student was rated elevated.'
            : '${_pct(risk.precision!)} of students rated elevated had difficulty '
                '(minimum ${_pct(PilotCriteria.minPrecision)}); ${risk.fp} false alarms.',
      ));
      checks.add(PilotCheck(
        'Recall of "elevated"',
        judged((risk.recall ?? 0) >= PilotCriteria.minRecall),
        risk.recall == null
            ? 'No student had difficulty.'
            : '${_pct(risk.recall!)} of students who had difficulty were rated elevated '
                '(minimum ${_pct(PilotCriteria.minRecall)}); ${risk.fn} missed.',
      ));
      checks.add(PilotCheck(
        'Calibration',
        judged((risk.calibrationError ?? 1) <= PilotCriteria.maxCalibrationError),
        'Predicted probabilities are off by ${_pct(risk.calibrationError ?? 0)} on average '
            '(maximum ${_pct(PilotCriteria.maxCalibrationError)}).',
      ));
      final bands = [for (final b in risk.byBand) if (b.n >= PilotCriteria.minBandRows) b];
      final ordered = [for (var i = 1; i < bands.length; i++) bands[i].observed >= bands[i - 1].observed].every((x) => x);
      checks.add(PilotCheck(
        'Bands are meaningful',
        bands.length < 2 ? CheckStatus.insufficient : judged(ordered),
        bands.isEmpty
            ? 'Not enough students in any band.'
            : 'Observed difficulty rate: ${bands.map((b) => '${b.range} ${_pct(b.observed)}').join(', ')} '
                '(should rise from low to elevated).',
      ));
      final judgedGroups = [
        for (final g in risk.groups)
          if (g.positives >= PilotCriteria.minGroupPositives && g.recall != null) g,
      ];
      final gaps = [for (final g in judgedGroups) ((g.recall! - (risk.recall ?? 0)).abs(), g)];
      final worst = gaps.isEmpty ? null : gaps.reduce((a, b) => a.$1 >= b.$1 ? a : b);
      checks.add(PilotCheck(
        'Stable across sections',
        judgedGroups.length < 2 ? CheckStatus.insufficient : judged(worst!.$1 <= PilotCriteria.maxGroupRecallGap),
        judgedGroups.length < 2
            ? 'Needs at least two sections with ${PilotCriteria.minGroupPositives}+ students who had difficulty.'
            : 'Largest recall gap: ${worst!.$2.group} at ${_pct(worst.$2.recall!)} vs ${_pct(risk.recall ?? 0)} overall '
                '(maximum gap ${_pct(PilotCriteria.maxGroupRecallGap)}).',
      ));
    }

    if (forecast != null) {
      final enoughForecast = forecast.n >= PilotCriteria.minOutcomes;
      final expected = forecast.expectedCoverage;
      checks.add(PilotCheck(
        'SGPA range coverage',
        !enoughForecast || expected == null
            ? CheckStatus.insufficient
            : ((forecast.coverage! - expected).abs() <= PilotCriteria.coverageTolerance ? CheckStatus.pass : CheckStatus.fail),
        '${_pct(forecast.coverage!)} of actual SGPAs fell inside the predicted range'
        '${expected == null ? '' : ' (model promises ${_pct(expected)}, tolerance ±${_pct(PilotCriteria.coverageTolerance)})'}; '
            '${forecast.n} outcomes.',
      ));
      checks.add(PilotCheck(
        'Forecast beats last semester\'s SGPA',
        !enoughForecast || forecast.baselineMae == null
            ? CheckStatus.insufficient
            : (forecast.mae! < forecast.baselineMae! ? CheckStatus.pass : CheckStatus.fail),
        'Average error ${forecast.mae!.toStringAsFixed(2)} SGPA vs '
        '${forecast.baselineMae?.toStringAsFixed(2) ?? '—'} for repeating the previous SGPA.',
      ));
    }

    checks.add(PilotCheck(
      'Faculty agree with signals',
      reviews.reviewed < PilotCriteria.minReviews
          ? CheckStatus.insufficient
          : (reviews.disagreementRate! <= PilotCriteria.maxDisagreementRate ? CheckStatus.pass : CheckStatus.fail),
      reviews.reviewed == 0
          ? 'No predictions reviewed yet (need ${PilotCriteria.minReviews}).'
          : 'Faculty disagreed with ${_pct(reviews.disagreementRate!)} of ${reviews.reviewed} reviewed predictions '
              '(maximum ${_pct(PilotCriteria.maxDisagreementRate)}).',
    ));

    final rejected = quality.rejectedRate;
    final missingPrev = quality.missingRate('prev_sgpa');
    checks.add(PilotCheck(
      'Data quality',
      rejected == null && quality.predictionsChecked == 0
          ? CheckStatus.insufficient
          : ((rejected ?? 0) <= PilotCriteria.maxRejectedRowRate && missingPrev <= PilotCriteria.maxMissingPrevSgpa
              ? CheckStatus.pass
              : CheckStatus.fail),
      '${rejected == null ? 'No import quality recorded' : '${_pct(rejected)} of imported rows rejected'} '
      '(maximum ${_pct(PilotCriteria.maxRejectedRowRate)}); previous SGPA missing for ${_pct(missingPrev)} of '
      'predictions (maximum ${_pct(PilotCriteria.maxMissingPrevSgpa)}).',
    ));
    return checks;
  }
}
