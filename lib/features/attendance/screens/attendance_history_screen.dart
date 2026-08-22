import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../l10n/app_localizations.dart';
import '../../clubs/providers/sport_theme_provider.dart';
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
    final l10n = AppLocalizations.of(context)!;
    final pastAsync = ref.watch(pastClubEventsProvider);
    final openAsync = ref.watch(openAttendanceOccurrencesProvider);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/home');
            }
          },
        ),
        title: Text(l10n.attendance),
        bottom: TabBar(
          controller: _tabs,
          labelColor: Theme.of(context).colorScheme.primary,
          unselectedLabelColor:
              Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.55),
          indicatorColor: Theme.of(context).colorScheme.primary,
          tabs: [
            Tab(text: l10n.openWindow),
            Tab(text: l10n.past),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabs,
        children: [
          openAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => _Error(
              message: apiErrorMessage(e, fallback: l10n.couldNotLoadSchedule),
              onRetry: () =>
                  ref.invalidate(openAttendanceOccurrencesProvider),
            ),
            data: (events) {
              if (events.isEmpty) {
                return Center(
                  child: Text(l10n.noSessionsInWindow),
                );
              }
              return RefreshIndicator(
                onRefresh: () async {
                  ref.invalidate(openAttendanceOccurrencesProvider);
                  await ref.read(openAttendanceOccurrencesProvider.future);
                },
                child: ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: events.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final event = events[index];
                    return Card(
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: clubEventTypeColor(event.type)
                              .withValues(alpha: 0.15),
                          child: Icon(
                            clubEventTypeIcon(
                              event.type,
                              sportIcon: ref.watch(sportThemeProvider).icon,
                            ),
                            color: clubEventTypeColor(event.type),
                          ),
                        ),
                        title: Text(
                          event.title.isNotEmpty
                              ? event.title
                              : eventTypeLabel(l10n, event.type),
                        ),
                        subtitle: Text(
                          '${formatEventDate(event.startAt)} · ${formatEventTimeRange(event.startAt, event.endAt)}'
                          '${event.scopeName != null ? ' · ${event.scopeName}' : ''}',
                        ),
                        trailing: const Icon(Icons.chevron_right_rounded),
                        onTap: () =>
                            context.push('/occurrences/${event.id}/attendance'),
                      ),
                    );
                  },
                ),
              );
            },
          ),
          pastAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => _Error(
              message: apiErrorMessage(e, fallback: l10n.couldNotLoadHistory),
              onRetry: () => ref.invalidate(pastClubEventsProvider),
            ),
            data: (events) {
              if (events.isEmpty) {
                return Center(child: Text(l10n.noPastSessions));
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
                              ListTile(
                                title: Text(
                                  entry.value[i].title.isNotEmpty
                                      ? entry.value[i].title
                                      : eventTypeLabel(l10n, entry.value[i].type),
                                ),
                                subtitle: Text(
                                  '${formatEventDate(entry.value[i].startAt)} · ${formatEventTimeRange(entry.value[i].startAt, entry.value[i].endAt)}',
                                ),
                                trailing:
                                    const Icon(Icons.chevron_right_rounded),
                                onTap: () => context.push(
                                  '/occurrences/${entry.value[i].id}/attendance/report',
                                ),
                              ),
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
        ],
      ),
    );
  }
}

class _Error extends StatelessWidget {
  const _Error({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            FilledButton(onPressed: onRetry, child: Text(l10n.retry)),
          ],
        ),
      ),
    );
  }
}
