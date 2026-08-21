import 'package:dio/dio.dart';

import '../models/notification.dart';

class NotificationsApi {
  NotificationsApi(this._dio);

  final Dio _dio;

  /// Cursor feed: pass [before] = previous [NotificationFeed.nextBefore].
  Future<NotificationFeed> listMine({
    DateTime? before,
    int limit = 30,
    bool unreadOnly = false,
  }) async {
    final response = await _dio.get<dynamic>(
      '/api/v1/me/notifications',
      queryParameters: {
        if (before != null) 'before': before.toUtc().toIso8601String(),
        'limit': limit,
        if (unreadOnly) 'unreadOnly': true,
      },
    );
    final raw = response.data;
    if (raw is! Map) {
      throw DioException(
        requestOptions: response.requestOptions,
        type: DioExceptionType.badResponse,
        response: response,
        message: 'Empty notification feed',
      );
    }
    return NotificationFeed.fromJson(Map<String, dynamic>.from(raw));
  }

  Future<MarkNotificationsReadResult> markRead({
    List<String>? notificationIds,
    DateTime? upToUtc,
  }) async {
    final Map<String, dynamic>? body;
    if (notificationIds != null || upToUtc != null) {
      body = {
        'notificationIds': ?notificationIds,
        'upToUtc': ?upToUtc?.toUtc().toIso8601String(),
      };
    } else {
      // Empty body marks the whole feed read.
      body = {};
    }

    final response = await _dio.post<dynamic>(
      '/api/v1/me/notifications/read',
      data: body,
    );
    final raw = response.data;
    if (raw is! Map) {
      throw DioException(
        requestOptions: response.requestOptions,
        type: DioExceptionType.badResponse,
        response: response,
        message: 'Empty mark-read response',
      );
    }
    return MarkNotificationsReadResult.fromJson(Map<String, dynamic>.from(raw));
  }
}
