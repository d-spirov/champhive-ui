import 'package:dio/dio.dart';

/// Turns [DioException] (and other errors) into a short user-facing message.
String apiErrorMessage(Object error, {String fallback = 'Something went wrong'}) {
  if (error is! DioException) return fallback;

  final data = error.response?.data;
  if (data is Map) {
    for (final key in ['message', 'error', 'title', 'detail']) {
      final value = data[key];
      if (value is String && value.trim().isNotEmpty) return value.trim();
    }
  } else if (data is String && data.trim().isNotEmpty) {
    return data.trim();
  }

  switch (error.type) {
    case DioExceptionType.connectionTimeout:
    case DioExceptionType.sendTimeout:
    case DioExceptionType.receiveTimeout:
      return 'Connection timed out. Check your network and try again.';
    case DioExceptionType.connectionError:
      return 'Unable to reach the server. Check your network.';
    default:
      final code = error.response?.statusCode;
      if (code == 401) return 'Invalid email or password.';
      if (code == 403) return 'You do not have permission to do that.';
      if (code == 404) return 'Not found.';
      if (code != null && code >= 500) return 'Server error. Please try again later.';
      return fallback;
  }
}
