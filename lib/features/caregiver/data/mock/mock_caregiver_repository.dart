import '../../domain/models/care_recipient.dart';
import '../../domain/models/caregiver_alert.dart';
import '../../domain/models/caregiver_reminder.dart';
import '../../domain/repositories/caregiver_repository.dart';
import 'mock_caregiver_data.dart';

class MockCaregiverRepository implements CaregiverRepository {
  const MockCaregiverRepository();

  @override
  List<CareRecipient> getCareRecipients() {
    return List.unmodifiable(MockCaregiverData.careRecipients);
  }

  @override
  List<CaregiverAlert> getAlerts() {
    return List.unmodifiable(MockCaregiverData.alerts);
  }

  @override
  List<CaregiverReminder> getReminders() {
    return List.unmodifiable(MockCaregiverData.reminders);
  }
}
