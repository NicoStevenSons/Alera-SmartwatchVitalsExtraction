import 'package:flutter/material.dart';

import '../../../../design_system/alera_colors.dart';
import '../../../../design_system/alera_spacing.dart';
import '../../domain/models/care_recipient.dart';
import '../../domain/models/caregiver_alert.dart';
import '../../domain/models/caregiver_reminder.dart';
import 'widgets/home_alerts_preview.dart';
import 'widgets/home_health_summary.dart';
import 'widgets/home_insights_card.dart';
import 'widgets/home_patient_header.dart';
import 'widgets/home_reminders_preview.dart';

class CaregiverHomePage extends StatelessWidget {
  final CareRecipient careRecipient;
  final List<CaregiverAlert> alerts;
  final List<CaregiverReminder> reminders;
  final VoidCallback onViewAllAlerts;
  final VoidCallback onViewAllReminders;

  const CaregiverHomePage({
    super.key,
    required this.careRecipient,
    required this.alerts,
    required this.reminders,
    required this.onViewAllAlerts,
    required this.onViewAllReminders,
  });

  void _mock(BuildContext context, String action) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text('$action is mock-only for now.')));
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      key: const PageStorageKey<String>('caregiver-home-dashboard'),
      padding: EdgeInsets.zero,
      children: [
        HomePatientHeader(
          careRecipient: careRecipient,
          onCall: () => _mock(context, 'Call'),
          onMessage: () => _mock(context, 'Message'),
        ),
        SizedBox(
          height: 60,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(
              horizontal: AleraSpacing.medium,
              vertical: 14,
            ),
            scrollDirection: Axis.horizontal,
            itemCount: careRecipient.quickMessages.length,
            separatorBuilder: (_, _) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final String message = careRecipient.quickMessages[index];
              return ActionChip(
                label: Text(message),
                onPressed: () => _mock(context, 'Quick message'),
                backgroundColor: Colors.white,
                side: BorderSide.none,
                shape: const StadiumBorder(),
                labelStyle: const TextStyle(
                  color: AleraColors.primary,
                  fontSize: 11,
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 2,
                ),
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
          child: Column(
            children: [
              HomeHealthSummary(
                careRecipient: careRecipient,
                onMetricTap: (metric) => _mock(context, '$metric history'),
              ),
              const SizedBox(height: 12),
              HomeAlertsPreview(
                alerts: alerts,
                onViewAll: onViewAllAlerts,
                onAlertTap: onViewAllAlerts,
              ),
              const SizedBox(height: 12),
              HomeInsightsCard(snapshot: careRecipient.healthSnapshot),
              const SizedBox(height: 12),
              HomeRemindersPreview(
                reminders: reminders,
                onViewAll: onViewAllReminders,
                onAction: (action) => _mock(context, action),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
