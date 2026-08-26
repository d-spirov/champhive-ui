import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../l10n/app_localizations.dart';
import '../../../shared/l10n/label_l10n.dart';
import '../../../shared/models/event_attendance.dart';
import '../../../shared/theme/app_theme.dart';
import '../../clubs/providers/sport_theme_provider.dart';

export '../../../shared/l10n/label_l10n.dart'
    show
        attendanceStatusLabel,
        eventTypeLabel,
        attendanceLockStatusLabel,
        occurrenceStatusLabel;


Color clubEventTypeColor(EventType type) {
  switch (type) {
    case EventType.training:
      return AppColors.training;
    case EventType.meeting:
      return AppColors.meeting;
    case EventType.match:
    case EventType.tournament:
      return AppColors.match;
    case EventType.other:
      return AppColors.lightMuted;
  }
}

IconData clubEventTypeIcon(EventType type, {IconData? sportIcon}) {
  switch (type) {
    case EventType.training:
      return sportIcon ?? Icons.sports_outlined;
    case EventType.meeting:
      return Icons.groups_rounded;
    case EventType.match:
    case EventType.tournament:
      return Icons.emoji_events_rounded;
    case EventType.other:
      return Icons.event_rounded;
  }
}

Color attendanceStatusColor(AttendanceStatus status) {
  switch (status) {
    case AttendanceStatus.present:
      return AppColors.present;
    case AttendanceStatus.late:
      return AppColors.late;
    case AttendanceStatus.absent:
      return AppColors.absent;
    case AttendanceStatus.excused:
      return AppColors.excused;
    case AttendanceStatus.notMarked:
      return const Color(0xFFCBD5E1);
  }
}

IconData attendanceStatusIcon(AttendanceStatus status) {
  switch (status) {
    case AttendanceStatus.present:
      return Icons.check_rounded;
    case AttendanceStatus.late:
      return Icons.schedule_rounded;
    case AttendanceStatus.absent:
      return Icons.close_rounded;
    case AttendanceStatus.excused:
      return Icons.event_busy_rounded;
    case AttendanceStatus.notMarked:
      return Icons.help_outline_rounded;
  }
}

AttendanceStatus nextAttendanceStatus(AttendanceStatus current) {
  switch (current) {
    case AttendanceStatus.notMarked:
      return AttendanceStatus.present;
    case AttendanceStatus.present:
      return AttendanceStatus.late;
    case AttendanceStatus.late:
      return AttendanceStatus.absent;
    case AttendanceStatus.absent:
      return AttendanceStatus.excused;
    case AttendanceStatus.excused:
      return AttendanceStatus.notMarked;
  }
}

bool statusNeedsNote(AttendanceStatus status) {
  return status == AttendanceStatus.absent ||
      status == AttendanceStatus.late ||
      status == AttendanceStatus.excused;
}

/// New API only has an optional free-text note — never a required reason enum.
bool statusOffersNote(AttendanceStatus status) => statusNeedsNote(status);

String formatEventTimeRange(DateTime start, DateTime? end) {
  final a = DateFormat.jm().format(start);
  if (end == null) return a;
  return '$a – ${DateFormat.jm().format(end)}';
}

String formatEventDate(DateTime dt) {
  return DateFormat('EEE, d MMM').format(dt);
}

class ClubEventListTile extends ConsumerWidget {
  const ClubEventListTile({
    super.key,
    required this.event,
    this.onTap,
  });

  final ClubEvent event;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final color = clubEventTypeColor(event.type);
    final sportIcon = ref.watch(sportThemeProvider).icon;
    final subtitle = [
      formatEventTimeRange(event.startAt, event.endAt),
      if (event.location.display != l10n.tbd) event.location.display,
    ].join(' · ');

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(
                clubEventTypeIcon(event.type, sportIcon: sportIcon),
                color: color,
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.title.isNotEmpty
                        ? event.title
                        : eventTypeLabel(l10n, event.type),
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withValues(alpha: 0.6),
                        ),
                  ),
                ],
              ),
            ),
            if (onTap != null)
              Icon(
                Icons.chevron_right_rounded,
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withValues(alpha: 0.35),
              ),
          ],
        ),
      ),
    );
  }
}

class AttendanceCountChip extends StatelessWidget {
  const AttendanceCountChip({
    super.key,
    required this.status,
    required this.count,
  });

  final AttendanceStatus status;
  final int count;

  @override
  Widget build(BuildContext context) {
    final color = attendanceStatusColor(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(attendanceStatusIcon(status), size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            '$count',
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class AttendanceStatusBadge extends StatelessWidget {
  const AttendanceStatusBadge({
    super.key,
    required this.status,
    this.size = 36,
  });

  final AttendanceStatus status;
  final double size;

  @override
  Widget build(BuildContext context) {
    final color = attendanceStatusColor(status);
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color.withValues(alpha: status == AttendanceStatus.notMarked ? 0.2 : 1),
        shape: BoxShape.circle,
      ),
      child: Icon(
        attendanceStatusIcon(status),
        color: status == AttendanceStatus.notMarked
            ? const Color(0xFF64748B)
            : Colors.white,
        size: size * 0.55,
      ),
    );
  }
}
