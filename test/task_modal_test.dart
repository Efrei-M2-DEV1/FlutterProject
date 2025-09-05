import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:flutterproject/features/tasks/presentation/providers/task_provider.dart';
import 'package:flutterproject/features/tasks/presentation/widgets/task_modal.dart';

void main() {
  testWidgets('TaskModal validates empty title', (WidgetTester tester) async {
    tester.binding.window.physicalSizeTestValue = const Size(800, 1200);
    tester.binding.window.devicePixelRatioTestValue = 1.0;
    addTearDown(tester.binding.window.clearPhysicalSizeTestValue);
    addTearDown(tester.binding.window.clearDevicePixelRatioTestValue);

    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => TaskProvider(),
        child: const MaterialApp(home: Scaffold(body: TaskModal())),
      ),
    );

    await tester.ensureVisible(find.text('Créer'));
    await tester.tap(find.text('Créer'));
    await tester.pump();

    expect(find.text('Le titre est obligatoire'), findsOneWidget);
  });
}
