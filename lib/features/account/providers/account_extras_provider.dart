import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/models/family.dart';
import '../../../shared/models/notification_preference.dart';
import '../../../shared/services/family_api.dart';
import '../../../shared/services/notifications_api.dart';
import '../../auth/providers/auth_provider.dart';
import '../../notifications/providers/notifications_provider.dart';

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

class AccountExtrasController {
  AccountExtrasController(this._ref);

  final Ref _ref;

  NotificationsApi get _notifications =>
      _ref.read(notificationsApiProvider);

  FamilyApi get _family => _ref.read(familyApiProvider);

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

  Future<void> refreshAll() async {
    _ref.invalidate(familyChildrenProvider);
    _ref.invalidate(pendingConsentsProvider);
    _ref.invalidate(notificationPreferencesProvider);
  }
}
