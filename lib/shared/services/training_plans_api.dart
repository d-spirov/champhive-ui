import 'dart:typed_data';

import 'package:dio/dio.dart';

import '../models/training_plan.dart';

class TrainingPlansApi {
  TrainingPlansApi(this._dio);

  final Dio _dio;

  Future<List<TrainingPlan>> listPlans({
    required String clubId,
    String? teamId,
    int page = 1,
    int pageSize = 100,
  }) async {
    final response = await _dio.get<dynamic>(
      '/api/v1/clubs/$clubId/training-plans',
      queryParameters: {
        'page': page,
        'pageSize': pageSize,
        if (teamId != null && teamId.isNotEmpty) 'teamId': teamId,
      },
    );
    return _parseList(response.data).map(TrainingPlan.fromJson).toList();
  }

  Future<TrainingPlan> getPlan({
    required String clubId,
    required String planId,
  }) async {
    final response = await _dio.get<dynamic>(
      '/api/v1/clubs/$clubId/training-plans/$planId',
    );
    final raw = response.data;
    if (raw is! Map) {
      throw DioException(
        requestOptions: response.requestOptions,
        type: DioExceptionType.badResponse,
        response: response,
        message: 'Empty training plan',
      );
    }
    return TrainingPlan.fromJson(Map<String, dynamic>.from(raw));
  }

  /// Authenticated image bytes. No public URL — the API re-checks access.
  Future<Uint8List?> getExerciseImageBytes({
    required String clubId,
    required String imageId,
  }) async {
    try {
      final response = await _dio.get<List<int>>(
        '/api/v1/clubs/$clubId/exercise-images/$imageId',
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

  List<Map<String, dynamic>> _parseList(Object? raw) {
    final list = raw is List
        ? raw
        : raw is Map && raw['items'] is List
        ? raw['items'] as List
        : raw is Map && raw['content'] is List
        ? raw['content'] as List
        : const [];
    return list
        .whereType<Map>()
        .map((e) => Map<String, dynamic>.from(e))
        .toList();
  }
}
