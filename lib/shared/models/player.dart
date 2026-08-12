class PlayerTeamAssignment {
  const PlayerTeamAssignment({
    required this.assignmentId,
    required this.teamId,
    required this.teamName,
    this.shirtNumber,
  });

  final String assignmentId;
  final String teamId;
  final String teamName;
  final String? shirtNumber;

  factory PlayerTeamAssignment.fromJson(Map<String, dynamic> json) {
    return PlayerTeamAssignment(
      assignmentId: json['assignmentId']?.toString() ?? '',
      teamId: json['teamId']?.toString() ?? '',
      teamName: json['teamName'] as String? ?? 'Team',
      shirtNumber: json['shirtNumber'] as String?,
    );
  }
}

class ClubPlayer {
  const ClubPlayer({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.status,
    required this.hasPhoto,
    this.preferredName,
    this.displayName,
    this.dateOfBirth,
    this.age,
    this.registrationNumber,
    this.gender,
    this.phone,
    this.email,
    this.notes,
    this.clubId,
    this.activeTeams = const [],
  });

  final String id;
  final String? clubId;
  final String firstName;
  final String lastName;
  final String? preferredName;
  final String? displayName;
  final DateTime? dateOfBirth;
  final int? age;
  final String? registrationNumber;
  final String? gender;
  final String? phone;
  final String? email;
  final String? notes;
  final String status;
  final bool hasPhoto;
  final List<PlayerTeamAssignment> activeTeams;

  String get name {
    if (displayName != null && displayName!.trim().isNotEmpty) {
      return displayName!.trim();
    }
    if (preferredName != null && preferredName!.trim().isNotEmpty) {
      return preferredName!.trim();
    }
    return '$firstName $lastName'.trim();
  }

  String get teamsLabel {
    if (activeTeams.isEmpty) return 'Unassigned';
    return activeTeams.map((t) {
      if (t.shirtNumber != null && t.shirtNumber!.isNotEmpty) {
        return '${t.teamName} #${t.shirtNumber}';
      }
      return t.teamName;
    }).join(' · ');
  }

  String? get primaryShirtNumber {
    for (final t in activeTeams) {
      if (t.shirtNumber != null && t.shirtNumber!.isNotEmpty) {
        return t.shirtNumber;
      }
    }
    return null;
  }

  factory ClubPlayer.fromListJson(Map<String, dynamic> json) {
    final teamsRaw = json['activeTeams'];
    final teams = <PlayerTeamAssignment>[];
    if (teamsRaw is List) {
      for (final t in teamsRaw) {
        if (t is Map) {
          teams.add(PlayerTeamAssignment.fromJson(Map<String, dynamic>.from(t)));
        }
      }
    }
    return ClubPlayer(
      id: json['id']?.toString() ?? '',
      firstName: json['firstName'] as String? ?? '',
      lastName: json['lastName'] as String? ?? '',
      preferredName: json['preferredName'] as String?,
      dateOfBirth: DateTime.tryParse(json['dateOfBirth'] as String? ?? ''),
      age: (json['age'] as num?)?.toInt(),
      registrationNumber: json['registrationNumber'] as String?,
      status: json['status'] as String? ?? 'ACTIVE',
      hasPhoto: json['hasPhoto'] as bool? ?? false,
      activeTeams: teams,
    );
  }

  factory ClubPlayer.fromDetailJson(Map<String, dynamic> json) {
    final teamsRaw = json['activeTeamAssignments'];
    final teams = <PlayerTeamAssignment>[];
    if (teamsRaw is List) {
      for (final t in teamsRaw) {
        if (t is Map) {
          teams.add(PlayerTeamAssignment.fromJson(Map<String, dynamic>.from(t)));
        }
      }
    }
    return ClubPlayer(
      id: json['id']?.toString() ?? '',
      clubId: json['clubId']?.toString(),
      firstName: json['firstName'] as String? ?? '',
      lastName: json['lastName'] as String? ?? '',
      preferredName: json['preferredName'] as String?,
      displayName: json['displayName'] as String?,
      dateOfBirth: DateTime.tryParse(json['dateOfBirth'] as String? ?? ''),
      age: (json['age'] as num?)?.toInt(),
      gender: json['gender'] as String?,
      registrationNumber: json['registrationNumber'] as String?,
      phone: json['phone'] as String?,
      email: json['email'] as String?,
      notes: json['notes'] as String?,
      status: json['status'] as String? ?? 'ACTIVE',
      hasPhoto: json['hasPhoto'] as bool? ?? false,
      activeTeams: teams,
    );
  }
}
