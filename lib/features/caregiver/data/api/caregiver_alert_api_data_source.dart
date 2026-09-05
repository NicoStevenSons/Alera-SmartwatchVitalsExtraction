import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../../config/app_config.dart';
import '../../domain/models/caregiver_alert.dart';
import '../auth/caregiver_session_controller.dart';
import 'dto/caregiver_alert_dto.dart';

abstract interface class CaregiverAlertDataSource {
  Future<List<CaregiverAlert>> fetchAlerts();
}

class CaregiverAlertApiDataSource implements CaregiverAlertDataSource {
  final http.Client _client;
  final CaregiverSession _session;
  final Duration timeout;

  CaregiverAlertApiDataSource({
    http.Client? client,
    CaregiverSession? session,
    this.timeout = const Duration(seconds: 15),
  }) : _client = client ?? http.Client(),
       _session = session ?? CaregiverSessionController.instance;

  /// Loads one alert using the active caregiver bearer token.
  Future<CaregiverAlert> fetchAlert(String alertId) async {
    final uri = Uri.parse(
      '${AppConfig.backendBaseUrl}/api/v1/alerts/${Uri.encodeComponent(alertId)}',
    );
    final token = _session.accessToken;
    if (token == null || token.isEmpty) {
      throw const CaregiverAlertsAuthFailure(401);
    }
    try {
      final response = await _client
          .get(uri, headers: {'authorization': 'Bearer $token'})
          .timeout(timeout);
      // Do not deliver data from a session that ended during the request.
      if (_session.accessToken != token) {
        throw const CaregiverAlertsAuthFailure(401);
      }
      if (response.statusCode == 401) {
        await _session.clearInvalidSession();
        throw const CaregiverAlertsAuthFailure(401);
      }
      if (response.statusCode == 403) {
        throw const CaregiverAlertsAuthFailure(403);
      }
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw CaregiverAlertsHttpFailure(response.statusCode);
      }
      final decoded = jsonDecode(utf8.decode(response.bodyBytes));
      if (decoded is! Map<String, dynamic>) {
        throw const FormatException('Alert response must be a JSON object.');
      }
      final alert = CaregiverAlertDto.fromJson(decoded).toDomain();
      if (alert.id.toLowerCase() != alertId.toLowerCase()) {
        throw const FormatException(
          'Alert response ID does not match request.',
        );
      }
      return alert;
    } on FormatException catch (error) {
      throw CaregiverAlertsParseFailure(error.message);
    } on TimeoutException {
      throw const CaregiverAlertsTimeoutFailure();
    } on http.ClientException catch (error) {
      throw CaregiverAlertsRequestFailure(error.message);
    }
  }

  @override
  Future<List<CaregiverAlert>> fetchAlerts() async {
    final Uri uri = Uri.parse(
      '${AppConfig.backendBaseUrl}/api/v1/alerts',
    ).replace(queryParameters: const {'limit': '100'});

    try {
      final String? token = _session.accessToken;
      if (token == null || token.isEmpty) {
        throw const CaregiverAlertsAuthFailure(401);
      }
      final http.Response response = await _client
          .get(uri, headers: {'authorization': 'Bearer $token'})
          .timeout(timeout);
      if (response.statusCode == 401) {
        // A late response from an old account must not sign out a new one.
        if (_session.accessToken == token) {
          await _session.clearInvalidSession();
        }
        throw const CaregiverAlertsAuthFailure(401);
      }
      if (response.statusCode == 403) {
        throw const CaregiverAlertsAuthFailure(403);
      }
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

final class CaregiverAlertsAuthFailure extends CaregiverAlertsFailure {
  final int statusCode;

  const CaregiverAlertsAuthFailure(this.statusCode)
    : super('Caregiver authorization failed.');
}
