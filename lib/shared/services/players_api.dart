import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';

import '../models/player.dart';

/// Club members (UI label may still say "Players").
class PlayersApi {
  PlayersApi(this._dio);

  final Dio _dio;

  Future<List<ClubPlayer>> listPlayers({
    required String clubId,
    String? search,
    String? status,
    String? teamId,
    int page = 1,
    int pageSize = 100,
  }) async {
    final response = await _dio.get<dynamic>(
      '/api/v1/clubs/$clubId/members',
      queryParameters: {
        'page': page,
        'pageSize': pageSize,
        if (search != null && search.isNotEmpty) 'search': search,
        if (status != null && status.isNotEmpty) 'status': status,
        if (teamId != null && teamId.isNotEmpty) 'teamId': teamId,
      },
    );
    final raw = response.data;
    final list = raw is Map && raw['items'] is List
        ? raw['items'] as List
        : (raw is Map && raw['content'] is List)
            ? raw['content'] as List
            : (raw is List ? raw : const []);
    return list
        .whereType<Map>()
        .map((e) => ClubPlayer.fromMemberJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  Future<ClubPlayer> getPlayer({
    required String clubId,
    required String playerId,
  }) async {
    final response = await _dio.get<dynamic>(
      '/api/v1/clubs/$clubId/members/$playerId',
    );
    final raw = response.data;
    if (raw is! Map) {
      throw DioException(
        requestOptions: response.requestOptions,
        type: DioExceptionType.badResponse,
        response: response,
        message: 'Empty member response',
      );
    }
    return ClubPlayer.fromMemberJson(Map<String, dynamic>.from(raw));
  }

  /// Authenticated photo bytes. Prefers member photo route; falls back to
  /// fetching [photoUrl] through Dio when it is a relative/API URL.
  Future<Uint8List?> getPhotoBytes({
    required String clubId,
    required String playerId,
    String? photoUrl,
  }) async {
    try {
      final response = await _dio.get<List<int>>(
        '/api/v1/members/$playerId/photo',
        options: Options(
          responseType: ResponseType.bytes,
          headers: const {'Accept': '*/*'},
        ),
      );
      final data = response.data;
      if (data != null && data.isNotEmpty) {
        return Uint8List.fromList(data);
      }
    } on DioException catch (e) {
      if (e.response?.statusCode != 404) {
        // Try photoUrl fallback below for non-404 failures too when provided.
        if (photoUrl == null || photoUrl.isEmpty) rethrow;
      }
    }

    if (photoUrl == null || photoUrl.isEmpty) return null;
    if (photoUrl.startsWith('http://') || photoUrl.startsWith('https://')) {
      try {
        final response = await _dio.get<List<int>>(
          photoUrl,
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
    return null;
  }

  /// `multipart/form-data` with a single `file` part (JPEG, PNG, or WebP).
  /// Replaces the photograph for this person across every club they belong to.
  Future<void> uploadPhoto({
    required String clubId,
    required String memberId,
    required List<int> bytes,
    required String filename,
  }) async {
    final name = _photoFilename(filename);
    final form = FormData.fromMap({
      'file': MultipartFile.fromBytes(
        bytes,
        filename: name,
        contentType: _photoContentType(name),
      ),
    });
    await _dio.post<dynamic>(
      '/api/v1/clubs/$clubId/members/$memberId/photo',
      data: form,
    );
  }

  /// Removes the photograph for this person in every club. Idempotent.
  Future<void> deletePhoto({
    required String clubId,
    required String memberId,
  }) async {
    await _dio.delete<dynamic>(
      '/api/v1/clubs/$clubId/members/$memberId/photo',
    );
  }

  static String _photoFilename(String raw) {
    final name = raw.trim().isEmpty ? 'photo.jpg' : raw.trim();
    final lower = name.toLowerCase();
    if (lower.endsWith('.jpg') ||
        lower.endsWith('.jpeg') ||
        lower.endsWith('.png') ||
        lower.endsWith('.webp')) {
      return name;
    }
    return 'photo.jpg';
  }

  static MediaType _photoContentType(String filename) {
    final lower = filename.toLowerCase();
    if (lower.endsWith('.png')) return MediaType('image', 'png');
    if (lower.endsWith('.webp')) return MediaType('image', 'webp');
    return MediaType('image', 'jpeg');
  }
}
