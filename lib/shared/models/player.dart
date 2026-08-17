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
      teamId: json['teamId']?.toString() ?? json['id']?.toString() ?? '',
      teamName: json['teamName'] as String? ?? json['name'] as String? ?? 'Team',
      shirtNumber: json['shirtNumber']?.toString(),
    );
  }
}

/// Club member — UI still says "Players" in places.
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
    this.photoUrl,
    this.shirtNumber,
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
  final String? photoUrl;
  final String? shirtNumber;
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
    if (activeTeams.isEmpty) {
      final n = shirtNumber;
      if (n != null && n.isNotEmpty) return '#$n';
      return 'Member';
    }
    return activeTeams.map((t) {
      if (t.shirtNumber != null && t.shirtNumber!.isNotEmpty) {
        return '${t.teamName} #${t.shirtNumber}';
      }
      return t.teamName;
    }).join(' · ');
  }

  String? get primaryShirtNumber {
    if (shirtNumber != null && shirtNumber!.isNotEmpty) return shirtNumber;
    for (final t in activeTeams) {
      if (t.shirtNumber != null && t.shirtNumber!.isNotEmpty) {
        return t.shirtNumber;
      }
    }
    return null;
  }

  factory ClubPlayer.fromMemberJson(Map<String, dynamic> json) {
    final photoUrl = json['photoUrl'] as String?;
    final dob = DateTime.tryParse(json['dateOfBirth'] as String? ?? '');
    final teamsRaw = json['activeTeams'] ?? json['activeTeamAssignments'];
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
      dateOfBirth: dob,
      age: (json['age'] as num?)?.toInt() ?? _ageFromDob(dob),
      gender: json['gender'] as String?,
      registrationNumber: json['licenseNumber'] as String? ??
          json['registrationNumber'] as String?,
      phone: json['phone'] as String?,
      email: json['email'] as String?,
      notes: json['notes'] as String?,
      status: json['status'] as String? ?? 'active',
      photoUrl: photoUrl,
      hasPhoto: json['hasPhoto'] as bool? ??
          (photoUrl != null && photoUrl.isNotEmpty),
      shirtNumber: json['shirtNumber']?.toString(),
      activeTeams: teams,
    );
  }

  /// Legacy aliases used by older call sites / tests.
  factory ClubPlayer.fromListJson(Map<String, dynamic> json) =>
      ClubPlayer.fromMemberJson(json);

  factory ClubPlayer.fromDetailJson(Map<String, dynamic> json) =>
      ClubPlayer.fromMemberJson(json);

  static int? _ageFromDob(DateTime? dob) {
    if (dob == null) return null;
    final now = DateTime.now();
    var age = now.year - dob.year;
    if (now.month < dob.month ||
        (now.month == dob.month && now.day < dob.day)) {
      age--;
    }
    return age;
  }
}
