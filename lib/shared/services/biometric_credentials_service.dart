import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _credentialsKey = 'champhive_login_credentials';
const _hasCredentialsFlag = 'biometric_credentials_saved';

/// Stores login credentials for Face ID / Touch ID unlock.
class BiometricCredentialsService {
  BiometricCredentialsService({
    FlutterSecureStorage? secureStorage,
    LocalAuthentication? localAuth,
  })  : _storage = secureStorage ??
            const FlutterSecureStorage(
              aOptions: AndroidOptions(encryptedSharedPreferences: true),
            ),
        _localAuth = localAuth ?? LocalAuthentication();

  final FlutterSecureStorage _storage;
  final LocalAuthentication _localAuth;

  Future<bool> get canUseBiometrics async {
    try {
      return await _localAuth.canCheckBiometrics &&
          await _localAuth.isDeviceSupported();
    } catch (_) {
      return false;
    }
  }

  Future<bool> get hasStoredCredentials async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_hasCredentialsFlag) ?? false;
  }

  Future<void> saveCredentials({
    required String email,
    required String password,
  }) async {
    final json = jsonEncode({'email': email, 'password': password});
    await _storage.write(key: _credentialsKey, value: json);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_hasCredentialsFlag, true);
  }

  Future<void> clearCredentials() async {
    await _storage.delete(key: _credentialsKey);
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_hasCredentialsFlag);
  }

  /// Stored email without a Face ID prompt (remembered email in the form).
  Future<String?> getStoredEmailQuiet() async {
    try {
      if (!await hasStoredCredentials) return null;
      final json = await _storage.read(key: _credentialsKey);
      if (json == null || json.isEmpty) return null;
      final map = jsonDecode(json) as Map<String, dynamic>;
      final email = map['email'];
      if (email is! String) return null;
      final s = email.trim();
      return s.isEmpty ? null : s;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('BiometricCredentialsService.getStoredEmailQuiet: $e');
      }
      return null;
    }
  }

  Future<({String email, String password})?> getCredentialsWithBiometrics({
    required String localizedReason,
  }) async {
    if (!await hasStoredCredentials) return null;
    if (!await canUseBiometrics) return null;

    try {
      final authenticated = await _localAuth.authenticate(
        localizedReason: localizedReason,
        options: const AuthenticationOptions(
          biometricOnly: false,
          stickyAuth: true,
        ),
      );

      if (!authenticated) return null;

      final json = await _storage.read(key: _credentialsKey);
      if (json == null || json.isEmpty) return null;

      final map = jsonDecode(json) as Map<String, dynamic>;
      final email = map['email'] as String?;
      final password = map['password'] as String?;
      if (email == null || password == null) return null;

      return (email: email, password: password);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('BiometricCredentialsService: $e');
      }
      return null;
    }
  }
}
