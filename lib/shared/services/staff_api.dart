import 'package:dio/dio.dart';

import '../models/staff.dart';

class StaffApi {
  StaffApi(this._dio);

  final Dio _dio;

  Future<List<StaffMember>> listStaff(
    String clubId, {
    bool includeEnded = false,
  }) async {
    final response = await _dio.get<dynamic>(
      '/api/v1/clubs/$clubId/staff',
      queryParameters: {
        if (includeEnded) 'includeEnded': true,
      },
    );
    final raw = response.data;
    if (raw is! Map) {
      throw DioException(
        requestOptions: response.requestOptions,
        type: DioExceptionType.badResponse,
        response: response,
        message: 'Empty staff list',
      );
    }
    final list = raw['staff'];
    if (list is! List) return const [];
    return list
        .whereType<Map>()
        .map((e) => StaffMember.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }
}
