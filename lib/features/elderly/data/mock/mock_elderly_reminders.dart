import '../../domain/models/elderly_reminder.dart';

final List<ElderlyReminder> mockElderlyReminders = [
  ElderlyReminder(
    reminderId: 'test-reminder-1',
    patientId: 'a076ecdb-ae38-4f84-b490-e714977027ee',
    title: 'Take medication',
    description: 'Take 1 tablet after dinner',
    dueAt: DateTime.now().add(
    const Duration(minutes: 1),
    ),
    status: 'UPCOMING',
  ),
];