import 'package:flutter/material.dart';

import '../../../../../design_system/alera_colors.dart';
import '../../../../../design_system/alera_typography.dart';
import '../../../../../design_system/widgets/alera_card.dart';
import '../../../domain/models/caregiver_alert.dart';

class PatientAlertHistory extends StatelessWidget {
  final List<CaregiverAlert> alerts;
  final VoidCallback onViewAll;
  final VoidCallback onAlertTap;

  const PatientAlertHistory({
    super.key,
    required this.alerts,
    required this.onViewAll,
    required this.onAlertTap,
  });

  @override
  Widget build(BuildContext context) {
    return AleraCard(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
      child: Column(
        children: [
          _SectionHeader(
            title: 'Alert History',
            action: 'View All Alerts',
            onAction: onViewAll,
          ),
          const SizedBox(height: 7),
          if (alerts.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Text('No alert history for this patient.'),
            )
          else
            for (final CaregiverAlert alert in alerts.take(2)) ...[
              _AlertRow(alert: alert, onTap: onAlertTap),
              if (alert != alerts.take(2).last) const SizedBox(height: 7),
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
    final bool heartRate = alert.metric == CaregiverAlertMetric.heartRate;
    final Color color = heartRate
        ? AleraColors.critical
        : AleraColors.information;
    return Material(
      color: const Color(0xFFFCFBFF),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            border: Border(left: BorderSide(color: color, width: 5)),
          ),
          child: Row(
            children: [
              Icon(
                heartRate ? Icons.monitor_heart : Icons.info,
                color: color,
                size: 28,
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
                      '${alert.reading.toStringAsFixed(alert.reading % 1 == 0 ? 0 : 1)} ${alert.unit} • 5 mins ago',
                      style: AleraTypography.body.copyWith(fontSize: 11),
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

class _SectionHeader extends StatelessWidget {
  final String title;
  final String action;
  final VoidCallback onAction;

  const _SectionHeader({
    required this.title,
    required this.action,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Text(title, style: AleraTypography.sectionTitle)),
        TextButton(
          onPressed: onAction,
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            minimumSize: const Size(44, 36),
          ),
          child: Text(action, style: const TextStyle(fontSize: 11)),
        ),
      ],
    );
  }
}
