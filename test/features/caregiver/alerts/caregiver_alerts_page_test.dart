import 'dart:async';

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
    await tester.pump();

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

  testWidgets('initial load shows skeleton without mock alerts or banner', (
    WidgetTester tester,
  ) async {
    final _PendingSource source = _PendingSource();

    await tester.pumpWidget(buildPage(source: source));

    expect(find.byKey(const Key('alerts-loading-skeleton')), findsOneWidget);
    expect(find.text('Alerts'), findsOneWidget);
    expect(find.text('Warning'), findsOneWidget);
    expect(find.text('Active Alerts'), findsOneWidget);
    expect(find.text('History'), findsOneWidget);
    expect(find.text('High Heart Rate'), findsNothing);
    expect(
      find.text('Live alerts unavailable. Showing fallback alerts.'),
      findsNothing,
    );
  });

  testWidgets('successful live data replaces the initial skeleton', (
    WidgetTester tester,
  ) async {
    final _PendingSource source = _PendingSource();
    await tester.pumpWidget(buildPage(source: source));

    source.succeed([_liveAlert()]);
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('alerts-loading-skeleton')), findsNothing);
    expect(find.text('Live Low SpO₂'), findsOneWidget);
    expect(find.text('High Heart Rate'), findsNothing);
    expect(
      find.text('Live alerts unavailable. Showing fallback alerts.'),
      findsNothing,
    );
  });

  testWidgets('successful empty response replaces skeleton without fallback', (
    WidgetTester tester,
  ) async {
    final _PendingSource source = _PendingSource();
    await tester.pumpWidget(buildPage(source: source));

    source.succeed(const []);
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('alerts-loading-skeleton')), findsNothing);
    expect(find.text('High Heart Rate'), findsNothing);
    expect(find.text('No active alerts right now'), findsOneWidget);
    expect(find.text('No alerts match the selected filters.'), findsOneWidget);
    expect(
      find.text('Live alerts unavailable. Showing fallback alerts.'),
      findsNothing,
    );
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
    await tester.pump();

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
    final _PendingSource source = _PendingSource();
    await tester.pumpWidget(buildPage(source: source));
    expect(find.text('High Heart Rate'), findsNothing);

    source.fail();
    await tester.pumpAndSettle();

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
    final List<CaregiverAlert> liveAlerts = [_liveAlert()];
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

class _PendingSource implements CaregiverAlertDataSource {
  final Completer<List<CaregiverAlert>> _completer = Completer();

  void succeed(List<CaregiverAlert> alerts) => _completer.complete(alerts);

  void fail() =>
      _completer.completeError(CaregiverAlertsRequestFailure('offline'));

  @override
  Future<List<CaregiverAlert>> fetchAlerts() => _completer.future;
}

CaregiverAlert _liveAlert() {
  return CaregiverAlert(
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
  );
}
