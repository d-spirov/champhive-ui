import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../l10n/app_localizations.dart';
import '../../../shared/models/event_attendance.dart';
import '../../../shared/models/team.dart';
import '../../../shared/theme/app_theme.dart';
import '../../../shared/utils/api_error_message.dart';
import '../../../shared/widgets/team_hive_logo.dart';
import '../../../shared/widgets/ui_bits.dart';
import '../../attendance/widgets/attendance_ui.dart';
import '../../auth/providers/auth_provider.dart';
import '../../clubs/providers/clubs_provider.dart';
import '../../clubs/providers/sport_theme_provider.dart';
import '../../events/providers/events_provider.dart';
import '../../messages/providers/chat_provider.dart';
import '../../players/widgets/player_avatar.dart';
import '../providers/teams_provider.dart';

class TeamDetailsScreen extends ConsumerWidget {
  const TeamDetailsScreen({super.key, required this.teamId});

  final String teamId;

  void _refresh(WidgetRef ref) {
    ref.invalidate(clubTeamsProvider);
    ref.invalidate(teamRosterProvider(teamId));
    ref.invalidate(teamScheduleProvider(teamId));
    ref.invalidate(clubEventsProvider);
    ref.invalidate(chatChannelsProvider);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final team = ref.watch(clubTeamProvider(teamId));
    final rosterAsync = ref.watch(teamRosterProvider(teamId));
    final title = team?.name ?? rosterAsync.valueOrNull?.teamName ?? l10n.team;

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text(title),
          actions: [
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'refresh') _refresh(ref);
              },
              itemBuilder: (context) => [
                PopupMenuItem(value: 'refresh', child: Text(l10n.refresh)),
              ],
            ),
          ],
          bottom: TabBar(
            tabs: [
              Tab(text: l10n.overview),
              Tab(text: l10n.members),
              Tab(text: l10n.calendar),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _OverviewTab(teamId: teamId, team: team),
            _MembersTab(teamId: teamId),
            _ScheduleTab(teamId: teamId),
          ],
        ),
      ),
    );
  }
}

class _OverviewTab extends ConsumerWidget {
  const _OverviewTab({required this.teamId, required this.team});

  final String teamId;
  final ClubTeam? team;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final rosterAsync = ref.watch(teamRosterProvider(teamId));
    final scheduleAsync = ref.watch(teamScheduleProvider(teamId));
    final clubEvents = ref.watch(clubEventsProvider).valueOrNull ?? const [];
    final sportTheme = ref.watch(sportThemeForSectionProvider(team?.sectionId));
    List<ClubEvent> merged(List<ClubEvent> teamEvents) => mergeTeamSchedule(
      teamEvents: teamEvents,
      clubEvents: clubEvents,
      teamId: teamId,
      sectionId: team?.sectionId,
    );

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(clubTeamsProvider);
        ref.invalidate(teamRosterProvider(teamId));
        ref.invalidate(teamScheduleProvider(teamId));
        ref.invalidate(clubEventsProvider);
        ref.invalidate(chatChannelsProvider);
        await Future.wait([
          ref.read(teamRosterProvider(teamId).future),
          ref.read(teamScheduleProvider(teamId).future),
          ref.read(clubEventsProvider.future),
        ]);
      },
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
        children: [
          _TeamHeroCard(
            team: team,
            roster: rosterAsync.valueOrNull,
            sportName: sportTheme.name,
            heroImage: sportTheme.heroImage,
            fallbackImage: sportTheme.backgroundImage,
          ),
          const SizedBox(height: 22),
          SectionHeader(title: l10n.quickActions),
          _QuickActionsRow(
            teamId: teamId,
            nextOccurrence: nextUpcomingEvent(
              merged(scheduleAsync.valueOrNull ?? const []),
            ),
          ),
          const SizedBox(height: 22),
          SectionHeader(
            title: l10n.nextUp,
            actionLabel: '${l10n.viewAll} ›',
            onAction: () => DefaultTabController.of(context).animateTo(2),
          ),
          scheduleAsync.when(
            loading: () => const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (e, _) => AppCard(
              padding: const EdgeInsets.all(16),
              child: Text(
                apiErrorMessage(e, fallback: l10n.couldNotLoadSchedule),
              ),
            ),
            data: (events) {
              final next = nextUpcomingEvent(merged(events));
              if (next == null) {
                return AppCard(
                  padding: const EdgeInsets.all(20),
                  child: Text(
                    l10n.noUpcomingSessionsForTeam,
                    textAlign: TextAlign.center,
                  ),
                );
              }
              return _NextUpCard(
                event: next,
                roster: rosterAsync.valueOrNull,
                sportIcon: sportTheme.icon,
              );
            },
          ),
          const SizedBox(height: 22),
          SectionHeader(
            title: l10n.team,
            actionLabel: '${l10n.viewAllMembers} ›',
            onAction: () => DefaultTabController.of(context).animateTo(1),
          ),
          rosterAsync.when(
            loading: () => const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (e, _) =>
                Text(apiErrorMessage(e, fallback: l10n.couldNotLoadRoster)),
            data: (roster) {
              if (roster.entries.isEmpty) {
                return AppCard(
                  padding: const EdgeInsets.all(20),
                  child: Text(
                    l10n.noMembersOnTeamRoster,
                    textAlign: TextAlign.center,
                  ),
                );
              }
              return _TeamMemberStrip(entries: sortedRoster(roster.entries));
            },
          ),
          const SizedBox(height: 22),
          _TeamDetailsList(team: team, roster: rosterAsync.valueOrNull),
        ],
      ),
    );
  }
}

class _TeamHeroCard extends StatelessWidget {
  const _TeamHeroCard({
    required this.team,
    required this.roster,
    required this.sportName,
    required this.heroImage,
    required this.fallbackImage,
  });

  final ClubTeam? team;
  final TeamRoster? roster;
  final String sportName;
  final String heroImage;
  final String fallbackImage;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final name = team?.name ?? roster?.teamName ?? l10n.team;
    final age = team?.ageBandLabel ?? '';
    final subtitleParts = <String>[
      if (sportName.isNotEmpty) sportName,
      if (age.isNotEmpty) age,
    ];
    final playerCount = roster?.entries.length ?? 0;
    final season = roster?.seasonLabel?.trim() ?? '';

    return ClipRRect(
      borderRadius: BorderRadius.circular(AppTheme.radiusLg),
      child: AspectRatio(
        aspectRatio: 16 / 10,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(
              heroImage,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) =>
                  Image.asset(fallbackImage, fit: BoxFit.cover),
            ),
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0x33070E22), Color(0xE6070E22)],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    padding: const EdgeInsets.all(5),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: Image.asset(
                      TeamHiveLogo.markAsset,
                      fit: BoxFit.contain,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    name,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 28,
                      height: 1.1,
                    ),
                  ),
                  if (subtitleParts.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      subtitleParts.join(' • '),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.white.withValues(alpha: 0.82),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 14,
                    runSpacing: 6,
                    children: [
                      if (roster != null)
                        _HeroMeta(
                          icon: Icons.groups_outlined,
                          label: l10n.playersCount(playerCount),
                        ),
                      if (season.isNotEmpty)
                        _HeroMeta(
                          icon: Icons.calendar_today_outlined,
                          label: l10n.seasonNamed(season),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeroMeta extends StatelessWidget {
  const _HeroMeta({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: Colors.white.withValues(alpha: 0.85)),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.9),
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
      ],
    );
  }
}

class _QuickActionsRow extends ConsumerWidget {
  const _QuickActionsRow({required this.teamId, required this.nextOccurrence});

  final String teamId;
  final ClubEvent? nextOccurrence;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final channels = ref.watch(chatChannelsProvider).valueOrNull ?? const [];
    final unread = teamChannelFor(channels, teamId)?.unreadCount ?? 0;
    final user = ref.watch(authNotifierProvider).user;
    final clubId = ref.watch(selectedClubIdProvider);
    final isDemo = user?.id == 'demo';
    final isStaff = isDemo || (user?.isStaff(clubId) ?? false);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: _TeamChatAction(teamId: teamId, unread: unread),
        ),
        if (isStaff) ...[
          const SizedBox(width: 10),
          Expanded(
            child: _QuickActionCard(
              icon: Icons.check_circle_rounded,
              iconColor: AppColors.success,
              label: l10n.takeAttendance,
              onTap: () => _openAttendance(context, l10n),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _QuickActionCard(
              icon: Icons.calendar_month_outlined,
              iconColor: AppColors.warning,
              label: l10n.addEvent,
              onTap: () => context.push('/schedule/create', extra: teamId),
            ),
          ),
        ],
      ],
    );
  }

  void _openAttendance(BuildContext context, AppLocalizations l10n) {
    final next = nextOccurrence;
    if (next == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.noSessionToTakeAttendance)));
      return;
    }
    context.push('/occurrences/${next.id}/attendance');
  }
}

class _TeamChatAction extends ConsumerStatefulWidget {
  const _TeamChatAction({required this.teamId, required this.unread});

  final String teamId;
  final int unread;

  @override
  ConsumerState<_TeamChatAction> createState() => _TeamChatActionState();
}

class _TeamChatActionState extends ConsumerState<_TeamChatAction> {
  bool _opening = false;

  Future<void> _open() async {
    if (_opening) return;
    final l10n = AppLocalizations.of(context)!;
    final auth = ref.read(authNotifierProvider);
    if (!auth.isAuthenticated || auth.user?.id == 'demo') {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.signInToOpenChat)));
      return;
    }
    setState(() => _opening = true);
    try {
      final channel = await loadTeamChannel(ref, widget.teamId);
      if (!mounted) return;
      if (channel == null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.couldNotOpenTeamChat)));
        return;
      }
      context.push('/messages/${channel.channelId}');
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            apiErrorMessage(e, fallback: l10n.couldNotOpenTeamChat),
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => _opening = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return _QuickActionCard(
      icon: Icons.chat_bubble_outline_rounded,
      iconColor: AppColors.primaryBright,
      label: l10n.teamChat,
      badge: widget.unread,
      busy: _opening,
      onTap: _opening ? null : _open,
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  const _QuickActionCard({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.onTap,
    this.badge = 0,
    this.busy = false,
  });

  final IconData icon;
  final Color iconColor;
  final String label;
  final VoidCallback? onTap;
  final int badge;
  final bool busy;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        SizedBox(
          height: 108,
          child: AppCard(
            onTap: onTap,
            padding: const EdgeInsets.fromLTRB(8, 16, 8, 12),
            child: Column(
              children: [
                SizedBox(
                  height: 32,
                  child: busy
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Icon(icon, color: iconColor, size: 28),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: Text(
                    label,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      height: 1.2,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        if (badge > 0)
          Positioned(
            top: -6,
            right: -4,
            child: Container(
              constraints: const BoxConstraints(minWidth: 20, minHeight: 20),
              padding: const EdgeInsets.symmetric(horizontal: 6),
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                color: AppColors.primaryBright,
                shape: BoxShape.circle,
              ),
              child: Text(
                badge > 99 ? '99+' : '$badge',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _NextUpCard extends ConsumerWidget {
  const _NextUpCard({
    required this.event,
    required this.roster,
    required this.sportIcon,
  });

  final ClubEvent event;
  final TeamRoster? roster;
  final IconData sportIcon;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;
    final muted = scheme.onSurface.withValues(alpha: 0.65);
    final title = event.title.trim().isEmpty
        ? eventTypeLabel(l10n, event.type)
        : event.title;
    final when = [
      formatEventDate(context, event.startAt),
      formatEventTimeRange(context, event.startAt, event.endAt),
    ].join(' • ');
    final location = event.location.display;
    final showLocation = location.isNotEmpty && location != l10n.tbd;

    final sessionAsync = event.rsvpRequested
        ? ref.watch(attendanceSessionProvider(event.id))
        : null;
    final rsvpReady = sessionAsync?.hasValue == true;
    final rsvp = sessionAsync?.valueOrNull;
    final going = rsvp == null
        ? const <AttendanceParticipant>[]
        : rsvp.participants.where((p) => isRsvpGoing(p.rsvpStatus)).toList();
    final awaiting = rsvp == null
        ? 0
        : rsvp.participants.where((p) => isRsvpAwaiting(p.rsvpStatus)).length;

    final avatarEntries = going.isNotEmpty
        ? going.map((p) => (id: p.memberId, name: p.displayName)).toList()
        : (roster?.entries ?? const <TeamRosterEntry>[])
              .map((e) => (id: e.memberId, name: e.displayName))
              .toList();

    return AppCard(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.primaryBright.withValues(alpha: 0.16),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  clubEventTypeIcon(event.type, sportIcon: sportIcon),
                  color: AppColors.primaryBright,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today_outlined,
                          size: 14,
                          color: muted,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            when,
                            style: Theme.of(
                              context,
                            ).textTheme.bodySmall?.copyWith(color: muted),
                          ),
                        ),
                      ],
                    ),
                    if (showLocation) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.place_outlined, size: 14, color: muted),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              location,
                              style: Theme.of(
                                context,
                              ).textTheme.bodySmall?.copyWith(color: muted),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _GoingRow(
                  avatars: avatarEntries,
                  goingCount: rsvpReady ? going.length : null,
                  awaitingCount: rsvpReady ? awaiting : null,
                ),
              ),
              const SizedBox(width: 8),
              FilledButton(
                onPressed: () => context.push('/occurrences/${event.id}'),
                style: FilledButton.styleFrom(
                  visualDensity: VisualDensity.compact,
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                ),
                child: Text(l10n.viewDetails),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _GoingRow extends StatelessWidget {
  const _GoingRow({
    required this.avatars,
    required this.goingCount,
    required this.awaitingCount,
  });

  final List<({String id, String name})> avatars;
  final int? goingCount;
  final int? awaitingCount;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final shown = avatars.take(3).toList();
    final extra = avatars.length - shown.length;
    if (shown.isEmpty && goingCount == null) {
      return const SizedBox.shrink();
    }

    return Row(
      children: [
        if (shown.isNotEmpty)
          SizedBox(
            width: 16.0 * (shown.length + (extra > 0 ? 1 : 0)) + 16,
            height: 28,
            child: Stack(
              children: [
                for (var i = 0; i < shown.length; i++)
                  Positioned(
                    left: i * 16.0,
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color:
                              Theme.of(context).cardTheme.color ??
                              Theme.of(context).colorScheme.surface,
                          width: 2,
                        ),
                      ),
                      child: MemberPhotoAvatar(
                        memberId: shown[i].id,
                        label: shown[i].name,
                        size: 26,
                      ),
                    ),
                  ),
                if (extra > 0)
                  Positioned(
                    left: shown.length * 16.0,
                    child: CircleAvatar(
                      radius: 13,
                      backgroundColor: Theme.of(
                        context,
                      ).colorScheme.surfaceContainerHighest,
                      child: Text(
                        '+$extra',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        if (goingCount != null) ...[
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              l10n.goingAwaiting(goingCount!, awaitingCount ?? 0),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.success,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _TeamMemberStrip extends StatelessWidget {
  const _TeamMemberStrip({required this.entries});

  final List<TeamRosterEntry> entries;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 108,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: entries.length,
        separatorBuilder: (_, _) => const SizedBox(width: 14),
        itemBuilder: (context, index) {
          final member = entries[index];
          return _MemberAvatarTile(member: member);
        },
      ),
    );
  }
}

class _MemberAvatarTile extends StatelessWidget {
  const _MemberAvatarTile({required this.member});

  final TeamRosterEntry member;

  @override
  Widget build(BuildContext context) {
    final number = member.shirtNumber?.trim();
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () => context.push('/members/${member.memberId}'),
      child: SizedBox(
        width: 76,
        child: Column(
          children: [
            SizedBox(
              width: 64,
              height: 64,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  MemberPhotoAvatar(
                    memberId: member.memberId,
                    label: member.displayName,
                    size: 64,
                  ),
                  if (number != null && number.isNotEmpty)
                    Positioned(
                      right: -2,
                      bottom: -2,
                      child: Container(
                        width: 22,
                        height: 22,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: AppColors.primaryBright,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Theme.of(context).scaffoldBackgroundColor,
                            width: 2,
                          ),
                        ),
                        child: Text(
                          number.replaceFirst('#', ''),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              member.shortDisplayName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}

class _TeamDetailsList extends StatelessWidget {
  const _TeamDetailsList({required this.team, required this.roster});

  final ClubTeam? team;
  final TeamRoster? roster;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final location = team?.trainingLocation?.trim() ?? '';
    final age = team?.ageBandLabel ?? '';
    final season = roster?.seasonLabel?.trim() ?? '';
    final rows = <({IconData icon, String label, String value})>[
      if (location.isNotEmpty)
        (
          icon: Icons.place_outlined,
          label: l10n.trainingLocation,
          value: location,
        ),
      if (age.isNotEmpty)
        (icon: Icons.person_outline, label: l10n.ageGroup, value: age),
      if (season.isNotEmpty)
        (
          icon: Icons.calendar_today_outlined,
          label: l10n.season,
          value: season,
        ),
    ];

    if (rows.isEmpty) {
      return const SizedBox.shrink();
    }

    final muted = Theme.of(
      context,
    ).colorScheme.onSurface.withValues(alpha: 0.65);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(title: l10n.details),
        AppCard(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Column(
            children: [
              for (var i = 0; i < rows.length; i++) ...[
                if (i > 0) const Divider(height: 1),
                ListTile(
                  leading: Icon(rows[i].icon, color: muted),
                  title: Text(
                    rows[i].label,
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(color: muted),
                  ),
                  trailing: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 180),
                    child: Text(
                      rows[i].value,
                      textAlign: TextAlign.end,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _MembersTab extends ConsumerWidget {
  const _MembersTab({required this.teamId});

  final String teamId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final rosterAsync = ref.watch(teamRosterProvider(teamId));

    return rosterAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                apiErrorMessage(e, fallback: l10n.couldNotLoadRoster),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () => ref.invalidate(teamRosterProvider(teamId)),
                child: Text(l10n.retry),
              ),
            ],
          ),
        ),
      ),
      data: (roster) {
        final entries = sortedRoster(roster.entries);
        final user = ref.watch(authNotifierProvider).user;
        final clubId = ref.watch(selectedClubIdProvider);
        final isDemo = user?.id == 'demo';
        final canAdd =
            !isDemo && (user?.canWriteMembers(clubId) ?? false);
        return Column(
          children: [
            if (canAdd)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: () =>
                        context.push('/teams/$teamId/members/add'),
                    icon: const Icon(Icons.person_add_alt_1_rounded),
                    label: Text(l10n.addMember),
                  ),
                ),
              ),
            Expanded(
              child: entries.isEmpty
                  ? Center(child: Text(l10n.noMembersOnTeamRoster))
                  : RefreshIndicator(
                      onRefresh: () async {
                        ref.invalidate(teamRosterProvider(teamId));
                        await ref.read(teamRosterProvider(teamId).future);
                      },
                      child: ListView.separated(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.all(16),
                        itemCount: entries.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 8),
                        itemBuilder: (context, index) {
                          final p = entries[index];
                          final number = p.shirtNumber?.trim();
                          return Card(
                            child: ListTile(
                              leading: SizedBox(
                                width: 48,
                                height: 48,
                                child: Stack(
                                  clipBehavior: Clip.none,
                                  children: [
                                    MemberPhotoAvatar(
                                      memberId: p.memberId,
                                      label: p.displayName,
                                      size: 48,
                                    ),
                                    if (number != null && number.isNotEmpty)
                                      Positioned(
                                        right: -2,
                                        bottom: -2,
                                        child: Container(
                                          width: 18,
                                          height: 18,
                                          alignment: Alignment.center,
                                          decoration: BoxDecoration(
                                            color: AppColors.primaryBright,
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              color: Theme.of(
                                                context,
                                              ).scaffoldBackgroundColor,
                                              width: 1.5,
                                            ),
                                          ),
                                          child: Text(
                                            number.replaceFirst('#', ''),
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 9,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              title: Text(p.displayName),
                              subtitle: Text(p.subtitle),
                              trailing: const Icon(Icons.chevron_right_rounded),
                              onTap: () =>
                                  context.push('/members/${p.memberId}'),
                            ),
                          );
                        },
                      ),
                    ),
            ),
          ],
        );
      },
    );
  }
}

class _ScheduleTab extends ConsumerWidget {
  const _ScheduleTab({required this.teamId});

  final String teamId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final user = ref.watch(authNotifierProvider).user;
    final clubId = ref.watch(selectedClubIdProvider);
    final isDemo = user?.id == 'demo';
    final isStaff = isDemo || (user?.isStaff(clubId) ?? false);
    final scheduleAsync = ref.watch(teamScheduleProvider(teamId));
    final team = ref.watch(clubTeamProvider(teamId));
    final clubEvents = ref.watch(clubEventsProvider).valueOrNull ?? const [];

    return scheduleAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                apiErrorMessage(e, fallback: l10n.couldNotLoadSchedule),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () => ref.invalidate(teamScheduleProvider(teamId)),
                child: Text(l10n.retry),
              ),
            ],
          ),
        ),
      ),
      data: (events) {
        final merged = mergeTeamSchedule(
          teamEvents: events,
          clubEvents: clubEvents,
          teamId: teamId,
          sectionId: team?.sectionId,
        );
        if (merged.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    l10n.noUpcomingSessionsForTeam,
                    textAlign: TextAlign.center,
                  ),
                  if (isStaff) ...[
                    const SizedBox(height: 16),
                    FilledButton.icon(
                      onPressed: () =>
                          context.push('/schedule/create', extra: teamId),
                      icon: const Icon(Icons.add_rounded),
                      label: Text(l10n.addEvent),
                    ),
                  ],
                ],
              ),
            ),
          );
        }
        return RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(teamScheduleProvider(teamId));
            ref.invalidate(clubEventsProvider);
            await Future.wait([
              ref.read(teamScheduleProvider(teamId).future),
              ref.read(clubEventsProvider.future),
            ]);
          },
          child: ListView.builder(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            itemCount: merged.length,
            itemBuilder: (context, index) {
              final e = merged[index];
              return ClubEventListTile(
                event: e,
                onTap: () => context.push('/occurrences/${e.id}'),
              );
            },
          ),
        );
      },
    );
  }
}

List<TeamRosterEntry> sortedRoster(List<TeamRosterEntry> entries) {
  final sorted = [...entries]
    ..sort((a, b) {
      final aActive = a.status.toLowerCase() == 'active' ? 0 : 1;
      final bActive = b.status.toLowerCase() == 'active' ? 0 : 1;
      if (aActive != bActive) return aActive - bActive;
      return a.displayName.toLowerCase().compareTo(b.displayName.toLowerCase());
    });
  return sorted;
}

ClubEvent? nextUpcomingEvent(List<ClubEvent>? events) {
  if (events == null || events.isEmpty) return null;
  final now = DateTime.now();
  final upcoming = events.where((e) {
    final status = (e.status ?? '').toLowerCase();
    if (status == 'canceled' ||
        status == 'cancelled' ||
        status == 'completed') {
      return false;
    }
    final end = e.endAt ?? e.startAt.add(const Duration(hours: 2));
    return end.isAfter(now);
  }).toList()..sort((a, b) => a.startAt.compareTo(b.startAt));
  return upcoming.isEmpty ? null : upcoming.first;
}

bool isRsvpGoing(String? status) {
  switch ((status ?? '').toLowerCase()) {
    case 'yes':
    case 'going':
    case 'accepted':
    case 'attending':
    case 'in':
      return true;
    default:
      return false;
  }
}

bool isRsvpAwaiting(String? status) {
  switch ((status ?? '').toLowerCase()) {
    case '':
    case 'noresponse':
    case 'no_response':
    case 'pending':
    case 'awaiting':
    case 'none':
      return true;
    default:
      return false;
  }
}
