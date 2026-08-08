import 'package:dio/dio.dart';

import '../models/club.dart';

class ClubsApi {
  ClubsApi(this._dio);

  final Dio _dio;

  Future<List<ClubSummary>> listMyClubs() async {
    final response = await _dio.get<dynamic>('/api/v1/users/me/clubs');
    return _parseClubList(response);
  }

  Future<List<ClubSummary>> listClubs() async {
    final response = await _dio.get<dynamic>('/api/v1/clubs');
    return _parseClubList(response);
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

  List<ClubSummary> _parseClubList(Response<dynamic> response) {
    final raw = response.data;
    final list = raw is List
        ? raw
        : (raw is Map && raw['content'] is List)
            ? raw['content'] as List
            : const [];
    return list
        .whereType<Map>()
        .map((e) => ClubSummary.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }
}
