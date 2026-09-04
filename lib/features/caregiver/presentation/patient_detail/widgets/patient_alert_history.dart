import 'package:flutter/material.dart';

import '../../../../../design_system/alera_typography.dart';
import '../../../../../design_system/widgets/alera_card.dart';
import '../../../domain/models/caregiver_alert.dart';
import '../../widgets/caregiver_alert_card.dart';

class PatientAlertHistory extends StatefulWidget {
  final List<CaregiverAlert> alerts;
  final VoidCallback onViewAll;
  final VoidCallback onAlertTap;
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
    return AleraCard(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
      child: Column(
        children: [
          _SectionHeader(
            title: 'Alert History',
            action: 'View All Alerts',
            onAction: widget.onViewAll,
          ),
          const SizedBox(height: 7),
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
                onViewMore: widget.onAlertTap,
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
