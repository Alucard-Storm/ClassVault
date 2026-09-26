import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/native.dart';
import 'package:classvault/app.dart';
import 'package:classvault/data/database/app_database.dart';
import 'package:classvault/data/services/providers.dart';

void main() {
  testWidgets('Fresh install shows administrator setup', (WidgetTester tester) async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [appDatabaseProvider.overrideWithValue(db)],
        child: const ClassVaultApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('ClassVault'), findsAtLeastNWidgets(1));
    expect(find.text('Attendance Management System'), findsOneWidget);
    expect(find.text('Create Administrator'), findsOneWidget);
    expect(find.text('Email Address'), findsOneWidget);
  });
}
