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

final playersSearchQueryProvider = StateProvider.autoDispose<String>(
  (ref) => '',
);

final clubPlayersProvider = FutureProvider.autoDispose<List<ClubPlayer>>((
  ref,
) async {
  final auth = ref.watch(authNotifierProvider);
  if (!auth.isAuthenticated || auth.user?.id == 'demo') {
    return const [];
  }
  final clubId = ref.watch(selectedClubIdProvider);
  if (clubId == null) return const [];

  await ref.watch(authApiProvider.future);
  final search = ref.watch(playersSearchQueryProvider).trim();
  return ref
      .watch(playersApiProvider)
      .listPlayers(
        clubId: clubId,
        search: search.isEmpty ? null : search,
        status: 'active',
        pageSize: 100,
      );
});

final playerDetailProvider = FutureProvider.autoDispose
    .family<ClubPlayer, String>((ref, playerId) async {
      final clubId = ref.watch(selectedClubIdProvider);
      if (clubId == null) {
        throw StateError('No club selected');
      }
      await ref.watch(authApiProvider.future);
      return ref
          .watch(playersApiProvider)
          .getPlayer(clubId: clubId, playerId: playerId);
    });

/// Loads member photo bytes through the authenticated Dio client.
/// Not club-scoped — the same person photo is shared across clubs.
final memberPhotoBytesProvider = FutureProvider.autoDispose
    .family<Uint8List?, String>((ref, memberId) async {
      final auth = ref.watch(authNotifierProvider);
      if (!auth.isAuthenticated ||
          auth.user?.id == 'demo' ||
          memberId.isEmpty) {
        return null;
      }

      await ref.watch(authApiProvider.future);
      return ref
          .watch(playersApiProvider)
          .getPhotoBytes(clubId: '', playerId: memberId);
    });
