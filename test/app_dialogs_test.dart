import 'package:classvault/core/theme/app_theme.dart';
import 'package:classvault/core/widgets/app_dialogs.dart';
import 'package:classvault/core/widgets/console_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// The app theme gives filled buttons a full-width minimum size; dialogs put
/// them in a button row, which used to fail layout. Guard both dialogs at a
/// phone width with a long confirm label.
void main() {
  for (final dark in [false, true]) {
    testWidgets('dialogs lay out under the app theme (${dark ? 'dark' : 'light'})', (tester) async {
      final theme = dark ? AppTheme.dark : AppTheme.light;
      tester.view.physicalSize = const Size(360, 740);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(MaterialApp(
        theme: theme,
        home: Scaffold(
          body: Column(
            children: [
              const AppConfirmDialog(
                title: 'Confirm', message: 'Message', confirmLabel: 'Activate Anyway', isDestructive: true),
              AppFormDialog(title: 'Form', confirmLabel: 'Change Password', onConfirm: () {}, child: const Text('x')),
            ],
          ),
        ),
      ));
      await tester.pumpAndSettle();
      expect(find.text('Activate Anyway'), findsOneWidget);
      expect(find.text('Change Password'), findsOneWidget);
    });
  }

  for (final width in [360.0, 1280.0]) {
    testWidgets('console header action lays out under the app theme at ${width.toInt()}px', (tester) async {
      tester.view.physicalSize = Size(width, 700);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: Padding(
            padding: const EdgeInsets.all(24),
            child: ConsoleHeader(title: 'Students', subtitle: 'Manage students', actionLabel: 'Attention Queue', onAction: () {}),
          ),
        ),
      ));
      await tester.pumpAndSettle();
      expect(find.text('Attention Queue'), findsOneWidget);
    });
  }
}
