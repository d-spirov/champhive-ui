import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../l10n/app_localizations.dart';
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
    final l10n = AppLocalizations.of(context)!;
    final isDemo = ref.watch(authNotifierProvider).user?.id == 'demo';
    final eventsAsync = ref.watch(clubEventsProvider);

    final days = List.generate(14, (i) {
      final base = DateTime.now().subtract(
        Duration(days: DateTime.now().weekday - 1),
      );
      return DateTime(base.year, base.month, base.day).add(Duration(days: i));
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(DateFormat('MMMM yyyy').format(_selected)),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            onPressed: () => context.push('/attendance/history'),
            icon: const Icon(Icons.how_to_reg_outlined),
            tooltip: l10n.attendance,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          final isDemo = ref.read(authNotifierProvider).user?.id == 'demo';
          if (isDemo) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(l10n.signInToCreateSchedule)),
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
                final selected =
                    day.year == _selected.year &&
                    day.month == _selected.month &&
                    day.day == _selected.day;
                return InkWell(
                  borderRadius: BorderRadius.circular(28),
                  onTap: () => setState(() => _selected = day),
                  child: SizedBox(
                    width: 52,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          DateFormat('EEE').format(day).toUpperCase(),
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.4,
                            color: selected
                                ? Theme.of(context).colorScheme.primary
                                : Theme.of(context).colorScheme.onSurface
                                      .withValues(alpha: 0.55),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          width: 36,
                          height: 36,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: selected
                                ? Theme.of(context).colorScheme.primary
                                : Colors.transparent,
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            '${day.day}',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                              color: selected
                                  ? Theme.of(context).colorScheme.onPrimary
                                  : Theme.of(context).colorScheme.onSurface,
                            ),
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
                                fallback: l10n.couldNotLoadEvents,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 12),
                            FilledButton(
                              onPressed: () =>
                                  ref.invalidate(clubEventsProvider),
                              child: Text(l10n.retry),
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
                            SectionHeader(
                              title: DateFormat('EEE, d MMM').format(_selected),
                            ),
                            if (dayEvents.isEmpty)
                              Card(
                                child: Padding(
                                  padding: const EdgeInsets.all(20),
                                  child: Text(
                                    l10n.noEventsOnThisDay,
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              )
                            else
                              Card(
                                child: Padding(
                                  padding: const EdgeInsets.fromLTRB(
                                    14,
                                    8,
                                    14,
                                    8,
                                  ),
                                  child: Column(
                                    children: [
                                      for (final e in dayEvents)
                                        ClubEventListTile(
                                          event: e,
                                          onTap: () => context.push(
                                            '/occurrences/${e.id}',
                                          ),
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
}

class _DemoAgenda extends StatelessWidget {
  const _DemoAgenda({required this.selected});

  final DateTime selected;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final dayEvents = DemoData.events.where((e) {
      return e.start.year == selected.year &&
          e.start.month == selected.month &&
          e.start.day == selected.day;
    }).toList();
    final shown = dayEvents.isEmpty ? DemoData.events : dayEvents;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 88),
      children: [
        SectionHeader(title: l10n.demoSchedule),
        Card(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 6),
            child: Column(
              children: [for (final e in shown) EventListTile(event: e)],
            ),
          ),
        ),
      ],
    );
  }
}
