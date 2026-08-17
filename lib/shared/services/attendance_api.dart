import 'package:dio/dio.dart';

import '../models/event_attendance.dart';

class AttendanceApi {
  AttendanceApi(this._dio);

  final Dio _dio;

  /// Prefetch before marking — roster + open/lock window.
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

  /// Posts one or more marks to `POST /api/v1/attendance/batch`, then refreshes
  /// the roster snapshot so the UI matches server truth.
  Future<AttendanceSaveResult> saveAttendance({
    required String occurrenceId,
    required List<AttendanceUpdate> updates,
  }) async {
    final entries = updates
        .where((u) => u.status.isMarkable)
        .map((u) => u.toBatchEntry(occurrenceId: occurrenceId))
        .toList();
    if (entries.isEmpty) {
      throw StateError('Mark at least one member before saving.');
    }

    final batch = await saveBatch(entries: entries);
    if (batch.hasRejects) {
      final rejected = batch.results.where((r) => r.outcome == 'rejected');
      final first = rejected.isEmpty ? null : rejected.first;
      final reason = first?.reason;
      throw StateError(
        reason != null && reason.isNotEmpty
            ? 'Could not save mark ($reason).'
            : 'Could not save attendance mark.',
      );
    }

    final session = await getRosterSnapshot(occurrenceId: occurrenceId);
    return AttendanceSaveResult(batch: batch, session: session);
  }

  /// Convenience: persist a single member status immediately.
  Future<AttendanceSaveResult> saveMemberStatus({
    required String occurrenceId,
    required String memberId,
    required AttendanceStatus status,
    String? note,
    DateTime? recordedAtClientUtc,
  }) {
    return saveAttendance(
      occurrenceId: occurrenceId,
      updates: [
        AttendanceUpdate(
          participantId: memberId,
          status: status,
          note: note,
          recordedAtClientUtc: recordedAtClientUtc ?? DateTime.now().toUtc(),
          clientRecordId: newClientRecordId(),
        ),
      ],
    );
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
