import 'package:dio/dio.dart';

import '../models/analytics.dart';

class AnalyticsApi {
  AnalyticsApi(this._dio);

  final Dio _dio;

  Future<MembershipAnalytics> membership(
    String clubId, {
    int months = 12,
  }) async {
    final response = await _dio.get<dynamic>(
      '/api/v1/clubs/$clubId/analytics/membership',
      queryParameters: {'months': months},
    );
    return MembershipAnalytics.fromJson(_asMap(response, 'Empty membership analytics'));
  }

  Future<RevenueAnalytics> revenue(
    String clubId, {
    int months = 12,
  }) async {
    final response = await _dio.get<dynamic>(
      '/api/v1/clubs/$clubId/analytics/revenue',
      queryParameters: {'months': months},
    );
    return RevenueAnalytics.fromJson(_asMap(response, 'Empty revenue analytics'));
  }

  Map<String, dynamic> _asMap(Response<dynamic> response, String emptyMessage) {
    final raw = response.data;
    if (raw is! Map) {
      throw DioException(
        requestOptions: response.requestOptions,
        type: DioExceptionType.badResponse,
        response: response,
        message: emptyMessage,
      );
    }
    return Map<String, dynamic>.from(raw);
  }
}
