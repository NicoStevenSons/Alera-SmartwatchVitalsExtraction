class HeartRateData {
  final int? bpm;
  final int? status;
  final String? measuredAt;

  const HeartRateData({
    required this.bpm,
    required this.status,
    required this.measuredAt,
  });

  factory HeartRateData.fromJson(
    Map<String, dynamic> json,
  ) {
    final num? bpmValue =
        json['heart_rate_bpm'] as num?;

    final num? statusValue =
        json['status'] as num?;

    return HeartRateData(
      bpm: bpmValue?.round(),
      status: statusValue?.toInt(),
      measuredAt:
          json['measured_at'] as String?,
    );
  }

  String get displayedHeartRate {
    if (bpm == null || bpm! <= 0) {
      return 'Waiting...';
    }

    return bpm.toString();
  }

  String get displayedStatus {
    switch (status) {
      case 1:
        return 'Valid reading';

      case 0:
        return 'Measuring';

      case -10:
        return 'Temporarily paused for SpO₂ measurement';

      case -999:
        return 'Sensor unavailable';

      default:
        return 'Waiting for smartwatch';
    }
  }
}