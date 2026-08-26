import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/models/compliance.dart';
import '../../../shared/services/documents_api.dart';
import '../../auth/providers/auth_provider.dart';
import '../../clubs/providers/clubs_provider.dart';

final documentsApiProvider = Provider<DocumentsApi>((ref) {
  final authApi = ref.watch(authApiProvider).valueOrNull;
  if (authApi == null) {
    throw StateError('AuthApi is not ready yet');
  }
  return DocumentsApi(authApi.dio);
});

bool _isLive(Ref ref) {
  final auth = ref.watch(authNotifierProvider);
  return auth.isAuthenticated && auth.user?.id != 'demo';
}

final complianceOverviewProvider =
    FutureProvider.autoDispose<ComplianceOverview?>((ref) async {
  if (!_isLive(ref)) return null;
  final clubId = ref.watch(selectedClubIdProvider);
  if (clubId == null || clubId.isEmpty) return null;
  await ref.watch(authApiProvider.future);
  return ref.watch(documentsApiProvider).getOverview(clubId);
});

final pendingComplianceDocumentsProvider =
    FutureProvider.autoDispose<ComplianceDocumentsPage?>((ref) async {
  if (!_isLive(ref)) return null;
  final clubId = ref.watch(selectedClubIdProvider);
  if (clubId == null || clubId.isEmpty) return null;
  await ref.watch(authApiProvider.future);
  return ref.watch(documentsApiProvider).listDocuments(
        clubId,
        status: 'pending',
        pageSize: 80,
      );
});

final memberComplianceProvider = FutureProvider.autoDispose
    .family<MemberCompliance, String>((ref, memberId) async {
  await ref.watch(authApiProvider.future);
  return ref.watch(documentsApiProvider).getMemberCompliance(memberId);
});

final complianceControllerProvider = Provider.autoDispose<ComplianceController>(
  (ref) => ComplianceController(ref),
);

class ComplianceController {
  ComplianceController(this._ref);

  final Ref _ref;

  DocumentsApi get _api => _ref.read(documentsApiProvider);

  Future<ComplianceDocument> upload({
    required String memberId,
    required String documentTypeId,
    required String fileName,
    required String contentType,
    required List<int> bytes,
    DateTime? issuedOn,
  }) async {
    final doc = await _api.uploadDocument(
      memberId: memberId,
      documentTypeId: documentTypeId,
      fileName: fileName,
      contentType: contentType,
      bytes: bytes,
      issuedOn: issuedOn,
    );
    _invalidate(memberId);
    return doc;
  }

  Future<void> delete(String documentId, {required String memberId}) async {
    await _api.deleteDocument(documentId);
    _invalidate(memberId);
  }

  Future<ComplianceDocument> review({
    required String documentId,
    required String memberId,
    required bool approved,
    String? reason,
    DateTime? expiresOn,
  }) async {
    final doc = await _api.reviewDocument(
      documentId: documentId,
      approved: approved,
      reason: reason,
      expiresOn: expiresOn,
    );
    _invalidate(memberId);
    return doc;
  }

  Future<AskFamilyResult> askFamily({
    required String clubId,
    required String memberId,
    required String documentTypeId,
  }) async {
    final result = await _api.askFamily(
      clubId: clubId,
      memberId: memberId,
      documentTypeId: documentTypeId,
    );
    _ref.invalidate(memberComplianceProvider(memberId));
    return result;
  }

  Future<DocumentContentUrl> contentUrl(String documentId) {
    return _api.getContentUrl(documentId);
  }

  void _invalidate(String memberId) {
    _ref.invalidate(memberComplianceProvider(memberId));
    _ref.invalidate(complianceOverviewProvider);
    _ref.invalidate(pendingComplianceDocumentsProvider);
  }
}
