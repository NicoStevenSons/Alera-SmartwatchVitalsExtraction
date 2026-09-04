import 'package:alera/features/caregiver/data/mock/mock_caregiver_repository.dart';
import 'package:alera/features/caregiver/presentation/alerts/caregiver_alerts_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const MockCaregiverRepository repository = MockCaregiverRepository();

  Widget buildPage() {
    return MaterialApp(
      home: Scaffold(
        body: CaregiverAlertsPage(
          alerts: repository.getAlerts(),
          careRecipients: repository.getCareRecipients(),
        ),
      ),
    );
  }

  testWidgets('renders filters, active section, and grouped history', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(buildPage());

    expect(find.text('Alerts'), findsOneWidget);
    expect(find.text('Warning'), findsOneWidget);
    expect(find.text('Critical'), findsOneWidget);
    expect(find.text('HR'), findsOneWidget);
    expect(find.text('SpO2'), findsOneWidget);
    expect(find.text('Unacknowledged'), findsOneWidget);
    expect(find.text('Active Alerts'), findsOneWidget);
    expect(find.text('High Heart Rate'), findsOneWidget);
    expect(find.text('History'), findsOneWidget);
    expect(find.text('Geraldine Laggui'), findsOneWidget);
  });

  testWidgets('filters combine and show an empty active result', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(buildPage());

    await tester.tap(find.text('Warning'));
    await tester.pump();
    await tester.ensureVisible(find.text('HR'));
    await tester.tap(find.text('HR'));
    await tester.pump();
    expect(find.text('High Heart Rate'), findsOneWidget);

    await tester.tap(find.text('SpO2'));
    await tester.pump();
    expect(find.text('No active alerts right now'), findsOneWidget);
    expect(find.text('No alerts match the selected filters.'), findsOneWidget);
  });

  testWidgets('alert cards show the next-step detail message', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(buildPage());

    await tester.tap(find.byIcon(Icons.keyboard_arrow_down).first);
    await tester.pump();
    final Finder viewMore = find.text('View Details').first;
    await tester.tap(viewMore);
    await tester.pump();
    expect(find.text('Alert detail coming next'), findsOneWidget);
  });
}
