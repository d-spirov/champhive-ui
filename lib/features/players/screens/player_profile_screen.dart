import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../shared/demo/demo_data.dart';
import '../../../shared/models/player.dart';
import '../../../shared/utils/api_error_message.dart';
import '../../../shared/widgets/ui_bits.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/players_provider.dart';
import '../widgets/player_avatar.dart';

class PlayerProfileScreen extends ConsumerWidget {
  const PlayerProfileScreen({super.key, required this.playerId});

  final String playerId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDemo = ref.watch(authNotifierProvider).user?.id == 'demo';
    if (isDemo) {
      return _DemoProfile(player: DemoData.player);
    }

    final async = ref.watch(playerDetailProvider(playerId));

    return async.when(
      loading: () => Scaffold(
        appBar: AppBar(title: const Text('Member')),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Scaffold(
        appBar: AppBar(title: const Text('Member')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  apiErrorMessage(e, fallback: 'Could not load member'),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                FilledButton(
                  onPressed: () =>
                      ref.invalidate(playerDetailProvider(playerId)),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      ),
      data: (player) => _PlayerProfileBody(player: player),
    );
  }
}

class _PlayerProfileBody extends StatelessWidget {
  const _PlayerProfileBody({required this.player});

  final ClubPlayer player;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Player Profile'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Info'),
              Tab(text: 'Teams'),
              Tab(text: 'Notes'),
            ],
          ),
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Row(
                children: [
                  PlayerAvatar(
                    playerId: player.id,
                    label: player.name,
                    hasPhoto: player.hasPhoto,
                    size: 72,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          player.name,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          player.teamsLabel,
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface
                                        .withValues(alpha: 0.65),
                                  ),
                        ),
                        const SizedBox(height: 8),
                        Chip(label: Text(_statusLabel(player.status))),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                children: [
                  _InfoTab(player: player),
                  _TeamsTab(player: player),
                  _NotesTab(notes: player.notes),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _statusLabel(String status) {
    if (status.isEmpty) return status;
    return status[0].toUpperCase() + status.substring(1).toLowerCase();
  }
}

class _InfoTab extends StatelessWidget {
  const _InfoTab({required this.player});

  final ClubPlayer player;

  @override
  Widget build(BuildContext context) {
    final dob = player.dateOfBirth == null
        ? null
        : DateFormat.yMMMd().format(player.dateOfBirth!);
    final rows = <(String, String)>[
      if (dob != null) ('Date of birth', dob),
      if (player.age != null) ('Age', '${player.age}'),
      if (player.gender != null) ('Gender', player.gender!),
      if (player.registrationNumber != null &&
          player.registrationNumber!.isNotEmpty)
        ('Registration #', player.registrationNumber!),
      if (player.email != null && player.email!.isNotEmpty)
        ('Email', player.email!),
      if (player.phone != null && player.phone!.isNotEmpty)
        ('Phone', player.phone!),
      if (player.primaryShirtNumber != null)
        ('Shirt number', '#${player.primaryShirtNumber}'),
    ];

    if (rows.isEmpty) {
      return const Center(child: Text('No profile details yet.'));
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: rows.length,
      separatorBuilder: (_, _) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final row = rows[index];
        return ListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(
            row.$1,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.55),
                ),
          ),
          subtitle: Text(
            row.$2,
            style: Theme.of(context).textTheme.titleSmall,
          ),
        );
      },
    );
  }
}

class _TeamsTab extends StatelessWidget {
  const _TeamsTab({required this.player});

  final ClubPlayer player;

  @override
  Widget build(BuildContext context) {
    if (player.activeTeams.isEmpty) {
      return const Center(child: Text('Not assigned to a team.'));
    }
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: player.activeTeams.length,
      separatorBuilder: (_, _) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final t = player.activeTeams[index];
        return Card(
          child: ListTile(
            leading: AvatarCircle(label: t.teamName),
            title: Text(t.teamName),
            subtitle: t.shirtNumber == null || t.shirtNumber!.isEmpty
                ? null
                : Text('Shirt #${t.shirtNumber}'),
          ),
        );
      },
    );
  }
}

class _NotesTab extends StatelessWidget {
  const _NotesTab({this.notes});

  final String? notes;

  @override
  Widget build(BuildContext context) {
    if (notes == null || notes!.trim().isEmpty) {
      return const Center(child: Text('No notes yet.'));
    }
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(notes!, style: Theme.of(context).textTheme.bodyLarge),
      ],
    );
  }
}

class _DemoProfile extends StatelessWidget {
  const _DemoProfile({required this.player});

  final DemoPlayer player;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Player Profile'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Info'),
              Tab(text: 'Notes'),
            ],
          ),
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Row(
                children: [
                  AvatarCircle(label: player.name, size: 72),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          player.name,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        Text('${player.position} · #${player.number}'),
                        const SizedBox(height: 8),
                        Chip(label: Text(player.status)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                children: [
                  ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      ListTile(
                        title: const Text('Email'),
                        subtitle: Text(player.email),
                      ),
                      ListTile(
                        title: const Text('Phone'),
                        subtitle: Text(player.phone),
                      ),
                    ],
                  ),
                  const Center(child: Text('Demo notes')),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
