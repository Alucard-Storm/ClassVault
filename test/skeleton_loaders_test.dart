import 'package:classvault/core/theme/app_theme.dart';
import 'package:classvault/core/widgets/skeleton_loaders.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Loading skeletons used to overflow on phones (fixed-width placeholders in
/// narrow columns). Any overflow fails these tests.
void main() {
  Future<void> pump(WidgetTester tester, Size size, Widget child) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(MaterialApp(theme: AppTheme.light, home: Scaffold(body: child)));
    // Shimmer animations repeat forever, so advance a few frames instead of settling.
    await tester.pump(const Duration(milliseconds: 100));
  }

  for (final width in [320.0, 390.0, 800.0, 1440.0]) {
    testWidgets('SkeletonDashboard lays out at ${width.toInt()}px', (tester) async {
      await pump(tester, Size(width, 900), const SkeletonDashboard());
      expect(find.byType(SkeletonMetricCard), findsWidgets);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('individual skeletons fit tight boxes', (tester) async {
    await pump(
      tester,
      const Size(390, 900),
      const SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(width: 100, child: SkeletonMetricCard()),
            SizedBox(width: 120, height: 200, child: SkeletonCard()),
            SizedBox(width: 110, height: 160, child: SkeletonChart(barCount: 5, height: 160)),
            SizedBox(width: 160, child: SkeletonListItem(hasTrailing: true)),
          ],
        ),
      ),
    );
    expect(tester.takeException(), isNull);
  });
}
