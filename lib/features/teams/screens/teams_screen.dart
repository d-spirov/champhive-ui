import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../shared/models/team.dart';
import '../../../shared/utils/api_error_message.dart';
import '../../../shared/widgets/ui_bits.dart';
import '../../auth/providers/auth_provider.dart';
import '../../clubs/providers/clubs_provider.dart';
import '../../shell/main_shell.dart';
import '../providers/teams_provider.dart';

class TeamsScreen extends ConsumerWidget {
  const TeamsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authNotifierProvider);
    final isDemo = auth.user?.id == 'demo';
    final clubId = ref.watch(selectedClubIdProvider);
    final teamsAsync = ref.watch(clubTeamsProvider);

    return Scaffold(
      appBar: shellAppBar(context, title: 'Teams'),
      body: isDemo
          ? const Center(
              child: Text('Sign in to load club teams from the API.'),
            )
          : clubId == null
              ? const Center(child: Text('Select a club to view teams.'))
              : teamsAsync.when(
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (e, _) => Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            apiErrorMessage(e, fallback: 'Could not load teams'),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          FilledButton(
                            onPressed: () => ref.invalidate(clubTeamsProvider),
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    ),
                  ),
                  data: (teams) {
                    if (teams.isEmpty) {
                      return const Center(
                        child: Text('No teams in this club yet.'),
                      );
                    }
                    return RefreshIndicator(
                      onRefresh: () async {
                        ref.invalidate(clubTeamsProvider);
                        await ref.read(clubTeamsProvider.future);
                      },
                      child: ListView.separated(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.all(16),
                        itemCount: teams.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          final team = teams[index];
                          return _TeamCard(team: team);
                        },
                      ),
                    );
                  },
                ),
    );
  }
}

class _TeamCard extends ConsumerWidget {
  const _TeamCard({required this.team});

  final ClubTeam team;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rosterAsync = ref.watch(teamRosterProvider(team.id));
    final count = rosterAsync.valueOrNull?.entries.length;
    final season = rosterAsync.valueOrNull?.seasonLabel;
    final subtitle = [
      if (count != null) '$count members',
      if (season != null && season.isNotEmpty) season,
      if (team.subtitle.isNotEmpty) team.subtitle,
    ].join(' · ');

    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        leading: AvatarCircle(label: team.name, size: 48),
        title: Text(team.name, style: Theme.of(context).textTheme.titleSmall),
        subtitle: Text(
          subtitle.isEmpty ? 'Tap to open roster' : subtitle,
        ),
        trailing: const Icon(Icons.chevron_right_rounded),
        onTap: () => context.push('/teams/${team.id}'),
      ),
    );
  }
}
