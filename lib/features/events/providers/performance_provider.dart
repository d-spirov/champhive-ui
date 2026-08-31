import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/models/performance.dart';
import '../../../shared/services/performance_api.dart';
import '../../auth/providers/auth_provider.dart';
import '../../clubs/providers/clubs_provider.dart';

final performanceApiProvider = Provider<PerformanceApi>((ref) {
  final authApi = ref.watch(authApiProvider).valueOrNull;
  if (authApi == null) {
    throw StateError('AuthApi is not ready yet');
  }
  return PerformanceApi(authApi.dio);
});

bool _isLive(Ref ref) {
  final auth = ref.watch(authNotifierProvider);
  return auth.isAuthenticated && auth.user?.id != 'demo';
}

final performanceSportsProvider = FutureProvider.autoDispose<List<String>>((
  ref,
) async {
  if (!_isLive(ref)) return const [];
  final clubId = ref.watch(selectedClubIdProvider);
  if (clubId == null || clubId.isEmpty) return const [];
  await ref.watch(authApiProvider.future);
  return ref.watch(performanceApiProvider).listSports(clubId: clubId);
});

final metricBatteriesProvider = FutureProvider.autoDispose
    .family<List<MetricBattery>, String?>((ref, sportCode) async {
      if (!_isLive(ref)) return const [];
      final clubId = ref.watch(selectedClubIdProvider);
      if (clubId == null || clubId.isEmpty) return const [];
      await ref.watch(authApiProvider.future);
      return ref
          .watch(performanceApiProvider)
          .listBatteries(clubId: clubId, sportCode: sportCode);
    });

final metricCatalogueProvider = FutureProvider.autoDispose
    .family<ClubMetricCatalogue, String>((ref, sportCode) async {
      if (!_isLive(ref) || sportCode.isEmpty) {
        return const ClubMetricCatalogue(sportCode: '', metrics: []);
      }
      final clubId = ref.watch(selectedClubIdProvider);
      if (clubId == null || clubId.isEmpty) {
        return ClubMetricCatalogue(sportCode: sportCode, metrics: const []);
      }
      await ref.watch(authApiProvider.future);
      return ref
          .watch(performanceApiProvider)
          .listMetrics(clubId: clubId, sportCode: sportCode);
    });

final testingDayProvider = FutureProvider.autoDispose
    .family<TestingDay, String>((ref, occurrenceId) async {
      final clubId = ref.watch(selectedClubIdProvider);
      if (clubId == null || clubId.isEmpty || occurrenceId.isEmpty) {
        throw StateError('No club or occurrence');
      }
      await ref.watch(authApiProvider.future);
      return ref
          .watch(performanceApiProvider)
          .getTestingDay(clubId: clubId, occurrenceId: occurrenceId);
    });
