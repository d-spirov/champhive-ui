import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';

import 'api_client.dart';
import 'csrf_cookie_reader_stub.dart'
    if (dart.library.html) 'csrf_cookie_reader_web.dart';

/// Double-submit CSRF for ChampHive cookie auth.
///
/// Bootstraps [GET /api/v1/auth/csrf] when needed, then echoes the
/// `XSRF-TOKEN` cookie in the `X-XSRF-TOKEN` header on mutating requests.
class CsrfInterceptor extends Interceptor {
  CsrfInterceptor(this._dio, {this.cookieJar});

  static const cookieName = 'XSRF-TOKEN';
  static const headerName = 'X-XSRF-TOKEN';

  final Dio _dio;
  final CookieJar? cookieJar;

  bool _bootstrapping = false;

  static bool isMutating(String method) {
    switch (method.toUpperCase()) {
      case 'POST':
      case 'PUT':
      case 'PATCH':
      case 'DELETE':
        return true;
      default:
        return false;
    }
  }

  Future<String?> _readToken() async {
    final fromJar = await _tokenFromJar();
    if (fromJar != null && fromJar.isNotEmpty) return fromJar;
    return readCsrfCookieFromDocument();
  }

  Future<String?> _tokenFromJar() async {
    final jar = cookieJar;
    if (jar == null) return null;
    final cookies = await jar.loadForRequest(Uri.parse(apiBaseUrl));
    for (final cookie in cookies) {
      if (cookie.name == cookieName && cookie.value.isNotEmpty) {
        return cookie.value;
      }
    }
    return null;
  }

  Future<void> _ensureBootstrapped() async {
    if (_bootstrapping) return;
    final existing = await _readToken();
    if (existing != null && existing.isNotEmpty) return;

    _bootstrapping = true;
    try {
      await _dio.get<void>('/api/v1/auth/csrf');
    } finally {
      _bootstrapping = false;
    }
  }

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    try {
      if (!isMutating(options.method)) {
        handler.next(options);
        return;
      }

      // Avoid recursion while the bootstrap GET is in flight via this Dio.
      if (options.path.contains('/auth/csrf')) {
        handler.next(options);
        return;
      }

      await _ensureBootstrapped();
      final token = await _readToken();
      if (token != null && token.isNotEmpty) {
        options.headers[headerName] = token;
      }
      handler.next(options);
    } catch (e, st) {
      handler.reject(
        DioException(
          requestOptions: options,
          error: e,
          stackTrace: st,
          type: DioExceptionType.unknown,
          message: 'Failed to attach CSRF token',
        ),
      );
    }
  }
}
