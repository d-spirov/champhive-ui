import '../../l10n/app_localizations.dart';
import '../models/event_attendance.dart';

String eventTypeLabel(AppLocalizations l10n, EventType type) {
  return switch (type) {
    EventType.training => l10n.eventTypeTraining,
    EventType.match => l10n.eventTypeMatch,
    EventType.tournament => l10n.eventTypeTournament,
    EventType.meeting => l10n.eventTypeClubEvent,
    EventType.other => l10n.eventTypeEvent,
  };
}

String occurrenceStatusLabel(AppLocalizations l10n, String? status) {
  switch ((status ?? '').toLowerCase()) {
    case 'canceled':
    case 'cancelled':
      return l10n.canceled;
    case 'moved':
      return l10n.statusMoved;
    case 'completed':
      return l10n.statusCompleted;
    case 'scheduled':
      return l10n.statusScheduled;
    default:
      if (status == null || status.isEmpty) return l10n.statusScheduled;
      return status[0].toUpperCase() + status.substring(1).toLowerCase();
  }
}

String scopeKindLabel(AppLocalizations l10n, String? kind) {
  switch ((kind ?? '').toLowerCase()) {
    case 'team':
      return l10n.team;
    case 'club':
      return l10n.club;
    case 'section':
      return l10n.section;
    default:
      return l10n.scope;
  }
}

String attendanceStatusLabel(AppLocalizations l10n, AttendanceStatus status) {
  return switch (status) {
    AttendanceStatus.notMarked => l10n.statusUnmarked,
    AttendanceStatus.present => l10n.statusPresent,
    AttendanceStatus.absent => l10n.statusAbsent,
    AttendanceStatus.late => l10n.statusLate,
    AttendanceStatus.excused => l10n.statusExcused,
  };
}

String attendanceLockStatusLabel(
  AppLocalizations l10n,
  AttendanceSession session,
) {
  if (session.isCanceled) return l10n.attendanceCanceledClosed;
  if (session.canMark) return l10n.attendanceOpen;
  return l10n.attendanceLockedShort;
}
