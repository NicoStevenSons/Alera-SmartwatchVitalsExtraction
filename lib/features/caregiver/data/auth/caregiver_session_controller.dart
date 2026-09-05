import 'package:flutter/foundation.dart';

import 'caregiver_auth_api.dart';
import 'caregiver_token_store.dart';

enum CaregiverSessionStatus { restoring, unauthenticated, authenticated }

abstract interface class CaregiverSession {
  String? get accessToken;
  Future<void> clearInvalidSession();
}

class CaregiverSessionController extends ChangeNotifier
    implements CaregiverSession {
  static final CaregiverSessionController instance = CaregiverSessionController(
    tokenStore: SecureCaregiverTokenStore(),
    authApi: CaregiverAuthApi(),
  );

  final CaregiverTokenStore _tokenStore;
  final CaregiverAuthApi _authApi;

  CaregiverSessionStatus _status = CaregiverSessionStatus.restoring;
  String? _accessToken;

  factory CaregiverSessionController({
    required CaregiverTokenStore tokenStore,
    required CaregiverAuthApi authApi,
  }) => CaregiverSessionController._(tokenStore, authApi);

  CaregiverSessionController._(this._tokenStore, this._authApi);

  CaregiverSessionStatus get status => _status;

  @override
  String? get accessToken => _accessToken;

  Future<void> restoreSession() async {
    try {
      final String? stored = await _tokenStore.readToken();
      _accessToken = stored == null || stored.trim().isEmpty ? null : stored;
      _status = _accessToken == null
          ? CaregiverSessionStatus.unauthenticated
          : CaregiverSessionStatus.authenticated;
    } catch (_) {
      _accessToken = null;
      _status = CaregiverSessionStatus.unauthenticated;
    }
    notifyListeners();
  }

  Future<void> login({
    required String householdCode,
    required String email,
    required String password,
  }) async {
    final String token = await _authApi.login(
      householdCode: householdCode,
      email: email,
      password: password,
    );
    try {
      await _tokenStore.writeToken(token);
    } catch (error, stackTrace) {
      if (kDebugMode) {
        debugPrint('Caregiver login: secure token persistence failed.');
        debugPrint('$error');
        debugPrintStack(stackTrace: stackTrace);
      }
      rethrow;
    }
    _accessToken = token;
    _status = CaregiverSessionStatus.authenticated;
    notifyListeners();
  }

  Future<void> logout() async {
    await _tokenStore.clearToken();
    _accessToken = null;
    _status = CaregiverSessionStatus.unauthenticated;
    notifyListeners();
  }

  @override
  Future<void> clearInvalidSession() => logout();
}
