import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/models/analytics.dart';
import '../../../shared/services/analytics_api.dart';
import '../../auth/providers/auth_provider.dart';
import '../../clubs/providers/clubs_provider.dart';

final analyticsApiProvider = Provider<AnalyticsApi>((ref) {
  final authApi = ref.watch(authApiProvider).valueOrNull;
  if (authApi == null) {
    throw StateError('AuthApi is not ready yet');
  }
  return AnalyticsApi(authApi.dio);
});

final membershipAnalyticsProvider =
    FutureProvider.autoDispose<MembershipAnalytics?>((ref) async {
  final auth = ref.watch(authNotifierProvider);
  if (!auth.isAuthenticated || auth.user?.id == 'demo') return null;
  final clubId = ref.watch(selectedClubIdProvider);
  if (clubId == null || clubId.isEmpty) return null;
  await ref.watch(authApiProvider.future);
  return ref.watch(analyticsApiProvider).membership(clubId, months: 12);
});

final revenueAnalyticsProvider =
    FutureProvider.autoDispose<RevenueAnalytics?>((ref) async {
  final auth = ref.watch(authNotifierProvider);
  if (!auth.isAuthenticated || auth.user?.id == 'demo') return null;
  final clubId = ref.watch(selectedClubIdProvider);
  if (clubId == null || clubId.isEmpty) return null;
  await ref.watch(authApiProvider.future);
  return ref.watch(analyticsApiProvider).revenue(clubId, months: 12);
});
