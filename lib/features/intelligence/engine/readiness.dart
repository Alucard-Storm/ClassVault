import '../../analytics/engine/student_analytics.dart';

/// Transparent, rule-based project-readiness indicators (no ML), per the
/// plan: "Project readiness indicators: strong", never "best student".
/// All cut-offs live here so faculty can review and adjust them.
class ReadinessRules {
  const ReadinessRules._();

  static const sustainedSemesters = 3;
  static const minSgpa = 7.5;
  static const minPercentage = 75.0; // when only percentages are recorded
  static const minAttendance = 85.0;
  static const minPracticalScore = 70.0;

  /// Fewer evaluable criteria than this means "not enough data".
  static const minEvaluated = 4;
}

enum CriterionResult { met, notMet, noData }

class ReadinessCriterion {
  final String name;
  final String rule;
  final CriterionResult result;
  final String detail;
  const ReadinessCriterion(this.name, this.rule, this.result, this.detail);
}

enum ReadinessLevel {
  strong('Strong'),
  developing('Developing'),
  notIndicated('Not currently indicated'),
  insufficientData('Not enough data');

  final String label;
  const ReadinessLevel(this.label);
}

class ProjectReadiness {
  final ReadinessLevel level;
  final List<ReadinessCriterion> criteria;
  const ProjectReadiness(this.level, this.criteria);

  int get met => criteria.where((c) => c.result == CriterionResult.met).length;
  int get evaluated => criteria.where((c) => c.result != CriterionResult.noData).length;

  static ProjectReadiness assess(StudentAnalytics a) {
    String f1(double v) => v.toStringAsFixed(1);
    String f2(double v) => v.toStringAsFixed(2);
    final criteria = <ReadinessCriterion>[];

    // 1. Sustained performance over recent semesters.
    final isSgpa = a.performanceMetric == 'SGPA';
    final floor = isSgpa ? ReadinessRules.minSgpa : ReadinessRules.minPercentage;
    final recent = a.performanceSeries.length >= ReadinessRules.sustainedSemesters
        ? a.performanceSeries.sublist(a.performanceSeries.length - ReadinessRules.sustainedSemesters)
        : null;
    criteria.add(ReadinessCriterion(
      'Sustained performance',
      '${a.performanceMetric} ≥ ${isSgpa ? f2(floor) : '${f1(floor)}%'} in each of the last ${ReadinessRules.sustainedSemesters} semesters',
      recent == null
          ? CriterionResult.noData
          : recent.every((p) => p.value >= floor)
              ? CriterionResult.met
              : CriterionResult.notMet,
      recent == null
          ? 'Needs ${ReadinessRules.sustainedSemesters} semesters of results'
          : recent.map((p) => 'S${p.semester} ${isSgpa ? f2(p.value) : '${f1(p.value)}%'}').join(', '),
    ));

    // 2. Consistency (not erratic).
    criteria.add(ReadinessCriterion(
      'Consistency',
      'Semester results do not swing widely around the trend',
      switch (a.consistency) {
        Consistency.consistent || Consistency.moderate => CriterionResult.met,
        Consistency.variable => CriterionResult.notMet,
        Consistency.insufficientData => CriterionResult.noData,
      },
      a.volatility == null ? 'Needs 3 semesters' : '±${f2(a.volatility!)} around the trend',
    ));

    // 3. Attendance.
    criteria.add(ReadinessCriterion(
      'Attendance',
      'Latest semester attendance ≥ ${f1(ReadinessRules.minAttendance)}%',
      a.latestAttendance == null
          ? CriterionResult.noData
          : a.latestAttendance! >= ReadinessRules.minAttendance
              ? CriterionResult.met
              : CriterionResult.notMet,
      a.latestAttendance == null ? 'No attendance recorded' : '${f1(a.latestAttendance!)}%',
    ));

    // 4. No outstanding backlogs.
    final hasBacklogData = a.backlogs.derivedFromSubjects || a.backlogs.reportedCount != null;
    criteria.add(ReadinessCriterion(
      'No outstanding backlogs',
      'Every attempted subject currently passed',
      !hasBacklogData
          ? CriterionResult.noData
          : a.backlogs.current == 0
              ? CriterionResult.met
              : CriterionResult.notMet,
      hasBacklogData ? '${a.backlogs.current} outstanding' : 'No backlog data',
    ));

    // 5. Recent trajectory.
    criteria.add(ReadinessCriterion(
      'Recent trajectory',
      '${a.performanceMetric} trend is improving or stable',
      switch (a.performanceTrend.direction) {
        TrendDirection.improving || TrendDirection.stable => CriterionResult.met,
        TrendDirection.declining => CriterionResult.notMet,
        TrendDirection.insufficientData => CriterionResult.noData,
      },
      a.performanceTrend.explanation,
    ));

    // 6. Practical / lab / project work.
    criteria.add(ReadinessCriterion(
      'Practical & project work',
      'Average lab, practical and project assessment score ≥ ${f1(ReadinessRules.minPracticalScore)}%',
      a.practicalScorePercent == null
          ? CriterionResult.noData
          : a.practicalScorePercent! >= ReadinessRules.minPracticalScore
              ? CriterionResult.met
              : CriterionResult.notMet,
      a.practicalScorePercent == null
          ? 'No lab, practical or project assessments recorded'
          : '${f1(a.practicalScorePercent!)}% over ${a.practicalAssessments} assessments',
    ));

    final result = ProjectReadiness(ReadinessLevel.insufficientData, criteria);
    final level = result.evaluated < ReadinessRules.minEvaluated
        ? ReadinessLevel.insufficientData
        : result.met == result.evaluated
            ? ReadinessLevel.strong
            : result.met >= result.evaluated - 1
                ? ReadinessLevel.developing
                : ReadinessLevel.notIndicated;
    return ProjectReadiness(level, criteria);
  }
}
