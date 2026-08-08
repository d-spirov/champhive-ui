import 'package:dio/browser.dart';
import 'package:dio/dio.dart';

/// Web — send cookies cross-origin (requires backend CORS credentials).
void configureAuthHttpClient(Dio dio) {
  dio.httpClientAdapter = BrowserHttpClientAdapter(withCredentials: true);
}
