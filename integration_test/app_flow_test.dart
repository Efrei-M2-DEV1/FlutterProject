import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutterproject/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('login then create task', (WidgetTester tester) async {
    app.main();

    // wait for splash screen to navigate to login
    await tester.pumpAndSettle(const Duration(seconds: 4));

    // fill login form
    await tester.enterText(
        find.byType(TextFormField).at(0), 'admin@todolist.com');
    await tester.enterText(
        find.byType(TextFormField).at(1), '123456');
    await tester.tap(find.text('Se connecter'));
    await tester.pumpAndSettle();

    // wait for tasks to load
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();

    // open form
    await tester.tap(find.text('Nouvelle tâche'));
    await tester.pumpAndSettle();

    // create task
    await tester.enterText(
        find.byType(TextFormField).first, 'Tâche intégration');
    await tester.tap(find.text('Créer'));
    await tester.pumpAndSettle();

    expect(find.text('Tâche intégration'), findsOneWidget);
  });
}
