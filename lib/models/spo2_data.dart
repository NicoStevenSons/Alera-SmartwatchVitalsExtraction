class SpO2Data {
  final double? percent;
  final int? status;
  final String? measuredAt;

  const SpO2Data({
    required this.percent,
    required this.status,
    required this.measuredAt,
  });

  factory SpO2Data.empty() {
    return const SpO2Data(
      percent: null,
      status: null,
      measuredAt: null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'event_type': 'spo2',
      'spo2_percent': percent,
      'status': status,
      'measured_at': measuredAt,
    };
  }

  factory SpO2Data.fromJson(
    Map<String, dynamic> json,
  ) {
    final num? percentValue =
        json['spo2_percent'] as num?;

    final num? statusValue =
        json['status'] as num?;

    return SpO2Data(
      percent: percentValue?.toDouble(),
      status: statusValue?.toInt(),
      measuredAt:
          json['measured_at'] as String?,
    );
  }

  String get displayedPercent {
    if (percent == null || percent! <= 0) {
      return 'Waiting...';
    }

    return percent!.round().toString();
  }

  String get displayedStatus {
    switch (status) {
      case 2:
        return 'Valid reading';

      case 0:
        return 'Measuring';

      case -4:
        return 'Measurement unsuccessful';

      case -5:
        return 'Poor sensor contact';

      case -6:
        return 'Measurement interrupted';

      default:
        return 'Waiting for smartwatch';
    }
  }
}