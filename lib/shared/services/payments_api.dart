import 'dart:math';

import 'package:dio/dio.dart';

import '../models/payment.dart';

class PaymentsApi {
  PaymentsApi(this._dio);

  final Dio _dio;

  Future<FamilyFees> getMyFees() async {
    final response = await _dio.get<dynamic>('/api/v1/me/fees');
    return FamilyFees.fromJson(_asMap(response, 'Empty fees'));
  }

  Future<FamilyFeeHistory> getMyFeeHistory({
    String? memberId,
    int page = 1,
    int pageSize = 30,
  }) async {
    final response = await _dio.get<dynamic>(
      '/api/v1/me/fees/history',
      queryParameters: {
        'memberId': ?memberId,
        'page': page,
        'pageSize': pageSize,
      },
    );
    return FamilyFeeHistory.fromJson(_asMap(response, 'Empty fee history'));
  }

  Future<ObligationsPage> listObligations(
    String clubId, {
    bool openOnly = true,
    String? memberId,
    String? search,
    int page = 1,
    int pageSize = 50,
  }) async {
    final response = await _dio.get<dynamic>(
      '/api/v1/clubs/$clubId/obligations',
      queryParameters: {
        'openOnly': openOnly,
        'memberId': ?memberId,
        'search': ?search,
        'page': page,
        'pageSize': pageSize,
        'sort': 'dueDate',
        'desc': false,
      },
    );
    return ObligationsPage.fromJson(_asMap(response, 'Empty obligations'));
  }

  Future<PaymentsPage> listPayments(
    String clubId, {
    String? memberId,
    int page = 1,
    int pageSize = 40,
  }) async {
    final response = await _dio.get<dynamic>(
      '/api/v1/clubs/$clubId/payments',
      queryParameters: {
        'memberId': ?memberId,
        'page': page,
        'pageSize': pageSize,
      },
    );
    return PaymentsPage.fromJson(_asMap(response, 'Empty payments'));
  }

  Future<ClubPayment> recordPayment(
    String clubId, {
    required String memberId,
    required double amount,
    required String method,
    String? currency,
    DateTime? paidOn,
    String? notes,
    String? idempotencyKey,
  }) async {
    final key = idempotencyKey ?? _newIdempotencyKey();
    final response = await _dio.post<dynamic>(
      '/api/v1/clubs/$clubId/payments',
      data: {
        'memberId': memberId,
        'amount': amount,
        'currency': currency,
        'method': method,
        'paidOn': paidOn?.toIso8601String().split('T').first,
        'notes': notes,
      },
      options: Options(headers: {'Idempotency-Key': key}),
    );
    return ClubPayment.fromJson(_asMap(response, 'Empty payment'));
  }

  static String _newIdempotencyKey() {
    final r = Random.secure();
    final bytes = List<int>.generate(16, (_) => r.nextInt(256));
    bytes[6] = (bytes[6] & 0x0f) | 0x40;
    bytes[8] = (bytes[8] & 0x3f) | 0x80;
    String hex(int b) => b.toRadixString(16).padLeft(2, '0');
    final h = bytes.map(hex).join();
    return '${h.substring(0, 8)}-${h.substring(8, 12)}-'
        '${h.substring(12, 16)}-${h.substring(16, 20)}-${h.substring(20)}';
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
