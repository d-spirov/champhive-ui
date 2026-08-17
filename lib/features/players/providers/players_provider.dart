import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/models/player.dart';
import '../../../shared/services/players_api.dart';
import '../../auth/providers/auth_provider.dart';
import '../../clubs/providers/clubs_provider.dart';

final playersApiProvider = Provider<PlayersApi>((ref) {
  final authApi = ref.watch(authApiProvider).valueOrNull;
  if (authApi == null) {
    throw StateError('AuthApi is not ready yet');
  }
  return PlayersApi(authApi.dio);
});

final playersSearchQueryProvider = StateProvider.autoDispose<String>((ref) => '');

final clubPlayersProvider =
    FutureProvider.autoDispose<List<ClubPlayer>>((ref) async {
  final auth = ref.watch(authNotifierProvider);
  if (!auth.isAuthenticated || auth.user?.id == 'demo') {
    return const [];
  }
  final clubId = ref.watch(selectedClubIdProvider);
  if (clubId == null) return const [];

  await ref.watch(authApiProvider.future);
  final search = ref.watch(playersSearchQueryProvider).trim();
  return ref.watch(playersApiProvider).listPlayers(
        clubId: clubId,
        search: search.isEmpty ? null : search,
        status: 'active',
        pageSize: 100,
      );
});

final playerDetailProvider =
    FutureProvider.autoDispose.family<ClubPlayer, String>((ref, playerId) async {
  final clubId = ref.watch(selectedClubIdProvider);
  if (clubId == null) {
    throw StateError('No club selected');
  }
  await ref.watch(authApiProvider.future);
  return ref.watch(playersApiProvider).getPlayer(
        clubId: clubId,
        playerId: playerId,
      );
});

/// Loads member photo bytes through the authenticated Dio client.
final playerPhotoProvider =
    FutureProvider.autoDispose.family<Uint8List?, String>((ref, playerId) async {
  final auth = ref.watch(authNotifierProvider);
  if (!auth.isAuthenticated || auth.user?.id == 'demo') {
    return null;
  }
  final clubId = ref.watch(selectedClubIdProvider);
  if (clubId == null) return null;

  await ref.watch(authApiProvider.future);
  String? photoUrl;
  final listed = ref.watch(clubPlayersProvider).valueOrNull;
  if (listed != null) {
    for (final p in listed) {
      if (p.id == playerId) {
        photoUrl = p.photoUrl;
        break;
      }
    }
  }
  return ref.watch(playersApiProvider).getPhotoBytes(
        clubId: clubId,
        playerId: playerId,
        photoUrl: photoUrl,
      );
});
