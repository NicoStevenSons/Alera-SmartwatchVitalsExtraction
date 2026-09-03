import 'package:flutter/material.dart';

import '../../../../../design_system/alera_colors.dart';
import '../../../../../design_system/alera_spacing.dart';
import '../../../../../design_system/alera_typography.dart';
import '../../../../../design_system/widgets/alera_card.dart';
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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Transform.translate(
            offset: const Offset(0, -18),
            child: _InitialAvatar(name: careRecipient.name),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  careRecipient.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AleraTypography.sectionTitle.copyWith(
                    fontSize: 19,
                    height: 1.05,
                  ),
                ),
                const SizedBox(height: 2),
                _StatusRow(
                  icon: isStable ? Icons.check : Icons.warning_rounded,
                  iconColor: isStable
                      ? AleraColors.success
                      : AleraColors.warning,
                  label: isStable ? 'Stable' : 'High Heart Rate',
                ),
                const SizedBox(height: 2), // ← vertical gap
                _StatusRow(
                  icon: Icons.notifications,
                  iconColor: AleraColors.primary,
                  label: careRecipient.alertCount == 0
                      ? 'No Alerts'
                      : '${careRecipient.alertCount} Alerts',
                ),
                const SizedBox(height: 2), // ← vertical gap
                _StatusRow(
                  icon: Icons.info,
                  iconColor: AleraColors.information,
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
          const Icon(Icons.chevron_right, color: Color(0xFFB7B2C3), size: 24),
        ],
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
      Color(0xFF8165C7),
      Color(0xFF4D91A8),
      Color(0xFFB36B8D),
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
  final IconData icon;
  final Color iconColor;
  final String label;

  const _StatusRow({
    required this.icon,
    required this.iconColor,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        DecoratedBox(
          decoration: BoxDecoration(color: iconColor, shape: BoxShape.circle),
          child: Padding(
            padding: const EdgeInsets.all(2),
            child: Icon(icon, color: Colors.white, size: 11),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            label,
            style: AleraTypography.body.copyWith(fontSize: 14, height: 1),
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
