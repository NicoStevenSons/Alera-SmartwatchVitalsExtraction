import 'package:flutter/material.dart';

import '../models/sleep_data.dart';

class SleepDisplay extends StatelessWidget {
  final SleepData sleepData;

  const SleepDisplay({
    super.key,
    required this.sleepData,
  });

  @override
  Widget build(BuildContext context) {
    if (sleepData.sessions.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Sleep',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              Text('No sleep data available'),
            ],
          ),
        ),
      );
    }

    // Most recent sleep session.
    final SleepSessionData session =
        sleepData.sessions.first;

    final DateTime start =
        DateTime.parse(session.startTime).toLocal();

    final DateTime end =
        DateTime.parse(session.endTime).toLocal();

    final Duration duration =
        end.difference(start);

    final int hours = duration.inHours;
    final int minutes =
        duration.inMinutes.remainder(60);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            const Text(
              'Sleep',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              '$hours hr $minutes min',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              'Sleep sessions: '
              '${sleepData.sessions.length}',
            ),

            Text(
              'Sleep stages: '
              '${session.stages.length}',
            ),

            const SizedBox(height: 8),

            Text(
              'Start: ${_formatTime(start)}',
            ),

            Text(
              'End: ${_formatTime(end)}',
            ),
          ],
        ),
      ),
    );
  }

  static String _formatTime(
    DateTime dateTime,
  ) {
    final int hour =
        dateTime.hour > 12
            ? dateTime.hour - 12
            : dateTime.hour == 0
                ? 12
                : dateTime.hour;

    final String minute =
        dateTime.minute
            .toString()
            .padLeft(2, '0');

    final String period =
        dateTime.hour >= 12
            ? 'PM'
            : 'AM';

    return '$hour:$minute $period';
  }
}