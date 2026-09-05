class MonitoringDevice {
  final String name;
  final int batteryPercent;
  final bool isConnected;

  const MonitoringDevice({
    required this.name,
    required this.batteryPercent,
    required this.isConnected,
  });
}

class HealthSnapshot {
  final int? heartRateBpm;
  final double? spo2Percent;
  final int? steps;
  final String stressLabel;
  final Duration sleepDuration;
  final int careRiskScore;
  final String careRiskLabel;
  final DateTime lastCheckIn;
  final List<MonitoringDevice> devices;

  const HealthSnapshot({
    required this.heartRateBpm,
    required this.spo2Percent,
    required this.steps,
    required this.stressLabel,
    required this.sleepDuration,
    required this.careRiskScore,
    required this.careRiskLabel,
    required this.lastCheckIn,
    required this.devices,
  });
}
