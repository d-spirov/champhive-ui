import 'package:dio/dio.dart';

import '../models/user.dart';
import 'api_client.dart';
import 'auth_interceptor.dart';
import 'token_store.dart';

/// Auth against TeamHive ClubPlatform Bearer JWT.
///
/// Mobile must send `client: "mobile"` so refresh tokens are returned in the body.
class AuthApi {
  AuthApi(this._dio, this._tokenStore);

  final Dio _dio;
  final TokenStore _tokenStore;

  static Future<AuthApi> create({
    required Future<void> Function() onSessionExpired,
  }) async {
    final tokenStore = await TokenStore.create();
    final dio = createApiDio();

    late final AuthApi api;
    api = AuthApi(dio, tokenStore);
    dio.interceptors.add(
      AuthInterceptor(
        dio: dio,
        tokenStore: tokenStore,
        refreshTokens: api._refreshPair,
        onSessionExpired: onSessionExpired,
      ),
    );
    return api;
  }

  Dio get dio => _dio;
  TokenStore get tokenStore => _tokenStore;

  Future<User> login({
    required String email,
    required String password,
  }) async {
    final response = await _dio.post<dynamic>(
      '/api/v1/auth/login',
      data: {
        'email': email,
        'password': password,
        'client': apiClientMobile,
      },
    );
    await _persistTokens(response);
    return currentUser();
  }

  Future<User> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    String locale = 'en',
  }) async {
    await _dio.post<dynamic>(
      '/api/v1/auth/register',
      data: {
        'email': email,
        'password': password,
        'firstName': firstName,
        'lastName': lastName,
        'locale': locale,
      },
    );
    // Register may not return tokens — log in immediately for mobile UX.
    return login(email: email, password: password);
  }

  Future<void> refresh() async {
    final pair = await _refreshPair();
    if (pair == null) {
      throw StateError('Session expired');
    }
  }

  Future<TokenPair?> _refreshPair() async {
    final refresh = _tokenStore.refreshToken;
    if (refresh == null || refresh.isEmpty) return null;

    final response = await _dio.post<dynamic>(
      '/api/v1/auth/refresh',
      data: {
        'refreshToken': refresh,
        'client': apiClientMobile,
      },
    );
    return _persistTokens(response);
  }

  Future<void> logout() async {
    try {
      await _dio.post<dynamic>(
        '/api/v1/auth/logout',
        data: {
          'refreshToken': _tokenStore.refreshToken,
        },
      );
    } catch (_) {
      // Best-effort — local tokens are cleared by the caller either way.
    }
  }

  Future<User> currentUser() async {
    final response = await _dio.get<dynamic>('/api/v1/me');
    return _requireUser(response);
  }

  Future<void> clearTokens() => _tokenStore.clear();

  Future<TokenPair> _persistTokens(Response<dynamic> response) async {
    final raw = response.data;
    if (raw is! Map) {
      throw DioException(
        requestOptions: response.requestOptions,
        type: DioExceptionType.badResponse,
        response: response,
        message: 'Empty token response',
      );
    }
    final pair = TokenPair.fromJson(Map<String, dynamic>.from(raw));
    if (pair.accessToken.isEmpty) {
      throw DioException(
        requestOptions: response.requestOptions,
        type: DioExceptionType.badResponse,
        response: response,
        message: 'Missing access token',
      );
    }
    await _tokenStore.save(
      accessToken: pair.accessToken,
      accessTokenExpiresAtUtc: pair.accessTokenExpiresAtUtc,
      refreshToken: pair.refreshToken,
    );
    return pair;
  }

  User _requireUser(Response<dynamic> response) {
    final raw = response.data;
    if (raw is! Map) {
      throw DioException(
        requestOptions: response.requestOptions,
        type: DioExceptionType.badResponse,
        response: response,
        message: 'Empty me response',
      );
    }
    return User.fromMeJson(Map<String, dynamic>.from(raw));
  }
}
