import 'package:dio/dio.dart';

import '../models/event_attendance.dart';
import '../models/team.dart';

class TeamsApi {
  TeamsApi(this._dio);

  final Dio _dio;

  Future<List<ClubTeam>> listTeams({required String clubId}) async {
    final response = await _dio.get<dynamic>('/api/v1/clubs/$clubId/teams');
    final raw = response.data;
    final list = raw is List
        ? raw
        : (raw is Map && raw['items'] is List)
        ? raw['items'] as List
        : const [];
    return list
        .whereType<Map>()
        .map((e) => ClubTeam.fromJson(Map<String, dynamic>.from(e)))
        .toList()
      ..sort((a, b) => a.name.compareTo(b.name));
  }

  Future<TeamRoster> getRoster({
    required String clubId,
    required String teamId,
    String? seasonId,
  }) async {
    final response = await _dio.get<dynamic>(
      '/api/v1/clubs/$clubId/teams/$teamId/roster',
      queryParameters: {
        if (seasonId != null && seasonId.isNotEmpty) 'seasonId': seasonId,
      },
    );
    final raw = response.data;
    if (raw is! Map) {
      throw DioException(
        requestOptions: response.requestOptions,
        type: DioExceptionType.badResponse,
        response: response,
        message: 'Empty roster response',
      );
    }
    return TeamRoster.fromJson(Map<String, dynamic>.from(raw));
  }

  Future<List<ClubEvent>> getSchedule({
    required String clubId,
    required String teamId,
    DateTime? from,
    DateTime? to,
  }) async {
    final response = await _dio.get<dynamic>(
      '/api/v1/clubs/$clubId/teams/$teamId/schedule',
      queryParameters: {
        if (from != null) 'from': from.toUtc().toIso8601String(),
        if (to != null) 'to': to.toUtc().toIso8601String(),
      },
    );
    final raw = response.data;
    final list = raw is Map && raw['items'] is List
        ? raw['items'] as List
        : (raw is List ? raw : const []);
    return list
        .whereType<Map>()
        .map((e) => ClubEvent.fromOccurrenceJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  Future<List<ClubSeason>> listSeasons({required String clubId}) async {
    final response = await _dio.get<dynamic>('/api/v1/clubs/$clubId/seasons');
    final raw = response.data;
    final list = raw is List
        ? raw
        : (raw is Map && raw['items'] is List)
        ? raw['items'] as List
        : const [];
    return list
        .whereType<Map>()
        .map((e) => ClubSeason.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }
}
