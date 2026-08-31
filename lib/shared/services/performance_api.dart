import 'package:dio/dio.dart';

import '../models/performance.dart';

class PerformanceApi {
  PerformanceApi(this._dio);

  final Dio _dio;

  Future<List<String>> listSports({required String clubId}) async {
    final response = await _dio.get<dynamic>(
      '/api/v1/clubs/$clubId/performance/sports',
    );
    final raw = response.data;
    final list = raw is Map && raw['sportCodes'] is List
        ? raw['sportCodes'] as List
        : const [];
    return list.map((e) => e.toString()).where((s) => s.isNotEmpty).toList();
  }

  Future<List<MetricBattery>> listBatteries({
    required String clubId,
    String? sportCode,
    bool includeArchived = false,
  }) async {
    final response = await _dio.get<dynamic>(
      '/api/v1/clubs/$clubId/performance/batteries',
      queryParameters: {
        if (sportCode != null && sportCode.isNotEmpty) 'sportCode': sportCode,
        if (includeArchived) 'includeArchived': true,
      },
    );
    final raw = response.data;
    final list = raw is Map && raw['items'] is List
        ? raw['items'] as List
        : (raw is List ? raw : const []);
    return list
        .whereType<Map>()
        .map((e) => MetricBattery.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  Future<MetricBattery> createBattery({
    required String clubId,
    required String sportCode,
    required String name,
    required List<String> metricCodes,
  }) async {
    final response = await _dio.post<dynamic>(
      '/api/v1/clubs/$clubId/performance/batteries',
      data: {'sportCode': sportCode, 'name': name, 'metricCodes': metricCodes},
    );
    return MetricBattery.fromJson(_asMap(response, 'Empty test set'));
  }

  Future<ClubMetricCatalogue> listMetrics({
    required String clubId,
    required String sportCode,
    String? sectionId,
  }) async {
    final response = await _dio.get<dynamic>(
      '/api/v1/clubs/$clubId/performance/metrics',
      queryParameters: {
        'sportCode': sportCode,
        if (sectionId != null && sectionId.isNotEmpty) 'sectionId': sectionId,
      },
    );
    return ClubMetricCatalogue.fromJson(
      _asMap(response, 'Empty metrics catalogue'),
    );
  }

  Future<TestingDay> getTestingDay({
    required String clubId,
    required String occurrenceId,
  }) async {
    final response = await _dio.get<dynamic>(
      '/api/v1/clubs/$clubId/performance/testing-days/$occurrenceId',
    );
    return TestingDay.fromJson(_asMap(response, 'Empty testing day'));
  }

  Future<ColumnRecorded> recordColumn({
    required String clubId,
    required String teamId,
    required String metricCode,
    required String assessedOn,
    required List<ColumnEntry> entries,
    String? seasonId,
    String? occurrenceId,
  }) async {
    final response = await _dio.post<dynamic>(
      '/api/v1/clubs/$clubId/performance/teams/$teamId/column',
      data: {
        'metricCode': metricCode,
        'assessedOn': assessedOn,
        'seasonId': seasonId,
        if (occurrenceId != null && occurrenceId.isNotEmpty)
          'occurrenceId': occurrenceId,
        'entries': entries.map((e) => e.toJson()).toList(),
      },
    );
    return ColumnRecorded.fromJson(_asMap(response, 'Empty column response'));
  }

  Future<List<PerformanceSitting>> listMyDrafts({
    required String clubId,
  }) async {
    final response = await _dio.get<dynamic>(
      '/api/v1/clubs/$clubId/performance/my-drafts',
    );
    final raw = response.data;
    final list = raw is List
        ? raw
        : (raw is Map && raw['items'] is List)
        ? raw['items'] as List
        : const [];
    return list
        .whereType<Map>()
        .map((e) => PerformanceSitting.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  Future<void> finalizeSitting({
    required String clubId,
    required String assessmentId,
  }) async {
    await _dio.post<dynamic>(
      '/api/v1/clubs/$clubId/performance/assessments/$assessmentId/finalize',
    );
  }

  Future<PlayerPerformance> memberHistory({
    required String clubId,
    required String memberId,
    String? sportCode,
  }) async {
    final response = await _dio.get<dynamic>(
      '/api/v1/clubs/$clubId/performance/members/$memberId',
      queryParameters: {
        if (sportCode != null && sportCode.isNotEmpty) 'sportCode': sportCode,
      },
    );
    return PlayerPerformance.fromJson(
      _asMap(response, 'Empty performance history'),
    );
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
