class StaffMember {
  const StaffMember({
    required this.id,
    required this.status,
    required this.name,
    required this.role,
    required this.scopeKind,
    required this.scopeId,
    required this.scopeName,
    required this.canEnd,
    this.userAccountId,
    this.email,
  });

  final String id;
  final String status;
  final String? userAccountId;
  final String name;
  final String? email;
  final String role;
  final String scopeKind;
  final String scopeId;
  final String scopeName;
  final bool canEnd;

  bool get isLive => status.toLowerCase() == 'live';

  factory StaffMember.fromJson(Map<String, dynamic> json) {
    return StaffMember(
      id: json['id']?.toString() ?? '',
      status: json['status'] as String? ?? '',
      userAccountId: json['userAccountId']?.toString(),
      name: json['name'] as String? ?? '',
      email: json['email'] as String?,
      role: json['role'] as String? ?? '',
      scopeKind: json['scopeKind'] as String? ?? '',
      scopeId: json['scopeId']?.toString() ?? '',
      scopeName: json['scopeName'] as String? ?? '',
      canEnd: json['canEnd'] as bool? ?? false,
    );
  }
}

/// Someone the caller can open a direct chat with.
class DirectMessageCandidate {
  const DirectMessageCandidate({
    required this.userAccountId,
    required this.name,
    this.email,
    this.subtitle,
  });

  final String userAccountId;
  final String name;
  final String? email;
  final String? subtitle;
}
