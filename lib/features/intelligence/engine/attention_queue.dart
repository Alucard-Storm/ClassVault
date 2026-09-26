import '../../../data/models/models.dart';
import '../../../data/repositories/intervention_repository.dart';
import '../../analytics/engine/student_analytics.dart';
import '../../prediction/engine/explanation.dart';
import '../../prediction/engine/model_bundle.dart';
import 'readiness.dart';

/// Weights for ordering the attention queue. Documented so faculty can see
/// why a student is higher in the list.
class QueueWeights {
  const QueueWeights._();

  static const attentionSignal = 3;
  static const monitorSignal = 1;
  static const elevatedRisk = 4;
  static const moderateRisk = 2;
  static const overdueFollowUp = 3;

  /// A review or note within this many days counts as "recently reviewed".
  static const recentDays = 30;
}

enum QueueStatus {
  needsReview('Needs review'),
  inProgress('In progress'),
  recentlyReviewed('Recently reviewed');

  final String label;
  const QueueStatus(this.label);
}

class QueueInput {
  final StudentAnalytics analytics;
  final String sectionLabel;
  final PredictionView? latestRisk;
  final List<InterventionEntry> interventions; // newest first

  const QueueInput({
    required this.analytics,
    required this.sectionLabel,
    required this.latestRisk,
    required this.interventions,
  });
}

class QueueItem {
  final QueueInput input;
  final int priority;
  final QueueStatus status;
  final List<String> reasons;

  /// Faculty disagreed with the latest risk prediction, so it is ignored.
  final bool riskOverridden;
  final DateTime? overdueFollowUp;
  final ProjectReadiness readiness;

  const QueueItem({
    required this.input,
    required this.priority,
    required this.status,
    required this.reasons,
    required this.riskOverridden,
    required this.overdueFollowUp,
    required this.readiness,
  });

  Student get student => input.analytics.student;
}

class AttentionQueue {
  const AttentionQueue._();

  /// Students who need a look: attention/monitor signals, a moderate or
  /// elevated risk signal faculty have not overridden, or open follow-ups.
  static List<QueueItem> build(List<QueueInput> inputs, {DateTime? now}) {
    final today = now ?? DateTime.now();
    final items = <QueueItem>[];

    for (final input in inputs) {
      final a = input.analytics;
      final reasons = <String>[];
      var priority = 0;

      for (final s in a.signals) {
        if (s.level == SignalLevel.attention) {
          priority += QueueWeights.attentionSignal;
          reasons.add(s.message);
        } else if (s.level == SignalLevel.monitor) {
          priority += QueueWeights.monitorSignal;
          reasons.add(s.message);
        }
      }

      final risk = input.latestRisk;
      final review = risk == null
          ? null
          : input.interventions
              .map((e) => e.intervention)
              .where((i) => i.isReview && i.predictionId == risk.record.id)
              .firstOrNull;
      final overridden = review?.reviewAssessment == 'disagree';
      if (risk != null && !overridden && risk.band != null && risk.band != RiskBand.low) {
        priority += risk.band == RiskBand.elevated ? QueueWeights.elevatedRisk : QueueWeights.moderateRisk;
        reasons.add('Risk signal ${risk.band == RiskBand.elevated ? 'elevated' : 'moderate'} '
            '(${((risk.record.probability ?? 0) * 100).round()}%)${risk.record.synthetic ? ' from a test model' : ''}');
      } else if (overridden) {
        reasons.add('Faculty disagreed with the risk signal');
      }

      final open = input.interventions.map((e) => e.intervention).where((i) => i.isOpen && !i.isReview).toList();
      final overdue = open
          .map((i) => i.followUpOn)
          .whereType<DateTime>()
          .where((d) => d.isBefore(DateTime(today.year, today.month, today.day)))
          .fold<DateTime?>(null, (earliest, d) => earliest == null || d.isBefore(earliest) ? d : earliest);
      if (overdue != null) {
        priority += QueueWeights.overdueFollowUp;
        reasons.add('Follow-up overdue');
      }

      if (priority == 0 && open.isEmpty) continue;

      final latestActivity = input.interventions.firstOrNull?.intervention.createdAt;
      final status = open.isNotEmpty
          ? QueueStatus.inProgress
          : latestActivity != null && today.difference(latestActivity).inDays <= QueueWeights.recentDays
              ? QueueStatus.recentlyReviewed
              : QueueStatus.needsReview;

      items.add(QueueItem(
        input: input,
        priority: priority,
        status: status,
        reasons: reasons,
        riskOverridden: overridden,
        overdueFollowUp: overdue,
        readiness: ProjectReadiness.assess(a),
      ));
    }

    items.sort((x, y) {
      final byStatus = x.status.index.compareTo(y.status.index);
      if (byStatus != 0) return byStatus;
      final byPriority = y.priority.compareTo(x.priority);
      return byPriority != 0 ? byPriority : x.student.name.compareTo(y.student.name);
    });
    return items;
  }
}
