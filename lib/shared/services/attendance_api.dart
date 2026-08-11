import 'package:dio/dio.dart';

import '../models/event_attendance.dart';

class AttendanceApi {
  AttendanceApi(this._dio);

  final Dio _dio;

  Future<AttendanceSession> getAttendance({
    required String clubId,
    required String eventId,
  }) async {
    final response = await _dio.get<dynamic>(
      '/api/v1/clubs/$clubId/events/$eventId/attendance',
    );
    return _parseSession(response);
  }

  Future<AttendanceSession> saveAttendance({
    required String clubId,
    required String eventId,
    required List<AttendanceUpdate> updates,
  }) async {
    final response = await _dio.put<dynamic>(
      '/api/v1/clubs/$clubId/events/$eventId/attendance',
      data: {
        'updates': updates.map((u) => u.toJson()).toList(),
      },
    );
    return _parseSession(response);
  }

  Future<AttendanceSession> openAttendance({
    required String clubId,
    required String eventId,
  }) async {
    final response = await _dio.post<dynamic>(
      '/api/v1/clubs/$clubId/events/$eventId/attendance/open',
    );
    return _parseSession(response);
  }

  Future<AttendanceSession> finalizeAttendance({
    required String clubId,
    required String eventId,
    bool force = false,
  }) async {
    final response = await _dio.post<dynamic>(
      '/api/v1/clubs/$clubId/events/$eventId/attendance/finalize',
      queryParameters: {'force': force},
    );
    return _parseSession(response);
  }

  Future<List<AttendanceEventCard>> listDashboardCards({
    required String clubId,
  }) async {
    final response = await _dio.get<dynamic>(
      '/api/v1/clubs/$clubId/attendance-dashboard',
    );
    final raw = response.data;
    if (raw is! Map) return const [];
    final cards = <AttendanceEventCard>[];
    for (final key in ['today', 'needsFinalization', 'awaitingResponses']) {
      final list = raw[key];
      if (list is! List) continue;
      for (final item in list) {
        if (item is Map) {
          cards.add(
            AttendanceEventCard.fromJson(Map<String, dynamic>.from(item)),
          );
        }
      }
    }
    // De-dupe by eventId, keep first occurrence.
    final seen = <String>{};
    return cards.where((c) => seen.add(c.eventId)).toList();
  }

  AttendanceSession _parseSession(Response<dynamic> response) {
    final raw = response.data;
    if (raw is! Map) {
      throw DioException(
        requestOptions: response.requestOptions,
        type: DioExceptionType.badResponse,
        response: response,
        message: 'Empty attendance response',
      );
    }
    return AttendanceSession.fromJson(Map<String, dynamic>.from(raw));
  }
}

class AttendanceEventCard {
  const AttendanceEventCard({
    required this.eventId,
    required this.title,
    required this.type,
    required this.startAt,
    required this.total,
    required this.marked,
    required this.noResponse,
    required this.attendanceState,
    this.timezone,
    this.teamNames,
  });

  final String eventId;
  final String title;
  final EventType type;
  final DateTime startAt;
  final String? timezone;
  final String? teamNames;
  final int total;
  final int marked;
  final int noResponse;
  final AttendanceState attendanceState;

  factory AttendanceEventCard.fromJson(Map<String, dynamic> json) {
    return AttendanceEventCard(
      eventId: json['eventId']?.toString() ?? '',
      title: json['title'] as String? ?? 'Event',
      type: parseEventType(json['type'] as String?),
      startAt: DateTime.tryParse(json['startAt'] as String? ?? '')?.toLocal() ??
          DateTime.now(),
      timezone: json['timezone'] as String?,
      teamNames: json['teamNames'] as String?,
      total: (json['total'] as num?)?.toInt() ?? 0,
      marked: (json['marked'] as num?)?.toInt() ?? 0,
      noResponse: (json['noResponse'] as num?)?.toInt() ?? 0,
      attendanceState: parseAttendanceState(json['attendanceState'] as String?),
    );
  }
}
