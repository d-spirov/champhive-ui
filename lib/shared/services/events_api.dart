import 'package:dio/dio.dart';

import '../models/event_attendance.dart';
import '../models/event_series.dart';

/// Club schedule of occurrences (replaces the old events list API).
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
      '/api/v1/clubs/$clubId/schedule',
      queryParameters: {
        if (from != null) 'from': from.toUtc().toIso8601String(),
        if (to != null) 'to': to.toUtc().toIso8601String(),
      },
    );
    var items = _parseOccurrences(response);
    if (eventType != null) {
      items = items.where((e) => e.type == eventType).toList();
    }
    if (sort == 'desc') {
      items = items.reversed.toList();
    }
    if (size > 0 && items.length > size) {
      items = items.take(size).toList();
    }
    return items;
  }

  Future<ClubEvent> getEvent({
    required String clubId,
    required String eventId,
  }) async {
    final response = await _dio.get<dynamic>('/api/v1/occurrences/$eventId');
    final raw = response.data;
    if (raw is! Map) {
      throw DioException(
        requestOptions: response.requestOptions,
        type: DioExceptionType.badResponse,
        response: response,
        message: 'Empty occurrence response',
      );
    }
    return ClubEvent.fromOccurrenceJson(Map<String, dynamic>.from(raw));
  }

  Future<EventSeries> getSeries({
    required String clubId,
    required String seriesId,
  }) async {
    final response = await _dio.get<dynamic>(
      '/api/v1/clubs/$clubId/events/$seriesId',
    );
    final raw = response.data;
    if (raw is! Map) {
      throw DioException(
        requestOptions: response.requestOptions,
        type: DioExceptionType.badResponse,
        response: response,
        message: 'Empty series response',
      );
    }
    return EventSeries.fromJson(Map<String, dynamic>.from(raw));
  }

  Future<EventSeries> createSeries({
    required String clubId,
    required SaveEventSeriesRequest request,
  }) async {
    final response = await _dio.post<dynamic>(
      '/api/v1/clubs/$clubId/events',
      data: request.toJson(),
    );
    final raw = response.data;
    if (raw is! Map) {
      throw DioException(
        requestOptions: response.requestOptions,
        type: DioExceptionType.badResponse,
        response: response,
        message: 'Empty series response',
      );
    }
    return EventSeries.fromJson(Map<String, dynamic>.from(raw));
  }

  List<ClubEvent> _parseOccurrences(Response<dynamic> response) {
    final raw = response.data;
    final list = raw is Map && raw['items'] is List
        ? raw['items'] as List
        : (raw is List ? raw : const []);
    return list
        .whereType<Map>()
        .map((e) => ClubEvent.fromOccurrenceJson(Map<String, dynamic>.from(e)))
        .toList();
  }
}
