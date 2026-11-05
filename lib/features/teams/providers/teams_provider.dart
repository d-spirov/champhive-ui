import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/models/event_attendance.dart';
import '../../../shared/models/family.dart';
import '../../../shared/models/team.dart';
import '../../../shared/models/user.dart';
import '../../../shared/services/teams_api.dart';
import '../../account/providers/account_extras_provider.dart';
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
  List<FamilyChild> children = const [];
  try {
    children = await ref.watch(familyChildrenProvider.future);
  } catch (_) {}
  final familyTeams = clubTeamsFromChildren(children, clubId);

  List<ClubTeam> listed = const [];
  try {
    listed = await ref.watch(teamsApiProvider).listTeams(clubId: clubId);
  } on DioException catch (e) {
    final code = e.response?.statusCode;
    if (code != 403 && code != 404) rethrow;
    if (familyTeams.isEmpty) rethrow;
  }

  return teamsVisibleToUser(
    listed,
    user: auth.user,
    clubId: clubId,
    familyTeams: familyTeams,
  );
});

List<ClubTeam> clubTeamsFromChildren(
  List<FamilyChild> children,
  String clubId,
) {
  final byId = <String, ClubTeam>{};
  for (final child in children) {
    if (!_sameId(child.clubId, clubId)) continue;
    final id = child.teamId?.trim() ?? '';
    if (id.isEmpty) continue;
    final name = child.teamName?.trim();
    byId.putIfAbsent(
      id.toLowerCase(),
      () => ClubTeam(
        id: id,
        clubId: clubId,
        name: (name != null && name.isNotEmpty) ? name : 'Team',
        sectionId: child.sectionId,
      ),
    );
  }
  return byId.values.toList()..sort((a, b) => a.name.compareTo(b.name));
}

Set<String> familyMemberIdsInClub(List<FamilyChild> children, String clubId) {
  return {
    for (final child in children)
      if (_sameId(child.clubId, clubId) && child.memberId.trim().isNotEmpty)
        child.memberId.trim(),
  };
}

/// Parent-readable stand-in for `GET .../teams/{id}/roster` (403 MEMBER_READ).
///
/// Only the caller's own children enrolled on this team. The chat directory
/// lists every player the parent can message and has no team id, so it must
/// not be used as a roster.
TeamRoster parentVisibleRoster({
  required String clubId,
  required String teamId,
  required String teamName,
  required List<FamilyChild> children,
  String? sectionId,
}) {
  final byId = <String, TeamRosterEntry>{};
  for (final child in children) {
    if (!_sameId(child.clubId, clubId) || child.memberId.trim().isEmpty) {
      continue;
    }
    if (!_sameId(child.teamId, teamId)) continue;
    final id = child.memberId.trim();
    byId.putIfAbsent(id.toLowerCase(), () => _rosterEntryFromChild(child));
  }

  return TeamRoster(
    clubId: clubId,
    teamId: teamId,
    teamName: teamName,
    sectionId: sectionId,
    entries: byId.values.toList(),
  );
}

/// Drops teammates a parent is not allowed to open. A successful roster read
/// can still list the whole team; attendance and profiles stay on own children.
TeamRoster limitRosterToFamily(
  TeamRoster roster, {
  required List<FamilyChild> children,
  required String clubId,
}) {
  final ids = {
    for (final id in familyMemberIdsInClub(children, clubId)) id.toLowerCase(),
  };
  return TeamRoster(
    clubId: roster.clubId,
    teamId: roster.teamId,
    teamName: roster.teamName,
    sectionId: roster.sectionId,
    seasonId: roster.seasonId,
    seasonLabel: roster.seasonLabel,
    entries: [
      for (final entry in roster.entries)
        if (ids.contains(entry.memberId.trim().toLowerCase())) entry,
    ],
  );
}

TeamRosterEntry _rosterEntryFromChild(FamilyChild child) {
  return TeamRosterEntry(
    memberId: child.memberId,
    firstName: child.firstName,
    lastName: child.lastName,
    status: child.status,
    dateOfBirth: child.dateOfBirth,
    complianceStatus: child.complianceStatus,
  );
}

/// Club admins see every team. Coaches see assigned teams.
/// Parents also see teams their children are enrolled in.
List<ClubTeam> teamsVisibleToUser(
  List<ClubTeam> teams, {
  required User? user,
  required String clubId,
  List<ClubTeam> familyTeams = const [],
}) {
  if (user == null) return const [];
  if (user.hasClubWideStaffGrant(clubId)) {
    return teams.isNotEmpty ? teams : familyTeams;
  }
  final teamIds = user.staffTeamIdsForClub(clubId);
  final sectionIds = user.staffSectionIdsForClub(clubId);
  final familyIds = {for (final t in familyTeams) t.id};
  final fromList = teams
      .where(
        (t) =>
            teamIds.contains(t.id) ||
            familyIds.contains(t.id) ||
            (t.sectionId != null &&
                t.sectionId!.isNotEmpty &&
                sectionIds.contains(t.sectionId)) ||
            t.isAssignedTo(user.id),
      )
      .toList();
  final seen = {for (final t in fromList) t.id};
  final extra = familyTeams.where((t) => !seen.contains(t.id));
  return [...fromList, ...extra];
}

/// Club admins may change any session. Coaches and section admins only
/// sessions in their assigned team / section. Parents never.
bool canManageOccurrence(
  ClubEvent event, {
  required User? user,
  required String? clubId,
  List<ClubTeam> teams = const [],
}) {
  if (user == null || clubId == null || clubId.isEmpty) return false;
  if (user.hasClubWideStaffGrant(clubId)) return true;
  if (!user.isStaff(clubId)) return false;

  final kind = (event.scopeKind ?? '').toLowerCase();
  if (kind == 'club') return false;

  final teamIds = user.staffTeamIdsForClub(clubId);
  final sectionIds = user.staffSectionIdsForClub(clubId);
  if (kind == 'section') {
    return sectionIds.any((id) => _sameId(id, event.scopeId));
  }
  if (teamIds.any((id) => _sameId(id, event.scopeId))) return true;
  for (final team in teams) {
    if (!_sameId(team.id, event.scopeId)) continue;
    if (team.sectionId != null &&
        team.sectionId!.isNotEmpty &&
        sectionIds.any((id) => _sameId(id, team.sectionId))) {
      return true;
    }
    if (team.isAssignedTo(user.id)) return true;
  }
  return false;
}

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
      final user = ref.watch(authNotifierProvider).user;
      final parentOnly = user != null && !user.isStaff(clubId);
      List<FamilyChild> children = const [];
      try {
        children = await ref.watch(familyChildrenProvider.future);
      } catch (_) {}

      try {
        final roster = await ref
            .watch(teamsApiProvider)
            .getRoster(clubId: clubId, teamId: teamId);
        if (!parentOnly) return roster;
        return limitRosterToFamily(roster, children: children, clubId: clubId);
      } on DioException catch (e) {
        final code = e.response?.statusCode;
        if (code != 403 && code != 404) rethrow;
      }

      final team = ref.read(clubTeamProvider(teamId));
      return parentVisibleRoster(
        clubId: clubId,
        teamId: teamId,
        teamName: team?.name ?? 'Team',
        sectionId: team?.sectionId,
        children: children,
      );
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

/// Club calendar for a parent: child's teams (and their section / club-wide
/// sessions). Staff keep the full list.
List<ClubEvent> eventsVisibleToUser(
  List<ClubEvent> events, {
  required User? user,
  required String clubId,
  List<ClubTeam> familyTeams = const [],
  Set<String> familyMemberIds = const {},
}) {
  if (user == null) return const [];
  if (user.isStaff(clubId)) return events;
  return events
      .where((e) => _eventVisibleToFamily(e, familyTeams, familyMemberIds))
      .toList();
}

bool _eventVisibleToFamily(
  ClubEvent event,
  List<ClubTeam> familyTeams,
  Set<String> familyMemberIds,
) {
  final related = {
    for (final id in event.relatedMemberIds)
      if (id.trim().isNotEmpty) id.trim().toLowerCase(),
  };
  final members = {
    for (final id in familyMemberIds)
      if (id.trim().isNotEmpty) id.trim().toLowerCase(),
  };
  if (related.isNotEmpty) {
    return related.intersection(members).isNotEmpty;
  }
  final kind = (event.scopeKind ?? '').toLowerCase();
  if (kind == 'club') return true;
  for (final team in familyTeams) {
    if (_eventVisibleOnTeam(
      event,
      teamId: team.id,
      sectionId: team.sectionId,
    )) {
      return true;
    }
  }
  final names = {for (final team in familyTeams) _foldTeamName(team.name)}
    ..removeWhere((name) => name.isEmpty);
  if (names.isEmpty) return false;
  if (names.contains(_foldTeamName(event.scopeName ?? ''))) return true;
  for (final name in event.teams) {
    if (names.contains(_foldTeamName(name))) return true;
  }
  return false;
}

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
  if (_sameId(event.scopeId, teamId)) return true;
  final kind = (event.scopeKind ?? '').toLowerCase();
  if (kind == 'club') return true;
  return kind == 'section' && _sameId(event.scopeId, sectionId);
}

bool _sameId(String? a, String? b) {
  if (a == null || b == null) return false;
  final left = a.trim();
  final right = b.trim();
  if (left.isEmpty || right.isEmpty) return false;
  return left.toLowerCase() == right.toLowerCase();
}

/// Latin/Cyrillic lookalikes so "М16" and "M16" match.
String _foldTeamName(String raw) {
  const map = {
    'А': 'A',
    'В': 'B',
    'Е': 'E',
    'К': 'K',
    'М': 'M',
    'Н': 'H',
    'О': 'O',
    'Р': 'P',
    'С': 'C',
    'Т': 'T',
    'Х': 'X',
    'а': 'a',
    'е': 'e',
    'к': 'k',
    'м': 'm',
    'н': 'h',
    'о': 'o',
    'р': 'p',
    'с': 'c',
    'т': 't',
    'х': 'x',
  };
  final folded = StringBuffer();
  for (final rune in raw.runes) {
    final ch = String.fromCharCode(rune);
    folded.write(map[ch] ?? ch);
  }
  return folded.toString().trim().toLowerCase();
}
