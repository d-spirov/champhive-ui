import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../auth/providers/auth_provider.dart';
import '../../clubs/providers/clubs_provider.dart';
import '../../shell/main_shell.dart';
import '../../../shared/demo/demo_data.dart';
import '../../../shared/models/club.dart';
import '../../../shared/theme/app_theme.dart';
import '../../../shared/utils/api_error_message.dart';
import '../../../shared/widgets/ui_bits.dart';

class HomeDashboardScreen extends ConsumerWidget {
  const HomeDashboardScreen({super.key});

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 18) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authNotifierProvider);
    final user = auth.user;
    final isDemo = user?.id == 'demo';
    final first = user?.firstName.isNotEmpty == true
        ? user!.firstName
        : (user?.displayName ?? 'Coach');
    final clubsAsync = ref.watch(myClubsProvider);
    final events = DemoData.events.take(3).toList();

    return Scaffold(
      appBar: shellAppBar(
        context,
        title: '${_greeting()}, $first! 👋',
        actions: [
          IconButton(
            onPressed: () {},
            icon: Badge(
              smallSize: 8,
              backgroundColor: AppColors.badge,
              child: Icon(
                Icons.notifications_outlined,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          if (!isDemo) {
            ref.invalidate(myClubsProvider);
            await ref.read(myClubsProvider.future);
          }
        },
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          children: [
            if (isDemo) ...[
              const SectionHeader(title: 'Your teams'),
              _YourTeamCard(team: DemoData.teams.first),
            ] else ...[
              const SectionHeader(title: 'Your clubs'),
              clubsAsync.when(
                loading: () => const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (e, _) => Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Text(
                          apiErrorMessage(e, fallback: 'Could not load clubs'),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        FilledButton(
                          onPressed: () => ref.invalidate(myClubsProvider),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                ),
                data: (clubs) {
                  if (clubs.isEmpty) {
                    return Card(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Text(
                          'You are not a member of any club yet.',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ),
                    );
                  }
                  return Column(
                    children: [
                      for (final club in clubs) ...[
                        _ClubCard(club: club),
                        const SizedBox(height: 10),
                      ],
                    ],
                  );
                },
              ),
            ],
            const SizedBox(height: 24),
            const SectionHeader(title: 'Upcoming events'),
            Card(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(14, 14, 14, 6),
                child: Column(
                  children: [
                    for (final e in events) EventListTile(event: e),
                  ],
                ),
              ),
            ),
            if (isDemo) ...[
              const SizedBox(height: 24),
              const SectionHeader(title: 'Recent activity'),
              Card(
                child: Column(
                  children: [
                    for (var i = 0; i < DemoData.activities.length; i++) ...[
                      if (i > 0) const Divider(height: 1),
                      ListTile(
                        leading: AvatarCircle(label: DemoData.activities[i].playerName),
                        title: Text(DemoData.activities[i].playerName),
                        subtitle: Text(DemoData.activities[i].status),
                        trailing: Text(
                          DemoData.activities[i].whenLabel,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        onTap: () => context.push('/players/${DemoData.player.id}'),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ClubCard extends ConsumerWidget {
  const _ClubCard({required this.club});

  final ClubSummary club;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedId = ref.watch(selectedClubIdProvider);
    final isSelected = selectedId == club.id;
    final subtitle = [
      if (club.sportType != null && club.sportType!.isNotEmpty) club.sportType!,
      if (club.city != null && club.city!.isNotEmpty) club.city!,
      if (club.currentUserRoles.isNotEmpty) club.currentUserRoles.first,
    ].join(' · ');

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () async {
          await ref.read(selectedClubIdProvider.notifier).select(club.id);
          if (context.mounted) context.push('/clubs/${club.id}');
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              AvatarCircle(label: club.name, size: 56),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            club.name,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ),
                        if (isSelected)
                          Icon(
                            Icons.check_circle,
                            size: 18,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                      ],
                    ),
                    if (subtitle.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withValues(alpha: 0.6),
                            ),
                      ),
                    ],
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded),
            ],
          ),
        ),
      ),
    );
  }
}

class _YourTeamCard extends StatelessWidget {
  const _YourTeamCard({required this.team});

  final DemoTeam team;

  @override
  Widget build(BuildContext context) {
    final next = team.nextMatchAt;
    final opponent = team.nextOpponent ?? 'TBD';

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => context.push('/teams/${team.id}'),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(team.name, style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 4),
                    Text(
                      team.season,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withValues(alpha: 0.6),
                          ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Next match',
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                            color: Theme.of(context).colorScheme.primary,
                          ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      next == null
                          ? 'vs $opponent'
                          : 'vs $opponent · ${_shortDate(next)}',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              AvatarCircle(label: team.name, size: 64),
              const SizedBox(width: 4),
              const Icon(Icons.chevron_right_rounded),
            ],
          ),
        ),
      ),
    );
  }

  String _shortDate(DateTime dt) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${dt.day} ${months[dt.month - 1]}, ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }
}
