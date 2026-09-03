import 'package:flutter/material.dart';

import '../../../../../design_system/alera_colors.dart';
import '../../../../../design_system/alera_typography.dart';
import '../../../../../design_system/widgets/alera_card.dart';
import '../../../domain/models/health_snapshot.dart';

class PatientMonitoringDevicesCard extends StatelessWidget {
  final List<MonitoringDevice> devices;

  const PatientMonitoringDevicesCard({super.key, required this.devices});

  @override
  Widget build(BuildContext context) {
    return AleraCard(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Monitoring Devices', style: AleraTypography.sectionTitle),
          const SizedBox(height: 6),
          for (int index = 0; index < devices.length; index++) ...[
            _DeviceRow(device: devices[index]),
            if (index != devices.length - 1) const Divider(height: 8),
          ],
        ],
      ),
    );
  }
}

class _DeviceRow extends StatelessWidget {
  final MonitoringDevice device;

  const _DeviceRow({required this.device});

  @override
  Widget build(BuildContext context) {
    final bool watch = device.name.toLowerCase() == 'watch';
    return Row(
      children: [
        Icon(
          watch ? Icons.watch_outlined : Icons.phone_android,
          color: AleraColors.primary,
          size: 24,
        ),
        const SizedBox(width: 9),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                device.name,
                style: AleraTypography.body.copyWith(fontSize: 13),
              ),
              Row(
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: const BoxDecoration(
                      color: AleraColors.success,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    device.isConnected ? 'Connected' : 'Disconnected',
                    style: AleraTypography.body.copyWith(fontSize: 12),
                  ),
                ],
              ),
            ],
          ),
        ),
        Text('${device.batteryPercent}%', style: AleraTypography.label),
        const SizedBox(width: 7),
        const Icon(Icons.battery_5_bar, color: AleraColors.primary, size: 20),
      ],
    );
  }
}
