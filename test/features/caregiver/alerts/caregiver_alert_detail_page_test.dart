import 'package:alera/features/caregiver/caregiver_shell.dart';
import 'package:alera/features/caregiver/data/mock/mock_caregiver_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('opens tapped alert detail and returns to Alerts', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: CaregiverShell(repository: MockCaregiverRepository()),
      ),
    );

    await tester.tap(find.text('Alerts'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('High Heart Rate').first);
    await tester.pumpAndSettle();

    expect(find.text('Alert Details'), findsOneWidget);
    expect(find.text('High Heart Rate'), findsWidgets);
    await tester.drag(find.byType(ListView), const Offset(0, -700));
    await tester.pumpAndSettle();
    expect(find.text('Call'), findsOneWidget);
    expect(find.text('Message'), findsOneWidget);
    expect(find.text('Acknowledge'), findsOneWidget);
    expect(find.text('Resolve'), findsOneWidget);
    expect(find.text('Add a note about this alert...'), findsOneWidget);
    expect(find.byType(NavigationBar), findsNothing);

    await tester.tap(find.byTooltip('Back'));
    await tester.pumpAndSettle();
    expect(find.text('Alerts'), findsWidgets);
    expect(find.byType(NavigationBar), findsOneWidget);
  });

  testWidgets('detail actions provide mock feedback', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: CaregiverShell(repository: MockCaregiverRepository()),
      ),
    );
    await tester.tap(find.text('Alerts'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('High Heart Rate').first);
    await tester.pumpAndSettle();

    await tester.drag(find.byType(ListView), const Offset(0, -700));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Call'));
    await tester.pump();
    expect(find.text('Call is mock-only for now.'), findsOneWidget);
  });
}
