import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/models/event_attendance.dart';
import '../../../shared/models/team.dart';
import '../../../shared/services/teams_api.dart';
import '../../auth/providers/auth_provider.dart';
import '../../clubs/providers/clubs_provider.dart';

final teamsApiProvider = Provider<TeamsApi>((ref) {
  final authApi = ref.watch(authApiProvider).valueOrNull;
  if (authApi == null) {
    throw StateError('AuthApi is not ready yet');
  }
  return TeamsApi(authApi.dio);
});

final clubTeamsProvider = FutureProvider.autoDispose<List<ClubTeam>>((
  ref,
) async {
  final auth = ref.watch(authNotifierProvider);
  if (!auth.isAuthenticated || auth.user?.id == 'demo') {
    return const [];
  }
  final clubId = ref.watch(selectedClubIdProvider);
  if (clubId == null) return const [];

  await ref.watch(authApiProvider.future);
  return ref.watch(teamsApiProvider).listTeams(clubId: clubId);
});

final clubTeamProvider = Provider.autoDispose.family<ClubTeam?, String>((
  ref,
  teamId,
) {
  final teams = ref.watch(clubTeamsProvider).valueOrNull ?? const <ClubTeam>[];
  for (final t in teams) {
    if (t.id == teamId) return t;
  }
  return null;
});

final teamRosterProvider = FutureProvider.autoDispose
    .family<TeamRoster, String>((ref, teamId) async {
      final clubId = ref.watch(selectedClubIdProvider);
      if (clubId == null) {
        throw StateError('No club selected');
      }
      await ref.watch(authApiProvider.future);
      return ref
          .watch(teamsApiProvider)
          .getRoster(clubId: clubId, teamId: teamId);
    });

final teamScheduleProvider = FutureProvider.autoDispose
    .family<List<ClubEvent>, String>((ref, teamId) async {
      final clubId = ref.watch(selectedClubIdProvider);
      if (clubId == null) {
        throw StateError('No club selected');
      }
      await ref.watch(authApiProvider.future);
      final now = DateTime.now();
      return ref
          .watch(teamsApiProvider)
          .getSchedule(
            clubId: clubId,
            teamId: teamId,
            from: now.subtract(const Duration(days: 7)),
            to: now.add(const Duration(days: 45)),
          );
    });

/// Team endpoint plus club-calendar rows that belong on this team.
List<ClubEvent> mergeTeamSchedule({
  required List<ClubEvent> teamEvents,
  required List<ClubEvent> clubEvents,
  required String teamId,
  String? sectionId,
}) {
  final merged = <String, ClubEvent>{
    for (final e in teamEvents)
      if (e.id.isNotEmpty) e.id: e,
  };
  for (final e in clubEvents) {
    if (e.id.isEmpty || merged.containsKey(e.id)) continue;
    if (!_eventVisibleOnTeam(e, teamId: teamId, sectionId: sectionId)) {
      continue;
    }
    merged[e.id] = e;
  }
  return merged.values.toList()..sort((a, b) => a.startAt.compareTo(b.startAt));
}

bool _eventVisibleOnTeam(
  ClubEvent event, {
  required String teamId,
  String? sectionId,
}) {
  if (event.scopeId == teamId) return true;
  final kind = (event.scopeKind ?? '').toLowerCase();
  if (kind == 'club') return true;
  return kind == 'section' &&
      sectionId != null &&
      sectionId.isNotEmpty &&
      event.scopeId == sectionId;
}
