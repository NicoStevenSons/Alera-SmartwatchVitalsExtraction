import 'package:flutter_secure_storage/flutter_secure_storage.dart';

abstract interface class CaregiverTokenStore {
  Future<String?> readToken();
  Future<void> writeToken(String token);
  Future<void> clearToken();
}

class SecureCaregiverTokenStore implements CaregiverTokenStore {
  static const String _tokenKey = 'caregiver_access_token';

  final FlutterSecureStorage _storage;

  SecureCaregiverTokenStore({FlutterSecureStorage? storage})
    : _storage = storage ?? const FlutterSecureStorage();

  @override
  Future<String?> readToken() => _storage.read(key: _tokenKey);

  @override
  Future<void> writeToken(String token) =>
      _storage.write(key: _tokenKey, value: token);

  @override
  Future<void> clearToken() => _storage.delete(key: _tokenKey);
}
