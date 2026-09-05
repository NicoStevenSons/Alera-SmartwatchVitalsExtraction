import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../../config/app_config.dart';

class PatientAuthApi {
  final http.Client _client;
  final Duration timeout;

  PatientAuthApi({
    http.Client? client,
    this.timeout = const Duration(seconds: 15),
  }) : _client = client ?? http.Client();

  Future<String> access({
    required String householdCode,
    required String accessCode,
  }) async {
    try {
      final response = await _client
          .post(
            Uri.parse('${AppConfig.backendBaseUrl}/api/v1/auth/patient/access'),
            headers: const {'content-type': 'application/json'},
            body: jsonEncode({
              'household_code': householdCode,
              'access_code': accessCode,
            }),
          )
          .timeout(timeout);
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw const PatientAccessFailure(
          'Unable to sign in. Check your household and access code.',
        );
      }
      final decoded = jsonDecode(response.body);
      if (decoded is! Map<String, dynamic>) throw const FormatException();
      final token = decoded['access_token'];
      final type = decoded['token_type'];
      if (token is! String ||
          token.trim().isEmpty ||
          (type != null &&
              (type is! String || type.toLowerCase() != 'bearer'))) {
        throw const FormatException();
      }
      return token;
    } on TimeoutException {
      throw const PatientAccessFailure('Unable to connect. Please try again.');
    } on http.ClientException {
      throw const PatientAccessFailure('Unable to connect. Please try again.');
    } on FormatException {
      throw const PatientAccessFailure('Unable to sign in. Please try again.');
    }
  }
}

class PatientAccessFailure implements Exception {
  final String message;
  const PatientAccessFailure(this.message);
}
