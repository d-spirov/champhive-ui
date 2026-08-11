import 'package:dio/dio.dart';

import '../models/event_attendance.dart';

class EventsApi {
  EventsApi(this._dio);

  final Dio _dio;

  Future<List<ClubEvent>> listEvents({
    required String clubId,
    DateTime? from,
    DateTime? to,
    String? teamId,
    EventType? eventType,
    int page = 0,
    int size = 200,
    String sort = 'asc',
  }) async {
    final response = await _dio.get<dynamic>(
      '/api/v1/clubs/$clubId/events',
      queryParameters: {
        if (from != null) 'from': from.toUtc().toIso8601String(),
        if (to != null) 'to': to.toUtc().toIso8601String(),
        'teamId': ?teamId,
        'eventType': ?eventType?.apiValue,
        'page': page,
        'size': size,
        'sort': sort,
      },
    );
    final raw = response.data;
    final list = raw is Map && raw['content'] is List
        ? raw['content'] as List
        : (raw is List ? raw : const []);
    return list
        .whereType<Map>()
        .map((e) => ClubEvent.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  Future<ClubEvent> getEvent({
    required String clubId,
    required String eventId,
  }) async {
    final response = await _dio.get<dynamic>(
      '/api/v1/clubs/$clubId/events/$eventId',
    );
    final raw = response.data;
    if (raw is! Map) {
      throw DioException(
        requestOptions: response.requestOptions,
        type: DioExceptionType.badResponse,
        response: response,
        message: 'Empty event response',
      );
    }
    return ClubEvent.fromJson(Map<String, dynamic>.from(raw));
  }
}
