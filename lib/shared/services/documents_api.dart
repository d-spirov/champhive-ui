import 'package:dio/dio.dart';

import '../models/compliance.dart';
import 'api_client.dart';

class DocumentsApi {
  DocumentsApi(this._dio);

  final Dio _dio;

  Future<MemberCompliance> getMemberCompliance(String memberId) async {
    final response = await _dio.get<dynamic>(
      '/api/v1/members/$memberId/compliance',
    );
    return MemberCompliance.fromJson(_asMap(response, 'Empty compliance'));
  }

  Future<ComplianceOverview> getOverview(String clubId) async {
    final response = await _dio.get<dynamic>(
      '/api/v1/clubs/$clubId/compliance/overview',
    );
    return ComplianceOverview.fromJson(_asMap(response, 'Empty overview'));
  }

  Future<ComplianceDocumentsPage> listDocuments(
    String clubId, {
    String? status,
    String? memberId,
    int page = 1,
    int pageSize = 50,
  }) async {
    final response = await _dio.get<dynamic>(
      '/api/v1/clubs/$clubId/compliance/documents',
      queryParameters: {
        if (status != null && status.isNotEmpty) 'status': status,
        if (memberId != null && memberId.isNotEmpty) 'memberId': memberId,
        'page': page,
        'pageSize': pageSize,
      },
    );
    return ComplianceDocumentsPage.fromJson(
      _asMap(response, 'Empty documents'),
    );
  }

  Future<DocumentUploadTicket> startUpload({
    required String memberId,
    required String documentTypeId,
    required String fileName,
    required String contentType,
    required int sizeBytes,
    DateTime? issuedOn,
  }) async {
    final response = await _dio.post<dynamic>(
      '/api/v1/documents',
      data: {
        'memberId': memberId,
        'documentTypeId': documentTypeId,
        'fileName': fileName,
        'contentType': contentType,
        'sizeBytes': sizeBytes,
        'issuedOn': jsonDateOnly(issuedOn),
      },
    );
    return DocumentUploadTicket.fromJson(_asMap(response, 'Empty upload ticket'));
  }

  /// PUT bytes to the ticket URL (signed cloud URL or host-relative blob).
  Future<void> putUploadBytes({
    required DocumentUploadTicket ticket,
    required List<int> bytes,
  }) async {
    final url = ticket.uploadUrl.startsWith('http')
        ? ticket.uploadUrl
        : apiPath(ticket.uploadUrl);
    final headers = Map<String, dynamic>.from(ticket.uploadHeaders);
    final contentType = headers['Content-Type'] ??
        headers['content-type'] ??
        'application/octet-stream';

    final blobDio = Dio(
      BaseOptions(
        connectTimeout: const Duration(seconds: 30),
        sendTimeout: const Duration(seconds: 90),
        receiveTimeout: const Duration(seconds: 90),
      ),
    );
    await blobDio.put<dynamic>(
      url,
      data: bytes,
      options: Options(
        headers: headers,
        contentType: '$contentType',
        followRedirects: true,
        validateStatus: (code) => code != null && code >= 200 && code < 300,
      ),
    );
  }

  Future<ComplianceDocument> completeUpload(String documentId) async {
    final response = await _dio.post<dynamic>(
      '/api/v1/documents/$documentId/complete',
    );
    return ComplianceDocument.fromJson(_asMap(response, 'Empty complete'));
  }

  Future<ComplianceDocument> uploadDocument({
    required String memberId,
    required String documentTypeId,
    required String fileName,
    required String contentType,
    required List<int> bytes,
    DateTime? issuedOn,
  }) async {
    final ticket = await startUpload(
      memberId: memberId,
      documentTypeId: documentTypeId,
      fileName: fileName,
      contentType: contentType,
      sizeBytes: bytes.length,
      issuedOn: issuedOn,
    );
    await putUploadBytes(ticket: ticket, bytes: bytes);
    return completeUpload(ticket.document.id);
  }

  Future<void> deleteDocument(String documentId) async {
    await _dio.delete<dynamic>('/api/v1/documents/$documentId');
  }

  Future<DocumentContentUrl> getContentUrl(String documentId) async {
    final response = await _dio.get<dynamic>(
      '/api/v1/documents/$documentId/content-url',
    );
    return DocumentContentUrl.fromJson(_asMap(response, 'Empty content URL'));
  }

  Future<ComplianceDocument> reviewDocument({
    required String documentId,
    required bool approved,
    String? reason,
    DateTime? expiresOn,
  }) async {
    final response = await _dio.post<dynamic>(
      '/api/v1/documents/$documentId/review',
      data: {
        'approved': approved,
        'reason': reason,
        'expiresOn': jsonDateOnly(expiresOn),
      },
    );
    return ComplianceDocument.fromJson(_asMap(response, 'Empty review'));
  }

  Future<AskFamilyResult> askFamily({
    required String clubId,
    required String memberId,
    required String documentTypeId,
  }) async {
    final response = await _dio.post<dynamic>(
      '/api/v1/clubs/$clubId/members/$memberId/compliance/$documentTypeId/ask',
    );
    return AskFamilyResult.fromJson(_asMap(response, 'Empty ask response'));
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
