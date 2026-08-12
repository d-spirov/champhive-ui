import 'package:dio/dio.dart';

/// Turns [DioException] (and other errors) into a short user-facing message.
String apiErrorMessage(Object error, {String fallback = 'Something went wrong'}) {
  if (error is StateError) {
    final msg = error.message;
    if (msg.isNotEmpty) return msg;
    return fallback;
  }

  if (error is! DioException) {
    final text = error.toString();
    if (text.isNotEmpty && text != "Instance of '${error.runtimeType}'") {
      return text;
    }
    return fallback;
  }

  final data = error.response?.data;
  if (data is Map) {
    for (final key in ['message', 'detail', 'error', 'title']) {
      final value = data[key];
      if (value is String && value.trim().isNotEmpty) {
        // Prefer the human message over the HTTP reason phrase when both exist.
        if (key == 'error' && data['message'] is String) continue;
        return value.trim();
      }
    }
    final fields = data['fieldErrors'];
    if (fields is List && fields.isNotEmpty) {
      final first = fields.first;
      if (first is Map) {
        final msg = first['message'] ?? first['defaultMessage'];
        if (msg is String && msg.trim().isNotEmpty) return msg.trim();
      }
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
      if (code == 403) {
        return 'Permission denied. If you just logged in, try saving again — '
            'or confirm you are a coach/admin for this team.';
      }
      if (code == 404) return 'Not found.';
      if (code == 409) {
        return 'Could not save — attendance may need to be opened, or was changed elsewhere.';
      }
      if (code != null && code >= 500) return 'Server error. Please try again later.';
      return fallback;
  }
}
