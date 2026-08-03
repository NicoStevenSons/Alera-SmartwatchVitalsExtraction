class StepSessionData {
  final int stepCount;
  final String startTime;
  final String endTime;

  const StepSessionData({
    required this.stepCount,
    required this.startTime,
    required this.endTime,
  });

  factory StepSessionData.fromJson(
    Map<String, dynamic> json,
  ) {
    final num? stepCountValue =
        json['step_count'] as num?;

    return StepSessionData(
      stepCount: stepCountValue?.toInt() ?? 0,
      startTime:
          json['start_time'] as String? ?? '',
      endTime:
          json['end_time'] as String? ?? '',
    );
  }
}

class StepsData {
  final List<StepSessionData> sessions;

  const StepsData({
    required this.sessions,
  });

  factory StepsData.fromJson(
    Map<String, dynamic> json,
  ) {
    final List<dynamic> sessionList =
        json['sessions'] as List<dynamic>? ??
            <dynamic>[];

    return StepsData(
      sessions: sessionList
          .map(
            (dynamic session) =>
                StepSessionData.fromJson(
              session as Map<String, dynamic>,
            ),
          )
          .toList(),
    );
  }

  factory StepsData.empty() {
    return const StepsData(
      sessions: <StepSessionData>[],
    );
  }

  int get totalSteps {
    return sessions.fold(
      0,
      (
        int total,
        StepSessionData session,
      ) {
        return total + session.stepCount;
      },
    );
  }

  String get displayedTotalSteps {
    if (sessions.isEmpty) {
      return '--';
    }

    return totalSteps.toString();
  }
}