import 'package:flutter/material.dart';

import '../../../../../design_system/alera_colors.dart';
import '../../../../../design_system/alera_typography.dart';
import '../../../../../design_system/widgets/alera_card.dart';
import '../../../domain/models/care_recipient.dart';

class PatientCareStatusCard extends StatelessWidget {
  final CareRecipient careRecipient;

  const PatientCareStatusCard({super.key, required this.careRecipient});

  @override
  Widget build(BuildContext context) {
    final bool stable = careRecipient.status == CareStatus.stable;
    final Color statusColor = stable
        ? AleraColors.success
        : AleraColors.warning;
    final String statusLabel = stable ? 'Stable' : 'Needs Attention';

    return AleraCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  stable ? Icons.check : Icons.warning_rounded,
                  color: statusColor,
                  size: 28,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(statusLabel, style: AleraTypography.sectionTitle),
                    Text(
                      stable
                          ? 'Vitals within normal range.'
                          : 'One or more items need attention.',
                      style: AleraTypography.body.copyWith(fontSize: 12),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '◷ Last Check-in: ${_time(careRecipient.healthSnapshot.lastCheckIn)}',
                      style: const TextStyle(
                        color: Color(0xFFAA91DD),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Divider(height: 24),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Care Risk', style: AleraTypography.sectionTitle),
                    const SizedBox(height: 10),
                    Text(
                      '${careRecipient.healthSnapshot.careRiskScore}',
                      style: const TextStyle(
                        color: AleraColors.textPrimary,
                        fontSize: 34,
                        height: 1,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      careRecipient.healthSnapshot.careRiskLabel,
                      style: AleraTypography.body.copyWith(fontSize: 13),
                    ),
                    const Text(
                      'Mock presentation score',
                      style: TextStyle(
                        color: AleraColors.textSecondary,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                width: 88,
                height: 88,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CircularProgressIndicator(
                      value: careRecipient.healthSnapshot.careRiskScore / 100,
                      strokeWidth: 13,
                      strokeCap: StrokeCap.round,
                      backgroundColor: AleraColors.primarySoft,
                      color: AleraColors.primary,
                    ),
                    const Icon(
                      Icons.health_and_safety,
                      color: AleraColors.primary,
                      size: 28,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _time(DateTime value) {
    final int hour = value.hour > 12 ? value.hour - 12 : value.hour;
    return '$hour:${value.minute.toString().padLeft(2, '0')} '
        '${value.hour >= 12 ? 'PM' : 'AM'}';
  }
}
