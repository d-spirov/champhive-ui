import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/models/family.dart';
import '../../../shared/models/notification_preference.dart';
import '../../../shared/models/player.dart';
import '../../../shared/models/user.dart';
import '../../../shared/services/family_api.dart';
import '../../../shared/services/notifications_api.dart';
import '../../../shared/services/players_api.dart';
import '../../auth/providers/auth_provider.dart';
import '../../clubs/providers/clubs_provider.dart';
import '../../notifications/providers/notifications_provider.dart';
import '../../players/providers/players_provider.dart';

final familyApiProvider = Provider<FamilyApi>((ref) {
  final authApi = ref.watch(authApiProvider).valueOrNull;
  if (authApi == null) {
    throw StateError('AuthApi is not ready yet');
  }
  return FamilyApi(authApi.dio);
});

bool _isLiveAccount(Ref ref) {
  final auth = ref.watch(authNotifierProvider);
  return auth.isAuthenticated && auth.user?.id != 'demo';
}

final familyChildrenProvider =
    FutureProvider.autoDispose<List<FamilyChild>>((ref) async {
  if (!_isLiveAccount(ref)) return const [];
  await ref.watch(authApiProvider.future);
  return ref.watch(familyApiProvider).listChildren();
});

final pendingConsentsProvider =
    FutureProvider.autoDispose<List<PendingConsent>>((ref) async {
  if (!_isLiveAccount(ref)) return const [];
  await ref.watch(authApiProvider.future);
  return ref.watch(familyApiProvider).listPendingConsents();
});

/// Non-push channels only — device/push registration is not wired yet.
final notificationPreferencesProvider =
    FutureProvider.autoDispose<List<NotificationPreference>>((ref) async {
  if (!_isLiveAccount(ref)) return const [];
  await ref.watch(authApiProvider.future);
  final all = await ref.watch(notificationsApiProvider).getPreferences();
  return all.where((p) => !p.isPushChannel).toList();
});

final accountExtrasControllerProvider =
    Provider.autoDispose<AccountExtrasController>((ref) {
  return AccountExtrasController(ref);
});

/// Club + member ids for the signed-in person's own photograph.
class MemberPhotoTarget {
  const MemberPhotoTarget({required this.clubId, required this.memberId});

  final String clubId;
  final String memberId;
}

/// Resolves the caller's own member row for My Account photo upload.
///
/// Prefers `/me/children` `isSelf`, then a selected-club roster match on email.
final selfPhotoTargetProvider =
    FutureProvider.autoDispose<MemberPhotoTarget?>((ref) async {
  if (!_isLiveAccount(ref)) return null;
  await ref.watch(authApiProvider.future);
  final user = ref.watch(authNotifierProvider).user;
  if (user == null) return null;

  List<FamilyChild> family = const [];
  try {
    family = await ref.watch(familyChildrenProvider.future);
  } catch (_) {}

  final selectedClubId = ref.watch(selectedClubIdProvider);
  final fromFamily = _selfFromFamily(family, selectedClubId);
  if (fromFamily != null) return fromFamily;

  if (selectedClubId == null || selectedClubId.isEmpty) return null;
  try {
    final match = await _findSelfOnRoster(
      api: ref.read(playersApiProvider),
      clubId: selectedClubId,
      user: user,
    );
    if (match == null) return null;
    final clubId =
        (match.clubId != null && match.clubId!.isNotEmpty)
            ? match.clubId!
            : selectedClubId;
    return MemberPhotoTarget(clubId: clubId, memberId: match.id);
  } catch (_) {
    return null;
  }
});

MemberPhotoTarget? _selfFromFamily(
  List<FamilyChild> family,
  String? selectedClubId,
) {
  for (final child in family) {
    if (!child.isSelf || child.memberId.isEmpty) continue;
    final clubId = child.clubId.isNotEmpty
        ? child.clubId
        : (selectedClubId ?? '');
    if (clubId.isEmpty) continue;
    return MemberPhotoTarget(clubId: clubId, memberId: child.memberId);
  }
  return null;
}

Future<ClubPlayer?> _findSelfOnRoster({
  required PlayersApi api,
  required String clubId,
  required User user,
}) async {
  final email = user.email.trim().toLowerCase();
  if (email.isEmpty) return null;

  Future<ClubPlayer?> scan(String? search) async {
    final list = await api.listPlayers(
      clubId: clubId,
      search: search,
      status: 'active',
      pageSize: 50,
    );
    for (final player in list) {
      if ((player.email ?? '').trim().toLowerCase() == email) {
        return player;
      }
    }
    return null;
  }

  final byEmail = await scan(user.email.trim());
  if (byEmail != null) return byEmail;
  final lastName = user.lastName.trim();
  if (lastName.isEmpty) return null;
  return scan(lastName);
}

class AccountExtrasController {
  AccountExtrasController(this._ref);

  final Ref _ref;

  NotificationsApi get _notifications =>
      _ref.read(notificationsApiProvider);

  FamilyApi get _family => _ref.read(familyApiProvider);

  PlayersApi get _photos => _ref.read(playersApiProvider);

  Future<void> setPreferenceEnabled({
    required String key,
    required String channel,
    required bool enabled,
  }) async {
    await _notifications.updatePreferences([
      NotificationPreference(
        key: key,
        channel: channel,
        enabled: enabled,
        isDefault: false,
      ),
    ]);
    _ref.invalidate(notificationPreferencesProvider);
  }

  Future<void> grantConsent({
    required String memberId,
    required String kind,
  }) async {
    await _family.grantConsent(memberId: memberId, kind: kind);
    _ref.invalidate(pendingConsentsProvider);
    _ref.invalidate(familyChildrenProvider);
  }

  Future<void> withdrawConsent({
    required String memberId,
    required String kind,
  }) async {
    await _family.withdrawConsent(memberId: memberId, kind: kind);
    _ref.invalidate(pendingConsentsProvider);
    _ref.invalidate(familyChildrenProvider);
  }

  Future<void> uploadMemberPhoto({
    required String clubId,
    required String memberId,
    required List<int> bytes,
    required String filename,
  }) async {
    await _photos.uploadPhoto(
      clubId: clubId,
      memberId: memberId,
      bytes: bytes,
      filename: filename,
    );
    _invalidateMemberPhoto(memberId);
  }

  Future<void> deleteMemberPhoto({
    required String clubId,
    required String memberId,
  }) async {
    await _photos.deletePhoto(clubId: clubId, memberId: memberId);
    _invalidateMemberPhoto(memberId);
  }

  void _invalidateMemberPhoto(String memberId) {
    _ref.invalidate(memberPhotoBytesProvider(memberId));
    _ref.invalidate(clubPlayersProvider);
    _ref.invalidate(playerDetailProvider(memberId));
  }

  Future<void> refreshAll() async {
    _ref.invalidate(familyChildrenProvider);
    _ref.invalidate(pendingConsentsProvider);
    _ref.invalidate(notificationPreferencesProvider);
  }
}
