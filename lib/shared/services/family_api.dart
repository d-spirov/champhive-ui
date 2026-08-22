import 'package:dio/dio.dart';

import '../models/family.dart';

class FamilyApi {
  FamilyApi(this._dio);

  final Dio _dio;

  Future<List<FamilyChild>> listChildren() async {
    final response = await _dio.get<dynamic>('/api/v1/me/children');
    final raw = _asMap(response, 'Empty family children');
    final list = raw['children'];
    if (list is! List) return const [];
    return list
        .whereType<Map>()
        .map((e) => FamilyChild.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  Future<FamilyChild> getChild(String memberId) async {
    final response =
        await _dio.get<dynamic>('/api/v1/me/children/$memberId');
    return FamilyChild.fromJson(_asMap(response, 'Empty family child'));
  }

  Future<List<PendingConsent>> listPendingConsents() async {
    final response = await _dio.get<dynamic>('/api/v1/me/consents/pending');
    final raw = _asMap(response, 'Empty pending consents');
    final list = raw['pending'];
    if (list is! List) return const [];
    return list
        .whereType<Map>()
        .map((e) => PendingConsent.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  Future<List<ConsentStatus>> listChildConsents(String memberId) async {
    final response =
        await _dio.get<dynamic>('/api/v1/me/children/$memberId/consents');
    final raw = _asMap(response, 'Empty consent status');
    final list = raw['consents'];
    if (list is! List) return const [];
    return list
        .whereType<Map>()
        .map((e) => ConsentStatus.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  Future<ConsentStatus> grantConsent({
    required String memberId,
    required String kind,
  }) async {
    final response = await _dio.post<dynamic>(
      '/api/v1/me/children/$memberId/consents',
      data: {'kind': kind},
    );
    return ConsentStatus.fromJson(_asMap(response, 'Empty grant consent'));
  }

  Future<ConsentStatus> withdrawConsent({
    required String memberId,
    required String kind,
  }) async {
    final response = await _dio.delete<dynamic>(
      '/api/v1/me/children/$memberId/consents/$kind',
    );
    return ConsentStatus.fromJson(_asMap(response, 'Empty withdraw consent'));
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
