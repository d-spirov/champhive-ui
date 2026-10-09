class RoleGrant {
  const RoleGrant({
    required this.role,
    required this.clubId,
    required this.scope,
    required this.scopeId,
  });

  final String role;
  final String clubId;
  final String scope;
  final String scopeId;

  factory RoleGrant.fromJson(Map<String, dynamic> json) {
    return RoleGrant(
      role: json['role'] as String? ?? '',
      clubId: json['clubId']?.toString() ?? '',
      scope: (json['scope'] as String? ?? json['scopeKind'] as String? ?? ''),
      scopeId: json['scopeId']?.toString() ?? '',
    );
  }
}

class ClubPermissions {
  const ClubPermissions({required this.clubId, this.permissions = const []});

  final String clubId;
  final List<String> permissions;

  factory ClubPermissions.fromJson(Map<String, dynamic> json) {
    final perms = json['permissions'];
    return ClubPermissions(
      clubId: json['clubId']?.toString() ?? '',
      permissions: perms is List
          ? perms.map((e) => e.toString()).toList()
          : const [],
    );
  }
}

class User {
  const User({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    this.locale = 'en',
    this.emailVerified = false,
    this.emailVerificationPending = false,
    this.isPlatformRoot = false,
    this.roles = const [],
    this.fam = const [],
    this.clubPermissions = const [],
    this.createdAt,
  });

  final String id;
  final String email;
  final String firstName;
  final String lastName;
  final String locale;
  final bool emailVerified;
  final bool emailVerificationPending;
  final bool isPlatformRoot;
  final List<RoleGrant> roles;
  final List<String> fam;
  final List<ClubPermissions> clubPermissions;
  final DateTime? createdAt;

  String get displayName {
    final parts = [firstName, lastName].where((p) => p.trim().isNotEmpty);
    if (parts.isNotEmpty) return parts.join(' ');
    return email.contains('@') ? email.split('@').first : email;
  }

  /// Club ids the user belongs to (from roles + clubPermissions).
  Set<String> get clubIds {
    final ids = <String>{};
    for (final r in roles) {
      if (r.clubId.isNotEmpty) ids.add(r.clubId);
    }
    for (final c in clubPermissions) {
      if (c.clubId.isNotEmpty) ids.add(c.clubId);
    }
    return ids;
  }

  List<String> rolesForClub(String clubId) {
    return roles.where((r) => r.clubId == clubId).map((r) => r.role).toList();
  }

  /// Club admins may see every team. A club-scoped coach does not.
  bool hasClubWideStaffGrant(String? clubId) {
    if (clubId == null || clubId.isEmpty) return false;
    if (isPlatformRoot) return true;
    for (final r in roles) {
      if (r.clubId != clubId) continue;
      if (r.role.toLowerCase() == 'clubadmin') return true;
    }
    return false;
  }

  /// Club admin, section admin, or coach in [clubId] (union with other roles).
  bool isStaff(String? clubId) {
    if (clubId == null || clubId.isEmpty) return false;
    if (isPlatformRoot) return true;
    for (final r in roles) {
      if (r.clubId != clubId) continue;
      if (_isStaffRole(r.role)) return true;
    }
    return false;
  }

  bool isParent(String? clubId) {
    if (clubId == null || clubId.isEmpty) return false;
    for (final r in roles) {
      if (r.clubId != clubId) continue;
      if (r.role.toLowerCase() == 'parent') return true;
    }
    return false;
  }

  /// Explicit team ids from team-scoped staff grants in [clubId].
  Set<String> staffTeamIdsForClub(String clubId) {
    return {
      for (final r in roles)
        if (r.clubId == clubId &&
            _isStaffRole(r.role) &&
            r.scope.toLowerCase() == 'team' &&
            r.scopeId.isNotEmpty)
          r.scopeId,
    };
  }

  /// Section ids from section-scoped staff grants in [clubId].
  Set<String> staffSectionIdsForClub(String clubId) {
    return {
      for (final r in roles)
        if (r.clubId == clubId &&
            _isStaffRole(r.role) &&
            r.scope.toLowerCase() == 'section' &&
            r.scopeId.isNotEmpty)
          r.scopeId,
    };
  }

  static bool _isStaffRole(String role) {
    switch (role.toLowerCase()) {
      case 'clubadmin':
      case 'sectionadmin':
      case 'coach':
        return true;
      default:
        return false;
    }
  }

  bool hasClubPermission(String? clubId, String permission) {
    if (clubId == null || clubId.isEmpty || permission.isEmpty) return false;
    final wanted = permission.toUpperCase();
    for (final c in clubPermissions) {
      if (c.clubId != clubId) continue;
      for (final p in c.permissions) {
        if (p.toUpperCase() == wanted) return true;
      }
    }
    return false;
  }

  /// ClubPlatform `MEMBER_WRITE` — create/enroll members. Coaches only hold
  /// this when the club has enabled `coachCreatesMembers`.
  bool canWriteMembers(String? clubId) =>
      hasClubPermission(clubId, 'MEMBER_WRITE');

  /// `sectionId` on create-member selects that section's field policy.
  /// A team-scoped coach grant does not cover a section-wide write, so
  /// sending it would 403 even when the coach may register a player.
  bool canSetMemberSectionPolicy(String clubId, String? sectionId) {
    if (hasClubWideStaffGrant(clubId)) return true;
    if (sectionId == null || sectionId.isEmpty) return false;
    return staffSectionIdsForClub(clubId).contains(sectionId);
  }

  factory User.fromMeJson(Map<String, dynamic> json) {
    final rolesRaw = json['roles'];
    final famRaw = json['fam'];
    final permsRaw = json['clubPermissions'];
    return User(
      id: json['id']?.toString() ?? '',
      email: json['email'] as String? ?? '',
      firstName: json['firstName'] as String? ?? '',
      lastName: json['lastName'] as String? ?? '',
      locale: json['locale'] as String? ?? 'en',
      emailVerified: json['emailVerified'] as bool? ?? false,
      emailVerificationPending:
          json['emailVerificationPending'] as bool? ?? false,
      isPlatformRoot: json['isPlatformRoot'] as bool? ?? false,
      roles: rolesRaw is List
          ? rolesRaw
                .whereType<Map>()
                .map((e) => RoleGrant.fromJson(Map<String, dynamic>.from(e)))
                .toList()
          : const [],
      fam: famRaw is List ? famRaw.map((e) => e.toString()).toList() : const [],
      clubPermissions: permsRaw is List
          ? permsRaw
                .whereType<Map>()
                .map(
                  (e) => ClubPermissions.fromJson(Map<String, dynamic>.from(e)),
                )
                .toList()
          : const [],
      createdAt: _parseDate(json['createdAtUtc'] ?? json['createdAt']),
    );
  }

  /// Legacy alias used by older call sites.
  factory User.fromJson(Map<String, dynamic> json) => User.fromMeJson(json);

  static DateTime? _parseDate(Object? value) {
    if (value is! String || value.isEmpty) return null;
    return DateTime.tryParse(value);
  }
}
