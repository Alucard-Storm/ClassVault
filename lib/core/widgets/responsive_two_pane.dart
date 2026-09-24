import 'package:flutter/material.dart';
import '../theme/app_tokens.dart';

/// A two-column desktop split (either a fixed-width left column, or a
/// proportional flex split) collapsing to a single stacked column below
/// [AppBreakpoints.twoPane]. Replaces the ~8 places that each
/// reimplemented this `LayoutBuilder` independently with slightly
/// different breakpoints/spacing.
///
/// Use the default constructor for "filters/action on the left, list on
/// the right" consoles (fixed [leftWidth]); use [ResponsiveTwoPane.flex]
/// for "main content + sidebar" dashboards where both columns should grow
/// proportionally with the window (e.g. a 3:2 split).
class ResponsiveTwoPane extends StatelessWidget {
  final Widget left;
  final Widget right;
  final double? leftWidth;
  final int? leftFlex;
  final int? rightFlex;
  final double spacing;

  const ResponsiveTwoPane({
    super.key,
    required this.left,
    required this.right,
    double this.leftWidth = 380,
    this.spacing = AppSpacing.xl,
  })  : leftFlex = null,
        rightFlex = null;

  const ResponsiveTwoPane.flex({
    super.key,
    required this.left,
    required this.right,
    int this.leftFlex = 3,
    int this.rightFlex = 2,
    this.spacing = AppSpacing.xl,
  }) : leftWidth = null;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < AppBreakpoints.twoPane) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              left,
              SizedBox(height: spacing),
              right,
            ],
          );
        }
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            leftWidth != null
                ? SizedBox(width: leftWidth, child: left)
                : Expanded(flex: leftFlex!, child: left),
            SizedBox(width: spacing),
            Expanded(flex: rightFlex ?? 1, child: right),
          ],
        );
      },
    );
  }
}
