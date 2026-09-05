import 'package:flutter/material.dart';

import '../../domain/models/elderly_reminder.dart';

class ElderlyReminderCard extends StatelessWidget {
  final ElderlyReminder reminder;

  const ElderlyReminderCard({
    super.key,
    required this.reminder,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(
              Icons.notifications_active,
              color: Colors.purple,
              size: 32,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    reminder.title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (reminder.description != null) ...[
                    const SizedBox(height: 6),
                    Text(
                      reminder.description!,
                    ),
                  ],
                  const SizedBox(height: 10),
                  Text(
                    _formatDateTime(
                      reminder.dueAt,
                    ),
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  static String _formatDateTime(
    DateTime dateTime,
  ) {
    final DateTime local =
        dateTime.toLocal();

    final int hour =
        local.hour > 12
            ? local.hour - 12
            : local.hour == 0
                ? 12
                : local.hour;

    final String minute =
        local.minute
            .toString()
            .padLeft(2, '0');

    final String period =
        local.hour >= 12
            ? 'PM'
            : 'AM';

    return '$hour:$minute $period';
  }
}