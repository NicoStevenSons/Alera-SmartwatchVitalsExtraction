import 'package:flutter/material.dart';

import '../models/sleep_data.dart';

class SleepHistoryPage extends StatelessWidget {
  final SleepData sleepData;

  const SleepHistoryPage({
    super.key,
    required this.sleepData,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.purple,
        title: const Text(
          'Sleep History',
        ),
      ),
      body: sleepData.sessions.isEmpty
          ? const Center(
              child: Text(
                'No sleep history available',
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: sleepData.sessions.length,
              itemBuilder: (
                context,
                index,
              ) {
                final SleepSessionData session =
                    sleepData.sessions[index];

                final DateTime start =
                    DateTime.parse(
                  session.startTime,
                ).toLocal();

                final DateTime end =
                    DateTime.parse(
                  session.endTime,
                ).toLocal();

                final Duration duration =
                    end.difference(start);

                final int hours =
                    duration.inHours;

                final int minutes =
                    duration.inMinutes
                        .remainder(60);

                return Card(
                  margin: const EdgeInsets.only(
                    bottom: 12,
                  ),
                  child: ListTile(
                    leading: const Icon(
                      Icons.bedtime,
                      color: Colors.indigo,
                    ),
                    title: Text(
                      '$hours hr $minutes min',
                    ),
                    subtitle: Text(
                      '${_formatDate(start)}\n'
                      '${_formatTime(start)} - '
                      '${_formatTime(end)}',
                    ),
                  ),
                );
              },
            ),
    );
  }

  static String _formatDate(
    DateTime dateTime,
  ) {
    return '${dateTime.month}/'
        '${dateTime.day}/'
        '${dateTime.year}';
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