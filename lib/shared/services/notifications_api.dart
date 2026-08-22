import 'package:dio/dio.dart';

import '../models/notification.dart';
import '../models/notification_preference.dart';

class NotificationsApi {
  NotificationsApi(this._dio);

  final Dio _dio;

  Future<List<NotificationPreference>> getPreferences() async {
    final response =
        await _dio.get<dynamic>('/api/v1/me/notification-preferences');
    final raw = response.data;
    if (raw is! Map) {
      throw DioException(
        requestOptions: response.requestOptions,
        type: DioExceptionType.badResponse,
        response: response,
        message: 'Empty notification preferences',
      );
    }
    final list = raw['preferences'];
    if (list is! List) return const [];
    return list
        .whereType<Map>()
        .map(
          (e) => NotificationPreference.fromJson(Map<String, dynamic>.from(e)),
        )
        .toList();
  }

  /// Partial update — send only the rows that changed; API returns the full set.
  Future<List<NotificationPreference>> updatePreferences(
    List<NotificationPreference> updates,
  ) async {
    final response = await _dio.patch<dynamic>(
      '/api/v1/me/notification-preferences',
      data: {
        'preferences': updates.map((e) => e.toUpdateJson()).toList(),
      },
    );
    final raw = response.data;
    if (raw is! Map) {
      throw DioException(
        requestOptions: response.requestOptions,
        type: DioExceptionType.badResponse,
        response: response,
        message: 'Empty notification preferences',
      );
    }
    final list = raw['preferences'];
    if (list is! List) return const [];
    return list
        .whereType<Map>()
        .map(
          (e) => NotificationPreference.fromJson(Map<String, dynamic>.from(e)),
        )
        .toList();
  }

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
