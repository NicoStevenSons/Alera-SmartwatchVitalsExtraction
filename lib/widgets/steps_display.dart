import 'package:flutter/material.dart';

import '../models/steps_data.dart';

class StepsDisplay extends StatelessWidget {
  final StepsData stepsData;

  const StepsDisplay({
    super.key,
    required this.stepsData,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(
              Icons.stairs,
            ),
            const SizedBox(width: 8),
            Text(
              'Total Steps: '
              '${stepsData.displayedTotalSteps}',
            ),
          ],
        ),
        Text(
          'Sessions: '
          '${stepsData.sessions.length}',
        ),
        if (stepsData.sessions.isEmpty)
          const Text(
            'No step sessions received',
          ),
        ...stepsData.sessions.map(
          (StepSessionData session) {
            return Padding(
              padding: const EdgeInsets.only(
                top: 16,
              ),
              child: Row(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.stairs,
                    color: Colors.blue,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '${session.stepCount} steps\n'
                      'Start: ${session.startTime}\n'
                      'End: ${session.endTime}',
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}