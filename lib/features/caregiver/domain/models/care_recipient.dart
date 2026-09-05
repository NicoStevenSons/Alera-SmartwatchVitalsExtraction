import 'health_snapshot.dart';

enum CareStatus { stable, needsAttention }

class CareRecipient {
  final String id;
  final String name;
  final String relationshipLabel;
  final CareStatus status;
  final int alertCount;
  final int reminderCount;
  final List<String> quickMessages;
  final HealthSnapshot healthSnapshot;

  const CareRecipient({
    required this.id,
    required this.name,
    required this.relationshipLabel,
    required this.status,
    required this.alertCount,
    required this.reminderCount,
    required this.quickMessages,
    required this.healthSnapshot,
  });
}
