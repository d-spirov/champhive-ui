import 'package:dio/dio.dart';

import '../models/club.dart';
import '../models/section.dart';
import '../models/user.dart';

class ClubsApi {
  ClubsApi(this._dio);

  final Dio _dio;

  /// Resolve the caller's clubs from `/me` grants, then fetch each club card.
  Future<List<ClubSummary>> listMyClubs(User me) async {
    final ids = me.clubIds.toList()..sort();
    if (ids.isEmpty) return const [];

    final clubs = <ClubSummary>[];
    for (final id in ids) {
      try {
        final club = await getClub(id);
        clubs.add(
          ClubSummary.fromClub(club, roles: me.rolesForClub(id)),
        );
      } catch (_) {
        // Skip clubs the caller can no longer read.
      }
    }
    return clubs;
  }

  Future<Club> getClub(String clubId) async {
    final response = await _dio.get<dynamic>('/api/v1/clubs/$clubId');
    final raw = response.data;
    if (raw is! Map) {
      throw DioException(
        requestOptions: response.requestOptions,
        type: DioExceptionType.badResponse,
        response: response,
        message: 'Empty club response',
      );
    }
    return Club.fromJson(Map<String, dynamic>.from(raw));
  }

  Future<List<ClubSection>> listSections(String clubId) async {
    final response =
        await _dio.get<dynamic>('/api/v1/clubs/$clubId/sections');
    final raw = response.data;
    final list = raw is List
        ? raw
        : (raw is Map ? raw['items'] ?? raw['sections'] : null);
    if (list is! List) return const [];
    return list
        .whereType<Map>()
        .map((e) => ClubSection.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }
}
