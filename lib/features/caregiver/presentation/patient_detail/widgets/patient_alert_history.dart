import 'package:flutter/material.dart';

import '../../../../../design_system/widgets/alera_section_card.dart';
import '../../../domain/models/caregiver_alert.dart';
import '../../widgets/caregiver_alert_card.dart';

class PatientAlertHistory extends StatefulWidget {
  final List<CaregiverAlert> alerts;
  final VoidCallback onViewAll;
  final ValueChanged<CaregiverAlert> onAlertTap;
  final ValueChanged<CaregiverAlert>? onMarkAsSeen;

  const PatientAlertHistory({
    super.key,
    required this.alerts,
    required this.onViewAll,
    required this.onAlertTap,
    this.onMarkAsSeen,
  });

  @override
  State<PatientAlertHistory> createState() => _PatientAlertHistoryState();
}

class _PatientAlertHistoryState extends State<PatientAlertHistory> {
  final Set<String> _expandedAlertIds = <String>{};

  void _toggle(String id) {
    setState(() {
      if (!_expandedAlertIds.add(id)) _expandedAlertIds.remove(id);
    });
  }

  @override
  Widget build(BuildContext context) {
    return AleraSectionCard(
      title: 'Alert History',
      actionLabel: 'View All Alerts',
      onActionPressed: widget.onViewAll,
      contentSpacing: 7,
      child: Column(
        children: [
          if (widget.alerts.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Text('No alert history for this patient.'),
            )
          else
            for (final CaregiverAlert alert in widget.alerts.take(2)) ...[
              CaregiverAlertCard(
                alert: alert,
                expanded: _expandedAlertIds.contains(alert.id),
                onToggleExpanded: () => _toggle(alert.id),
                onViewMore: () => widget.onAlertTap(alert),
                onMarkAsSeen: widget.onMarkAsSeen == null
                    ? null
                    : () => widget.onMarkAsSeen!(alert),
              ),
              if (alert != widget.alerts.take(2).last)
                const SizedBox(height: 7),
            ],
        ],
      ),
    );
  }
}
