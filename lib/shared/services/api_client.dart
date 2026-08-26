import 'package:dio/dio.dart';

/// ChampHive ClubPlatform API.
/// Docs: https://api.champhive.app/scalar/v1
/// OpenAPI: https://api.champhive.app/openapi/v1.json
const String apiBaseUrl = 'https://api.champhive.app';

const String apiClientMobile = 'mobile';

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
        'User-Agent': 'ChampHive/1.0 (Flutter)',
      },
    ),
  );
  for (final interceptor in interceptors) {
    dio.interceptors.add(interceptor);
  }
  return dio;
}
