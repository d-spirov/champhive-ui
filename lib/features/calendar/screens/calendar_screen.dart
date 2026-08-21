import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../auth/providers/auth_provider.dart';
import '../../events/providers/events_provider.dart';
import '../../attendance/widgets/attendance_ui.dart';
import '../../../shared/demo/demo_data.dart';
import '../../../shared/utils/api_error_message.dart';
import '../../../shared/widgets/ui_bits.dart';

class CalendarScreen extends ConsumerStatefulWidget {
  const CalendarScreen({super.key});

  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen> {
  late DateTime _selected;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selected = DateTime(now.year, now.month, now.day);
  }

  @override
  Widget build(BuildContext context) {
    final isDemo = ref.watch(authNotifierProvider).user?.id == 'demo';
    final eventsAsync = ref.watch(clubEventsProvider);

    final days = List.generate(14, (i) {
      final base =
          DateTime.now().subtract(Duration(days: DateTime.now().weekday - 1));
      return DateTime(base.year, base.month, base.day).add(Duration(days: i));
    });

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.menu_rounded),
          onPressed: () => Scaffold.of(context).openDrawer(),
        ),
        title: Text(_monthLabel(_selected)),
        actions: [
          IconButton(
            onPressed: () => context.push('/attendance/history'),
            icon: const Icon(Icons.how_to_reg_outlined),
            tooltip: 'Attendance',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          final isDemo = ref.read(authNotifierProvider).user?.id == 'demo';
          if (isDemo) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Sign in to create schedule items')),
            );
            return;
          }
          context.push('/schedule/create', extra: _selected);
        },
        child: const Icon(Icons.add_rounded),
      ),
      body: Column(
        children: [
          SizedBox(
            height: 84,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              itemCount: days.length,
              separatorBuilder: (context, index) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final day = days[index];
                final selected = day.year == _selected.year &&
                    day.month == _selected.month &&
                    day.day == _selected.day;
                return InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () => setState(() => _selected = day),
                  child: Container(
                    width: 56,
                    decoration: BoxDecoration(
                      color: selected
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).cardTheme.color,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: selected
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).dividerColor,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _weekday(day.weekday),
                          style: TextStyle(
                            fontSize: 12,
                            color: selected
                                ? Theme.of(context).colorScheme.onPrimary
                                : Theme.of(context)
                                    .colorScheme
                                    .onSurface
                                    .withValues(alpha: 0.6),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${day.day}',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                            color: selected
                                ? Theme.of(context).colorScheme.onPrimary
                                : Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Expanded(
            child: isDemo
                ? _DemoAgenda(selected: _selected)
                : eventsAsync.when(
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
                                fallback: 'Could not load events',
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 12),
                            FilledButton(
                              onPressed: () =>
                                  ref.invalidate(clubEventsProvider),
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      ),
                    ),
                    data: (events) {
                      final dayEvents = events.where((e) {
                        return e.startAt.year == _selected.year &&
                            e.startAt.month == _selected.month &&
                            e.startAt.day == _selected.day;
                      }).toList();
                      return RefreshIndicator(
                        onRefresh: () async {
                          ref.invalidate(clubEventsProvider);
                          await ref.read(clubEventsProvider.future);
                        },
                        child: ListView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 88),
                          children: [
                            SectionHeader(title: _dayLabel(_selected)),
                            if (dayEvents.isEmpty)
                              const Card(
                                child: Padding(
                                  padding: EdgeInsets.all(20),
                                  child: Text(
                                    'No events on this day.',
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              )
                            else
                              Card(
                                child: Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(14, 8, 14, 8),
                                  child: Column(
                                    children: [
                                      for (final e in dayEvents)
                                        ClubEventListTile(
                                          event: e,
                                          onTap: () =>
                                              context.push('/occurrences/${e.id}'),
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  String _monthLabel(DateTime dt) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December',
    ];
    return '${months[dt.month - 1]} ${dt.year}';
  }

  String _weekday(int weekday) {
    const names = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return names[weekday - 1];
  }

  String _dayLabel(DateTime dt) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${_weekday(dt.weekday)}, ${dt.day} ${months[dt.month - 1]}';
  }
}

class _DemoAgenda extends StatelessWidget {
  const _DemoAgenda({required this.selected});

  final DateTime selected;

  @override
  Widget build(BuildContext context) {
    final dayEvents = DemoData.events.where((e) {
      return e.start.year == selected.year &&
          e.start.month == selected.month &&
          e.start.day == selected.day;
    }).toList();
    final shown = dayEvents.isEmpty ? DemoData.events : dayEvents;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 88),
      children: [
        SectionHeader(title: 'Demo schedule'),
        Card(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 6),
            child: Column(
              children: [
                for (final e in shown) EventListTile(event: e),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
