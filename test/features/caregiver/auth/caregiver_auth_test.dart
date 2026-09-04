import 'dart:convert';

import 'package:alera/features/caregiver/data/auth/caregiver_auth_api.dart';
import 'package:alera/features/caregiver/data/auth/caregiver_session_controller.dart';
import 'package:alera/features/caregiver/data/auth/caregiver_token_store.dart';
import 'package:alera/features/caregiver/presentation/auth/caregiver_auth_gate.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  test('successful demo login persists and restores the session', () async {
    final _MemoryTokenStore store = _MemoryTokenStore();
    final CaregiverAuthApi authApi = CaregiverAuthApi(
      client: MockClient((http.Request request) async {
        expect(request.method, 'POST');
        expect(request.url.path, '/api/v1/auth/caregiver/login');
        expect(request.headers['content-type'], 'application/json');
        expect(jsonDecode(request.body), {
          'household_code': 'TEST-HOUSEHOLD',
          'email': 'caregiver@example.test',
          'password': 'test-password',
        });
        return http.Response(
          jsonEncode({
            'access_token': 'test-access-token',
            'token_type': 'bearer',
            'expires_at': '2026-09-05T12:00:00Z',
            'actor': {
              'user_id': '11111111-1111-1111-1111-111111111111',
              'full_name': 'Test Caregiver',
              'role': 'CAREGIVER',
              'household_id': '22222222-2222-2222-2222-222222222222',
              'household_name': 'Test Household',
              'household_code': 'TEST-HOUSEHOLD',
            },
          }),
          200,
        );
      }),
    );
    final CaregiverSessionController session = CaregiverSessionController(
      tokenStore: store,
      authApi: authApi,
    );

    await session.login(
      householdCode: 'TEST-HOUSEHOLD',
      email: 'caregiver@example.test',
      password: 'test-password',
    );

    expect(store.token, 'test-access-token');
    expect(session.status, CaregiverSessionStatus.authenticated);

    final CaregiverSessionController restored = CaregiverSessionController(
      tokenStore: store,
      authApi: authApi,
    );
    await restored.restoreSession();
    expect(restored.status, CaregiverSessionStatus.authenticated);
    expect(restored.accessToken, 'test-access-token');
  });

  test(
    'accepts deployed response when default token_type is omitted',
    () async {
      final CaregiverAuthApi authApi = CaregiverAuthApi(
        client: MockClient(
          (_) async => http.Response(
            jsonEncode({
              'access_token': 'default-bearer-token',
              'expires_at': '2026-09-05T12:00:00Z',
              'actor': {
                'user_id': '11111111-1111-1111-1111-111111111111',
                'full_name': 'Test Caregiver',
                'role': 'CAREGIVER',
                'household_id': '22222222-2222-2222-2222-222222222222',
                'household_name': 'Test Household',
                'household_code': 'TEST-HOUSEHOLD',
              },
            }),
            200,
          ),
        ),
      );

      final String token = await authApi.login(
        householdCode: 'TEST-HOUSEHOLD',
        email: 'caregiver@example.test',
        password: 'test-password',
      );

      expect(token, 'default-bearer-token');
    },
  );

  testWidgets('failed login shows a useful generic error', (
    WidgetTester tester,
  ) async {
    final CaregiverSessionController session = CaregiverSessionController(
      tokenStore: _MemoryTokenStore(),
      authApi: CaregiverAuthApi(
        client: MockClient((_) async => http.Response('invalid', 401)),
      ),
    );
    await tester.pumpWidget(
      MaterialApp(home: CaregiverLoginPage(sessionController: session)),
    );

    await tester.enterText(
      find.byKey(const Key('household-code-field')),
      'TEST-HOUSEHOLD',
    );
    await tester.enterText(
      find.byKey(const Key('caregiver-email-field')),
      'caregiver@example.test',
    );
    await tester.enterText(
      find.byKey(const Key('caregiver-password-field')),
      'wrong-password',
    );
    await tester.tap(find.text('Sign in'));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('caregiver-login-error')), findsOneWidget);
    expect(find.text('Unable to sign in. Check your details.'), findsOneWidget);
    expect(session.status, CaregiverSessionStatus.restoring);
  });
}

class _MemoryTokenStore implements CaregiverTokenStore {
  String? token;

  @override
  Future<void> clearToken() async => token = null;

  @override
  Future<String?> readToken() async => token;

  @override
  Future<void> writeToken(String token) async => this.token = token;
}
