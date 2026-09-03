import 'package:flutter/material.dart';

import '../../../../../design_system/alera_colors.dart';
import '../../../../../design_system/alera_typography.dart';
import '../../../../../design_system/widgets/alera_section_card.dart';
import '../../../../../design_system/widgets/alera_svg_icon.dart';
import '../../../domain/models/caregiver_alert.dart';

class HomeAlertsPreview extends StatelessWidget {
  final List<CaregiverAlert> alerts;
  final VoidCallback onViewAll;
  final VoidCallback onAlertTap;

  const HomeAlertsPreview({
    super.key,
    required this.alerts,
    required this.onViewAll,
    required this.onAlertTap,
  });

  @override
  Widget build(BuildContext context) {
    final visibleAlerts = alerts.take(2).toList();
    return AleraSectionCard(
      title: 'Alerts (${alerts.length} active)',
      actionLabel: 'View All Alerts',
      onActionPressed: onViewAll,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (visibleAlerts.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Text('No active alerts'),
            )
          else
            for (int index = 0; index < visibleAlerts.length; index++) ...[
              _AlertRow(alert: visibleAlerts[index], onTap: onAlertTap),
              if (index != visibleAlerts.length - 1) const SizedBox(height: 7),
            ],
        ],
      ),
    );
  }
}

class _AlertRow extends StatelessWidget {
  final CaregiverAlert alert;
  final VoidCallback onTap;

  const _AlertRow({required this.alert, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final bool heart = alert.metric == CaregiverAlertMetric.heartRate;
    final Color color = heart ? AleraColors.critical : AleraColors.information;
    return Material(
      color: const Color(0xFFFCFBFF),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 8),
          decoration: BoxDecoration(
            border: Border(left: BorderSide(color: color, width: 5)),
          ),
          child: Row(
            children: [
              AleraSvgIcon(
                assetPath: heart
                    ? 'alera-figma-assets/assets/icons/mini_status/heart_rate.svg'
                    : 'alera-figma-assets/assets/icons/mini_status/info.svg',
                width: 28,
                height: 28,
                semanticLabel: alert.title,
              ),
              const SizedBox(width: 9),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      alert.title,
                      style: AleraTypography.label.copyWith(
                        color: AleraColors.textPrimary,
                      ),
                    ),
                    Text(
                      '${alert.reading.toStringAsFixed(0)} ${alert.unit} • 5 mins ago',
                      style: AleraTypography.body.copyWith(fontSize: 10),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.expand_more, color: Color(0xFFB7B2C3)),
            ],
          ),
        ),
      ),
    );
  }
}
