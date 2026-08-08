import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

import '../models/user.dart';
import 'api_client.dart';
import 'auth_api_stub.dart'
    if (dart.library.html) 'auth_api_web.dart'
    if (dart.library.io) 'auth_api_io.dart';
import 'csrf_interceptor.dart';

/// Auth against ChampHive cookie session (`champhive_at` + `champhive_rt`).
///
/// Login/register return [User] in the body; tokens are HttpOnly cookies.
/// Mutating calls need CSRF (`XSRF-TOKEN` → `X-XSRF-TOKEN`).
class AuthApi {
  AuthApi(this._dio, {this.cookieJar});

  final Dio _dio;
  final CookieJar? cookieJar;

  static Future<AuthApi> create() async {
    final dio = createApiDio();
    configureAuthHttpClient(dio);

    CookieJar? jar;
    if (!kIsWeb) {
      final dir = await getApplicationSupportDirectory();
      jar = PersistCookieJar(
        storage: FileStorage('${dir.path}/cookies'),
      );
      dio.interceptors.add(CookieManager(jar));
    }

    dio.interceptors.add(CsrfInterceptor(dio, cookieJar: jar));
    return AuthApi(dio, cookieJar: jar);
  }

  Dio get dio => _dio;

  /// Ensures the CSRF cookie exists (safe to call before login).
  Future<void> ensureCsrf() async {
    await _dio.get<void>('/api/v1/auth/csrf');
  }

  Future<User> login({
    required String email,
    required String password,
  }) async {
    final response = await _dio.post<dynamic>(
      '/api/v1/auth/login',
      data: {
        'email': email,
        'password': password,
      },
      options: Options(
        headers: const {
          'User-Agent': 'TeamHive/1.0 (Flutter)',
        },
      ),
    );
    return _requireUser(response);
  }

  Future<User> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    String? phone,
  }) async {
    final response = await _dio.post<dynamic>(
      '/api/v1/auth/register',
      data: {
        'email': email,
        'password': password,
        'firstName': firstName,
        'lastName': lastName,
        if (phone != null && phone.isNotEmpty) 'phone': phone,
      },
      options: Options(
        headers: const {
          'User-Agent': 'TeamHive/1.0 (Flutter)',
        },
      ),
    );
    return _requireUser(response);
  }

  Future<void> refresh() async {
    await _dio.post<dynamic>(
      '/api/v1/auth/refresh',
      options: Options(
        headers: const {
          'User-Agent': 'TeamHive/1.0 (Flutter)',
        },
      ),
    );
  }

  Future<void> logout() async {
    try {
      await _dio.post<dynamic>('/api/v1/auth/logout');
    } catch (_) {
      // Best-effort — local session is cleared by the caller either way.
    }
  }

  Future<User> currentUser() async {
    final response = await _dio.get<dynamic>('/api/v1/users/me');
    return _requireUser(response);
  }

  Future<void> clearCookies() async {
    final jar = cookieJar;
    if (jar == null) return;
    await jar.deleteAll();
  }

  User _requireUser(Response<dynamic> response) {
    final raw = response.data;
    if (raw is! Map) {
      throw DioException(
        requestOptions: response.requestOptions,
        type: DioExceptionType.badResponse,
        response: response,
        message: 'Empty auth response',
      );
    }
    return User.fromJson(Map<String, dynamic>.from(raw));
  }
}
