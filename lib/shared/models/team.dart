class ClubTeam {
  const ClubTeam({
    required this.id,
    required this.clubId,
    required this.name,
    this.sectionId,
    this.gender,
    this.birthYearFrom,
    this.birthYearTo,
    this.trainingLocation,
  });

  final String id;
  final String clubId;
  final String name;
  final String? sectionId;
  final String? gender;
  final int? birthYearFrom;
  final int? birthYearTo;
  final String? trainingLocation;

  String get ageBandLabel {
    final from = birthYearFrom;
    final to = birthYearTo;
    if (from == null && to == null) return '';
    if (from != null && to != null && from == to) return '$from';
    if (from != null && to != null) return '$from–$to';
    return '${from ?? to}';
  }

  String get subtitle {
    final parts = <String>[
      if (gender != null && gender!.isNotEmpty && gender != 'mixed') gender!,
      if (ageBandLabel.isNotEmpty) ageBandLabel,
      if (trainingLocation != null && trainingLocation!.isNotEmpty)
        trainingLocation!,
    ];
    return parts.join(' · ');
  }

  factory ClubTeam.fromJson(Map<String, dynamic> json) {
    return ClubTeam(
      id: json['id']?.toString() ?? '',
      clubId: json['clubId']?.toString() ?? '',
      sectionId: json['sectionId']?.toString(),
      name: json['name'] as String? ?? 'Team',
      gender: json['gender'] as String?,
      birthYearFrom: (json['birthYearFrom'] as num?)?.toInt(),
      birthYearTo: (json['birthYearTo'] as num?)?.toInt(),
      trainingLocation: json['trainingLocation'] as String?,
    );
  }
}

class TeamRosterEntry {
  const TeamRosterEntry({
    required this.memberId,
    required this.firstName,
    required this.lastName,
    required this.status,
    this.dateOfBirth,
    this.gender,
    this.shirtNumber,
    this.medicalNoteFlag = false,
    this.enrolledOn,
    this.complianceStatus,
  });

  final String memberId;
  final String firstName;
  final String lastName;
  final String status;
  final DateTime? dateOfBirth;
  final String? gender;
  final String? shirtNumber;
  final bool medicalNoteFlag;
  final DateTime? enrolledOn;
  final String? complianceStatus;

  String get displayName {
    final name = '$firstName $lastName'.trim();
    return name.isEmpty ? 'Member' : name;
  }

  /// First name plus last initial, e.g. "Filip A."
  String get shortDisplayName {
    final first = firstName.trim();
    final last = lastName.trim();
    if (first.isEmpty) return displayName;
    if (last.isEmpty) return first;
    return '$first ${last[0].toUpperCase()}.';
  }

  String get subtitle {
    final parts = <String>[
      if (shirtNumber != null && shirtNumber!.isNotEmpty) '#$shirtNumber',
      if (status.isNotEmpty) status,
      if (complianceStatus != null && complianceStatus!.isNotEmpty)
        complianceStatus!,
    ];
    return parts.join(' · ');
  }

  factory TeamRosterEntry.fromJson(Map<String, dynamic> json) {
    return TeamRosterEntry(
      memberId: json['memberId']?.toString() ?? '',
      firstName: json['firstName'] as String? ?? '',
      lastName: json['lastName'] as String? ?? '',
      dateOfBirth: DateTime.tryParse(json['dateOfBirth'] as String? ?? ''),
      gender: json['gender'] as String?,
      status: json['status'] as String? ?? 'active',
      shirtNumber: json['shirtNumber']?.toString(),
      medicalNoteFlag: json['medicalNoteFlag'] as bool? ?? false,
      enrolledOn: DateTime.tryParse(json['enrolledOn'] as String? ?? ''),
      complianceStatus: json['complianceStatus'] as String?,
    );
  }
}

class TeamRoster {
  const TeamRoster({
    required this.clubId,
    required this.teamId,
    required this.teamName,
    required this.entries,
    this.sectionId,
    this.seasonId,
    this.seasonLabel,
  });

  final String clubId;
  final String teamId;
  final String teamName;
  final String? sectionId;
  final String? seasonId;
  final String? seasonLabel;
  final List<TeamRosterEntry> entries;

  factory TeamRoster.fromJson(Map<String, dynamic> json) {
    final raw = json['entries'];
    final entries = <TeamRosterEntry>[];
    if (raw is List) {
      for (final e in raw) {
        if (e is Map) {
          entries.add(TeamRosterEntry.fromJson(Map<String, dynamic>.from(e)));
        }
      }
    }
    return TeamRoster(
      clubId: json['clubId']?.toString() ?? '',
      teamId: json['teamId']?.toString() ?? '',
      teamName: json['teamName'] as String? ?? 'Team',
      sectionId: json['sectionId']?.toString(),
      seasonId: json['seasonId']?.toString(),
      seasonLabel: json['seasonLabel'] as String?,
      entries: entries,
    );
  }
}
