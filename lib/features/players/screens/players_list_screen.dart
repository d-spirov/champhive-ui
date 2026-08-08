import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../shared/demo/demo_data.dart';
import '../../../shared/widgets/ui_bits.dart';
import '../../shell/app_drawer.dart';

class PlayersListScreen extends StatelessWidget {
  const PlayersListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final players = [
      DemoData.player,
      const DemoPlayer(
        id: 'p2',
        name: 'Marco Rossi',
        position: 'Midfielder',
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
        position: 'Defender',
        number: 4,
        status: 'Active',
        dateOfBirth: '18 Jul 2011',
        email: 'luka@email.com',
        phone: '+389 70 333 444',
        parent: 'Ivan Petrov',
        jerseySize: 'M',
      ),
    ];

    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(
        title: const Text('Players'),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: players.length,
        separatorBuilder: (context, index) => const SizedBox(height: 8),
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
      ),
    );
  }
}
