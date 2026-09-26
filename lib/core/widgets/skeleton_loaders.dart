import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class SkeletonLoader extends StatelessWidget {
  final double width;
  final double height;
  final BorderRadius? borderRadius;
  final Color? baseColor;
  final Color? highlightColor;

  const SkeletonLoader({
    super.key,
    this.width = double.infinity,
    this.height = 16,
    this.borderRadius,
    this.baseColor,
    this.highlightColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Built from onSurface at low alpha (rather than hardcoded hex) so the
    // shimmer always reads correctly against whatever surface it sits on,
    // in both themes, without per-theme upkeep.
    final base =
        baseColor ??
        theme.colorScheme.onSurface.withValues(alpha: isDark ? 0.08 : 0.06);
    final highlight =
        highlightColor ??
        theme.colorScheme.onSurface.withValues(alpha: isDark ? 0.18 : 0.12);

    return Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            color: base,
            borderRadius: borderRadius ?? BorderRadius.circular(8),
          ),
        )
        .animate(onPlay: (controller) => controller.repeat())
        .shimmer(duration: 1500.ms, color: highlight, size: 1.0);
  }
}

class SkeletonCard extends StatelessWidget {
  final double? height;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;

  const SkeletonCard({super.key, this.height, this.padding, this.margin});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      margin: margin,
      padding: padding ?? const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).dividerColor.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SkeletonLoader(
            width: 120,
            height: 20,
            borderRadius: BorderRadius.circular(4),
          ),
          const SizedBox(height: 16),
          SkeletonLoader(
            width: 200,
            height: 28,
            borderRadius: BorderRadius.circular(4),
          ),
          const SizedBox(height: 8),
          SkeletonLoader(
            width: 150,
            height: 16,
            borderRadius: BorderRadius.circular(4),
          ),
          const Spacer(),
          Row(
            children: [
              Flexible(
                child: SkeletonLoader(
                  width: 80,
                  height: 32,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              const SizedBox(width: 12),
              Flexible(
                child: SkeletonLoader(
                  width: 80,
                  height: 32,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class SkeletonMetricCard extends StatelessWidget {
  const SkeletonMetricCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).dividerColor.withValues(alpha: 0.2),
        ),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) => Row(
          children: [
            if (constraints.maxWidth >= 160) ...[
              SkeletonLoader(
                width: 56,
                height: 56,
                borderRadius: BorderRadius.circular(12),
              ),
              const SizedBox(width: 16),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SkeletonLoader(
                    width: 80,
                    height: 12,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  const SizedBox(height: 8),
                  SkeletonLoader(
                    width: 60,
                    height: 24,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  const SizedBox(height: 4),
                  SkeletonLoader(
                    width: 100,
                    height: 12,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SkeletonTableRow extends StatelessWidget {
  final int columnCount;
  final List<double>? columnWidths;

  const SkeletonTableRow({super.key, this.columnCount = 4, this.columnWidths});

  @override
  Widget build(BuildContext context) {
    final widths = columnWidths ?? List.filled(columnCount, 120.0);

    return Row(
      children: List.generate(columnCount, (index) {
        return Expanded(
          flex: widths.length > index ? (widths[index] ~/ 20).clamp(1, 10) : 1,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
            child: SkeletonLoader(
              height: 16,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        );
      }),
    );
  }
}

class SkeletonListItem extends StatelessWidget {
  final bool hasLeading;
  final bool hasTrailing;

  const SkeletonListItem({
    super.key,
    this.hasLeading = true,
    this.hasTrailing = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          if (hasLeading) ...[
            SkeletonLoader(
              width: 40,
              height: 40,
              borderRadius: BorderRadius.circular(20),
            ),
            const SizedBox(width: 16),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SkeletonLoader(
                  width: 120,
                  height: 16,
                  borderRadius: BorderRadius.circular(4),
                ),
                const SizedBox(height: 4),
                SkeletonLoader(
                  width: 80,
                  height: 12,
                  borderRadius: BorderRadius.circular(4),
                ),
              ],
            ),
          ),
          if (hasTrailing) ...[
            SkeletonLoader(
              width: 60,
              height: 24,
              borderRadius: BorderRadius.circular(8),
            ),
          ],
        ],
      ),
    );
  }
}

class SkeletonChart extends StatelessWidget {
  final int barCount;
  final double height;

  const SkeletonChart({super.key, this.barCount = 5, this.height = 200});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          SkeletonLoader(
            width: 180,
            height: 20,
            borderRadius: BorderRadius.circular(4),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                // Labels and gaps above/below each bar take 48px; bars use the
                // rest, and bar width shares the row with the gaps between bars.
                final maxBar = (constraints.maxHeight - 48).clamp(0.0, 100.0);
                final barWidth = (constraints.maxWidth / (barCount * 1.6))
                    .clamp(8.0, 38.0);
                final labelWidth = barWidth < 30 ? barWidth : 30.0;
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: List.generate(barCount, (index) {
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        SkeletonLoader(
                          width: labelWidth,
                          height: 16,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        const SizedBox(height: 8),
                        // Flexible lets the bar give up a few pixels rather than overflow.
                        Flexible(
                          child: Container(
                            width: barWidth,
                            height: maxBar * (index % 5 + 1) / 5,
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.onSurface
                                  .withValues(
                                    alpha:
                                        Theme.of(context).brightness ==
                                            Brightness.dark
                                        ? 0.08
                                        : 0.06,
                                  ),
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(8),
                                topRight: Radius.circular(8),
                              ),
                            ),
                          ).animate().shimmer(),
                        ),
                        const SizedBox(height: 12),
                        SkeletonLoader(
                          width: labelWidth,
                          height: 12,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ],
                    );
                  }),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class SkeletonSection extends StatelessWidget {
  final String title;
  final int itemCount;
  final Widget Function(int) itemBuilder;

  const SkeletonSection({
    super.key,
    required this.title,
    this.itemCount = 3,
    required this.itemBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: SkeletonLoader(
            width: 200,
            height: 24,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(height: 16),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: itemCount,
          itemBuilder: (context, index) => itemBuilder(index),
        ),
      ],
    );
  }
}

class SkeletonDashboard extends StatelessWidget {
  const SkeletonDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SkeletonLoader(
            width: 280,
            height: 32,
            borderRadius: BorderRadius.circular(4),
          ),
          const SizedBox(height: 8),
          SkeletonLoader(
            width: 400,
            height: 16,
            borderRadius: BorderRadius.circular(4),
          ),
          const SizedBox(height: 32),
          LayoutBuilder(
            builder: (context, constraints) {
              final columns = constraints.maxWidth > 1200
                  ? 5
                  : (constraints.maxWidth > 600 ? 3 : 2);
              const spacing = 16.0;
              final cardWidth =
                  (constraints.maxWidth - spacing * (columns - 1)) / columns;
              return Wrap(
                spacing: spacing,
                runSpacing: spacing,
                children: List.generate(
                  columns,
                  (_) => SizedBox(
                    width: cardWidth,
                    child: const SkeletonMetricCard(),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 32),
          LayoutBuilder(
            builder: (context, constraints) {
              const left = [
                SkeletonChart(barCount: 5, height: 220),
                SizedBox(height: 24),
                SkeletonCard(height: 300),
              ];
              const right = [
                SkeletonCard(height: 300),
                SizedBox(height: 24),
                SkeletonCard(height: 220),
              ];
              if (constraints.maxWidth < 700) {
                return const Column(
                  children: [...left, SizedBox(height: 24), ...right],
                );
              }
              return const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 3, child: Column(children: left)),
                  SizedBox(width: 24),
                  Expanded(flex: 2, child: Column(children: right)),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
