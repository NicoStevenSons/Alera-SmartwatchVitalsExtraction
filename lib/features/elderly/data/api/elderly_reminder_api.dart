import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../../domain/models/elderly_reminder.dart';

class ElderlyReminderApi {
  final String baseUrl;
  final String patientId;

  const ElderlyReminderApi({
    required this.baseUrl,
    required this.patientId,
  });

  Future<List<ElderlyReminder>> fetchReminders() async {
    final Uri endpoint = Uri.parse(
      '$baseUrl/api/v1/reminders/patient/$patientId',
    );

    debugPrint(
      'Fetching reminders for patient: $patientId',
    );

    final http.Response response = await http.get(
      endpoint,
      headers: {
        'Content-Type': 'application/json',
      },
    );

    debugPrint(
      'Reminder response: '
      '${response.statusCode} ${response.body}',
    );

    if (response.statusCode < 200 ||
        response.statusCode >= 300) {
      throw Exception(
        'Failed to fetch reminders: '
        '${response.statusCode}',
      );
    }

    final dynamic decoded = jsonDecode(
      response.body,
    );

    final List<dynamic> items;

    if (decoded is List<dynamic>) {
      items = decoded;
    } else if (decoded is Map<String, dynamic> &&
        decoded['items'] is List<dynamic>) {
      items = decoded['items'] as List<dynamic>;
    } else {
      throw Exception(
        'Unexpected reminder response format',
      );
    }

    return items
        .map(
          (dynamic item) =>
              ElderlyReminder.fromJson(
            item as Map<String, dynamic>,
          ),
        )
        .toList();
  }
}