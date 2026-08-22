import 'package:flutter/material.dart';

import '../models/heart_rate_data.dart';

class HeartRateDisplay extends StatelessWidget {
  final HeartRateData heartRateData;

  const HeartRateDisplay({
    super.key,
    required this.heartRateData,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(
              Icons.favorite,
              color: Colors.red,
            ),
            const SizedBox(width: 8),
            Text(
              'Heart Rate: '
              '${heartRateData.displayedHeartRate} BPM',
            ),
          ],
        ),
        Text(
          heartRateData.displayedStatus,
        ),
        Text(
          heartRateData.measuredAt ??
              'No measurement received',
        ),
      ],
    );
  }
}