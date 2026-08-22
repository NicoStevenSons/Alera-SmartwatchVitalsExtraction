import 'package:flutter/material.dart';

import '../models/spo2_data.dart';

class SpO2Display extends StatelessWidget {
  final SpO2Data spo2Data;

  const SpO2Display({
    super.key,
    required this.spo2Data,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(
              Icons.bloodtype,
              color: Colors.red,
            ),
            const SizedBox(width: 8),
            Text(
              'SpO2: '
              '${spo2Data.displayedPercent}%',
            ),
          ],
        ),
        Text(
          spo2Data.displayedStatus,
        ),
        Text(
          spo2Data.measuredAt ??
              'No measurement received',
        ),
      ],
    );
  }
}