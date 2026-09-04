import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../../config/app_config.dart';
import '../../domain/models/caregiver_alert.dart';
import 'dto/caregiver_alert_dto.dart';

abstract interface class CaregiverAlertDataSource {
  Future<List<CaregiverAlert>> fetchAlerts();
}

class CaregiverAlertApiDataSource implements CaregiverAlertDataSource {
  final http.Client _client;
  final Duration timeout;

  CaregiverAlertApiDataSource({
    http.Client? client,
    this.timeout = const Duration(seconds: 15),
  }) : _client = client ?? http.Client();

  @override
  Future<List<CaregiverAlert>> fetchAlerts() async {
    final Uri uri = Uri.parse(
      '${AppConfig.backendBaseUrl}/api/v1/alerts',
    ).replace(queryParameters: const {'limit': '100'});

    try {
      final http.Response response = await _client.get(uri).timeout(timeout);
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw CaregiverAlertsHttpFailure(response.statusCode);
      }

      try {
        final Object? decoded = jsonDecode(response.body);
        if (decoded is! Map<String, dynamic>) {
          throw const FormatException('Alerts response must be a JSON object.');
        }
        final CaregiverAlertsResponseDto dto =
            CaregiverAlertsResponseDto.fromJson(decoded);
        return dto.items.map((item) => item.toDomain()).toList(growable: false);
      } on FormatException catch (error) {
        throw CaregiverAlertsParseFailure(error.message);
      }
    } on TimeoutException {
      throw const CaregiverAlertsTimeoutFailure();
    } on CaregiverAlertsFailure {
      rethrow;
    } on http.ClientException catch (error) {
      throw CaregiverAlertsRequestFailure(error.message);
    }
  }
}

sealed class CaregiverAlertsFailure implements Exception {
  final String message;

  const CaregiverAlertsFailure(this.message);

  @override
  String toString() => message;
}

final class CaregiverAlertsHttpFailure extends CaregiverAlertsFailure {
  final int statusCode;

  CaregiverAlertsHttpFailure(this.statusCode)
    : super('Alerts request failed with HTTP $statusCode.');
}

final class CaregiverAlertsParseFailure extends CaregiverAlertsFailure {
  CaregiverAlertsParseFailure(String details)
    : super('Could not parse alerts response: $details');
}

final class CaregiverAlertsTimeoutFailure extends CaregiverAlertsFailure {
  const CaregiverAlertsTimeoutFailure() : super('Alerts request timed out.');
}

final class CaregiverAlertsRequestFailure extends CaregiverAlertsFailure {
  CaregiverAlertsRequestFailure(String details)
    : super('Could not load alerts: $details');
}
