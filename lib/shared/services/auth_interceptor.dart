import 'package:dio/dio.dart';

import 'token_store.dart';

typedef TokenRefresher = Future<TokenPair?> Function();
typedef SessionExpiredCallback = Future<void> Function();

/// Attaches Bearer access tokens and performs single-flight refresh on 401.
///
/// Refresh tokens rotate: a spent refresh must never be retried.
class AuthInterceptor extends Interceptor {
  AuthInterceptor({
    required this.dio,
    required this.tokenStore,
    required this.refreshTokens,
    required this.onSessionExpired,
  });

  final Dio dio;
  final TokenStore tokenStore;
  final TokenRefresher refreshTokens;
  final SessionExpiredCallback onSessionExpired;

  bool _refreshing = false;
  Future<TokenPair?>? _refreshFuture;

  static bool isAuthPath(String path) {
    final p = path.toLowerCase();
    return p.contains('/auth/login') ||
        p.contains('/auth/register') ||
        p.contains('/auth/refresh') ||
        p.contains('/auth/logout') ||
        p.contains('/auth/forgot-password') ||
        p.contains('/auth/reset-password') ||
        p.contains('/auth/verify-email') ||
        p.contains('/auth/google');
  }

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (!isAuthPath(options.path)) {
      final token = tokenStore.accessToken;
      if (token != null && token.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $token';
      }
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    final code = err.response?.statusCode;
    final path = err.requestOptions.uri.path;

    if (code != 401 || isAuthPath(path) || err.requestOptions.extra['auth_retried'] == true) {
      handler.next(err);
      return;
    }

    try {
      final pair = await _refreshOnce();
      if (pair == null || pair.accessToken.isEmpty) {
        await onSessionExpired();
        handler.next(err);
        return;
      }

      final req = err.requestOptions;
      req.extra['auth_retried'] = true;
      req.headers['Authorization'] = 'Bearer ${pair.accessToken}';
      final response = await dio.fetch<dynamic>(req);
      handler.resolve(response);
    } catch (_) {
      await onSessionExpired();
      handler.next(err);
    }
  }

  Future<TokenPair?> _refreshOnce() {
    if (_refreshing && _refreshFuture != null) {
      return _refreshFuture!;
    }
    _refreshing = true;
    _refreshFuture = () async {
      try {
        return await refreshTokens();
      } finally {
        _refreshing = false;
        _refreshFuture = null;
      }
    }();
    return _refreshFuture!;
  }
}
