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
  switch ((raw ?? '').toUpperCase()) {
    case 'TRAINING':
      return EventType.training;
    case 'MATCH':
      return EventType.match;
    case 'TOURNAMENT':
      return EventType.tournament;
    case 'MEETING':
      return EventType.meeting;
    default:
      return EventType.other;
  }
}

AttendanceStatus parseAttendanceStatus(String? raw) {
  switch ((raw ?? '').toUpperCase()) {
    case 'PRESENT':
      return AttendanceStatus.present;
    case 'ABSENT':
      return AttendanceStatus.absent;
    case 'LATE':
      return AttendanceStatus.late;
    case 'EXCUSED':
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

AttendanceState parseAttendanceState(String? raw) {
  switch ((raw ?? '').toUpperCase()) {
    case 'OPEN':
      return AttendanceState.open;
    case 'FINALIZED':
      return AttendanceState.finalized;
    default:
      return AttendanceState.notOpen;
  }
}

extension EventTypeX on EventType {
  String get apiValue => name.toUpperCase();

  String get label => switch (this) {
        EventType.training => 'Training',
        EventType.match => 'Match',
        EventType.tournament => 'Tournament',
        EventType.meeting => 'Team Meeting',
        EventType.other => 'Event',
      };
}

extension AttendanceStatusX on AttendanceStatus {
  String get apiValue => switch (this) {
        AttendanceStatus.notMarked => 'NOT_MARKED',
        AttendanceStatus.present => 'PRESENT',
        AttendanceStatus.absent => 'ABSENT',
        AttendanceStatus.late => 'LATE',
        AttendanceStatus.excused => 'EXCUSED',
      };

  String get label => switch (this) {
        AttendanceStatus.notMarked => 'Unmarked',
        AttendanceStatus.present => 'Present',
        AttendanceStatus.absent => 'Absent',
        AttendanceStatus.late => 'Late',
        AttendanceStatus.excused => 'Excused',
      };
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

  String get display {
    if (name != null && name!.isNotEmpty) return name!;
    if (address != null && address!.isNotEmpty) return address!;
    if (meetingPoint != null && meetingPoint!.isNotEmpty) return meetingPoint!;
    return 'TBD';
  }
}

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

  factory ClubEvent.fromJson(Map<String, dynamic> json) {
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
      timezone: json['timezone'] as String?,
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
      notMarked: (json['notMarked'] as num?)?.toInt() ?? 0,
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
  });

  final String id;
  final String playerId;
  final String displayName;
  final int version;
  final AttendanceStatus status;
  final String? teamName;
  final bool hasPhoto;
  final AbsenceReason? reason;
  final String? note;

  factory AttendanceParticipant.fromJson(Map<String, dynamic> json) {
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
      id: json['id']?.toString() ?? '',
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
    required this.canFinalize,
    required this.canOpen,
    required this.canManageParticipants,
    this.attendanceEnabled = true,
    this.timezone,
    this.allDay = false,
  });

  final String eventId;
  final String title;
  final EventType type;
  final DateTime startAt;
  final String? timezone;
  final bool allDay;
  final bool attendanceEnabled;
  final AttendanceState attendanceState;
  final AttendanceSummaryCounts summary;
  final List<AttendanceParticipant> participants;
  final bool canMark;
  final bool canFinalize;
  final bool canOpen;
  final bool canManageParticipants;

  factory AttendanceSession.fromJson(Map<String, dynamic> json) {
    final event = json['event'] is Map
        ? Map<String, dynamic>.from(json['event'] as Map)
        : const <String, dynamic>{};
    final permissions = json['permissions'] is Map
        ? Map<String, dynamic>.from(json['permissions'] as Map)
        : const <String, dynamic>{};
    final participantsRaw = json['participants'];
    final participants = <AttendanceParticipant>[];
    if (participantsRaw is List) {
      for (final p in participantsRaw) {
        if (p is Map) {
          participants.add(
            AttendanceParticipant.fromJson(Map<String, dynamic>.from(p)),
          );
        }
      }
    }
    return AttendanceSession(
      eventId: event['id']?.toString() ?? '',
      title: event['title'] as String? ?? 'Event',
      type: parseEventType(event['type'] as String?),
      startAt: DateTime.tryParse(event['startAt'] as String? ?? '')?.toLocal() ??
          DateTime.now(),
      timezone: event['timezone'] as String?,
      allDay: event['allDay'] as bool? ?? false,
      attendanceEnabled: event['attendanceEnabled'] as bool? ?? true,
      attendanceState: parseAttendanceState(event['attendanceState'] as String?),
      summary: AttendanceSummaryCounts.fromJson(
        json['summary'] is Map
            ? Map<String, dynamic>.from(json['summary'] as Map)
            : null,
      ),
      participants: participants,
      canMark: permissions['canMarkAttendance'] as bool? ?? false,
      canFinalize: permissions['canFinalize'] as bool? ?? false,
      canOpen: permissions['canOpen'] as bool? ?? false,
      canManageParticipants:
          permissions['canManageParticipants'] as bool? ?? false,
    );
  }
}

class AttendanceUpdate {
  const AttendanceUpdate({
    required this.participantId,
    required this.status,
    this.version,
    this.reason,
    this.note,
  });

  final String participantId;
  final AttendanceStatus status;
  final int? version;
  final AbsenceReason? reason;
  final String? note;

  Map<String, dynamic> toJson() => {
        'participantId': participantId,
        'status': status.apiValue,
        // Version is optional on the API; omitting avoids stale optimistic-lock
        // conflicts after roster refresh / open.
        if (version != null) 'version': version,
        if (reason != null) 'reason': reason!.apiValue,
        if (note != null && note!.isNotEmpty) 'note': note,
      };
}
