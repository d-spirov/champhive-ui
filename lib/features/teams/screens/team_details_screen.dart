import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../shared/demo/demo_data.dart';
import '../../../shared/theme/app_theme.dart';
import '../../../shared/widgets/ui_bits.dart';

class TeamDetailsScreen extends StatelessWidget {
  const TeamDetailsScreen({super.key, required this.teamId});

  final String teamId;

  @override
  Widget build(BuildContext context) {
    final team = DemoData.teams.firstWhere(
      (t) => t.id == teamId,
      orElse: () => DemoData.teams.first,
    );

    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: Text(team.name),
          actions: [
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.more_vert_rounded),
            ),
          ],
          bottom: const TabBar(
            isScrollable: true,
            tabs: [
              Tab(text: 'Overview'),
              Tab(text: 'Players'),
              Tab(text: 'Schedule'),
              Tab(text: 'Stats'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _OverviewTab(team: team),
            _PlayersTab(),
            _ScheduleTab(),
            _StatsTab(),
          ],
        ),
      ),
    );
  }
}

class _OverviewTab extends StatelessWidget {
  const _OverviewTab({required this.team});

  final DemoTeam team;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
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
        const SectionHeader(title: 'Next match'),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                AvatarCircle(label: team.name, size: 48),
                const SizedBox(width: 12),
                const Text('vs', style: TextStyle(fontWeight: FontWeight.w700)),
                const SizedBox(width: 12),
                AvatarCircle(label: team.nextOpponent ?? 'OPP', size: 48),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        team.nextOpponent ?? 'TBD',
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      Text(
                        team.nextMatchAt == null
                            ? 'Schedule TBD'
                            : _fmt(team.nextMatchAt!),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const Text('City Stadium', style: TextStyle(fontSize: 12)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
        const SectionHeader(title: 'Team stats'),
        Row(
          children: const [
            Expanded(child: StatCard(label: 'Matches', value: '18')),
            SizedBox(width: 10),
            Expanded(child: StatCard(label: 'Wins', value: '12')),
            SizedBox(width: 10),
            Expanded(child: StatCard(label: 'Win %', value: '67%')),
          ],
        ),
        const SizedBox(height: 20),
        const SectionHeader(title: 'Recent matches'),
        Card(
          child: Column(
            children: const [
              ListTile(
                title: Text('vs United FC'),
                subtitle: Text('12 Apr'),
                trailing: Text('W 3-1', style: TextStyle(fontWeight: FontWeight.w700)),
              ),
              Divider(height: 1),
              ListTile(
                title: Text('vs North End'),
                subtitle: Text('5 Apr'),
                trailing: Text('D 1-1', style: TextStyle(fontWeight: FontWeight.w700)),
              ),
              Divider(height: 1),
              ListTile(
                title: Text('vs Riverside'),
                subtitle: Text('29 Mar'),
                trailing: Text('L 0-2', style: TextStyle(fontWeight: FontWeight.w700)),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _fmt(DateTime dt) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${dt.day} ${months[dt.month - 1]} · ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }
}

class _PlayersTab extends StatelessWidget {
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

    return ListView.separated(
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
    );
  }
}

class _ScheduleTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        for (final e in DemoData.events) EventListTile(event: e),
      ],
    );
  }
}

class _StatsTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          children: const [
            Expanded(child: StatCard(label: 'Matches', value: '18')),
            SizedBox(width: 10),
            Expanded(child: StatCard(label: 'Wins', value: '12')),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: const [
            Expanded(child: StatCard(label: 'Draws', value: '3')),
            SizedBox(width: 10),
            Expanded(child: StatCard(label: 'Losses', value: '3')),
          ],
        ),
      ],
    );
  }
}
