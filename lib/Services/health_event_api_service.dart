import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class HealthEventApiService {
  HealthEventApiService({
    required this.baseUrl,
    required this.patientId,
  });

  final String baseUrl;
  final String patientId;

  Future<bool> sendHealthEvent(
    Map<String, dynamic> payload,
  ) async {
    final Uri endpoint = Uri.parse(
      '$baseUrl/api/v1/health-events',
    );

    try {
      debugPrint(
        'Sending backend payload: ${jsonEncode(payload)}',
      );

      final http.Response response = await http
          .post(
            endpoint,
            headers: const {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: jsonEncode(payload),
          )
          .timeout(
            const Duration(seconds: 15),
          );

      if (response.statusCode >= 200 &&
          response.statusCode < 300) {
        debugPrint(
          'Health event accepted: ${response.body}',
        );
        return true;
      }

      debugPrint(
        'Health event rejected: '
        '${response.statusCode} ${response.body}',
      );

      return false;
    } catch (error, stackTrace) {
      debugPrint(
        'Health event request failed: $error',
      );
      debugPrintStack(stackTrace: stackTrace);
      return false;
    }
  }
}