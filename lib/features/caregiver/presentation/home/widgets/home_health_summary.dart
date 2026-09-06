import 'package:flutter/material.dart';

import '../../../../../design_system/alera_typography.dart';
import '../../../../../design_system/widgets/alera_card.dart';
import '../../../../../design_system/widgets/alera_svg_icon.dart';
import '../../../domain/models/care_recipient.dart';

class HomeHealthSummary extends StatelessWidget {
  final CareRecipient careRecipient;
  final ValueChanged<String> onMetricTap;

  const HomeHealthSummary({
    super.key,
    required this.careRecipient,
    required this.onMetricTap,
  });

  @override
  Widget build(BuildContext context) {
    final snapshot = careRecipient.healthSnapshot;
    return AleraCard(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              AleraSvgIcon(
                assetPath: careRecipient.status == CareStatus.stable
                    ? 'alera-figma-assets/assets/icons/status/stable.svg'
                    : 'alera-figma-assets/assets/icons/status/warning.svg',
                width: 20,
                height: 20,
                semanticLabel: 'Current health status',
              ),
              const SizedBox(width: 6),
              Text(
                careRecipient.backendBacked
                    ? careRecipient.monitoringStatusLabel
                    : careRecipient.status == CareStatus.stable
                    ? 'Stable'
                    : 'Needs Attention',
                style: AleraTypography.sectionTitle.copyWith(fontSize: 17),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            careRecipient.backendBacked
                ? _backendStatusDescription(careRecipient)
                : careRecipient.status == CareStatus.stable
                ? 'All vitals within normal range'
                : 'Review the latest alerts and vital readings',
            style: AleraTypography.body.copyWith(fontSize: 11),
          ),
          if (careRecipient.backendBacked) ...[
            const SizedBox(height: 5),
            Text(
              '${careRecipient.alertCount} active alert${careRecipient.alertCount == 1 ? '' : 's'}'
              '${snapshot.highestActiveAlertSeverity == null ? '' : ' • Highest severity: ${snapshot.highestActiveAlertSeverity}'}',
              style: AleraTypography.body.copyWith(fontSize: 11),
            ),
            const SizedBox(height: 3),
            Text(
              'Device: ${snapshot.deviceConnectionLabel ?? 'Not reported'}'
              '${snapshot.lastDeviceSyncAt == null ? ' • Last sync: No data' : ' • Last sync: ${snapshot.lastDeviceSyncAt!.toLocal()}'}',
              style: AleraTypography.body.copyWith(fontSize: 11),
            ),
          ],
          const SizedBox(height: 9),
          Row(
            children: [
              Expanded(
                child: _Metric(
                  assetPath:
                      'alera-figma-assets/assets/icons/vitals/heart_rate.svg',
                  label: snapshot.heartRateBpm == null
                      ? 'Heart rate: No data'
                      : '${snapshot.heartRateBpm} ${snapshot.heartRateUnit ?? 'bpm'}${_recordedSuffix(snapshot.heartRateRecordedAt)}',
                  color: const Color(0xFFFF7192),
                  onTap: () => onMetricTap('Heart Rate'),
                ),
              ),
              Expanded(
                child: _Metric(
                  assetPath: 'alera-figma-assets/assets/icons/vitals/spo2.svg',
                  label: snapshot.spo2Percent == null
                      ? 'SpO₂: No data'
                      : '${snapshot.spo2Percent!.toStringAsFixed(0)}${snapshot.spo2Unit ?? '%'}${_recordedSuffix(snapshot.spo2RecordedAt)}',
                  color: const Color(0xFF9378F1),
                  onTap: () => onMetricTap('SpO2'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 7),
          Row(
            children: [
              Expanded(
                child: _Metric(
                  assetPath:
                      'alera-figma-assets/assets/icons/vitals/stress.svg',
                  label: careRecipient.backendBacked
                      ? 'Stress — mock-only'
                      : snapshot.stressLabel,
                  color: const Color(0xFFFF875F),
                  onTap: () => onMetricTap('Stress'),
                ),
              ),
              Expanded(
                child: _Metric(
                  assetPath:
                      'alera-figma-assets/assets/icons/vitals/activity.svg',
                  label: careRecipient.backendBacked
                      ? 'Activity — mock-only'
                      : snapshot.steps == null
                      ? 'No activity'
                      : 'Active',
                  color: const Color(0xFF73C838),
                  onTap: () => onMetricTap('Activity'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _recordedSuffix(DateTime? value) =>
      value == null ? '' : ' • ${_time(value.toLocal())}';

  String _time(DateTime value) =>
      '${value.hour.toString().padLeft(2, '0')}:${value.minute.toString().padLeft(2, '0')}';

  String _backendStatusDescription(CareRecipient patient) =>
      switch (patient.status) {
        CareStatus.critical => 'Critical active health alert',
        CareStatus.warning => 'Warning active health alert',
        CareStatus.stable => 'Latest accepted readings are stable',
        CareStatus.noData => 'No accepted heart rate or SpO₂ data yet',
        CareStatus.unknown => 'Status reported by the patient service',
        CareStatus.needsAttention =>
          'Review the latest alerts and vital readings',
      };
}

class _Metric extends StatelessWidget {
  final String assetPath;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _Metric({
    required this.assetPath,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.015),
            blurRadius: 2,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            child: Row(
              children: [
                AleraSvgIcon(
                  assetPath: assetPath,
                  width: 20,
                  height: 20,
                  semanticLabel: label,
                ),
                const SizedBox(width: 5),
                Flexible(
                  child: Text(
                    label,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: color,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
