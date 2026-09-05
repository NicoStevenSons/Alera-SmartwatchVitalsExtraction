import 'package:alera/features/caregiver/domain/models/caregiver_alert.dart';
import 'package:alera/features/caregiver/presentation/widgets/caregiver_alert_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('renders compact and expanded alert variants', (tester) async {
    final alert = CaregiverAlert(
      id: 'alert',
      careRecipientId: 'patient',
      title: 'High Heart Rate',
      description: 'Heart rate exceeded the threshold.',
      severity: CaregiverAlertSeverity.warning,
      metric: CaregiverAlertMetric.heartRate,
      status: CaregiverAlertStatus.active,
      reading: 120,
      threshold: 100,
      unit: 'BPM',
      triggerDuration: Duration(minutes: 5),
      detectedAt: DateTime(2026, 9, 4, 10),
      timeline: [],
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: CaregiverAlertCard(
            alert: alert,
            patientName: 'Maria Santos',
            showPatientName: true,
            expanded: true,
            unread: true,
          ),
        ),
      ),
    );

    expect(find.text('Maria Santos'), findsOneWidget);
    expect(find.text('High Heart Rate'), findsOneWidget);
    expect(find.text('View Details'), findsOneWidget);
    expect(find.text('Mark as Seen'), findsOneWidget);
    expect(find.byIcon(Icons.keyboard_arrow_up), findsOneWidget);
  });

  testWidgets('chevron toggles without making the body a detail action', (
    tester,
  ) async {
    bool toggleTapped = false;
    final alert = CaregiverAlert(
      id: 'alert',
      careRecipientId: 'patient',
      title: 'Alert',
      description: '',
      severity: CaregiverAlertSeverity.warning,
      metric: CaregiverAlertMetric.heartRate,
      status: CaregiverAlertStatus.active,
      reading: 110,
      threshold: 100,
      unit: 'BPM',
      triggerDuration: Duration(minutes: 1),
      detectedAt: DateTime(2026, 9, 4),
      timeline: [],
    );
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: CaregiverAlertCard(
            alert: alert,
            onToggleExpanded: () => toggleTapped = true,
          ),
        ),
      ),
    );
    await tester.tap(find.byIcon(Icons.keyboard_arrow_down));
    expect(toggleTapped, isTrue);
    expect(find.byType(CaregiverAlertCard), findsOneWidget);
    await tester.tap(find.text('Alert'));
    expect(toggleTapped, isTrue);
  });
}
