import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/models/chat.dart';
import '../../../shared/models/staff.dart';
import '../../../shared/services/chat_api.dart';
import '../../../shared/services/staff_api.dart';
import '../../auth/providers/auth_provider.dart';
import '../../clubs/providers/clubs_provider.dart';

final chatApiProvider = Provider<ChatApi>((ref) {
  final authApi = ref.watch(authApiProvider).valueOrNull;
  if (authApi == null) {
    throw StateError('AuthApi is not ready yet');
  }
  return ChatApi(authApi.dio);
});

final staffApiProvider = Provider<StaffApi>((ref) {
  final authApi = ref.watch(authApiProvider).valueOrNull;
  if (authApi == null) {
    throw StateError('AuthApi is not ready yet');
  }
  return StaffApi(authApi.dio);
});

final chatChannelsProvider =
    FutureProvider.autoDispose<List<ChatChannel>>((ref) async {
  final auth = ref.watch(authNotifierProvider);
  if (!auth.isAuthenticated || auth.user?.id == 'demo') {
    return const [];
  }
  await ref.watch(authApiProvider.future);
  final page = await ref.watch(chatApiProvider).listChannels(pageSize: 50);
  return page.items;
});

final chatChannelProvider =
    FutureProvider.autoDispose.family<ChatChannel, String>((ref, channelId) async {
  await ref.watch(authApiProvider.future);
  return ref.watch(chatApiProvider).getChannel(channelId);
});

final unreadChatCountProvider = Provider.autoDispose<int>((ref) {
  final channels = ref.watch(chatChannelsProvider).valueOrNull;
  if (channels == null) return 0;
  return channels.fold<int>(0, (sum, c) => sum + c.unreadCount);
});

/// Adults the caller can open a 1:1 thread with (staff + known channel peers).
final directMessageCandidatesProvider =
    FutureProvider.autoDispose<List<DirectMessageCandidate>>((ref) async {
  final auth = ref.watch(authNotifierProvider);
  final me = auth.user;
  if (!auth.isAuthenticated || me == null || me.id == 'demo') {
    return const [];
  }

  await ref.watch(authApiProvider.future);
  final byId = <String, DirectMessageCandidate>{};

  // Peers already visible in chat (team channels / existing DMs).
  try {
    final channels = await ref.watch(chatChannelsProvider.future);
    for (final channel in channels) {
      for (final p in channel.participants) {
        if (p.userAccountId.isEmpty || p.userAccountId == me.id) continue;
        byId.putIfAbsent(
          p.userAccountId,
          () => DirectMessageCandidate(
            userAccountId: p.userAccountId,
            name: p.displayName.isNotEmpty ? p.displayName : 'Member',
            subtitle: p.role.isNotEmpty ? p.role : channel.name,
          ),
        );
      }
    }
  } catch (_) {}

  // Club staff when the caller can read the register.
  final clubId = ref.watch(selectedClubIdProvider);
  if (clubId != null && clubId.isNotEmpty) {
    try {
      final staff = await ref.watch(staffApiProvider).listStaff(clubId);
      for (final row in staff) {
        final uid = row.userAccountId;
        if (uid == null || uid.isEmpty || uid == me.id || !row.isLive) {
          continue;
        }
        final label = [
          row.role,
          if (row.scopeName.isNotEmpty) row.scopeName,
        ].join(' · ');
        byId[uid] = DirectMessageCandidate(
          userAccountId: uid,
          name: row.name.isNotEmpty ? row.name : (row.email ?? 'Staff'),
          email: row.email,
          subtitle: label,
        );
      }
    } on DioException catch (e) {
      // Coaches often lack staff-register access — peers list still works.
      if (e.response?.statusCode != 403) rethrow;
    }
  }

  final list = byId.values.toList()
    ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
  return list;
});
