import 'package:flutter/material.dart';

import '../../../shared/widgets/ui_bits.dart';
import '../../shell/app_drawer.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs = TabController(length: 2, vsync: this);
  String _competition = 'All Competitions';

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(
        title: const Text('Statistics'),
        bottom: TabBar(
          controller: _tabs,
          tabs: const [
            Tab(text: 'Team'),
            Tab(text: 'Player'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabs,
        children: [
          _TeamStats(
            competition: _competition,
            onCompetitionChanged: (v) => setState(() => _competition = v),
          ),
          const Center(child: Text('Player statistics coming soon')),
        ],
      ),
    );
  }
}

class _TeamStats extends StatelessWidget {
  const _TeamStats({
    required this.competition,
    required this.onCompetitionChanged,
  });

  final String competition;
  final ValueChanged<String> onCompetitionChanged;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        DropdownButtonFormField<String>(
          initialValue: competition,
          items: const [
            DropdownMenuItem(value: 'All Competitions', child: Text('All Competitions')),
            DropdownMenuItem(value: 'League', child: Text('League')),
            DropdownMenuItem(value: 'Cup', child: Text('Cup')),
          ],
          onChanged: (v) {
            if (v != null) onCompetitionChanged(v);
          },
          decoration: const InputDecoration(labelText: 'Competition'),
        ),
        const SizedBox(height: 16),
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
        const SizedBox(height: 24),
        const SectionHeader(title: 'Goals'),
        _GoalBar(label: 'Total goals', value: 36, max: 40, color: const Color(0xFF3B82F6)),
        const SizedBox(height: 12),
        _GoalBar(label: 'Goals conceded', value: 18, max: 40, color: const Color(0xFF22C55E)),
        const SizedBox(height: 24),
        SectionHeader(
          title: 'Top scorers',
          actionLabel: 'See all',
          onAction: () {},
        ),
        Card(
          child: Column(
            children: const [
              ListTile(
                leading: AvatarCircle(label: 'John Smith'),
                title: Text('John Smith'),
                trailing: Text('12', style: TextStyle(fontWeight: FontWeight.w700)),
              ),
              Divider(height: 1),
              ListTile(
                leading: AvatarCircle(label: 'Marco Rossi'),
                title: Text('Marco Rossi'),
                trailing: Text('8', style: TextStyle(fontWeight: FontWeight.w700)),
              ),
              Divider(height: 1),
              ListTile(
                leading: AvatarCircle(label: 'Luka Petrov'),
                title: Text('Luka Petrov'),
                trailing: Text('5', style: TextStyle(fontWeight: FontWeight.w700)),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _GoalBar extends StatelessWidget {
  const _GoalBar({
    required this.label,
    required this.value,
    required this.max,
    required this.color,
  });

  final String label;
  final int value;
  final int max;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(child: Text(label)),
            Text('$value', style: const TextStyle(fontWeight: FontWeight.w700)),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: value / max,
            minHeight: 10,
            color: color,
            backgroundColor: color.withValues(alpha: 0.15),
          ),
        ),
      ],
    );
  }
}
