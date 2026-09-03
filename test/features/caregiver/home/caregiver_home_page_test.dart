import 'package:alera/features/caregiver/caregiver_shell.dart';
import 'package:alera/features/caregiver/data/mock/mock_caregiver_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('renders real Home dashboard and fixed shell navigation', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: CaregiverShell(repository: MockCaregiverRepository()),
      ),
    );

    expect(find.text('Maria Santos'), findsOneWidget);
    expect(find.text('Needs Attention'), findsOneWidget);
    expect(find.text('Low Stress'), findsOneWidget);
    expect(find.text('Alerts (1 active)'), findsOneWidget);
    expect(find.byType(NavigationBar), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text("Today's Insights"),
      220,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text("Today's Insights"), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('View all Reminders'),
      220,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('View all Reminders'), findsOneWidget);
    expect(find.byType(NavigationBar), findsOneWidget);
  });

  testWidgets('Home actions are mock-only and links switch shell tabs', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: CaregiverShell(repository: MockCaregiverRepository()),
      ),
    );

    await tester.tap(find.text('Call').first);
    await tester.pump();
    expect(find.text('Call is mock-only for now.'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('View All Alerts'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('View All Alerts'));
    await tester.pumpAndSettle();

    final NavigationBar navigationBar = tester.widget(
      find.byType(NavigationBar),
    );
    expect(navigationBar.selectedIndex, 2);
  });
}
