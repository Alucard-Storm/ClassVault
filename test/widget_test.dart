import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:classvault/app.dart';

void main() {
  testWidgets('App login screen smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      const ProviderScope(
        child: ClassVaultApp(),
      ),
    );
    await tester.pumpAndSettle();

    // Verify that CampusVault title is present.
    expect(find.text('CampusVault'), findsOneWidget);
    expect(find.text('Attendance Management System'), findsOneWidget);
    expect(find.text('Email Address'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);
  });
}
