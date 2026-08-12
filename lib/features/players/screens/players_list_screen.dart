import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../shared/demo/demo_data.dart';
import '../../../shared/utils/api_error_message.dart';
import '../../../shared/widgets/ui_bits.dart';
import '../../auth/providers/auth_provider.dart';
import '../../clubs/providers/clubs_provider.dart';
import '../../shell/app_drawer.dart';
import '../providers/players_provider.dart';
import '../widgets/player_avatar.dart';

class PlayersListScreen extends ConsumerStatefulWidget {
  const PlayersListScreen({super.key});

  @override
  ConsumerState<PlayersListScreen> createState() => _PlayersListScreenState();
}

class _PlayersListScreenState extends ConsumerState<PlayersListScreen> {
  final _search = TextEditingController();
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDemo = ref.watch(authNotifierProvider).user?.id == 'demo';
    final clubId = ref.watch(selectedClubIdProvider);
    final playersAsync = ref.watch(clubPlayersProvider);

    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(
        title: const Text('Players'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: AppSearchField(
              controller: _search,
              hintText: 'Search players',
              onChanged: (value) {
                _debounce?.cancel();
                _debounce = Timer(const Duration(milliseconds: 350), () {
                  ref.read(playersSearchQueryProvider.notifier).state = value;
                });
              },
            ),
          ),
          Expanded(
            child: isDemo
                ? _DemoPlayersList()
                : clubId == null
                    ? const Center(
                        child: Text('Select a club to view players.'),
                      )
                    : playersAsync.when(
                        loading: () =>
                            const Center(child: CircularProgressIndicator()),
                        error: (e, _) => Center(
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  apiErrorMessage(
                                    e,
                                    fallback: 'Could not load players',
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 12),
                                FilledButton(
                                  onPressed: () =>
                                      ref.invalidate(clubPlayersProvider),
                                  child: const Text('Retry'),
                                ),
                              ],
                            ),
                          ),
                        ),
                        data: (players) {
                          if (players.isEmpty) {
                            return const Center(
                              child: Text('No players found for this club.'),
                            );
                          }
                          return RefreshIndicator(
                            onRefresh: () async {
                              ref.invalidate(clubPlayersProvider);
                              await ref.read(clubPlayersProvider.future);
                            },
                            child: ListView.separated(
                              physics: const AlwaysScrollableScrollPhysics(),
                              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                              itemCount: players.length,
                              separatorBuilder: (_, _) =>
                                  const SizedBox(height: 8),
                              itemBuilder: (context, index) {
                                final p = players[index];
                                return Card(
                                  child: ListTile(
                                    leading: PlayerAvatar(
                                      playerId: p.id,
                                      label: p.name,
                                      hasPhoto: p.hasPhoto,
                                    ),
                                    title: Text(p.name),
                                    subtitle: Text(p.teamsLabel),
                                    trailing: const Icon(
                                      Icons.chevron_right_rounded,
                                    ),
                                    onTap: () =>
                                        context.push('/players/${p.id}'),
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}

class _DemoPlayersList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final players = [
      DemoData.player,
      const DemoPlayer(
        id: 'p2',
        name: 'Marco Rossi',
        position: 'Forward',
        number: 8,
        status: 'Active',
        dateOfBirth: '2 Jan 2012',
        email: 'marco@email.com',
        phone: '+389 70 111 222',
        parent: 'Anna Rossi',
        jerseySize: 'S',
      ),
      const DemoPlayer(
        id: 'p3',
        name: 'Luka Petrov',
        position: 'Guard',
        number: 4,
        status: 'Active',
        dateOfBirth: '18 Jul 2011',
        email: 'luka@email.com',
        phone: '+389 70 333 444',
        parent: 'Ivan Petrov',
        jerseySize: 'M',
      ),
    ];

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      itemCount: players.length,
      separatorBuilder: (_, _) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final p = players[index];
        return Card(
          child: ListTile(
            leading: AvatarCircle(label: p.name),
            title: Text(p.name),
            subtitle: Text('${p.position} · #${p.number}'),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () => context.push('/players/${p.id}'),
          ),
        );
      },
    );
  }
}
