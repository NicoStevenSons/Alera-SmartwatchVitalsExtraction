class HealthEventMapper {
  const HealthEventMapper._();

  static Map<String, dynamic> mapHeartRate({
    required String patientId,
    required num heartRateBpm,
    required String recordedAt,
    required Map<String, dynamic> rawPayload,
    String validationStatus = 'VALID_REALTIME',
    String? validationReason,
  }) {
    final DateTime timestamp =
        DateTime.parse(recordedAt).toUtc();

    return {
      'patient_id': patientId,
      'external_event_id': _createExternalEventId(
        prefix: 'watch-hr',
        timestamp: timestamp,
      ),
      'metric_type': 'HEART_RATE',
      'numeric_value': heartRateBpm,
      'text_value': null,
      'boolean_value': null,
      'metric_unit': 'bpm',
      'recorded_at': timestamp.toIso8601String(),
      'validation_status': validationStatus,
      'validation_reason': validationReason,
      'raw_payload': rawPayload,
    };
  }

  static Map<String, dynamic> mapSpO2({
    required String patientId,
    required num spo2Percent,
    required String recordedAt,
    required Map<String, dynamic> rawPayload,
    String validationStatus = 'VALID_REALTIME',
    String? validationReason,
  }) {
    final DateTime timestamp =
        DateTime.parse(recordedAt).toUtc();

    return {
      'patient_id': patientId,
      'external_event_id': _createExternalEventId(
        prefix: 'watch-spo2',
        timestamp: timestamp,
      ),
      'metric_type': 'SPO2',
      'numeric_value': spo2Percent,
      'text_value': null,
      'boolean_value': null,
      'metric_unit': 'percent',
      'recorded_at': timestamp.toIso8601String(),
      'validation_status': validationStatus,
      'validation_reason': validationReason,
      'raw_payload': rawPayload,
    };
  }

  static String _createExternalEventId({
    required String prefix,
    required DateTime timestamp,
  }) {
    final String formattedTimestamp = timestamp
        .toUtc()
        .toIso8601String()
        .replaceAll('-', '')
        .replaceAll(':', '')
        .replaceAll('.', '');

    return '$prefix-$formattedTimestamp';
  }
}