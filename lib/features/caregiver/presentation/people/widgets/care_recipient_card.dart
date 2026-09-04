import 'package:flutter/material.dart';

import '../../../../../design_system/alera_colors.dart';
import '../../../../../design_system/alera_spacing.dart';
import '../../../../../design_system/alera_typography.dart';
import '../../../../../design_system/widgets/alera_card.dart';
import '../../../../../design_system/widgets/alera_svg_icon.dart';
import '../../../domain/models/care_recipient.dart';
import '../../../domain/models/health_snapshot.dart';

class CareRecipientCard extends StatelessWidget {
  final CareRecipient careRecipient;
  final VoidCallback onTap;

  const CareRecipientCard({
    super.key,
    required this.careRecipient,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bool isStable = careRecipient.status == CareStatus.stable;
    final List<MonitoringDevice> devices = careRecipient.healthSnapshot.devices;

    return AleraCard(
      onTap: onTap,
      padding: const EdgeInsets.fromLTRB(10, 10, 14, 12),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Align(
              alignment: Alignment.topCenter,
              child: _InitialAvatar(name: careRecipient.name),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    careRecipient.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AleraTypography.sectionTitle.copyWith(
                      fontSize: 18,
                      height: 1.05,
                    ),
                  ),
                  const SizedBox(height: 2),
                  _StatusRow(
                    assetPath: isStable
                        ? 'alera-figma-assets/assets/icons/status/stable.svg'
                        : 'alera-figma-assets/assets/icons/status/warning.svg',
                    label: isStable ? 'Stable' : 'High Heart Rate',
                  ),
                  const SizedBox(height: 2),
                  _StatusRow(
                    assetPath:
                        'alera-figma-assets/assets/icons/status/alert.svg',
                    label: careRecipient.alertCount == 0
                        ? 'No Alerts'
                        : '${careRecipient.alertCount} Alerts',
                  ),
                  const SizedBox(height: 2),
                  _StatusRow(
                    assetPath:
                        'alera-figma-assets/assets/icons/status/reminder.svg',
                    label: '${careRecipient.reminderCount} Reminders',
                  ),
                  if (devices.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Wrap(
                      spacing: 8,
                      runSpacing: 2,
                      children: devices
                          .map((device) => _DeviceBattery(device: device))
                          .toList(),
                    ),
                  ],
                ],
              ),
            ),
            const Align(
              alignment: Alignment.center,
              child: Icon(
                Icons.chevron_right,
                color: Color(0xFFB7B2C3),
                size: 24,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InitialAvatar extends StatelessWidget {
  final String name;

  const _InitialAvatar({required this.name});

  @override
  Widget build(BuildContext context) {
    final List<String> words = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((word) => word.isNotEmpty)
        .toList();
    final String initials = words
        .take(2)
        .map((word) => word.characters.first.toUpperCase())
        .join();
    const List<Color> colors = [
      AleraColors.primary,
      AleraColors.information,
      AleraColors.critical,
    ];
    final int colorIndex =
        name.codeUnits.fold(0, (sum, value) => sum + value) % colors.length;

    return CircleAvatar(
      radius: 20,
      backgroundColor: colors[colorIndex],
      child: Text(
        initials,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _StatusRow extends StatelessWidget {
  final String assetPath;
  final String label;

  const _StatusRow({required this.assetPath, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        AleraSvgIcon(assetPath: assetPath, width: 16, height: 16),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            label,
            style: AleraTypography.body.copyWith(fontSize: 13, height: 1),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

class _DeviceBattery extends StatelessWidget {
  final MonitoringDevice device;

  const _DeviceBattery({required this.device});

  @override
  Widget build(BuildContext context) {
    final bool isWatch = device.name.toLowerCase() == 'watch';

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          isWatch ? Icons.watch_outlined : Icons.phone_android_outlined,
          color: AleraColors.textSecondary,
          size: 17,
        ),
        const SizedBox(width: AleraSpacing.xSmall),
        Text(
          '${device.batteryPercent}%',
          style: AleraTypography.body.copyWith(fontSize: 14, height: 1),
        ),
      ],
    );
  }
}
