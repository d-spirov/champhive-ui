import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../shared/models/team.dart';
import '../../../shared/theme/app_theme.dart';
import '../../../shared/utils/api_error_message.dart';
import '../../../shared/widgets/ui_bits.dart';
import '../../attendance/widgets/attendance_ui.dart';
import '../../players/widgets/player_avatar.dart';
import '../providers/teams_provider.dart';

class TeamDetailsScreen extends ConsumerWidget {
  const TeamDetailsScreen({super.key, required this.teamId});

  final String teamId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final team = ref.watch(clubTeamProvider(teamId));
    final rosterAsync = ref.watch(teamRosterProvider(teamId));
    final title = team?.name ??
        rosterAsync.valueOrNull?.teamName ??
        'Team';

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text(title),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Overview'),
              Tab(text: 'Members'),
              Tab(text: 'Schedule'),
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
    final rosterAsync = ref.watch(teamRosterProvider(teamId));
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final clubTeam = team;
    final location = clubTeam?.trainingLocation;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(AppTheme.radius),
          child: AspectRatio(
            aspectRatio: 16 / 9,
            child: Image.asset(
              isDark
                  ? 'assets/images/stadium_dark.jpg'
                  : 'assets/images/stadium_light.jpg',
              fit: BoxFit.cover,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          clubTeam?.name ?? rosterAsync.valueOrNull?.teamName ?? 'Team',
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
            apiErrorMessage(e, fallback: 'Could not load roster'),
          ),
          data: (roster) {
            final active = roster.entries
                .where((e) => e.status.toLowerCase() == 'active')
                .length;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SectionHeader(title: 'Roster'),
                Row(
                  children: [
                    Expanded(
                      child: StatCard(
                        label: 'Members',
                        value: '${roster.entries.length}',
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: StatCard(
                        label: 'Active',
                        value: '$active',
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: StatCard(
                        label: 'Season',
                        value: roster.seasonLabel?.isNotEmpty == true
                            ? roster.seasonLabel!
                            : '—',
                      ),
                    ),
                  ],
                ),
                if (location != null && location.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  const SectionHeader(title: 'Training location'),
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
                apiErrorMessage(e, fallback: 'Could not load roster'),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () => ref.invalidate(teamRosterProvider(teamId)),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
      data: (roster) {
        if (roster.entries.isEmpty) {
          return const Center(child: Text('No members on this team roster.'));
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
                apiErrorMessage(e, fallback: 'Could not load schedule'),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () => ref.invalidate(teamScheduleProvider(teamId)),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
      data: (events) {
        if (events.isEmpty) {
          return const Center(child: Text('No upcoming sessions for this team.'));
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
