class ElderlyReminder {
  final String reminderId;
  final String patientId;
  final String title;
  final String? description;
  final DateTime dueAt;
  final String status;

  const ElderlyReminder({
    required this.reminderId,
    required this.patientId,
    required this.title,
    this.description,
    required this.dueAt,
    required this.status,
  });

  factory ElderlyReminder.fromJson(
    Map<String, dynamic> json,
  ) {
    return ElderlyReminder(
      reminderId: json['reminder_id'] as String,
      patientId: json['patient_id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      dueAt: DateTime.parse(
        json['due_at'] as String,
      ),
      status: json['status'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'reminder_id': reminderId,
      'patient_id': patientId,
      'title': title,
      'description': description,
      'due_at': dueAt.toIso8601String(),
      'status': status,
    };
  }
}