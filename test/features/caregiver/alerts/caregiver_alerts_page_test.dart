import 'package:alera/features/caregiver/data/mock/mock_caregiver_repository.dart';
import 'package:alera/features/caregiver/data/api/caregiver_alert_api_data_source.dart';
import 'package:alera/features/caregiver/domain/models/caregiver_alert.dart';
import 'package:alera/features/caregiver/presentation/alerts/caregiver_alerts_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const MockCaregiverRepository repository = MockCaregiverRepository();

  Widget buildPage({CaregiverAlertDataSource? source}) {
    return MaterialApp(
      home: Scaffold(
        body: CaregiverAlertsPage(
          alerts: repository.getAlerts(),
          careRecipients: repository.getCareRecipients(),
          alertDataSource: source ?? _SuccessfulSource(repository.getAlerts()),
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

  testWidgets('API failure preserves mock fallback alerts and offers retry', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(buildPage(source: _FailingSource()));
    await tester.pump();

    expect(find.text('High Heart Rate'), findsOneWidget);
    expect(
      find.text('Live alerts unavailable. Showing fallback alerts.'),
      findsOneWidget,
    );
    expect(find.text('Retry'), findsOneWidget);
  });

  testWidgets('filters operate on the loaded live alert list', (
    WidgetTester tester,
  ) async {
    final List<CaregiverAlert> liveAlerts = [
      CaregiverAlert(
        id: 'live-spo2',
        careRecipientId: 'backend-patient',
        patientDisplayName: 'Nana',
        title: 'Live Low SpO₂',
        description: '',
        severity: CaregiverAlertSeverity.critical,
        metric: CaregiverAlertMetric.spo2,
        status: CaregiverAlertStatus.active,
        reading: 88,
        threshold: 92,
        unit: '%',
        triggerDuration: null,
        detectedAt: DateTime(2026, 9, 4),
        timeline: const [],
      ),
    ];
    await tester.pumpWidget(buildPage(source: _SuccessfulSource(liveAlerts)));
    await tester.pump();

    expect(find.text('Live Low SpO₂'), findsOneWidget);
    expect(find.text('High Heart Rate'), findsNothing);
    expect(find.text('Nana'), findsOneWidget);

    await tester.tap(find.text('HR'));
    await tester.pump();
    expect(find.text('Live Low SpO₂'), findsNothing);

    await tester.tap(find.text('HR'));
    await tester.tap(find.text('SpO2'));
    await tester.pump();
    expect(find.text('Live Low SpO₂'), findsOneWidget);
  });
}

class _SuccessfulSource implements CaregiverAlertDataSource {
  final List<CaregiverAlert> alerts;

  const _SuccessfulSource(this.alerts);

  @override
  Future<List<CaregiverAlert>> fetchAlerts() async => alerts;
}

class _FailingSource implements CaregiverAlertDataSource {
  @override
  Future<List<CaregiverAlert>> fetchAlerts() async =>
      throw Exception('offline');
}
