import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/theme/app_color_scheme.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/widgets/app_dialogs.dart';
import '../../core/widgets/app_snackbar.dart';
import '../../data/repositories/intervention_repository.dart';
import '../analytics/analytics_widgets.dart';
import '../auth/auth_provider.dart';
import 'attention_queue_screen.dart';
import 'intelligence_service.dart';
import 'student_intelligence_cards.dart';

final _reviewsProvider = FutureProvider.autoDispose
    .family<List<InterventionEntry>, ({String predictionId, String studentId})>((ref, key) async {
  final user = ref.watch(authStateProvider).valueOrNull;
  if (user == null) return const [];
  return ref.watch(intelligenceServiceProvider).reviewsOf(key.predictionId, key.studentId, user);
});

/// Lets faculty record whether they agree with a prediction. Disagreeing
/// (with a reason) removes its weight from the attention queue: faculty
/// judgement overrides the model.
class PredictionReviewCard extends ConsumerWidget {
  final String predictionId;
  final String studentId;
  const PredictionReviewCard({super.key, required this.predictionId, required this.studentId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final key = (predictionId: predictionId, studentId: studentId);
    final reviews = ref.watch(_reviewsProvider(key)).valueOrNull ?? const [];

    return AnalyticsCard(
      title: 'Faculty review',
      subtitle: 'Do you agree with this signal? Your view is recorded with the prediction. If you disagree, it no '
          'longer counts towards the attention queue.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final r in reviews)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    r.intervention.reviewAssessment == 'disagree'
                        ? Icons.thumb_down_alt_outlined
                        : Icons.thumb_up_alt_outlined,
                    size: 18,
                    color: r.intervention.reviewAssessment == 'disagree'
                        ? theme.appColors.warning
                        : theme.appColors.success,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      '${r.authorName ?? 'Someone'} '
                      '${r.intervention.reviewAssessment == 'disagree' ? 'disagreed' : 'agreed'} '
                      'on ${DateFormat('d MMM yyyy').format(r.intervention.createdAt)}: ${r.intervention.note}',
                      style: theme.textTheme.bodySmall,
                    ),
                  ),
                ],
              ),
            ),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              OutlinedButton.icon(
                onPressed: () => _review(context, ref, agree: true),
                icon: const Icon(Icons.thumb_up_alt_outlined, size: 18),
                label: const Text('Agree'),
              ),
              OutlinedButton.icon(
                onPressed: () => _review(context, ref, agree: false),
                icon: const Icon(Icons.thumb_down_alt_outlined, size: 18),
                label: const Text('Disagree'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _review(BuildContext context, WidgetRef ref, {required bool agree}) async {
    final reason = await showDialog<String>(context: context, builder: (_) => _ReasonDialog(agree: agree));
    if (reason == null) return;
    final user = ref.read(authStateProvider).valueOrNull;
    if (user == null) return;
    try {
      await ref.read(intelligenceServiceProvider).reviewPrediction(
            predictionId: predictionId,
            agree: agree,
            reason: reason,
            user: user,
          );
      ref.invalidate(_reviewsProvider((predictionId: predictionId, studentId: studentId)));
      ref.invalidate(interventionsProvider(studentId));
      ref.invalidate(attentionQueueProvider);
      if (context.mounted) AppSnackBar.success(context, 'Review recorded.');
    } catch (e) {
      if (context.mounted) AppSnackBar.error(context, '$e');
    }
  }
}

class _ReasonDialog extends StatefulWidget {
  final bool agree;
  const _ReasonDialog({required this.agree});

  @override
  State<_ReasonDialog> createState() => _ReasonDialogState();
}

class _ReasonDialogState extends State<_ReasonDialog> {
  final _formKey = GlobalKey<FormState>();
  final _reason = TextEditingController();

  @override
  void dispose() {
    _reason.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppFormDialog(
      title: widget.agree ? 'Agree with this signal' : 'Disagree with this signal',
      icon: widget.agree ? Icons.thumb_up_alt_outlined : Icons.thumb_down_alt_outlined,
      confirmLabel: 'Record Review',
      onConfirm: () {
        if (_formKey.currentState!.validate()) Navigator.of(context).pop(_reason.text);
      },
      child: Form(
        key: _formKey,
        child: TextFormField(
          controller: _reason,
          autofocus: true,
          minLines: 2,
          maxLines: 5,
          decoration: InputDecoration(
            labelText: widget.agree ? 'Comment (optional)' : 'Why? (required)',
            hintText: widget.agree ? null : 'e.g. the dip was due to illness and has since recovered',
          ),
          validator: (v) => !widget.agree && (v == null || v.trim().isEmpty) ? 'Say why you disagree' : null,
        ),
      ),
    );
  }
}
