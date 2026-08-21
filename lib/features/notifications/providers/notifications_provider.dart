import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/models/notification.dart';
import '../../../shared/services/notifications_api.dart';
import '../../auth/providers/auth_provider.dart';

final notificationsApiProvider = Provider<NotificationsApi>((ref) {
  final authApi = ref.watch(authApiProvider).valueOrNull;
  if (authApi == null) {
    throw StateError('AuthApi is not ready yet');
  }
  return NotificationsApi(authApi.dio);
});

/// First page of the caller's notification feed (for badge + list bootstrap).
final notificationFeedProvider =
    FutureProvider.autoDispose<NotificationFeed>((ref) async {
  final auth = ref.watch(authNotifierProvider);
  if (!auth.isAuthenticated || auth.user?.id == 'demo') {
    return const NotificationFeed(items: [], unreadCount: 0);
  }
  await ref.watch(authApiProvider.future);
  return ref.watch(notificationsApiProvider).listMine(limit: 30);
});

final unreadNotificationCountProvider = Provider.autoDispose<int>((ref) {
  return ref.watch(notificationFeedProvider).valueOrNull?.unreadCount ?? 0;
});
