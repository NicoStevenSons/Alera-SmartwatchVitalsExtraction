import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../../config/app_config.dart';
import '../auth/caregiver_session_controller.dart';
import 'dto/patient_dto.dart';

abstract interface class CaregiverPatientDataSource {
  Future<PatientCreatedResponse> createPatient(CreatePatientRequest request);
  Future<PatientAccessCodeResponse> createAccessCode(String patientId);
}

class CaregiverPatientApiDataSource implements CaregiverPatientDataSource {
  final http.Client _client;
  final CaregiverSession _session;
  final Duration timeout;

  CaregiverPatientApiDataSource({
    http.Client? client,
    CaregiverSession? session,
    this.timeout = const Duration(seconds: 15),
  }) : _client = client ?? http.Client(),
       _session = session ?? CaregiverSessionController.instance;

  @override
  Future<PatientCreatedResponse> createPatient(
    CreatePatientRequest request,
  ) async {
    final response = await _post('/api/v1/patients', request.toJson());
    return PatientCreatedResponse.fromJson(_jsonObject(response));
  }

  @override
  Future<PatientAccessCodeResponse> createAccessCode(String patientId) async {
    final response = await _post(
      '/api/v1/patients/${Uri.encodeComponent(patientId)}/access-codes',
      const {'expires_in_hours': 24},
    );
    return PatientAccessCodeResponse.fromJson(_jsonObject(response));
  }

  Future<http.Response> _post(String path, Map<String, Object?> body) async {
    final token = _session.accessToken;
    if (token == null || token.isEmpty) {
      throw const CaregiverPatientApiFailure('Please sign in again.');
    }
    try {
      final response = await _client
          .post(
            Uri.parse('${AppConfig.backendBaseUrl}$path'),
            headers: {
              'authorization': 'Bearer $token',
              'content-type': 'application/json',
            },
            body: jsonEncode(body),
          )
          .timeout(timeout);
      if (response.statusCode == 401) {
        await _session.clearInvalidSession();
        throw const CaregiverPatientApiFailure('Please sign in again.');
      }
      if (response.statusCode != 201) {
        throw CaregiverPatientApiFailure(_safeMessage(response));
      }
      return response;
    } on TimeoutException {
      throw const CaregiverPatientApiFailure(
        'The request timed out. Please try again.',
      );
    } on http.ClientException {
      throw const CaregiverPatientApiFailure(
        'Unable to connect. Please try again.',
      );
    } on CaregiverPatientApiFailure {
      rethrow;
    } catch (_) {
      throw const CaregiverPatientApiFailure(
        'The server returned an unexpected response. Please try again.',
      );
    }
  }

  Map<String, dynamic> _jsonObject(http.Response response) {
    final decoded = jsonDecode(response.body);
    if (decoded is! Map<String, dynamic>) throw const FormatException();
    return decoded;
  }

  String _safeMessage(http.Response response) {
    if (response.statusCode == 422) {
      try {
        final decoded = jsonDecode(response.body);
        final detail = decoded is Map<String, dynamic>
            ? decoded['detail']
            : null;
        if (detail is List) {
          final messages = detail
              .whereType<Map<String, dynamic>>()
              .map((item) => item['msg'])
              .whereType<String>()
              .toSet()
              .take(3)
              .join(' ');
          if (messages.isNotEmpty) return messages;
        }
      } catch (_) {}
      return 'Please check the patient details and try again.';
    }
    if (response.statusCode == 403) {
      return 'You do not have permission to perform this action.';
    }
    return 'Unable to complete the request. Please try again.';
  }
}

class CaregiverPatientApiFailure implements Exception {
  final String message;
  const CaregiverPatientApiFailure(this.message);
}
