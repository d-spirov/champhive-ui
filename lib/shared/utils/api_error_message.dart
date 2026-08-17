import 'package:dio/dio.dart';

/// Turns [DioException] (and other errors) into a short user-facing message.
///
/// Prefers RFC 7807 [ApiProblemDetails]: localized `detail`/`title`, with
/// stable `errorCode` available for callers that need to branch.
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
    final detail = data['detail'];
    if (detail is String && detail.trim().isNotEmpty) {
      return detail.trim();
    }
    final title = data['title'];
    if (title is String && title.trim().isNotEmpty) {
      return title.trim();
    }
    for (final key in ['message', 'error']) {
      final value = data[key];
      if (value is String && value.trim().isNotEmpty) {
        return value.trim();
      }
    }
    final errors = data['errors'];
    if (errors is Map && errors.isNotEmpty) {
      final first = errors.values.first;
      if (first is List && first.isNotEmpty) {
        final msg = first.first;
        if (msg is String && msg.trim().isNotEmpty) return msg.trim();
      } else if (first is String && first.trim().isNotEmpty) {
        return first.trim();
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
        return 'Permission denied. Confirm you have coach/admin access for this club.';
      }
      if (code == 404) return 'Not found.';
      if (code == 409) {
        return 'Could not save — attendance may be locked, or was changed elsewhere.';
      }
      if (code != null && code >= 500) return 'Server error. Please try again later.';
      return fallback;
  }
}

/// Stable snake_case problem code from `ApiProblemDetails`, if present.
String? apiErrorCode(Object error) {
  if (error is! DioException) return null;
  final data = error.response?.data;
  if (data is! Map) return null;
  final code = data['errorCode'];
  return code is String && code.isNotEmpty ? code : null;
}
