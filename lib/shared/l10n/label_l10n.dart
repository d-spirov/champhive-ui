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
