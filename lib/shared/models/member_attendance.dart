import 'event_attendance.dart';

/// `GET /api/v1/me/children/{memberId}/attendance`.
///
/// Only marked sessions are included. A guardian may read their own child;
/// the club roster report stays staff-only.
class MemberAttendance {
  const MemberAttendance({
    required this.memberId,
    required this.clubId,
    required this.present,
    required this.late,
    required this.excused,
    required this.absent,
    required this.entries,
    this.fromUtc,
    this.toUtc,
    this.attendanceRate,
  });

  final String memberId;
  final String clubId;
  final DateTime? fromUtc;
  final DateTime? toUtc;
  final int present;
  final int late;
  final int excused;
  final int absent;
  final double? attendanceRate;
  final List<MemberAttendanceEntry> entries;

  factory MemberAttendance.fromJson(Map<String, dynamic> json) {
    final raw = json['entries'];
    final entries = <MemberAttendanceEntry>[];
    if (raw is List) {
      for (final item in raw) {
        if (item is Map) {
          entries.add(
            MemberAttendanceEntry.fromJson(Map<String, dynamic>.from(item)),
          );
        }
      }
    }
    return MemberAttendance(
      memberId: json['memberId']?.toString() ?? '',
      clubId: json['clubId']?.toString() ?? '',
      fromUtc: _date(json['fromUtc']),
      toUtc: _date(json['toUtc']),
      present: _int(json['present']),
      late: _int(json['late']),
      excused: _int(json['excused']),
      absent: _int(json['absent']),
      attendanceRate: _double(json['attendanceRate']),
      entries: entries,
    );
  }
}

class MemberAttendanceEntry {
  const MemberAttendanceEntry({
    required this.occurrenceId,
    required this.title,
    required this.type,
    required this.startsAt,
    required this.status,
    this.scopeName,
    this.note,
  });

  final String occurrenceId;
  final String title;
  final EventType type;
  final DateTime startsAt;
  final AttendanceStatus status;
  final String? scopeName;
  final String? note;

  factory MemberAttendanceEntry.fromJson(Map<String, dynamic> json) {
    final note = json['note'] as String?;
    final scope = json['scopeName'] as String?;
    return MemberAttendanceEntry(
      occurrenceId: json['occurrenceId']?.toString() ?? '',
      title: json['title'] as String? ?? '',
      type: parseEventType(json['type'] as String?),
      startsAt:
          DateTime.tryParse(json['startsAtUtc'] as String? ?? '')?.toLocal() ??
          DateTime.now(),
      status: parseAttendanceStatus(json['status'] as String?),
      scopeName: scope == null || scope.trim().isEmpty ? null : scope.trim(),
      note: note == null || note.trim().isEmpty ? null : note.trim(),
    );
  }
}

int _int(Object? value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '') ?? 0;
}

double? _double(Object? value) {
  if (value == null) return null;
  if (value is num) return value.toDouble();
  return double.tryParse(value.toString());
}

DateTime? _date(Object? value) {
  if (value is! String || value.isEmpty) return null;
  return DateTime.tryParse(value)?.toLocal();
}
