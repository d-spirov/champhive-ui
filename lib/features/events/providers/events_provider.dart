import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/models/event_attendance.dart';
import '../../../shared/models/team.dart';
import '../../../shared/services/attendance_api.dart';
import '../../../shared/services/events_api.dart';
import '../../account/providers/account_extras_provider.dart';
import '../../auth/providers/auth_provider.dart';
import '../../clubs/providers/clubs_provider.dart';
import '../../teams/providers/teams_provider.dart';

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

/// Club schedule occurrences for the selected club (last 7 / next 21 days).
final clubEventsProvider = FutureProvider.autoDispose<List<ClubEvent>>((
  ref,
) async {
  final auth = ref.watch(authNotifierProvider);
  if (!auth.isAuthenticated || auth.user?.id == 'demo') {
    return const [];
  }
  final clubId = ref.watch(selectedClubIdProvider);
  if (clubId == null) return const [];

  await ref.watch(authApiProvider.future);
  final now = DateTime.now();
  return _loadVisibleSchedule(
    ref,
    clubId: clubId,
    from: now.subtract(const Duration(days: 7)),
    to: now.add(const Duration(days: 21)),
    size: 200,
  );
});

final pastClubEventsProvider = FutureProvider.autoDispose<List<ClubEvent>>((
  ref,
) async {
  final auth = ref.watch(authNotifierProvider);
  if (!auth.isAuthenticated || auth.user?.id == 'demo') {
    return const [];
  }
  final clubId = ref.watch(selectedClubIdProvider);
  if (clubId == null) return const [];

  await ref.watch(authApiProvider.future);
  final user = auth.user;
  final now = DateTime.now();
  final parentOnly = user != null && !user.isStaff(clubId);
  return _loadVisibleSchedule(
    ref,
    clubId: clubId,
    from: now.subtract(Duration(days: parentOnly ? 55 : 60)),
    to: now,
    sort: 'desc',
    size: 100,
  );
});

Future<List<ClubEvent>> _loadVisibleSchedule(
  Ref ref, {
  required String clubId,
  required DateTime from,
  required DateTime to,
  String sort = 'asc',
  int size = 200,
}) async {
  final api = ref.watch(eventsApiProvider);
  final user = ref.watch(authNotifierProvider).user;
  final parentOnly = user != null && !user.isStaff(clubId);
  List<ClubEvent> events;
  if (parentOnly) {
    try {
      events = [
        for (final event in await api.listMySchedule(from: from, to: to))
          if (event.clubId.toLowerCase() == clubId.toLowerCase()) event,
      ];
      if (sort == 'desc') {
        events = events.reversed.toList();
      }
    } catch (_) {
      events = await api.listEvents(
        clubId: clubId,
        from: from,
        to: to,
        sort: sort,
        size: size,
      );
    }
  } else {
    events = await api.listEvents(
      clubId: clubId,
      from: from,
      to: to,
      sort: sort,
      size: size,
    );
  }
  return _eventsForViewer(ref, clubId: clubId, events: events);
}

Future<List<ClubEvent>> _eventsForViewer(
  Ref ref, {
  required String clubId,
  required List<ClubEvent> events,
}) async {
  final user = ref.watch(authNotifierProvider).user;
  if (user == null || user.isStaff(clubId)) return events;
  List<ClubTeam> familyTeams = const [];
  var familyMemberIds = const <String>{};
  try {
    final children = await ref.watch(familyChildrenProvider.future);
    familyTeams = clubTeamsFromChildren(children, clubId);
    familyMemberIds = familyMemberIdsInClub(children, clubId);
  } catch (_) {}
  return eventsVisibleToUser(
    events,
    user: user,
    clubId: clubId,
    familyTeams: familyTeams,
    familyMemberIds: familyMemberIds,
  );
}

final eventDetailProvider = FutureProvider.autoDispose
    .family<ClubEvent, String>((ref, eventId) async {
      final clubId = ref.watch(selectedClubIdProvider);
      if (clubId == null) {
        throw StateError('No club selected');
      }
      await ref.watch(authApiProvider.future);
      final api = ref.watch(eventsApiProvider);
      final event = await api.getEvent(clubId: clubId, eventId: eventId);
      if (event.type != EventType.testing) return event;
      final seriesId = event.seriesId;
      if (seriesId == null ||
          seriesId.isEmpty ||
          (event.metricBatteryName != null &&
              event.metricBatteryName!.isNotEmpty)) {
        return event;
      }
      try {
        final series = await api.getSeries(clubId: clubId, seriesId: seriesId);
        return event.copyWith(
          metricBatteryId: series.metricBatteryId,
          metricBatteryName: series.metricBatteryName,
        );
      } catch (_) {
        return event;
      }
    });

final attendanceSessionProvider = FutureProvider.autoDispose
    .family<AttendanceSession, String>((ref, occurrenceId) async {
      ref.watch(selectedClubIdProvider);
      await ref.watch(authApiProvider.future);
      final api = ref.watch(attendanceApiProvider);
      return api.getRosterSnapshot(occurrenceId: occurrenceId);
    });

/// Server attendance report for an occurrence (works after lock too).
final occurrenceAttendanceReportProvider = FutureProvider.autoDispose
    .family<AttendanceSession, String>((ref, occurrenceId) async {
      ref.watch(selectedClubIdProvider);
      await ref.watch(authApiProvider.future);
      return ref
          .watch(attendanceApiProvider)
          .getOccurrenceAttendance(occurrenceId: occurrenceId);
    });

/// Upcoming schedule items still inside the typical attendance window.
final openAttendanceOccurrencesProvider =
    FutureProvider.autoDispose<List<ClubEvent>>((ref) async {
      final events = await ref.watch(clubEventsProvider.future);
      final now = DateTime.now();
      return events.where((e) {
        final status = (e.status ?? '').toLowerCase();
        if (status == 'canceled') return false;
        final lockAt = e.startAt.add(const Duration(hours: 72));
        return lockAt.isAfter(now);
      }).toList();
    });
