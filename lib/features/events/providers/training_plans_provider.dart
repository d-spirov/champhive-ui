import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/models/training_plan.dart';
import '../../../shared/services/training_plans_api.dart';
import '../../auth/providers/auth_provider.dart';
import '../../clubs/providers/clubs_provider.dart';

final trainingPlansApiProvider = Provider<TrainingPlansApi>((ref) {
  final authApi = ref.watch(authApiProvider).valueOrNull;
  if (authApi == null) {
    throw StateError('AuthApi is not ready yet');
  }
  return TrainingPlansApi(authApi.dio);
});

bool _isLive(Ref ref) {
  final auth = ref.watch(authNotifierProvider);
  return auth.isAuthenticated && auth.user?.id != 'demo';
}

/// Club plans, optionally narrowed to those that apply to [teamId].
final trainingPlansProvider = FutureProvider.autoDispose
    .family<List<TrainingPlan>, String?>((ref, teamId) async {
      if (!_isLive(ref)) return const [];
      final clubId = ref.watch(selectedClubIdProvider);
      if (clubId == null || clubId.isEmpty) return const [];
      await ref.watch(authApiProvider.future);
      return ref
          .watch(trainingPlansApiProvider)
          .listPlans(clubId: clubId, teamId: teamId);
    });

final trainingPlanDetailProvider = FutureProvider.autoDispose
    .family<TrainingPlan, String>((ref, planId) async {
      final clubId = ref.watch(selectedClubIdProvider);
      if (clubId == null || clubId.isEmpty || planId.isEmpty) {
        throw StateError('No club or plan');
      }
      await ref.watch(authApiProvider.future);
      return ref
          .watch(trainingPlansApiProvider)
          .getPlan(clubId: clubId, planId: planId);
    });

final exerciseImageBytesProvider = FutureProvider.autoDispose
    .family<Uint8List?, String>((ref, imageId) async {
      if (!_isLive(ref) || imageId.isEmpty) return null;
      final clubId = ref.watch(selectedClubIdProvider);
      if (clubId == null || clubId.isEmpty) return null;
      await ref.watch(authApiProvider.future);
      return ref
          .watch(trainingPlansApiProvider)
          .getExerciseImageBytes(clubId: clubId, imageId: imageId);
    });
