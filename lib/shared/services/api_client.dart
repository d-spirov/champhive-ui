import 'package:dio/dio.dart';

/// ChampHive / TeamHive backend.
/// Swagger: https://backend-production-785b.up.railway.app/swagger-ui/index.html
const String apiBaseUrl = 'https://backend-production-785b.up.railway.app';

String apiPath(String path) {
  if (path.startsWith('http')) return path;
  final normalized = path.startsWith('/') ? path : '/$path';
  return '$apiBaseUrl$normalized';
}

/// Shared Dio factory used by authenticated API clients.
Dio createApiDio({List<Interceptor> interceptors = const []}) {
  final dio = Dio(
    BaseOptions(
      baseUrl: apiBaseUrl,
      connectTimeout: const Duration(seconds: 20),
      receiveTimeout: const Duration(seconds: 30),
      headers: const {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
    ),
  );
  for (final interceptor in interceptors) {
    dio.interceptors.add(interceptor);
  }
  return dio;
}
