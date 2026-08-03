class DeviceStatusData {
  final int? batteryPercent;
  final String? deviceName;
  final String? deviceModel;
  final bool connectedToPhone;
  final String? connectedPhoneName;
  final String? measuredAt;

  const DeviceStatusData({
    required this.batteryPercent,
    required this.deviceName,
    required this.deviceModel,
    required this.connectedToPhone,
    required this.connectedPhoneName,
    required this.measuredAt,
  });

  factory DeviceStatusData.fromJson(
    Map<String, dynamic> json,
  ) {
    final num? batteryValue =
        json['battery_percent'] as num?;

    return DeviceStatusData(
      batteryPercent: batteryValue?.toInt(),
      deviceName:
          json['device_name'] as String?,
      deviceModel:
          json['device_model'] as String?,
      connectedToPhone:
          json['connected_to_phone']
              as bool? ??
              false,
      connectedPhoneName:
          json['connected_phone_name']
              as String?,
      measuredAt:
          json['measured_at'] as String?,
    );
  }

  factory DeviceStatusData.empty() {
    return const DeviceStatusData(
      batteryPercent: null,
      deviceName: null,
      deviceModel: null,
      connectedToPhone: false,
      connectedPhoneName: null,
      measuredAt: null,
    );
  }

  String get displayedBattery {
    if (batteryPercent == null) {
      return '--';
    }

    return '$batteryPercent%';
  }

  String get displayedConnection {
    return connectedToPhone
        ? 'Connected'
        : 'Disconnected';
  }

  String get displayedDeviceName {
    if (deviceName == null ||
        deviceName!.isEmpty) {
      return 'Unknown device';
    }

    return deviceName!;
  }

  String get displayedPhoneName {
    if (connectedPhoneName == null ||
        connectedPhoneName!.isEmpty) {
      return 'No phone connected';
    }

    return connectedPhoneName!;
  }
}