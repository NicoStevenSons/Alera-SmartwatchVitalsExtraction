class SleepStageData {
  final int stage;
  final String startTime;
  final String endTime;

  const SleepStageData({
    required this.stage,
    required this.startTime,
    required this.endTime,
  });

  factory SleepStageData.fromJson(
    Map<String, dynamic> json,
  ) {
    return SleepStageData(
      stage: json['stage'] as int,
      startTime: json['start_time'] as String,
      endTime: json['end_time'] as String,
    );
  }
}

class SleepSessionData {
  final String startTime;
  final String endTime;
  final String? title;
  final String? notes;
  final List<SleepStageData> stages;

  const SleepSessionData({
    required this.startTime,
    required this.endTime,
    required this.title,
    required this.notes,
    required this.stages,
  });

  factory SleepSessionData.fromJson(
    Map<String, dynamic> json,
  ) {
    final List<dynamic> rawStages =
        json['stages'] as List<dynamic>? ?? [];

    return SleepSessionData(
      startTime: json['start_time'] as String,
      endTime: json['end_time'] as String,
      title: json['title'] as String?,
      notes: json['notes'] as String?,
      stages: rawStages
          .map(
            (stage) => SleepStageData.fromJson(
              Map<String, dynamic>.from(stage),
            ),
          )
          .toList(),
    );
  }
}

class SleepData {
  final List<SleepSessionData> sessions;

  const SleepData({
    required this.sessions,
  });

  factory SleepData.empty() {
    return const SleepData(
      sessions: [],
    );
  }

  factory SleepData.fromJson(
    Map<String, dynamic> json,
  ) {
    final List<dynamic> rawSessions =
        json['sessions'] as List<dynamic>? ?? [];

    return SleepData(
      sessions: rawSessions
          .map(
            (session) =>
                SleepSessionData.fromJson(
              Map<String, dynamic>.from(session),
            ),
          )
          .toList(),
    );
  }
}