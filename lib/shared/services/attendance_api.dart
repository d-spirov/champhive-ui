import 'package:dio/dio.dart';

import '../models/event_attendance.dart';

class AttendanceApi {
  AttendanceApi(this._dio);

  final Dio _dio;

  /// Prefetch call before marking — roster + open/lock window.
  Future<AttendanceSession> getRosterSnapshot({
    required String occurrenceId,
  }) async {
    final response = await _dio.get<dynamic>(
      '/api/v1/occurrences/$occurrenceId/roster-snapshot',
    );
    return _parseRoster(response);
  }

  /// Attendance report (readable after lock).
  Future<AttendanceSession> getOccurrenceAttendance({
    required String occurrenceId,
  }) async {
    final response = await _dio.get<dynamic>(
      '/api/v1/occurrences/$occurrenceId/attendance',
    );
    final raw = response.data;
    if (raw is! Map) {
      throw DioException(
        requestOptions: response.requestOptions,
        type: DioExceptionType.badResponse,
        response: response,
        message: 'Empty attendance response',
      );
    }
    return AttendanceSession.fromOccurrenceAttendance(
      Map<String, dynamic>.from(raw),
    );
  }

  /// Legacy-shaped helper used by screens: prefer roster snapshot for marking.
  Future<AttendanceSession> getAttendance({
    required String clubId,
    required String eventId,
  }) {
    return getRosterSnapshot(occurrenceId: eventId);
  }

  Future<AttendanceBatchResult> saveBatch({
    required List<Map<String, dynamic>> entries,
  }) async {
    final response = await _dio.post<dynamic>(
      '/api/v1/attendance/batch',
      data: {'entries': entries},
    );
    final raw = response.data;
    if (raw is! Map) {
      throw DioException(
        requestOptions: response.requestOptions,
        type: DioExceptionType.badResponse,
        response: response,
        message: 'Empty batch response',
      );
    }
    return AttendanceBatchResult.fromJson(Map<String, dynamic>.from(raw));
  }

  Future<AttendanceSession> saveAttendance({
    required String clubId,
    required String eventId,
    required List<AttendanceUpdate> updates,
  }) async {
    final entries = updates
        .where((u) => u.status.isMarkable)
        .map((u) => u.toBatchEntry(occurrenceId: eventId))
        .toList();
    if (entries.isEmpty) {
      throw StateError('Mark at least one player before saving.');
    }

    final batch = await saveBatch(entries: entries);
    if (batch.hasRejects) {
      final firstReject = batch.results.cast<AttendanceEntryResult?>().firstWhere(
            (r) => r?.outcome == 'rejected',
            orElse: () => null,
          );
      final reason = firstReject?.reason;
      throw StateError(
        reason != null && reason.isNotEmpty
            ? 'Some marks were rejected ($reason).'
            : 'Some attendance marks were rejected.',
      );
    }

    // Re-fetch roster so the saved screen / UI sees server truth.
    return getRosterSnapshot(occurrenceId: eventId);
  }

  AttendanceSession _parseRoster(Response<dynamic> response) {
    final raw = response.data;
    if (raw is! Map) {
      throw DioException(
        requestOptions: response.requestOptions,
        type: DioExceptionType.badResponse,
        response: response,
        message: 'Empty roster snapshot',
      );
    }
    return AttendanceSession.fromRosterSnapshot(
      Map<String, dynamic>.from(raw),
    );
  }
}
