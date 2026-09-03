import 'package:flutter/material.dart';

import '../../../../../design_system/alera_colors.dart';
import '../../../../../design_system/alera_typography.dart';
import '../../../../../design_system/widgets/alera_card.dart';
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
              const Icon(
                Icons.check_circle,
                color: AleraColors.success,
                size: 20,
              ),
              const SizedBox(width: 6),
              Text(
                careRecipient.status == CareStatus.stable
                    ? 'Stable'
                    : 'Needs Attention',
                style: AleraTypography.sectionTitle.copyWith(fontSize: 17),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            careRecipient.status == CareStatus.stable
                ? 'All vitals within normal range'
                : 'Review the latest alerts and vital readings',
            style: AleraTypography.body.copyWith(fontSize: 11),
          ),
          const SizedBox(height: 9),
          Row(
            children: [
              Expanded(
                child: _Metric(
                  icon: Icons.favorite,
                  label: '${snapshot.heartRateBpm ?? '--'} Bpm',
                  color: const Color(0xFFFF7192),
                  onTap: () => onMetricTap('Heart Rate'),
                ),
              ),
              Expanded(
                child: _Metric(
                  icon: Icons.water_drop,
                  label: '${snapshot.spo2Percent?.toStringAsFixed(0) ?? '--'}%',
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
                  icon: Icons.multiline_chart,
                  label: snapshot.stressLabel,
                  color: const Color(0xFFFF875F),
                  onTap: () => onMetricTap('Stress'),
                ),
              ),
              Expanded(
                child: _Metric(
                  icon: Icons.directions_walk,
                  label: snapshot.steps == null ? 'No activity' : 'Active',
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
}

class _Metric extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _Metric({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          child: Row(
            children: [
              Icon(icon, color: color, size: 18),
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
    );
  }
}
