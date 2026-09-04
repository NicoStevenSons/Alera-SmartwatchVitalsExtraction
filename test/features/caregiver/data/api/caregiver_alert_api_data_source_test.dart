import 'dart:convert';

import 'package:alera/features/caregiver/data/api/caregiver_alert_api_data_source.dart';
import 'package:alera/features/caregiver/domain/models/caregiver_alert.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  test('maps heart-rate API JSON into the shared alert-card model', () async {
    final CaregiverAlertApiDataSource source = _sourceFor([
      _alertJson(
        alertId: 'hr-alert',
        conditionKey: 'HR_HIGH',
        metricType: 'HEART_RATE',
        severity: 'WARNING',
        reading: '121.00',
        unit: 'BPM',
        threshold: 100,
      ),
    ]);

    final CaregiverAlert alert = (await source.fetchAlerts()).single;

    expect(alert.id, 'hr-alert');
    expect(alert.careRecipientId, 'patient-1');
    expect(alert.patientDisplayName, 'Nana');
    expect(alert.metric, CaregiverAlertMetric.heartRate);
    expect(alert.severity, CaregiverAlertSeverity.warning);
    expect(alert.status, CaregiverAlertStatus.active);
    expect(alert.reading, 121);
    expect(alert.threshold, 100);
    expect(alert.unit, 'BPM');
    expect(alert.triggerDuration, const Duration(minutes: 5));
  });

  test('maps SpO2 API JSON and terminal lifecycle status', () async {
    final CaregiverAlertApiDataSource source = _sourceFor([
      _alertJson(
        alertId: 'spo2-alert',
        conditionKey: 'SPO2_LOW',
        metricType: 'SPO2',
        severity: 'CRITICAL',
        status: 'FALSE_ALARM',
        reading: 88.5,
        unit: '%',
        threshold: '92.00',
      ),
    ]);

    final CaregiverAlert alert = (await source.fetchAlerts()).single;

    expect(alert.metric, CaregiverAlertMetric.spo2);
    expect(alert.severity, CaregiverAlertSeverity.critical);
    expect(alert.status, CaregiverAlertStatus.resolved);
    expect(alert.reading, 88.5);
    expect(alert.threshold, 92);
    expect(alert.unit, '%');
  });

  test('missing optional display values use safe defaults', () async {
    final Map<String, dynamic> json =
        _alertJson(
          alertId: 'minimal-alert',
          conditionKey: 'HR_LOW',
          metricType: 'HEART_RATE',
          severity: 'WARNING',
          reading: null,
          unit: null,
          threshold: null,
        )..addAll({
          'patient_display_name': null,
          'title': null,
          'evaluation_reason': null,
          'confirmed_at': 'not-a-date',
        });

    final CaregiverAlert alert = (await _sourceFor([
      json,
    ]).fetchAlerts()).single;

    expect(alert.patientDisplayName, isNull);
    expect(alert.title, 'Health alert');
    expect(alert.description, '');
    expect(alert.reading, 0);
    expect(alert.threshold, isNull);
    expect(alert.unit, '');
    expect(alert.triggerDuration, isNull);
  });

  test('throws a typed failure for a non-success response', () async {
    final CaregiverAlertApiDataSource source = CaregiverAlertApiDataSource(
      client: MockClient((_) async => http.Response('unavailable', 503)),
    );

    expect(source.fetchAlerts(), throwsA(isA<CaregiverAlertsHttpFailure>()));
  });
}

CaregiverAlertApiDataSource _sourceFor(List<Map<String, dynamic>> items) {
  return CaregiverAlertApiDataSource(
    client: MockClient((http.Request request) async {
      expect(request.method, 'GET');
      expect(request.url.path, '/api/v1/alerts');
      expect(request.url.queryParameters['limit'], '100');
      return http.Response.bytes(
        utf8.encode(
          jsonEncode({
            'items': items,
            'total': items.length,
            'limit': 100,
            'offset': 0,
          }),
        ),
        200,
        headers: const {'content-type': 'application/json; charset=utf-8'},
      );
    }),
  );
}

Map<String, dynamic> _alertJson({
  required String alertId,
  required String conditionKey,
  required String metricType,
  required String severity,
  String status = 'ACTIVE',
  required Object? reading,
  required String? unit,
  required Object? threshold,
}) {
  return {
    'alert_id': alertId,
    'patient_id': 'patient-1',
    'condition_key': conditionKey,
    'severity': severity,
    'status': status,
    'detected_at': '2026-09-04T10:00:00Z',
    'confirmed_at': '2026-09-04T10:05:00Z',
    'resolved_at': null,
    'created_at': '2026-09-04T10:05:00Z',
    'updated_at': '2026-09-04T10:05:00Z',
    'patient_display_name': 'Nana',
    'metric_type': metricType,
    'title': conditionKey == 'SPO2_LOW' ? 'Low SpO₂' : 'High Heart Rate',
    'reading_value': reading,
    'reading_unit': unit,
    'threshold_value': threshold,
    'threshold_unit': unit,
    'evaluation_reason': 'Threshold exceeded.',
  };
}
