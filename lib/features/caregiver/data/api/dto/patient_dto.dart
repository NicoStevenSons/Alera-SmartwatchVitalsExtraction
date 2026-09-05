class CreatePatientRequest {
  final String fullName;
  final DateTime? birthdate;
  final String? sex;
  final String? phoneNumber;
  final String? addressOrRoom;
  final String? emergencyContactName;
  final String? emergencyContactPhone;
  final String? knownConditions;
  final String? medications;
  final num? baselineHeartRate;
  final num? baselineSpo2;
  final String? monitoringNotes;

  const CreatePatientRequest({
    required this.fullName,
    this.birthdate,
    this.sex,
    this.phoneNumber,
    this.addressOrRoom,
    this.emergencyContactName,
    this.emergencyContactPhone,
    this.knownConditions,
    this.medications,
    this.baselineHeartRate,
    this.baselineSpo2,
    this.monitoringNotes,
  });

  Map<String, Object?> toJson() => {
    'full_name': fullName.trim(),
    'birthdate': birthdate == null
        ? null
        : '${birthdate!.year.toString().padLeft(4, '0')}-'
              '${birthdate!.month.toString().padLeft(2, '0')}-'
              '${birthdate!.day.toString().padLeft(2, '0')}',
    'sex': sex,
    'phone_number': _trimmedOrNull(phoneNumber),
    'address_or_room': _trimmedOrNull(addressOrRoom),
    'emergency_contact_name': _trimmedOrNull(emergencyContactName),
    'emergency_contact_phone': _trimmedOrNull(emergencyContactPhone),
    'known_conditions': _trimmedOrNull(knownConditions),
    'medications': _trimmedOrNull(medications),
    'baseline_heart_rate': baselineHeartRate,
    'baseline_spo2': baselineSpo2,
    'monitoring_notes': _trimmedOrNull(monitoringNotes),
  };
}

String? _trimmedOrNull(String? value) {
  final trimmed = value?.trim();
  return trimmed == null || trimmed.isEmpty ? null : trimmed;
}

class PatientCreatedResponse {
  final String patientId;
  final String userId;
  final String householdId;
  final String accountStatus;
  final Object? assignment;
  final String fullName;
  final DateTime? birthdate;
  final String? sex;
  final String? phoneNumber;
  final String? addressOrRoom;
  final String? emergencyContactName;
  final String? emergencyContactPhone;
  final String? knownConditions;
  final String? medications;
  final double? baselineHeartRate;
  final double? baselineSpo2;
  final String? monitoringNotes;
  final DateTime createdAt;

  const PatientCreatedResponse({
    required this.patientId,
    required this.userId,
    required this.householdId,
    required this.accountStatus,
    required this.assignment,
    required this.fullName,
    required this.birthdate,
    required this.sex,
    required this.phoneNumber,
    required this.addressOrRoom,
    required this.emergencyContactName,
    required this.emergencyContactPhone,
    required this.knownConditions,
    required this.medications,
    required this.baselineHeartRate,
    required this.baselineSpo2,
    required this.monitoringNotes,
    required this.createdAt,
  });

  factory PatientCreatedResponse.fromJson(Map<String, dynamic> json) {
    return PatientCreatedResponse(
      patientId: json['patient_id'] as String,
      userId: json['user_id'] as String,
      householdId: json['household_id'] as String,
      accountStatus: json['account_status'] as String,
      assignment: json['assignment'],
      fullName: json['full_name'] as String,
      birthdate: _dateOrNull(json['birthdate']),
      sex: json['sex'] as String?,
      phoneNumber: json['phone_number'] as String?,
      addressOrRoom: json['address_or_room'] as String?,
      emergencyContactName: json['emergency_contact_name'] as String?,
      emergencyContactPhone: json['emergency_contact_phone'] as String?,
      knownConditions: json['known_conditions'] as String?,
      medications: json['medications'] as String?,
      baselineHeartRate: _decimalOrNull(json['baseline_heart_rate']),
      baselineSpo2: _decimalOrNull(json['baseline_spo2']),
      monitoringNotes: json['monitoring_notes'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}

double? _decimalOrNull(Object? value) => switch (value) {
  num number => number.toDouble(),
  String text => double.tryParse(text),
  _ => null,
};

DateTime? _dateOrNull(Object? value) =>
    value is String ? DateTime.tryParse(value) : null;

class PatientAccessCodeResponse {
  final String accessCodeId;
  final String patientId;
  final String accessCode;
  final String createdByUserId;
  final DateTime createdAt;
  final DateTime expiresAt;
  final String status;

  const PatientAccessCodeResponse({
    required this.accessCodeId,
    required this.patientId,
    required this.accessCode,
    required this.createdByUserId,
    required this.createdAt,
    required this.expiresAt,
    required this.status,
  });

  factory PatientAccessCodeResponse.fromJson(Map<String, dynamic> json) =>
      PatientAccessCodeResponse(
        accessCodeId: json['access_code_id'] as String,
        patientId: json['patient_id'] as String,
        accessCode: json['access_code'] as String,
        createdByUserId: json['created_by_user_id'] as String,
        createdAt: DateTime.parse(json['created_at'] as String),
        expiresAt: DateTime.parse(json['expires_at'] as String),
        status: json['status'] as String,
      );
}
