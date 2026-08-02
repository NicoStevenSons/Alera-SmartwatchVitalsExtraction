class HeartRateData{
  final int? bpm;
  final int? status;
  final String? measuredAt;

  const HeartRateData({
    required this.bpm,
    required this.status,
    required this.measuredAt,
  });

  factory HeartRateData.fromJson(Map<String, dynamic> json) {
    final num? bpmValue = json['heart_rate_bpm'] as num?;
    final num? statusValue = json['status'] as num?;

    return HeartRateData(
      bpm: bpmValue?.round(),
      status: statusValue?.toInt(),
      measuredAt: json['measured_at'] as String?,
    );
  }

  HeartRateData copyWith({
    int? bpm,
    int? status,
    String? measuredAt,
  }) {
    return HeartRateData(
      bpm: bpm ?? this.bpm,
      status: status ?? this.status,
      measuredAt: measuredAt ?? this.measuredAt,
    );
  }

  HeartRateData mergeWithIncoming(HeartRateData incoming) {
  final bool hasValidReading =
      incoming.bpm != null && incoming.bpm! > 0;

  return copyWith(
    bpm: hasValidReading
        ? incoming.bpm
        : bpm,
    status: incoming.status,
    measuredAt: hasValidReading
        ? incoming.measuredAt
        : measuredAt,
  );
}

  String get displayedHeartRate {
    if (bpm == null || bpm! <= 0) {
      return '--';
    }

    return bpm.toString();
  }

  String get displayedStatus {
    switch (status) {
      case 1:
        return 'Valid reading';
      case 0:
        return 'Measuring';
      case -999:
        return 'Sensor unavailable';
        case -10:
      return 'Temporarily paused for SpO₂ measurement';
      default:
        return 'Waiting for smartwatch';
    }
  }
}