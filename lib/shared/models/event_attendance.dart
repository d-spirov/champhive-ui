import 'dart:math';

enum EventType { training, match, tournament, meeting, other }

enum AttendanceStatus { notMarked, present, absent, late, excused }

enum AbsenceReason {
  illness,
  injury,
  school,
  family,
  travel,
  work,
  other,
  unspecified,
}

enum AttendanceState { notOpen, open, finalized }

EventType parseEventType(String? raw) {
  switch ((raw ?? '').trim()) {
    case 'training':
    case 'TRAINING':
      return EventType.training;
    case 'match':
    case 'MATCH':
      return EventType.match;
    case 'tournament':
    case 'TOURNAMENT':
      return EventType.tournament;
    case 'clubEvent':
    case 'meeting':
    case 'MEETING':
      return EventType.meeting;
    default:
      return EventType.other;
  }
}

AttendanceStatus parseAttendanceStatus(String? raw) {
  switch ((raw ?? '').trim().toLowerCase()) {
    case 'present':
      return AttendanceStatus.present;
    case 'absent':
      return AttendanceStatus.absent;
    case 'late':
      return AttendanceStatus.late;
    case 'excused':
      return AttendanceStatus.excused;
    default:
      return AttendanceStatus.notMarked;
  }
}

AbsenceReason? parseAbsenceReason(String? raw) {
  if (raw == null || raw.isEmpty) return null;
  switch (raw.toUpperCase()) {
    case 'ILLNESS':
      return AbsenceReason.illness;
    case 'INJURY':
      return AbsenceReason.injury;
    case 'SCHOOL':
      return AbsenceReason.school;
    case 'FAMILY':
      return AbsenceReason.family;
    case 'TRAVEL':
      return AbsenceReason.travel;
    case 'WORK':
      return AbsenceReason.work;
    case 'OTHER':
      return AbsenceReason.other;
    case 'UNSPECIFIED':
      return AbsenceReason.unspecified;
    default:
      return AbsenceReason.other;
  }
}

AttendanceState parseAttendanceState({
  required bool attendanceOpen,
  String? occurrenceStatus,
}) {
  final status = (occurrenceStatus ?? '').toLowerCase();
  if (status == 'canceled') return AttendanceState.finalized;
  if (attendanceOpen) return AttendanceState.open;
  return AttendanceState.notOpen;
}

extension EventTypeX on EventType {
  String get apiValue => switch (this) {
        EventType.training => 'training',
        EventType.match => 'match',
        EventType.tournament => 'tournament',
        EventType.meeting => 'clubEvent',
        EventType.other => 'clubEvent',
      };

  String get label => switch (this) {
        EventType.training => 'Training',
        EventType.match => 'Match',
        EventType.tournament => 'Tournament',
        EventType.meeting => 'Club Event',
        EventType.other => 'Event',
      };
}

extension AttendanceStatusX on AttendanceStatus {
  /// Wire values for attendance batch: present|late|excused|absent.
  String get apiValue => switch (this) {
        AttendanceStatus.notMarked => 'absent', // should not be sent
        AttendanceStatus.present => 'present',
        AttendanceStatus.absent => 'absent',
        AttendanceStatus.late => 'late',
        AttendanceStatus.excused => 'excused',
      };

  String get label => switch (this) {
        AttendanceStatus.notMarked => 'Unmarked',
        AttendanceStatus.present => 'Present',
        AttendanceStatus.absent => 'Absent',
        AttendanceStatus.late => 'Late',
        AttendanceStatus.excused => 'Excused',
      };

  bool get isMarkable => this != AttendanceStatus.notMarked;
}

extension AbsenceReasonX on AbsenceReason {
  String get apiValue => name.toUpperCase();

  String get label => switch (this) {
        AbsenceReason.illness => 'Illness',
        AbsenceReason.injury => 'Injured',
        AbsenceReason.school => 'School',
        AbsenceReason.family => 'Family',
        AbsenceReason.travel => 'Travel',
        AbsenceReason.work => 'Work',
        AbsenceReason.other => 'Other',
        AbsenceReason.unspecified => 'Unspecified',
      };
}

class EventLocation {
  const EventLocation({this.name, this.address, this.meetingPoint});

  final String? name;
  final String? address;
  final String? meetingPoint;

  factory EventLocation.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const EventLocation();
    return EventLocation(
      name: json['name'] as String?,
      address: json['address'] as String?,
      meetingPoint: json['meetingPoint'] as String?,
    );
  }

  factory EventLocation.fromString(String? location) {
    if (location == null || location.isEmpty) return const EventLocation();
    return EventLocation(name: location);
  }

  String get display {
    if (name != null && name!.isNotEmpty) return name!;
    if (address != null && address!.isNotEmpty) return address!;
    if (meetingPoint != null && meetingPoint!.isNotEmpty) return meetingPoint!;
    return 'TBD';
  }
}

/// Calendar / detail model mapped from [ScheduleOccurrenceResponse].
class ClubEvent {
  const ClubEvent({
    required this.id,
    required this.clubId,
    required this.type,
    required this.title,
    required this.startAt,
    this.endAt,
    this.description,
    this.timezone,
    this.allDay = false,
    this.isPast = false,
    this.status,
    this.teams = const [],
    this.location = const EventLocation(),
    this.opponentName,
    this.competitionName,
    this.seriesId,
    this.scopeName,
    this.clubName,
  });

  final String id;
  final String clubId;
  final EventType type;
  final String title;
  final DateTime startAt;
  final DateTime? endAt;
  final String? description;
  final String? timezone;
  final bool allDay;
  final bool isPast;
  final String? status;
  final List<String> teams;
  final EventLocation location;
  final String? opponentName;
  final String? competitionName;
  final String? seriesId;
  final String? scopeName;
  final String? clubName;

  /// Occurrence id (opaque).
  String get occurrenceId => id;

  factory ClubEvent.fromOccurrenceJson(Map<String, dynamic> json) {
    final starts = DateTime.tryParse(json['startsAtUtc'] as String? ?? '')
            ?.toLocal() ??
        DateTime.now();
    final ends =
        DateTime.tryParse(json['endsAtUtc'] as String? ?? '')?.toLocal();
    final scopeName = json['scopeName'] as String?;
    final status = json['status'] as String?;
    return ClubEvent(
      id: json['occurrenceId']?.toString() ?? json['id']?.toString() ?? '',
      clubId: json['clubId']?.toString() ?? '',
      seriesId: json['seriesId']?.toString(),
      type: parseEventType(json['type'] as String?),
      title: json['title'] as String? ?? '',
      description: json['purpose'] as String? ?? json['note'] as String?,
      startAt: starts,
      endAt: ends,
      timezone: json['timeZone'] as String? ?? json['timezone'] as String?,
      isPast: starts.isBefore(DateTime.now()),
      status: status,
      teams: scopeName != null && scopeName.isNotEmpty
          ? [scopeName]
          : const [],
      scopeName: scopeName,
      clubName: json['clubName'] as String?,
      location: EventLocation.fromString(json['location'] as String?),
    );
  }

  factory ClubEvent.fromJson(Map<String, dynamic> json) {
    if (json.containsKey('occurrenceId') || json.containsKey('startsAtUtc')) {
      return ClubEvent.fromOccurrenceJson(json);
    }
    final teamsRaw = json['teams'];
    final teamNames = <String>[];
    if (teamsRaw is List) {
      for (final t in teamsRaw) {
        if (t is Map && t['name'] != null) teamNames.add(t['name'].toString());
      }
    }
    return ClubEvent(
      id: json['id']?.toString() ?? '',
      clubId: json['clubId']?.toString() ?? '',
      type: parseEventType(json['type'] as String?),
      title: json['title'] as String? ?? '',
      description: json['description'] as String?,
      startAt: DateTime.tryParse(json['startAt'] as String? ?? '')?.toLocal() ??
          DateTime.now(),
      endAt: DateTime.tryParse(json['endAt'] as String? ?? '')?.toLocal(),
      timezone: json['timezone'] as String? ?? json['timeZone'] as String?,
      allDay: json['allDay'] as bool? ?? false,
      isPast: json['isPast'] as bool? ?? false,
      status: json['status'] as String?,
      teams: teamNames,
      location: EventLocation.fromJson(
        json['location'] is Map
            ? Map<String, dynamic>.from(json['location'] as Map)
            : null,
      ),
      opponentName: json['opponentName'] as String?,
      competitionName: json['competitionName'] as String?,
    );
  }
}

class AttendanceSummaryCounts {
  const AttendanceSummaryCounts({
    this.total = 0,
    this.present = 0,
    this.absent = 0,
    this.late = 0,
    this.excused = 0,
    this.notMarked = 0,
  });

  final int total;
  final int present;
  final int absent;
  final int late;
  final int excused;
  final int notMarked;

  factory AttendanceSummaryCounts.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const AttendanceSummaryCounts();
    return AttendanceSummaryCounts(
      total: (json['total'] as num?)?.toInt() ?? 0,
      present: (json['present'] as num?)?.toInt() ?? 0,
      absent: (json['absent'] as num?)?.toInt() ?? 0,
      late: (json['late'] as num?)?.toInt() ?? 0,
      excused: (json['excused'] as num?)?.toInt() ?? 0,
      notMarked: (json['notMarked'] as num?)?.toInt() ??
          (json['unmarked'] as num?)?.toInt() ??
          0,
    );
  }

  factory AttendanceSummaryCounts.fromParticipants(
    List<AttendanceParticipant> participants,
  ) {
    var present = 0, absent = 0, late = 0, excused = 0, notMarked = 0;
    for (final p in participants) {
      switch (p.status) {
        case AttendanceStatus.present:
          present++;
        case AttendanceStatus.absent:
          absent++;
        case AttendanceStatus.late:
          late++;
        case AttendanceStatus.excused:
          excused++;
        case AttendanceStatus.notMarked:
          notMarked++;
      }
    }
    return AttendanceSummaryCounts(
      total: participants.length,
      present: present,
      absent: absent,
      late: late,
      excused: excused,
      notMarked: notMarked,
    );
  }
}

class AttendanceParticipant {
  const AttendanceParticipant({
    required this.id,
    required this.playerId,
    required this.displayName,
    required this.version,
    required this.status,
    this.teamName,
    this.hasPhoto = false,
    this.reason,
    this.note,
    this.recordedAtClientUtc,
    this.rsvpStatus,
  });

  /// Local draft key — same as [playerId] / memberId for the new API.
  final String id;
  final String playerId;
  final String displayName;
  final int version;
  final AttendanceStatus status;
  final String? teamName;
  final bool hasPhoto;
  final AbsenceReason? reason;
  final String? note;
  final DateTime? recordedAtClientUtc;
  final String? rsvpStatus;

  String get memberId => playerId;

  factory AttendanceParticipant.fromRosterEntry(
    Map<String, dynamic> json, {
    String? teamName,
  }) {
    final first = json['firstName'] as String? ?? '';
    final last = json['lastName'] as String? ?? '';
    final memberId = json['memberId']?.toString() ?? '';
    return AttendanceParticipant(
      id: memberId,
      playerId: memberId,
      displayName: '$first $last'.trim().isEmpty ? 'Member' : '$first $last'.trim(),
      version: 0,
      status: parseAttendanceStatus(json['attendanceStatus'] as String?),
      note: json['attendanceNote'] as String?,
      teamName: teamName,
      recordedAtClientUtc: DateTime.tryParse(
        json['recordedAtClientUtc'] as String? ?? '',
      )?.toUtc(),
      rsvpStatus: json['rsvpStatus'] as String?,
    );
  }

  factory AttendanceParticipant.fromOccurrenceEntry(
    Map<String, dynamic> json, {
    String? teamName,
  }) {
    final first = json['firstName'] as String? ?? '';
    final last = json['lastName'] as String? ?? '';
    final memberId = json['memberId']?.toString() ?? '';
    return AttendanceParticipant(
      id: memberId,
      playerId: memberId,
      displayName: '$first $last'.trim().isEmpty ? 'Member' : '$first $last'.trim(),
      version: 0,
      status: parseAttendanceStatus(json['status'] as String?),
      note: json['note'] as String?,
      teamName: teamName,
      recordedAtClientUtc: DateTime.tryParse(
        json['recordedAtClientUtc'] as String? ?? '',
      )?.toUtc(),
      rsvpStatus: json['rsvpStatus'] as String?,
    );
  }

  factory AttendanceParticipant.fromJson(Map<String, dynamic> json) {
    if (json.containsKey('memberId')) {
      return AttendanceParticipant.fromRosterEntry(json);
    }
    final player = json['player'] is Map
        ? Map<String, dynamic>.from(json['player'] as Map)
        : const <String, dynamic>{};
    final team = json['team'] is Map
        ? Map<String, dynamic>.from(json['team'] as Map)
        : null;
    final attendance = json['attendance'] is Map
        ? Map<String, dynamic>.from(json['attendance'] as Map)
        : null;
    return AttendanceParticipant(
      id: json['id']?.toString() ?? player['id']?.toString() ?? '',
      playerId: player['id']?.toString() ?? '',
      displayName: player['displayName'] as String? ?? 'Player',
      hasPhoto: player['hasPhoto'] as bool? ?? false,
      teamName: team?['name'] as String?,
      version: (json['version'] as num?)?.toInt() ?? 0,
      status: parseAttendanceStatus(attendance?['status'] as String?),
      reason: parseAbsenceReason(attendance?['reason'] as String?),
      note: attendance?['note'] as String?,
    );
  }

  AttendanceParticipant copyWith({
    AttendanceStatus? status,
    AbsenceReason? reason,
    String? note,
    int? version,
    DateTime? recordedAtClientUtc,
    bool clearReason = false,
    bool clearNote = false,
  }) {
    return AttendanceParticipant(
      id: id,
      playerId: playerId,
      displayName: displayName,
      version: version ?? this.version,
      status: status ?? this.status,
      teamName: teamName,
      hasPhoto: hasPhoto,
      reason: clearReason ? null : (reason ?? this.reason),
      note: clearNote ? null : (note ?? this.note),
      recordedAtClientUtc: recordedAtClientUtc ?? this.recordedAtClientUtc,
      rsvpStatus: rsvpStatus,
    );
  }
}

class AttendanceSession {
  const AttendanceSession({
    required this.eventId,
    required this.title,
    required this.type,
    required this.startAt,
    required this.attendanceState,
    required this.summary,
    required this.participants,
    required this.canMark,
    this.attendanceEnabled = true,
    this.timezone,
    this.allDay = false,
    this.endAt,
    this.location,
    this.scopeName,
    this.maxBatchEntries = 500,
    this.attendanceLockAtUtc,
    this.attendanceUnlockedUntilUtc,
    this.occurrenceStatus,
  });

  final String eventId;
  final String title;
  final EventType type;
  final DateTime startAt;
  final DateTime? endAt;
  final String? timezone;
  final bool allDay;
  final bool attendanceEnabled;
  final AttendanceState attendanceState;
  final AttendanceSummaryCounts summary;
  final List<AttendanceParticipant> participants;
  final bool canMark;
  final String? location;
  final String? scopeName;
  final int maxBatchEntries;
  final DateTime? attendanceLockAtUtc;
  final DateTime? attendanceUnlockedUntilUtc;
  final String? occurrenceStatus;

  String get occurrenceId => eventId;

  bool get isCanceled =>
      (occurrenceStatus ?? '').toLowerCase() == 'canceled';

  String get lockStatusLabel {
    if (isCanceled) return 'Canceled — attendance closed';
    if (canMark) return 'Attendance open';
    return 'Attendance locked';
  }

  factory AttendanceSession.fromRosterSnapshot(Map<String, dynamic> json) {
    final entriesRaw = json['entries'];
    final scopeName = json['scopeName'] as String?;
    final participants = <AttendanceParticipant>[];
    if (entriesRaw is List) {
      for (final e in entriesRaw) {
        if (e is Map) {
          participants.add(
            AttendanceParticipant.fromRosterEntry(
              Map<String, dynamic>.from(e),
              teamName: scopeName,
            ),
          );
        }
      }
    }
    final open = json['attendanceOpen'] as bool? ?? false;
    final type = parseEventType(json['type'] as String?);
    final status = json['status'] as String?;
    final start = DateTime.tryParse(json['startsAtUtc'] as String? ?? '')
            ?.toLocal() ??
        DateTime.now();
    final end =
        DateTime.tryParse(json['endsAtUtc'] as String? ?? '')?.toLocal();
    return AttendanceSession(
      eventId: json['occurrenceId']?.toString() ?? '',
      title: json['title'] as String? ?? 'Session',
      type: type,
      startAt: start,
      endAt: end,
      timezone: json['timeZone'] as String?,
      attendanceEnabled: true,
      attendanceState: parseAttendanceState(
        attendanceOpen: open,
        occurrenceStatus: status,
      ),
      summary: AttendanceSummaryCounts.fromParticipants(participants),
      participants: participants,
      canMark: open,
      location: json['location'] as String?,
      scopeName: scopeName,
      maxBatchEntries: (json['maxBatchEntries'] as num?)?.toInt() ?? 500,
      attendanceLockAtUtc: DateTime.tryParse(
        json['attendanceLockAtUtc'] as String? ?? '',
      )?.toLocal(),
      attendanceUnlockedUntilUtc: DateTime.tryParse(
        json['attendanceUnlockedUntilUtc'] as String? ?? '',
      )?.toLocal(),
      occurrenceStatus: status,
    );
  }

  factory AttendanceSession.fromOccurrenceAttendance(
    Map<String, dynamic> json,
  ) {
    final entriesRaw = json['entries'];
    final participants = <AttendanceParticipant>[];
    if (entriesRaw is List) {
      for (final e in entriesRaw) {
        if (e is Map) {
          participants.add(
            AttendanceParticipant.fromOccurrenceEntry(
              Map<String, dynamic>.from(e),
            ),
          );
        }
      }
    }
    final open = json['attendanceOpen'] as bool? ?? false;
    final status = json['status'] as String?;
    return AttendanceSession(
      eventId: json['occurrenceId']?.toString() ?? '',
      title: json['title'] as String? ?? 'Session',
      type: EventType.other,
      startAt: DateTime.tryParse(json['startsAtUtc'] as String? ?? '')
              ?.toLocal() ??
          DateTime.now(),
      timezone: json['timeZone'] as String?,
      attendanceEnabled: true,
      attendanceState: parseAttendanceState(
        attendanceOpen: open,
        occurrenceStatus: status,
      ),
      summary: AttendanceSummaryCounts(
        total: participants.length,
        present: (json['present'] as num?)?.toInt() ?? 0,
        late: (json['late'] as num?)?.toInt() ?? 0,
        excused: (json['excused'] as num?)?.toInt() ?? 0,
        absent: (json['absent'] as num?)?.toInt() ?? 0,
        notMarked: (json['unmarked'] as num?)?.toInt() ?? 0,
      ),
      participants: participants,
      canMark: open,
      attendanceLockAtUtc: DateTime.tryParse(
        json['attendanceLockAtUtc'] as String? ?? '',
      )?.toLocal(),
      attendanceUnlockedUntilUtc: DateTime.tryParse(
        json['attendanceUnlockedUntilUtc'] as String? ?? '',
      )?.toLocal(),
      occurrenceStatus: status,
    );
  }

  factory AttendanceSession.fromJson(Map<String, dynamic> json) {
    if (json.containsKey('snapshotAtUtc') || json.containsKey('syncWindowDays')) {
      return AttendanceSession.fromRosterSnapshot(json);
    }
    return AttendanceSession.fromOccurrenceAttendance(json);
  }
}

class AttendanceSaveResult {
  const AttendanceSaveResult({
    required this.batch,
    required this.session,
  });

  final AttendanceBatchResult batch;
  final AttendanceSession session;
}

class AttendanceUpdate {
  const AttendanceUpdate({
    required this.participantId,
    required this.status,
    this.version,
    this.reason,
    this.note,
    this.recordedAtClientUtc,
    this.clientRecordId,
  });

  final String participantId;
  final AttendanceStatus status;
  final int? version;
  final AbsenceReason? reason;
  final String? note;
  final DateTime? recordedAtClientUtc;
  final String? clientRecordId;

  Map<String, dynamic> toBatchEntry({
    required String occurrenceId,
  }) {
    final trimmed = note?.trim();
    return {
      'clientRecordId': clientRecordId ?? newClientRecordId(),
      'occurrenceId': occurrenceId,
      'memberId': participantId,
      'status': status.apiValue,
      'recordedAtClientUtc':
          (recordedAtClientUtc ?? DateTime.now().toUtc()).toIso8601String(),
      'note': ?trimmed,
    };
  }
}

class AttendanceBatchResult {
  const AttendanceBatchResult({
    required this.batchId,
    required this.applied,
    required this.alreadyApplied,
    required this.supersededByNewer,
    required this.rejected,
    required this.results,
  });

  final String batchId;
  final int applied;
  final int alreadyApplied;
  final int supersededByNewer;
  final int rejected;
  final List<AttendanceEntryResult> results;

  factory AttendanceBatchResult.fromJson(Map<String, dynamic> json) {
    final resultsRaw = json['results'];
    final results = <AttendanceEntryResult>[];
    if (resultsRaw is List) {
      for (final r in resultsRaw) {
        if (r is Map) {
          results.add(
            AttendanceEntryResult.fromJson(Map<String, dynamic>.from(r)),
          );
        }
      }
    }
    return AttendanceBatchResult(
      batchId: json['batchId']?.toString() ?? '',
      applied: (json['applied'] as num?)?.toInt() ?? 0,
      alreadyApplied: (json['alreadyApplied'] as num?)?.toInt() ?? 0,
      supersededByNewer: (json['supersededByNewer'] as num?)?.toInt() ?? 0,
      rejected: (json['rejected'] as num?)?.toInt() ?? 0,
      results: results,
    );
  }

  bool get hasRejects => rejected > 0;
}

class AttendanceEntryResult {
  const AttendanceEntryResult({
    required this.clientRecordId,
    required this.occurrenceId,
    required this.memberId,
    required this.outcome,
    this.reason,
    this.status,
  });

  final String clientRecordId;
  final String occurrenceId;
  final String memberId;
  final String outcome;
  final String? reason;
  final AttendanceStatus? status;

  factory AttendanceEntryResult.fromJson(Map<String, dynamic> json) {
    return AttendanceEntryResult(
      clientRecordId: json['clientRecordId']?.toString() ?? '',
      occurrenceId: json['occurrenceId']?.toString() ?? '',
      memberId: json['memberId']?.toString() ?? '',
      outcome: json['outcome'] as String? ?? '',
      reason: json['reason'] as String?,
      status: json['status'] == null
          ? null
          : parseAttendanceStatus(json['status'] as String?),
    );
  }
}

String newClientRecordId() {
  final rand = Random.secure();
  final bytes = List<int>.generate(16, (_) => rand.nextInt(256));
  bytes[6] = (bytes[6] & 0x0f) | 0x40;
  bytes[8] = (bytes[8] & 0x3f) | 0x80;
  String hex(int b) => b.toRadixString(16).padLeft(2, '0');
  final h = bytes.map(hex).join();
  return '${h.substring(0, 8)}-${h.substring(8, 12)}-'
      '${h.substring(12, 16)}-${h.substring(16, 20)}-${h.substring(20)}';
}
