enum CaregiverReminderStatus { missed, upcoming, completed }

class CaregiverReminder {
  final String id;
  final String careRecipientId;
  final String title;
  final String description;
  final DateTime scheduledAt;
  final CaregiverReminderStatus status;

  const CaregiverReminder({
    required this.id,
    required this.careRecipientId,
    required this.title,
    required this.description,
    required this.scheduledAt,
    required this.status,
  });
}
