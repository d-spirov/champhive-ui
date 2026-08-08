import 'package:flutter/material.dart';

import '../../../shared/demo/demo_data.dart';
import '../../../shared/widgets/ui_bits.dart';

class PlayerProfileScreen extends StatelessWidget {
  const PlayerProfileScreen({super.key, required this.playerId});

  final String playerId;

  @override
  Widget build(BuildContext context) {
    final player = DemoData.player;

    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Player Profile'),
          actions: [
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.more_vert_rounded),
            ),
          ],
          bottom: const TabBar(
            isScrollable: true,
            tabs: [
              Tab(text: 'Info'),
              Tab(text: 'Stats'),
              Tab(text: 'Attendance'),
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
                        const SizedBox(height: 4),
                        Text(
                          '${player.position} · #${player.number}',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurface
                                    .withValues(alpha: 0.65),
                              ),
                        ),
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
                  _InfoTab(player: player),
                  const _PlaceholderTab(text: 'Player stats coming soon'),
                  const _PlaceholderTab(text: 'Attendance history coming soon'),
                  const _PlaceholderTab(text: 'Notes coming soon'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoTab extends StatelessWidget {
  const _InfoTab({required this.player});

  final DemoPlayer player;

  @override
  Widget build(BuildContext context) {
    final rows = [
      ('Date of birth', player.dateOfBirth),
      ('Email', player.email),
      ('Phone', player.phone),
      ('Parent', player.parent),
      ('Jersey size', player.jerseySize),
      ('Position', player.position),
    ];

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: rows.length,
      separatorBuilder: (context, index) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final row = rows[index];
        return ListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(
            row.$1,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.55),
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

class _PlaceholderTab extends StatelessWidget {
  const _PlaceholderTab({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Center(child: Text(text));
  }
}
