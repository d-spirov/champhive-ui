import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../attendance/widgets/attendance_ui.dart';
import '../../events/providers/events_provider.dart';
import '../../../shared/models/event_attendance.dart';
import '../../../shared/theme/app_theme.dart';
import '../../../shared/utils/api_error_message.dart';

void popOrGoHome(BuildContext context) {
  if (context.canPop()) {
    context.pop();
  } else {
    context.go('/home');
  }
}

/// Schedule occurrence detail (ClubPlatform).
class EventDetailScreen extends ConsumerWidget {
  const EventDetailScreen({super.key, required this.eventId});

  /// Opaque occurrence id.
  final String eventId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(eventDetailProvider(eventId));
    final rosterAsync = ref.watch(attendanceSessionProvider(eventId));

    return async.when(
      loading: () => Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            onPressed: () => popOrGoHome(context),
          ),
          title: const Text('Session'),
        ),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            onPressed: () => popOrGoHome(context),
          ),
          title: const Text('Session'),
        ),
        body: _ErrorBody(
          message: apiErrorMessage(e, fallback: 'Could not load session'),
          onRetry: () => ref.invalidate(eventDetailProvider(eventId)),
        ),
      ),
      data: (occurrence) => Scaffold(
        body: _OccurrenceBody(
          occurrence: occurrence,
          roster: rosterAsync.valueOrNull,
          onRetryRoster: () =>
              ref.invalidate(attendanceSessionProvider(eventId)),
        ),
      ),
    );
  }
}

class _OccurrenceBody extends StatelessWidget {
  const _OccurrenceBody({
    required this.occurrence,
    required this.roster,
    required this.onRetryRoster,
  });

  final ClubEvent occurrence;
  final AttendanceSession? roster;
  final VoidCallback onRetryRoster;

  @override
  Widget build(BuildContext context) {
    final color = clubEventTypeColor(occurrence.type);
    final scope = occurrence.scopeName ??
        (occurrence.teams.isEmpty ? null : occurrence.teams.join(', '));
    final canceled = (occurrence.status ?? '').toLowerCase() == 'canceled';
    final snapshot = roster;
    final open = snapshot?.canMark ?? false;
    final lockLabel = snapshot?.lockStatusLabel ??
        (canceled ? 'Canceled' : 'Loading attendance status…');
    final lockAt = snapshot?.attendanceLockAtUtc;

    return CustomScrollView(
      slivers: [
        SliverAppBar(
          expandedHeight: 200,
          pinned: true,
          automaticallyImplyLeading: false,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
            style: IconButton.styleFrom(
              backgroundColor: Colors.black.withValues(alpha: 0.4),
            ),
            onPressed: () => popOrGoHome(context),
          ),
          flexibleSpace: FlexibleSpaceBar(
            background: Stack(
              fit: StackFit.expand,
              children: [
                Image.asset(
                  'assets/images/basketball_court.jpg',
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => Container(color: color),
                ),
                DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withValues(alpha: 0.15),
                        Colors.black.withValues(alpha: 0.65),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  occurrence.title.isNotEmpty
                      ? occurrence.title
                      : occurrence.type.label,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    Chip(
                      label: Text(occurrence.type.label),
                      visualDensity: VisualDensity.compact,
                    ),
                    if (occurrence.status != null)
                      Chip(
                        label: Text(occurrence.status!),
                        visualDensity: VisualDensity.compact,
                      ),
                    Chip(
                      avatar: Icon(
                        open ? Icons.lock_open_rounded : Icons.lock_rounded,
                        size: 16,
                        color: open ? AppColors.present : AppColors.absent,
                      ),
                      label: Text(lockLabel),
                      visualDensity: VisualDensity.compact,
                    ),
                  ],
                ),
                if (scope != null) ...[
                  const SizedBox(height: 10),
                  Text(
                    scope,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                  ),
                ],
                const SizedBox(height: 20),
                _MetaRow(
                  icon: Icons.calendar_today_outlined,
                  label: formatEventDate(occurrence.startAt),
                ),
                _MetaRow(
                  icon: Icons.schedule_outlined,
                  label: formatEventTimeRange(
                    occurrence.startAt,
                    occurrence.endAt,
                  ),
                ),
                _MetaRow(
                  icon: Icons.place_outlined,
                  label: occurrence.location.display,
                ),
                if (occurrence.timezone != null &&
                    occurrence.timezone!.isNotEmpty)
                  _MetaRow(
                    icon: Icons.public_outlined,
                    label: occurrence.timezone!,
                  ),
                if (lockAt != null)
                  _MetaRow(
                    icon: Icons.timer_outlined,
                    label:
                        'Marks accepted until ${formatEventDate(lockAt)} · ${formatEventTimeRange(lockAt, null)}',
                  ),
                if (occurrence.description != null &&
                    occurrence.description!.trim().isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Text(
                    'Notes',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    occurrence.description!,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withValues(alpha: 0.7),
                        ),
                  ),
                ],
                const SizedBox(height: 28),
                if (!canceled && open)
                  _ActionTile(
                    icon: Icons.how_to_reg_rounded,
                    title: 'Take attendance',
                    subtitle: snapshot == null
                        ? 'Load roster and mark members'
                        : '${snapshot.participants.length} on roster · tap to mark',
                    color: AppColors.training,
                    onTap: () => context.push(
                      '/occurrences/${occurrence.id}/attendance',
                    ),
                  )
                else if (!canceled)
                  _ActionTile(
                    icon: Icons.lock_rounded,
                    title: 'Attendance locked',
                    subtitle:
                        'View the report, or ask an admin to reopen temporarily',
                    color: AppColors.meeting,
                    onTap: () => context.push(
                      '/occurrences/${occurrence.id}/attendance/report',
                    ),
                  ),
                const SizedBox(height: 12),
                _ActionTile(
                  icon: Icons.assignment_outlined,
                  title: 'Attendance report',
                  subtitle: 'Roster with present / late / absent / excused',
                  color: AppColors.match,
                  onTap: () => context.push(
                    '/occurrences/${occurrence.id}/attendance/report',
                  ),
                ),
                const SizedBox(height: 12),
                _ActionTile(
                  icon: Icons.history_rounded,
                  title: 'Attendance history',
                  subtitle: 'Past and open sessions for this club',
                  color: AppColors.meeting,
                  onTap: () => context.push('/attendance/history'),
                ),
                if (snapshot == null) ...[
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: onRetryRoster,
                    child: const Text('Refresh attendance status'),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _MetaRow extends StatelessWidget {
  const _MetaRow({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 10),
          Expanded(
            child: Text(label, style: Theme.of(context).textTheme.bodyLarge),
          ),
        ],
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color),
        ),
        title: Text(title, style: Theme.of(context).textTheme.titleMedium),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right_rounded),
        onTap: onTap,
      ),
    );
  }
}

class _ErrorBody extends StatelessWidget {
  const _ErrorBody({required this.message, required this.onRetry});

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
