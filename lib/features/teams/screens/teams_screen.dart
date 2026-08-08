import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../shared/demo/demo_data.dart';
import '../../../shared/widgets/ui_bits.dart';

class TeamsScreen extends StatefulWidget {
  const TeamsScreen({super.key});

  @override
  State<TeamsScreen> createState() => _TeamsScreenState();
}

class _TeamsScreenState extends State<TeamsScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs = TabController(length: 2, vsync: this);

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.menu_rounded),
          onPressed: () => Scaffold.of(context).openDrawer(),
        ),
        title: const Text('Teams'),
        actions: [
          IconButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Create team coming soon')),
              );
            },
            icon: const Icon(Icons.add_rounded),
          ),
        ],
        bottom: TabBar(
          controller: _tabs,
          tabs: const [
            Tab(text: 'My Teams'),
            Tab(text: 'All Teams'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabs,
        children: [
          _TeamList(teams: DemoData.teams),
          _TeamList(teams: DemoData.teams),
        ],
      ),
    );
  }
}

class _TeamList extends StatelessWidget {
  const _TeamList({required this.teams});

  final List<DemoTeam> teams;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: teams.length,
      separatorBuilder: (context, index) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final team = teams[index];
        return Card(
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            leading: AvatarCircle(label: team.name, size: 48),
            title: Text(team.name, style: Theme.of(context).textTheme.titleSmall),
            subtitle: Text('${team.playerCount} Players · ${team.season}'),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () => context.push('/teams/${team.id}'),
          ),
        );
      },
    );
  }
}
