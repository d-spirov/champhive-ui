import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../l10n/app_localizations.dart';
import '../../../shared/models/team.dart';
import '../../../shared/theme/app_theme.dart';
import '../../../shared/utils/api_error_message.dart';
import '../../../shared/widgets/ui_bits.dart';
import '../../attendance/widgets/attendance_ui.dart';
import '../../clubs/providers/sport_theme_provider.dart';
import '../../players/widgets/player_avatar.dart';
import '../providers/teams_provider.dart';

class TeamDetailsScreen extends ConsumerWidget {
  const TeamDetailsScreen({super.key, required this.teamId});

  final String teamId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final team = ref.watch(clubTeamProvider(teamId));
    final rosterAsync = ref.watch(teamRosterProvider(teamId));
    final title = team?.name ??
        rosterAsync.valueOrNull?.teamName ??
        l10n.team;

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text(title),
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
    final clubTeam = team;
    final location = clubTeam?.trainingLocation;
    final sportTheme =
        ref.watch(sportThemeForSectionProvider(clubTeam?.sectionId));

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(AppTheme.radius),
          child: AspectRatio(
            aspectRatio: 16 / 9,
            child: Image.asset(
              sportTheme.heroImage,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => Image.asset(
                sportTheme.backgroundImage,
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          clubTeam?.name ?? rosterAsync.valueOrNull?.teamName ?? l10n.team,
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        if (clubTeam?.subtitle.isNotEmpty == true) ...[
          const SizedBox(height: 4),
          Text(
            clubTeam!.subtitle,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.65),
                ),
          ),
        ],
        const SizedBox(height: 20),
        rosterAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Text(
            apiErrorMessage(e, fallback: l10n.couldNotLoadRoster),
          ),
          data: (roster) {
            final active = roster.entries
                .where((e) => e.status.toLowerCase() == 'active')
                .length;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SectionHeader(title: l10n.roster),
                Row(
                  children: [
                    Expanded(
                      child: StatCard(
                        label: l10n.members,
                        value: '${roster.entries.length}',
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: StatCard(
                        label: l10n.active,
                        value: '$active',
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: StatCard(
                        label: l10n.season,
                        value: roster.seasonLabel?.isNotEmpty == true
                            ? roster.seasonLabel!
                            : '—',
                      ),
                    ),
                  ],
                ),
                if (location != null && location.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  SectionHeader(title: l10n.trainingLocation),
                  Card(
                    child: ListTile(
                      leading: const Icon(Icons.place_outlined),
                      title: Text(location),
                    ),
                  ),
                ],
              ],
            );
          },
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
        if (roster.entries.isEmpty) {
          return Center(child: Text(l10n.noMembersOnTeamRoster));
        }
        final entries = [...roster.entries]
          ..sort((a, b) => a.displayName.compareTo(b.displayName));
        return RefreshIndicator(
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
              return Card(
                child: ListTile(
                  leading: PlayerAvatar(
                    playerId: p.memberId,
                    label: p.displayName,
                    hasPhoto: false,
                  ),
                  title: Text(p.displayName),
                  subtitle: Text(p.subtitle),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => context.push('/members/${p.memberId}'),
                ),
              );
            },
          ),
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
    final scheduleAsync = ref.watch(teamScheduleProvider(teamId));

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
        if (events.isEmpty) {
          return Center(child: Text(l10n.noUpcomingSessionsForTeam));
        }
        return RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(teamScheduleProvider(teamId));
            await ref.read(teamScheduleProvider(teamId).future);
          },
          child: ListView.builder(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            itemCount: events.length,
            itemBuilder: (context, index) {
              final e = events[index];
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
