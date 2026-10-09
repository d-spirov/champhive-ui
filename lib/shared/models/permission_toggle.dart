/// One catalogued club permission toggle from
/// `GET /api/v1/clubs/{clubId}/permission-toggles`.
///
/// Keys are a closed set: `coachCreatesMembers`, `coachSeesPaymentStatus`,
/// `trainingPlanCoachScope`.
class PermissionToggle {
  const PermissionToggle({
    required this.key,
    required this.role,
    this.grants = const [],
    required this.enabled,
    required this.defaultEnabled,
    required this.isConfigured,
  });

  final String key;
  final String role;
  final List<String> grants;
  final bool enabled;
  final bool defaultEnabled;
  final bool isConfigured;

  factory PermissionToggle.fromJson(Map<String, dynamic> json) {
    final grants = json['grants'] ?? json['Grants'];
    return PermissionToggle(
      key: (json['key'] ?? json['Key'])?.toString() ?? '',
      role: (json['role'] ?? json['Role'])?.toString() ?? '',
      grants: grants is List
          ? grants.map((e) => e.toString()).toList()
          : const [],
      enabled: json['enabled'] == true || json['Enabled'] == true,
      defaultEnabled:
          json['defaultEnabled'] == true || json['DefaultEnabled'] == true,
      isConfigured:
          json['isConfigured'] == true || json['IsConfigured'] == true,
    );
  }
}
