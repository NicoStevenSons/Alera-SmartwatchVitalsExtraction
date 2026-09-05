import '../models/care_recipient.dart';
import '../models/caregiver_alert.dart';
import '../models/caregiver_reminder.dart';

abstract interface class CaregiverRepository {
  List<CareRecipient> getCareRecipients();

  List<CaregiverAlert> getAlerts();

  List<CaregiverReminder> getReminders();
}
