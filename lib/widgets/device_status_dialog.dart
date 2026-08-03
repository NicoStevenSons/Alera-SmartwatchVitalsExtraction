import 'package:flutter/material.dart';
import '../models/device_status_data.dart';

Future<void> showDeviceStatusDialog({
  required BuildContext context,
  required DeviceStatusData deviceStatusData,
}) {
  return showDialog<void>(
    context: context,
    builder: (BuildContext dialogContext) {
      return AlertDialog(
        title: const Text('Device Status'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Device: '
              '${deviceStatusData.displayedDeviceName}',
            ),
            const SizedBox(height: 8),
            Text(
              'Model: '
              '${deviceStatusData.deviceModel ?? '--'}',
            ),
            const SizedBox(height: 8),
            Text(
              'Battery: '
              '${deviceStatusData.displayedBattery}',
            ),
            const SizedBox(height: 8),
            Text(
              'Connection: '
              '${deviceStatusData.displayedConnection}',
            ),
            const SizedBox(height: 8),
            Text(
              'Phone: '
              '${deviceStatusData.displayedPhoneName}',
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
            },
            child: const Text('Close'),
          ),
        ],
      );
    },
  );
}