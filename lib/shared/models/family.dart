class FamilyChild {
  const FamilyChild({
    required this.memberId,
    required this.firstName,
    required this.lastName,
    required this.dateOfBirth,
    required this.status,
    required this.clubId,
    required this.clubName,
    required this.hasActiveEnrollment,
    required this.consentGranted,
    required this.isSelf,
    this.sectionId,
    this.sectionName,
    this.teamId,
    this.teamName,
    this.complianceStatus,
  });

  final String memberId;
  final String firstName;
  final String lastName;
  final DateTime? dateOfBirth;
  final String status;
  final String clubId;
  final String clubName;
  final String? sectionId;
  final String? sectionName;
  final String? teamId;
  final String? teamName;
  final bool hasActiveEnrollment;
  final bool consentGranted;
  final String? complianceStatus;
  final bool isSelf;

  String get displayName {
    final parts = [firstName, lastName].where((p) => p.trim().isNotEmpty);
    return parts.isEmpty ? memberId : parts.join(' ');
  }

  factory FamilyChild.fromJson(Map<String, dynamic> json) {
    final club = json['club'];
    final nestedClubId = club is Map ? club['id']?.toString() ?? '' : '';
    final nestedClubName = club is Map ? club['name'] as String? ?? '' : '';
    return FamilyChild(
      memberId: json['memberId']?.toString() ?? '',
      firstName: json['firstName'] as String? ?? '',
      lastName: json['lastName'] as String? ?? '',
      dateOfBirth: DateTime.tryParse(json['dateOfBirth'] as String? ?? ''),
      status: json['status'] as String? ?? '',
      clubId: json['clubId']?.toString() ?? nestedClubId,
      clubName: json['clubName'] as String? ?? nestedClubName,
      sectionId: json['sectionId']?.toString(),
      sectionName: json['sectionName'] as String?,
      teamId: json['teamId']?.toString(),
      teamName: json['teamName'] as String?,
      hasActiveEnrollment: json['hasActiveEnrollment'] as bool? ?? false,
      consentGranted: json['consentGranted'] as bool? ?? false,
      complianceStatus: json['complianceStatus'] as String?,
      isSelf: _readBool(json['isSelf']) ||
          _readBool(json['self']) ||
          _readBool(json['own']),
    );
  }
}

bool _readBool(Object? value) {
  if (value == true || value == 1) return true;
  if (value is String) {
    final lower = value.toLowerCase();
    return lower == 'true' || lower == '1';
  }
  return false;
}

class PendingConsent {
  const PendingConsent({
    required this.memberId,
    required this.memberFirstName,
    required this.clubId,
    required this.kind,
    required this.version,
    required this.locale,
    required this.body,
    required this.reason,
  });

  final String memberId;
  final String memberFirstName;
  final String clubId;
  final String kind;
  final int version;
  final String locale;
  final String body;
  final String reason;

  factory PendingConsent.fromJson(Map<String, dynamic> json) {
    return PendingConsent(
      memberId: json['memberId']?.toString() ?? '',
      memberFirstName: json['memberFirstName'] as String? ?? '',
      clubId: json['clubId']?.toString() ?? '',
      kind: json['kind'] as String? ?? '',
      version: (json['version'] as num?)?.toInt() ??
          int.tryParse(json['version']?.toString() ?? '') ??
          0,
      locale: json['locale'] as String? ?? '',
      body: json['body'] as String? ?? '',
      reason: json['reason'] as String? ?? '',
    );
  }
}

class ConsentStatus {
  const ConsentStatus({
    required this.memberId,
    required this.kind,
    required this.granted,
    this.grantedVersion,
    this.withdrawnAtUtc,
    this.lastAskedAtUtc,
    this.channel,
    this.signedOn,
  });

  final String memberId;
  final String kind;
  final bool granted;
  final int? grantedVersion;
  final DateTime? withdrawnAtUtc;
  final DateTime? lastAskedAtUtc;
  final String? channel;
  final String? signedOn;

  factory ConsentStatus.fromJson(Map<String, dynamic> json) {
    return ConsentStatus(
      memberId: json['memberId']?.toString() ?? '',
      kind: json['kind'] as String? ?? '',
      granted: json['granted'] as bool? ?? false,
      grantedVersion: (json['grantedVersion'] as num?)?.toInt() ??
          int.tryParse(json['grantedVersion']?.toString() ?? ''),
      withdrawnAtUtc:
          DateTime.tryParse(json['withdrawnAtUtc'] as String? ?? '')?.toUtc(),
      lastAskedAtUtc:
          DateTime.tryParse(json['lastAskedAtUtc'] as String? ?? '')?.toUtc(),
      channel: json['channel'] as String?,
      signedOn: json['signedOn'] as String?,
    );
  }
}
