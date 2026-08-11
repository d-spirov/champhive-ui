import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/models/event_attendance.dart';
import '../../../shared/services/attendance_api.dart';
import '../../../shared/services/events_api.dart';
import '../../auth/providers/auth_provider.dart';
import '../../clubs/providers/clubs_provider.dart';

final eventsApiProvider = Provider<EventsApi>((ref) {
  final authApi = ref.watch(authApiProvider).valueOrNull;
  if (authApi == null) {
    throw StateError('AuthApi is not ready yet');
  }
  return EventsApi(authApi.dio);
});

final attendanceApiProvider = Provider<AttendanceApi>((ref) {
  final authApi = ref.watch(authApiProvider).valueOrNull;
  if (authApi == null) {
    throw StateError('AuthApi is not ready yet');
  }
  return AttendanceApi(authApi.dio);
});

/// Upcoming + recent club events for the selected club (last 7 / next 21 days).
final clubEventsProvider = FutureProvider.autoDispose<List<ClubEvent>>((ref) async {
  final auth = ref.watch(authNotifierProvider);
  if (!auth.isAuthenticated || auth.user?.id == 'demo') {
    return const [];
  }
  final clubId = ref.watch(selectedClubIdProvider);
  if (clubId == null) return const [];

  await ref.watch(authApiProvider.future);
  final api = ref.watch(eventsApiProvider);
  final now = DateTime.now();
  final from = now.subtract(const Duration(days: 7));
  final to = now.add(const Duration(days: 21));
  return api.listEvents(clubId: clubId, from: from, to: to, size: 200);
});

final pastClubEventsProvider =
    FutureProvider.autoDispose<List<ClubEvent>>((ref) async {
  final auth = ref.watch(authNotifierProvider);
  if (!auth.isAuthenticated || auth.user?.id == 'demo') {
    return const [];
  }
  final clubId = ref.watch(selectedClubIdProvider);
  if (clubId == null) return const [];

  await ref.watch(authApiProvider.future);
  final api = ref.watch(eventsApiProvider);
  final now = DateTime.now();
  final from = now.subtract(const Duration(days: 60));
  return api.listEvents(
    clubId: clubId,
    from: from,
    to: now,
    sort: 'desc',
    size: 100,
  );
});

final eventDetailProvider =
    FutureProvider.autoDispose.family<ClubEvent, String>((ref, eventId) async {
  final clubId = ref.watch(selectedClubIdProvider);
  if (clubId == null) {
    throw StateError('No club selected');
  }
  await ref.watch(authApiProvider.future);
  return ref.watch(eventsApiProvider).getEvent(clubId: clubId, eventId: eventId);
});

final attendanceSessionProvider = FutureProvider.autoDispose
    .family<AttendanceSession, String>((ref, eventId) async {
  final clubId = ref.watch(selectedClubIdProvider);
  if (clubId == null) {
    throw StateError('No club selected');
  }
  await ref.watch(authApiProvider.future);
  return ref
      .watch(attendanceApiProvider)
      .getAttendance(clubId: clubId, eventId: eventId);
});

final attendanceDashboardProvider =
    FutureProvider.autoDispose<List<AttendanceEventCard>>((ref) async {
  final auth = ref.watch(authNotifierProvider);
  if (!auth.isAuthenticated || auth.user?.id == 'demo') {
    return const [];
  }
  final clubId = ref.watch(selectedClubIdProvider);
  if (clubId == null) return const [];
  await ref.watch(authApiProvider.future);
  return ref.watch(attendanceApiProvider).listDashboardCards(clubId: clubId);
});
