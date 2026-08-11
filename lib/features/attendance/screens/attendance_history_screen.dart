import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../events/providers/events_provider.dart';
import '../../../shared/models/event_attendance.dart';
import '../../../shared/utils/api_error_message.dart';
import '../widgets/attendance_ui.dart';

class AttendanceHistoryScreen extends ConsumerStatefulWidget {
  const AttendanceHistoryScreen({super.key});

  @override
  ConsumerState<AttendanceHistoryScreen> createState() =>
      _AttendanceHistoryScreenState();
}

class _AttendanceHistoryScreenState
    extends ConsumerState<AttendanceHistoryScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final eventsAsync = ref.watch(pastClubEventsProvider);
    final dashAsync = ref.watch(attendanceDashboardProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Attendance History'),
        bottom: TabBar(
          controller: _tabs,
          labelColor: Theme.of(context).colorScheme.primary,
          unselectedLabelColor:
              Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.55),
          indicatorColor: Theme.of(context).colorScheme.primary,
          tabs: const [
            Tab(text: 'By Date'),
            Tab(text: 'Hub'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabs,
        children: [
          eventsAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => _Error(
              message: apiErrorMessage(e, fallback: 'Could not load history'),
              onRetry: () => ref.invalidate(pastClubEventsProvider),
            ),
            data: (events) {
              if (events.isEmpty) {
                return const Center(child: Text('No past events yet.'));
              }
              final grouped = <String, List<ClubEvent>>{};
              final monthFmt = DateFormat('MMMM yyyy');
              for (final e in events) {
                final key = monthFmt.format(e.startAt);
                grouped.putIfAbsent(key, () => []).add(e);
              }
              return RefreshIndicator(
                onRefresh: () async {
                  ref.invalidate(pastClubEventsProvider);
                  await ref.read(pastClubEventsProvider.future);
                },
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                  children: [
                    for (final entry in grouped.entries) ...[
                      Padding(
                        padding: const EdgeInsets.only(top: 12, bottom: 8),
                        child: Text(
                          entry.key,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
                      Card(
                        child: Column(
                          children: [
                            for (var i = 0; i < entry.value.length; i++) ...[
                              if (i > 0) const Divider(height: 1),
                              _HistoryRow(event: entry.value[i]),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              );
            },
          ),
          dashAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => _Error(
              message: apiErrorMessage(e, fallback: 'Could not load dashboard'),
              onRetry: () => ref.invalidate(attendanceDashboardProvider),
            ),
            data: (cards) {
              if (cards.isEmpty) {
                return const Center(
                  child: Text('Nothing needs attendance action right now.'),
                );
              }
              return ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: cards.length,
                separatorBuilder: (_, _) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final card = cards[index];
                  return Card(
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor:
                            clubEventTypeColor(card.type).withValues(alpha: 0.15),
                        child: Icon(
                          clubEventTypeIcon(card.type),
                          color: clubEventTypeColor(card.type),
                        ),
                      ),
                      title: Text(card.title),
                      subtitle: Text(
                        '${formatEventDate(card.startAt)} · ${card.marked}/${card.total} marked',
                      ),
                      trailing: const Icon(Icons.chevron_right_rounded),
                      onTap: () =>
                          context.push('/events/${card.eventId}/attendance'),
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}

class _HistoryRow extends StatelessWidget {
  const _HistoryRow({required this.event});

  final ClubEvent event;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(event.title.isNotEmpty ? event.title : event.type.label),
      subtitle: Text(
        '${formatEventDate(event.startAt)} · ${formatEventTimeRange(event.startAt, event.endAt)}',
      ),
      trailing: const Icon(Icons.chevron_right_rounded),
      onTap: () => context.push('/events/${event.id}'),
    );
  }
}

class _Error extends StatelessWidget {
  const _Error({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            FilledButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }
}
