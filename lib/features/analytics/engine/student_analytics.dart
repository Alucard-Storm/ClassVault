import '../../../core/constants/app_constants.dart';
import '../../../data/models/models.dart';
import 'stats.dart';

/// Every cut-off the analytics use, in one place so they can be reviewed and
/// tuned against real outcomes. All analytics here are deterministic; there
/// is no ML in this layer.
class AnalyticsThresholds {
  const AnalyticsThresholds._();

  /// Trends use the most recent N semesters (or assessments).
  static const trendWindow = 4;

  /// Minimum change per semester for a trend to count as improving/declining.
  static const sgpaTrendPerSemester = 0.15;
  static const percentageTrendPerSemester = 1.5;
  static const attendanceTrendPerSemester = 3.0;

  /// Minimum change in score % per assessment for a within-subject trend.
  static const assessmentTrendPerStep = 5.0;
  static const minAssessmentsForTrend = 3;

  /// Bands for consistency, measured as the standard deviation of each
  /// semester around the student's own trend line (SGPA / percentage
  /// points). Detrending means steady improvement or decline is not mistaken
  /// for volatility; only erratic swings are.
  static const sgpaConsistent = 0.3;
  static const sgpaModerate = 0.6;
  static const percentageConsistent = 3.0;
  static const percentageModerate = 6.0;
  static const minPointsForConsistency = 3;

  /// A subject is a relative strength/weakness when its score differs from
  /// the student's own average by at least this many percentage points.
  static const subjectRelativeBand = 10.0;
  static const minSubjectsForRelative = 3;

  static const attendanceThreshold = AppConstants.minAttendanceThreshold;
}

enum TrendDirection { improving, stable, declining, insufficientData }

class TrendResult {
  final TrendDirection direction;

  /// Least-squares slope in units per step (semester or assessment).
  final double? slope;
  final int points;
  final String explanation;

  const TrendResult(this.direction, this.slope, this.points, this.explanation);

  static TrendResult compute(
    List<SemesterPoint> series, {
    required double threshold,
    required String unit,
    String step = 'semester',
    int window = AnalyticsThresholds.trendWindow,
  }) {
    final recent = series.length > window ? series.sublist(series.length - window) : series;
    if (recent.length < 2) {
      return TrendResult(
        TrendDirection.insufficientData,
        null,
        recent.length,
        'Needs at least 2 ${step}s of data.',
      );
    }
    final slope = Stats.slope(recent.map((p) => p.semester.toDouble()).toList(), recent.map((p) => p.value).toList());
    final direction = slope >= threshold
        ? TrendDirection.improving
        : slope <= -threshold
            ? TrendDirection.declining
            : TrendDirection.stable;
    final sign = slope >= 0 ? '+' : '−';
    return TrendResult(
      direction,
      slope,
      recent.length,
      '$sign${slope.abs().toStringAsFixed(2)} $unit per $step over the last ${recent.length} ${step}s '
      '(±${threshold.toStringAsFixed(threshold < 1 ? 2 : 1)} counts as stable).',
    );
  }

}

enum Consistency { consistent, moderate, variable, insufficientData }

/// One value per semester (or per step, for assessment trends).
class SemesterPoint {
  final int semester;
  final double value;
  const SemesterPoint(this.semester, this.value);

  @override
  String toString() => 'Sem $semester: $value';
}

/// Attendance for one subject in one semester, from an import or from
/// sessions marked in ClassVault.
class SubjectAttendance {
  final int semester;
  final String subjectName;
  final double percentage;
  final int? held;
  final int? attended;
  final bool fromSessions;

  const SubjectAttendance({
    required this.semester,
    required this.subjectName,
    required this.percentage,
    this.held,
    this.attended,
    this.fromSessions = false,
  });
}

enum SubjectStanding { strength, typical, weakness, unknown }

class SubjectPerformance {
  final int semester;
  final String subjectName;
  final double? scorePercent;
  final String? grade;
  final bool? passed;
  final int attempts;
  final SubjectStanding standing;

  const SubjectPerformance({
    required this.semester,
    required this.subjectName,
    required this.scorePercent,
    required this.grade,
    required this.passed,
    required this.attempts,
    required this.standing,
  });
}

class BacklogSummary {
  /// Subjects whose latest attempt failed.
  final List<SubjectPerformance> outstanding;

  /// Subjects failed at some point and later passed.
  final List<SubjectPerformance> cleared;

  /// Subjects failed on two or more attempts.
  final List<SubjectPerformance> repeated;

  /// Backlog count from the latest semester result, if reported.
  final int? reportedCount;

  /// Whether subject-level pass/fail data exists (otherwise [current] is the
  /// reported count).
  final bool derivedFromSubjects;

  const BacklogSummary({
    required this.outstanding,
    required this.cleared,
    required this.repeated,
    required this.reportedCount,
    required this.derivedFromSubjects,
  });

  int get current => derivedFromSubjects ? outstanding.length : (reportedCount ?? 0);
  int get everFailed => outstanding.length + cleared.length;
}

class AssessmentTrend {
  final int semester;
  final String subjectName;
  final TrendResult trend;
  final List<SemesterPoint> scores; // step index → score %

  const AssessmentTrend(this.semester, this.subjectName, this.trend, this.scores);
}

enum SignalLevel { attention, monitor, positive }

/// A neutral, explainable observation for faculty, never a label for the
/// student. Wording follows the governance guidance in the project plan.
class AnalyticsSignal {
  final SignalLevel level;
  final String message;
  const AnalyticsSignal(this.level, this.message);
}

class StudentAnalytics {
  final Student student;
  final StudentEnrollment? currentEnrollment;
  final Map<String, double> schoolResults; // level → %

  /// 'SGPA' when SGPA data exists, otherwise 'Percentage'.
  final String performanceMetric;
  final List<SemesterPoint> performanceSeries;
  final List<SemesterPoint> cgpaSeries;
  final double? cgpa;
  final bool cgpaEstimated;
  final double? latestPerformance;
  final double? recentWeightedAverage;
  final TrendResult performanceTrend;
  final double? volatility;
  final Consistency consistency;

  final List<SubjectAttendance> attendance;
  final List<SemesterPoint> attendanceSeries;
  final double? overallAttendance;
  final double? latestAttendance;
  final TrendResult attendanceTrend;
  final List<SubjectAttendance> lowAttendanceSubjects;

  final List<SubjectPerformance> subjects;
  final BacklogSummary backlogs;
  final List<AssessmentTrend> assessmentTrends;

  /// Mean score % across lab, practical and project assessments.
  final double? practicalScorePercent;
  final int practicalAssessments;
  final List<AnalyticsSignal> signals;

  const StudentAnalytics({
    required this.student,
    required this.currentEnrollment,
    required this.schoolResults,
    required this.performanceMetric,
    required this.performanceSeries,
    required this.cgpaSeries,
    required this.cgpa,
    required this.cgpaEstimated,
    required this.latestPerformance,
    required this.recentWeightedAverage,
    required this.performanceTrend,
    required this.volatility,
    required this.consistency,
    required this.attendance,
    required this.attendanceSeries,
    required this.overallAttendance,
    required this.latestAttendance,
    required this.attendanceTrend,
    required this.lowAttendanceSubjects,
    required this.subjects,
    required this.backlogs,
    required this.assessmentTrends,
    this.practicalScorePercent,
    this.practicalAssessments = 0,
    required this.signals,
  });

  bool get hasHistory => performanceSeries.isNotEmpty || attendance.isNotEmpty || subjects.isNotEmpty;

  SignalLevel? get highestSignal {
    if (signals.any((s) => s.level == SignalLevel.attention)) return SignalLevel.attention;
    if (signals.any((s) => s.level == SignalLevel.monitor)) return SignalLevel.monitor;
    return null;
  }
}

class StudentAnalyticsEngine {
  const StudentAnalyticsEngine._();

  static StudentAnalytics compute(
    StudentAcademicHistory history, {
    List<SubjectAttendance> sessionAttendance = const [],
    double attendanceThreshold = AnalyticsThresholds.attendanceThreshold,
  }) {
    final current = history.enrollments.where((e) => e.isCurrent).lastOrNull;

    // Performance ----------------------------------------------------------
    final results = [...history.semesterResults]..sort((a, b) => a.semesterNumber.compareTo(b.semesterNumber));
    final sgpa = [for (final r in results) if (r.sgpa != null) SemesterPoint(r.semesterNumber, r.sgpa!)];
    final pct = [for (final r in results) if (r.percentage != null) SemesterPoint(r.semesterNumber, r.percentage!)];
    final useSgpa = sgpa.isNotEmpty || pct.isEmpty;
    final series = useSgpa ? sgpa : pct;
    final metric = useSgpa ? 'SGPA' : 'Percentage';

    final cgpaSeries = [for (final r in results) if (r.cgpa != null) SemesterPoint(r.semesterNumber, r.cgpa!)];
    double? cgpa;
    var cgpaEstimated = false;
    if (cgpaSeries.isNotEmpty) {
      cgpa = cgpaSeries.last.value;
    } else if (sgpa.isNotEmpty) {
      cgpa = sgpa.map((p) => p.value).reduce((a, b) => a + b) / sgpa.length;
      cgpaEstimated = true;
    }

    final trend = TrendResult.compute(
      series,
      threshold: useSgpa ? AnalyticsThresholds.sgpaTrendPerSemester : AnalyticsThresholds.percentageTrendPerSemester,
      unit: useSgpa ? 'SGPA' : 'percentage points',
    );

    double? volatility;
    var consistency = Consistency.insufficientData;
    if (series.length >= AnalyticsThresholds.minPointsForConsistency) {
      volatility = Stats.residualStdDev(
          series.map((p) => p.semester.toDouble()).toList(), series.map((p) => p.value).toList());
      final (tight, loose) = useSgpa
          ? (AnalyticsThresholds.sgpaConsistent, AnalyticsThresholds.sgpaModerate)
          : (AnalyticsThresholds.percentageConsistent, AnalyticsThresholds.percentageModerate);
      consistency = volatility < tight
          ? Consistency.consistent
          : volatility < loose
              ? Consistency.moderate
              : Consistency.variable;
    }

    // Attendance -----------------------------------------------------------
    final attendance = _mergeAttendance(history.attendanceSummaries, sessionAttendance);
    final attendanceSeries = attendanceBySemester(attendance);
    final attendanceTrend = TrendResult.compute(
      attendanceSeries,
      threshold: AnalyticsThresholds.attendanceTrendPerSemester,
      unit: 'percentage points',
    );
    final latestAttendanceSemester = attendanceSeries.lastOrNull?.semester;
    final lowSubjects = [
      for (final a in attendance)
        if (a.semester == latestAttendanceSemester && a.percentage < attendanceThreshold) a,
    ];

    // Subjects & backlogs --------------------------------------------------
    final (subjects, backlogs) = _subjects(history.subjectResults, results.lastOrNull?.backlogs);
    final assessmentTrends = _assessmentTrends(history.assessments);
    final practical = [
      for (final a in history.assessments)
        if (a.maxScore > 0 && _isPractical(a)) a.score / a.maxScore * 100,
    ];

    final analytics = StudentAnalytics(
      student: history.student,
      currentEnrollment: current,
      schoolResults: {for (final s in history.schoolResults) s.level: s.percentage},
      performanceMetric: metric,
      performanceSeries: series,
      cgpaSeries: cgpaSeries,
      cgpa: cgpa,
      cgpaEstimated: cgpaEstimated,
      latestPerformance: series.lastOrNull?.value,
      recentWeightedAverage: _recentWeighted(series),
      performanceTrend: trend,
      volatility: volatility,
      consistency: consistency,
      attendance: attendance,
      attendanceSeries: attendanceSeries,
      overallAttendance: attendanceSeries.isEmpty
          ? null
          : attendanceSeries.map((p) => p.value).reduce((a, b) => a + b) / attendanceSeries.length,
      latestAttendance: attendanceSeries.lastOrNull?.value,
      attendanceTrend: attendanceTrend,
      lowAttendanceSubjects: lowSubjects,
      subjects: subjects,
      backlogs: backlogs,
      assessmentTrends: assessmentTrends,
      practicalScorePercent: practical.isEmpty ? null : practical.reduce((a, b) => a + b) / practical.length,
      practicalAssessments: practical.length,
      signals: const [],
    );
    return analytics._withSignals(_signals(analytics, attendanceThreshold));
  }

  /// Attendance for the student's current section computed from sessions
  /// marked in ClassVault: per subject, held = sessions, attended = present.
  static List<SubjectAttendance> attendanceFromSessions({
    required String studentId,
    required int semester,
    required List<AttendanceSession> sectionSessions,
    required List<AttendanceRecord> records,
    required Map<String, String> subjectNames,
  }) {
    final present = {
      for (final r in records)
        if (r.studentId == studentId && r.status == 'present') r.sessionId,
    };
    final held = <String, int>{};
    final attended = <String, int>{};
    for (final s in sectionSessions) {
      held[s.subjectId] = (held[s.subjectId] ?? 0) + 1;
      if (present.contains(s.id)) attended[s.subjectId] = (attended[s.subjectId] ?? 0) + 1;
    }
    return [
      for (final e in held.entries)
        SubjectAttendance(
          semester: semester,
          subjectName: subjectNames[e.key] ?? e.key,
          percentage: (attended[e.key] ?? 0) / e.value * 100,
          held: e.value,
          attended: attended[e.key] ?? 0,
          fromSessions: true,
        ),
    ];
  }

  /// Class-wide averages and signal counts.
  static ClassSummary summarize(List<StudentAnalytics> students) => ClassSummary._(students);

  // ---------------------------------------------------------------------------

  static List<SubjectAttendance> _mergeAttendance(
    List<AttendanceSummary> imported,
    List<SubjectAttendance> fromSessions,
  ) {
    String key(int sem, String subject) => '$sem|${subject.trim().toLowerCase()}';
    final merged = <String, SubjectAttendance>{
      for (final a in imported)
        key(a.semesterNumber, a.subjectName): SubjectAttendance(
          semester: a.semesterNumber,
          subjectName: a.subjectName,
          percentage: a.percentage,
          held: a.classesHeld,
          attended: a.classesAttended,
        ),
    };
    // Imported figures win where both exist (they are the official record).
    for (final a in fromSessions) {
      merged.putIfAbsent(key(a.semester, a.subjectName), () => a);
    }
    return merged.values.toList()
      ..sort((a, b) {
        final bySem = a.semester.compareTo(b.semester);
        return bySem != 0 ? bySem : a.subjectName.compareTo(b.subjectName);
      });
  }

  /// Per-semester attendance: class-count weighted when every subject has
  /// counts, otherwise the mean of subject percentages.
  static List<SemesterPoint> attendanceBySemester(List<SubjectAttendance> attendance) {
    final bySem = <int, List<SubjectAttendance>>{};
    for (final a in attendance) {
      bySem.putIfAbsent(a.semester, () => []).add(a);
    }
    final sems = bySem.keys.toList()..sort();
    return [
      for (final sem in sems)
        SemesterPoint(sem, () {
          final items = bySem[sem]!;
          if (items.every((a) => a.held != null && a.attended != null && a.held! > 0)) {
            final held = items.fold<int>(0, (s, a) => s + a.held!);
            final attended = items.fold<int>(0, (s, a) => s + a.attended!);
            return attended / held * 100;
          }
          return items.map((a) => a.percentage).reduce((a, b) => a + b) / items.length;
        }()),
    ];
  }

  static (List<SubjectPerformance>, BacklogSummary) _subjects(List<SubjectResult> results, int? reportedBacklogs) {
    final groups = <String, List<SubjectResult>>{};
    for (final r in results) {
      groups.putIfAbsent('${r.semesterNumber}|${r.subjectName.trim().toLowerCase()}', () => []).add(r);
    }

    double? scoreOf(SubjectResult r) =>
        r.totalMarks != null && r.maxMarks != null && r.maxMarks! > 0 ? r.totalMarks! / r.maxMarks! * 100 : null;

    final latest = [
      for (final g in groups.values) (g..sort((a, b) => a.attempt.compareTo(b.attempt))).last,
    ];
    final scores = latest.map(scoreOf).whereType<double>().toList();
    final canRank = scores.length >= AnalyticsThresholds.minSubjectsForRelative;
    final mean = scores.isEmpty ? 0.0 : scores.reduce((a, b) => a + b) / scores.length;

    final outstanding = <SubjectPerformance>[];
    final cleared = <SubjectPerformance>[];
    final repeated = <SubjectPerformance>[];
    final subjects = <SubjectPerformance>[];
    var anyPassInfo = false;

    for (final g in groups.values) {
      final last = g.last;
      final score = scoreOf(last);
      final standing = !canRank || score == null
          ? SubjectStanding.unknown
          : score >= mean + AnalyticsThresholds.subjectRelativeBand
              ? SubjectStanding.strength
              : score <= mean - AnalyticsThresholds.subjectRelativeBand
                  ? SubjectStanding.weakness
                  : SubjectStanding.typical;
      final perf = SubjectPerformance(
        semester: last.semesterNumber,
        subjectName: last.subjectName,
        scorePercent: score,
        grade: last.grade,
        passed: last.passed,
        attempts: g.length,
        standing: standing,
      );
      subjects.add(perf);

      if (g.any((r) => r.passed != null)) anyPassInfo = true;
      final failures = g.where((r) => r.passed == false).length;
      if (last.passed == false) {
        outstanding.add(perf);
      } else if (failures > 0 && last.passed == true) {
        cleared.add(perf);
      }
      if (failures >= 2) repeated.add(perf);
    }

    subjects.sort((a, b) {
      final bySem = a.semester.compareTo(b.semester);
      return bySem != 0 ? bySem : a.subjectName.compareTo(b.subjectName);
    });

    return (
      subjects,
      BacklogSummary(
        outstanding: outstanding,
        cleared: cleared,
        repeated: repeated,
        reportedCount: reportedBacklogs,
        derivedFromSubjects: anyPassInfo,
      ),
    );
  }

  static List<AssessmentTrend> _assessmentTrends(List<Assessment> assessments) {
    final groups = <String, List<Assessment>>{};
    for (final a in assessments) {
      if (a.maxScore <= 0) continue;
      groups.putIfAbsent('${a.semesterNumber}|${a.subjectName.trim().toLowerCase()}', () => []).add(a);
    }
    final out = <AssessmentTrend>[];
    for (final g in groups.values) {
      if (g.length < AnalyticsThresholds.minAssessmentsForTrend) continue;
      // Dated assessments in date order; undated keep their recorded order.
      final ordered = [...g]..sort((a, b) {
          if (a.assessedOn == null || b.assessedOn == null) return 0;
          return a.assessedOn!.compareTo(b.assessedOn!);
        });
      final points = [
        for (var i = 0; i < ordered.length; i++) SemesterPoint(i + 1, ordered[i].score / ordered[i].maxScore * 100),
      ];
      out.add(AssessmentTrend(
        g.first.semesterNumber,
        g.first.subjectName,
        TrendResult.compute(
          points,
          threshold: AnalyticsThresholds.assessmentTrendPerStep,
          unit: 'percentage points',
          step: 'assessment',
        ),
        points,
      ));
    }
    out.sort((a, b) => a.semester != b.semester
        ? a.semester.compareTo(b.semester)
        : a.subjectName.compareTo(b.subjectName));
    return out;
  }

  static final _practicalPattern = RegExp(r'\b(lab|labs|practical|practicals|project|projects|viva)\b');

  static bool _isPractical(Assessment a) =>
      _practicalPattern.hasMatch('${a.assessmentType} ${a.title ?? ''}'.toLowerCase());

  static double? _recentWeighted(List<SemesterPoint> series) {
    if (series.isEmpty) return null;
    final recent = series.length > 3 ? series.sublist(series.length - 3) : series;
    var sum = 0.0, weights = 0.0;
    for (var i = 0; i < recent.length; i++) {
      sum += recent[i].value * (i + 1);
      weights += i + 1;
    }
    return sum / weights;
  }



  static List<AnalyticsSignal> _signals(StudentAnalytics a, double attendanceThreshold) {
    String fmt(double v) => v.toStringAsFixed(1);
    final signals = <AnalyticsSignal>[];

    if (a.backlogs.current > 0) {
      signals.add(AnalyticsSignal(SignalLevel.attention,
          '${a.backlogs.current} outstanding backlog${a.backlogs.current == 1 ? '' : 's'}'));
    }
    if (a.latestAttendance != null && a.latestAttendance! < attendanceThreshold) {
      signals.add(AnalyticsSignal(SignalLevel.attention,
          'Attendance ${fmt(a.latestAttendance!)}% in semester ${a.attendanceSeries.last.semester} '
          '(below ${attendanceThreshold.toInt()}%)'));
    }
    if (a.performanceTrend.direction == TrendDirection.declining) {
      signals.add(AnalyticsSignal(SignalLevel.attention, '${a.performanceMetric} declining: ${a.performanceTrend.explanation}'));
    }
    if (a.attendanceTrend.direction == TrendDirection.declining) {
      signals.add(AnalyticsSignal(SignalLevel.monitor, 'Attendance declining: ${a.attendanceTrend.explanation}'));
    }
    if (a.consistency == Consistency.variable) {
      signals.add(AnalyticsSignal(SignalLevel.monitor,
          '${a.performanceMetric} swings between semesters (±${a.volatility!.toStringAsFixed(2)} around its trend)'));
    }
    for (final t in a.assessmentTrends) {
      if (t.trend.direction == TrendDirection.declining) {
        signals.add(AnalyticsSignal(SignalLevel.monitor, '${t.subjectName} (sem ${t.semester}) assessment scores declining'));
      }
    }
    if (a.performanceTrend.direction == TrendDirection.improving) {
      signals.add(AnalyticsSignal(SignalLevel.positive, '${a.performanceMetric} improving: ${a.performanceTrend.explanation}'));
    }
    if (a.backlogs.cleared.isNotEmpty) {
      signals.add(AnalyticsSignal(SignalLevel.positive,
          'Cleared ${a.backlogs.cleared.length} earlier backlog${a.backlogs.cleared.length == 1 ? '' : 's'}'));
    }
    return signals;
  }
}

extension on StudentAnalytics {
  StudentAnalytics _withSignals(List<AnalyticsSignal> signals) => StudentAnalytics(
        student: student,
        currentEnrollment: currentEnrollment,
        schoolResults: schoolResults,
        performanceMetric: performanceMetric,
        performanceSeries: performanceSeries,
        cgpaSeries: cgpaSeries,
        cgpa: cgpa,
        cgpaEstimated: cgpaEstimated,
        latestPerformance: latestPerformance,
        recentWeightedAverage: recentWeightedAverage,
        performanceTrend: performanceTrend,
        volatility: volatility,
        consistency: consistency,
        attendance: attendance,
        attendanceSeries: attendanceSeries,
        overallAttendance: overallAttendance,
        latestAttendance: latestAttendance,
        attendanceTrend: attendanceTrend,
        lowAttendanceSubjects: lowAttendanceSubjects,
        subjects: subjects,
        backlogs: backlogs,
        assessmentTrends: assessmentTrends,
        practicalScorePercent: practicalScorePercent,
        practicalAssessments: practicalAssessments,
        signals: signals,
      );
}

class ClassSummary {
  final int studentCount;
  final int withHistory;
  final double? averageCgpa;
  final double? averageAttendance;
  final int attention;
  final int monitor;
  final int stable;
  final int improving;
  final int declining;
  final int withBacklogs;
  final int belowAttendance;

  ClassSummary._(List<StudentAnalytics> s)
      : studentCount = s.length,
        withHistory = s.where((a) => a.hasHistory).length,
        averageCgpa = _mean(s.map((a) => a.cgpa)),
        averageAttendance = _mean(s.map((a) => a.latestAttendance)),
        attention = s.where((a) => a.highestSignal == SignalLevel.attention).length,
        monitor = s.where((a) => a.highestSignal == SignalLevel.monitor).length,
        stable = s.where((a) => a.hasHistory && a.highestSignal == null).length,
        improving = s.where((a) => a.performanceTrend.direction == TrendDirection.improving).length,
        declining = s.where((a) => a.performanceTrend.direction == TrendDirection.declining).length,
        withBacklogs = s.where((a) => a.backlogs.current > 0).length,
        belowAttendance = s
            .where((a) => a.latestAttendance != null && a.latestAttendance! < AnalyticsThresholds.attendanceThreshold)
            .length;

  static double? _mean(Iterable<double?> values) {
    final v = values.whereType<double>().toList();
    return v.isEmpty ? null : v.reduce((a, b) => a + b) / v.length;
  }
}
