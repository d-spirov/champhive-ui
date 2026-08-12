import 'dart:typed_data';

import 'package:dio/dio.dart';

import '../models/player.dart';

class PlayersApi {
  PlayersApi(this._dio);

  final Dio _dio;

  Future<List<ClubPlayer>> listPlayers({
    required String clubId,
    String? search,
    String status = 'ACTIVE',
    String? teamId,
    int page = 0,
    int size = 100,
  }) async {
    final response = await _dio.get<dynamic>(
      '/api/v1/clubs/$clubId/players',
      queryParameters: {
        'page': page,
        'size': size,
        'status': status,
        'search': ?search,
        'teamId': ?teamId,
      },
    );
    final raw = response.data;
    final list = raw is Map && raw['content'] is List
        ? raw['content'] as List
        : (raw is List ? raw : const []);
    return list
        .whereType<Map>()
        .map((e) => ClubPlayer.fromListJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  Future<ClubPlayer> getPlayer({
    required String clubId,
    required String playerId,
  }) async {
    final response = await _dio.get<dynamic>(
      '/api/v1/clubs/$clubId/players/$playerId',
    );
    final raw = response.data;
    if (raw is! Map) {
      throw DioException(
        requestOptions: response.requestOptions,
        type: DioExceptionType.badResponse,
        response: response,
        message: 'Empty player response',
      );
    }
    return ClubPlayer.fromDetailJson(Map<String, dynamic>.from(raw));
  }

  /// Authenticated photo bytes (session cookies via Dio). Null if no photo.
  Future<Uint8List?> getPhotoBytes({
    required String clubId,
    required String playerId,
  }) async {
    try {
      final response = await _dio.get<List<int>>(
        '/api/v1/clubs/$clubId/players/$playerId/photo',
        options: Options(
          responseType: ResponseType.bytes,
          headers: const {'Accept': '*/*'},
        ),
      );
      final data = response.data;
      if (data == null || data.isEmpty) return null;
      return Uint8List.fromList(data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return null;
      rethrow;
    }
  }
}
