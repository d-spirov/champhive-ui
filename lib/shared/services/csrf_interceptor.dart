import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';

import 'api_client.dart';
import 'csrf_cookie_reader_stub.dart'
    if (dart.library.html) 'csrf_cookie_reader_web.dart';

/// Double-submit CSRF for ChampHive cookie auth.
///
/// Bootstraps [GET /api/v1/auth/csrf], then echoes the `XSRF-TOKEN` cookie in
/// the `X-XSRF-TOKEN` header on mutating requests. Retries once on CSRF 403.
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

  Future<String?> _readToken([Uri? forUri]) async {
    final fromJar = await _tokenFromJar(forUri ?? Uri.parse(apiBaseUrl));
    if (fromJar != null && fromJar.isNotEmpty) return fromJar;
    final fromDoc = readCsrfCookieFromDocument();
    if (fromDoc == null || fromDoc.isEmpty) return null;
    return _decodeCookieValue(fromDoc);
  }

  Future<String?> _tokenFromJar(Uri uri) async {
    final jar = cookieJar;
    if (jar == null) return null;

    // Try the concrete request URI first, then the API root (path matching).
    final candidates = <Uri>{
      uri,
      Uri.parse(apiBaseUrl),
      Uri.parse('$apiBaseUrl/'),
      Uri.parse('$apiBaseUrl/api/v1/auth/csrf'),
    };

    for (final candidate in candidates) {
      final cookies = await jar.loadForRequest(candidate);
      for (final cookie in cookies) {
        if (cookie.name == cookieName && cookie.value.isNotEmpty) {
          return _decodeCookieValue(cookie.value);
        }
      }
    }
    return null;
  }

  /// Spring URL-encodes the cookie; the header must be the decoded token.
  static String _decodeCookieValue(String raw) {
    try {
      return Uri.decodeComponent(raw);
    } catch (_) {
      return raw;
    }
  }

  Future<void> _bootstrapCsrf({bool force = false}) async {
    if (_bootstrapping) return;
    if (!force) {
      final existing = await _readToken();
      if (existing != null && existing.isNotEmpty) return;
    }

    _bootstrapping = true;
    try {
      await _dio.get<void>('/api/v1/auth/csrf');
    } finally {
      _bootstrapping = false;
    }
  }

  Future<void> _attachToken(RequestOptions options, {bool forceRefresh = false}) async {
    await _bootstrapCsrf(force: forceRefresh);
    final token = await _readToken(options.uri);
    if (token != null && token.isNotEmpty) {
      options.headers[headerName] = token;
    } else {
      options.headers.remove(headerName);
    }
  }

  bool _looksLikeCsrfFailure(DioException err) {
    if (err.response?.statusCode != 403) return false;
    final data = err.response?.data;
    if (data is Map) {
      final message = (data['message'] as String?)?.toLowerCase() ?? '';
      final code = (data['code'] as String?)?.toLowerCase() ?? '';
      if (code.contains('csrf')) return true;
      // ChampHive RestAccessDeniedHandler uses this copy for CSRF failures.
      if (message.contains('do not have permission to perform this action')) {
        return true;
      }
      // Real attendance/role denials have their own messages — don't retry those.
      return false;
    }
    // Opaque 403 on a mutating call — worth one CSRF refresh retry.
    return true;
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

      if (options.path.contains('/auth/csrf')) {
        handler.next(options);
        return;
      }

      // Skip if a prior retry already attached a fresh token.
      final alreadyRetried = options.extra['csrf_retried'] == true;
      await _attachToken(options, forceRefresh: alreadyRetried);
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

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    final req = err.requestOptions;
    final canRetry = isMutating(req.method) &&
        req.extra['csrf_retried'] != true &&
        !req.path.contains('/auth/csrf') &&
        _looksLikeCsrfFailure(err);

    if (!canRetry) {
      handler.next(err);
      return;
    }

    try {
      req.extra['csrf_retried'] = true;
      await _attachToken(req, forceRefresh: true);
      final response = await _dio.fetch<dynamic>(req);
      handler.resolve(response);
    } catch (e) {
      if (e is DioException) {
        handler.next(e);
      } else {
        handler.next(
          DioException(
            requestOptions: req,
            error: e,
            type: DioExceptionType.unknown,
            message: 'CSRF retry failed',
          ),
        );
      }
    }
  }
}
