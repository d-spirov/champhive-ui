import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/models/payment.dart';
import '../../../shared/services/payments_api.dart';
import '../../auth/providers/auth_provider.dart';
import '../../clubs/providers/clubs_provider.dart';

final paymentsApiProvider = Provider<PaymentsApi>((ref) {
  final authApi = ref.watch(authApiProvider).valueOrNull;
  if (authApi == null) {
    throw StateError('AuthApi is not ready yet');
  }
  return PaymentsApi(authApi.dio);
});

final clubObligationsProvider =
    FutureProvider.autoDispose<ObligationsPage?>((ref) async {
  final auth = ref.watch(authNotifierProvider);
  if (!auth.isAuthenticated || auth.user?.id == 'demo') return null;
  final clubId = ref.watch(selectedClubIdProvider);
  if (clubId == null || clubId.isEmpty) return null;
  await ref.watch(authApiProvider.future);
  return ref.watch(paymentsApiProvider).listObligations(clubId, openOnly: true);
});

final clubPaymentsProvider =
    FutureProvider.autoDispose<PaymentsPage?>((ref) async {
  final auth = ref.watch(authNotifierProvider);
  if (!auth.isAuthenticated || auth.user?.id == 'demo') return null;
  final clubId = ref.watch(selectedClubIdProvider);
  if (clubId == null || clubId.isEmpty) return null;
  await ref.watch(authApiProvider.future);
  return ref.watch(paymentsApiProvider).listPayments(clubId);
});

final myFeesProvider = FutureProvider.autoDispose<FamilyFees?>((ref) async {
  final auth = ref.watch(authNotifierProvider);
  if (!auth.isAuthenticated || auth.user?.id == 'demo') return null;
  await ref.watch(authApiProvider.future);
  return ref.watch(paymentsApiProvider).getMyFees();
});

final myFeeHistoryProvider =
    FutureProvider.autoDispose<FamilyFeeHistory?>((ref) async {
  final auth = ref.watch(authNotifierProvider);
  if (!auth.isAuthenticated || auth.user?.id == 'demo') return null;
  await ref.watch(authApiProvider.future);
  return ref.watch(paymentsApiProvider).getMyFeeHistory();
});
