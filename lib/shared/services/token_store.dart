import 'package:shared_preferences/shared_preferences.dart';

/// Persists JWT access + rotating refresh tokens for the mobile client.
class TokenStore {
  TokenStore(this._prefs);

  static const _accessKey = 'auth_access_token';
  static const _refreshKey = 'auth_refresh_token';
  static const _expiryKey = 'auth_access_expires_at';

  final SharedPreferences _prefs;

  static Future<TokenStore> create() async {
    final prefs = await SharedPreferences.getInstance();
    return TokenStore(prefs);
  }

  String? get accessToken => _prefs.getString(_accessKey);
  String? get refreshToken => _prefs.getString(_refreshKey);

  DateTime? get accessTokenExpiresAt {
    final raw = _prefs.getString(_expiryKey);
    if (raw == null || raw.isEmpty) return null;
    return DateTime.tryParse(raw);
  }

  bool get hasTokens =>
      (accessToken?.isNotEmpty ?? false) || (refreshToken?.isNotEmpty ?? false);

  bool get isAccessExpired {
    final exp = accessTokenExpiresAt;
    if (exp == null) return true;
    // Refresh slightly early to avoid edge races.
    return DateTime.now().toUtc().isAfter(exp.subtract(const Duration(seconds: 30)));
  }

  Future<void> save({
    required String accessToken,
    required DateTime accessTokenExpiresAtUtc,
    String? refreshToken,
  }) async {
    await _prefs.setString(_accessKey, accessToken);
    await _prefs.setString(
      _expiryKey,
      accessTokenExpiresAtUtc.toUtc().toIso8601String(),
    );
    if (refreshToken != null && refreshToken.isNotEmpty) {
      await _prefs.setString(_refreshKey, refreshToken);
    }
  }

  Future<void> clear() async {
    await _prefs.remove(_accessKey);
    await _prefs.remove(_refreshKey);
    await _prefs.remove(_expiryKey);
  }
}

class TokenPair {
  const TokenPair({
    required this.userId,
    required this.accessToken,
    required this.accessTokenExpiresAtUtc,
    this.refreshToken,
  });

  final String userId;
  final String accessToken;
  final DateTime accessTokenExpiresAtUtc;
  final String? refreshToken;

  factory TokenPair.fromJson(Map<String, dynamic> json) {
    return TokenPair(
      userId: json['userId']?.toString() ?? '',
      accessToken: json['accessToken'] as String? ?? '',
      accessTokenExpiresAtUtc: DateTime.tryParse(
            json['accessTokenExpiresAtUtc'] as String? ?? '',
          )?.toUtc() ??
          DateTime.now().toUtc().add(const Duration(minutes: 15)),
      refreshToken: json['refreshToken'] as String?,
    );
  }
}
