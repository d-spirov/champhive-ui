int jsonInt(Object? raw, [int fallback = 0]) {
  if (raw is int) return raw;
  if (raw is num) return raw.toInt();
  if (raw is String) return int.tryParse(raw) ?? fallback;
  return fallback;
}

int? jsonIntOrNull(Object? raw) {
  if (raw == null) return null;
  if (raw is int) return raw;
  if (raw is num) return raw.toInt();
  if (raw is String) return int.tryParse(raw);
  return null;
}

DateTime? jsonDate(Object? raw) {
  if (raw is! String || raw.isEmpty) return null;
  return DateTime.tryParse(raw);
}

String? jsonDateOnly(DateTime? value) {
  if (value == null) return null;
  final local = DateTime(value.year, value.month, value.day);
  final y = local.year.toString().padLeft(4, '0');
  final m = local.month.toString().padLeft(2, '0');
  final d = local.day.toString().padLeft(2, '0');
  return '$y-$m-$d';
}

class ComplianceDocument {
  const ComplianceDocument({
    required this.id,
    required this.clubId,
    required this.memberId,
    required this.memberName,
    required this.documentTypeId,
    required this.documentTypeCode,
    required this.documentTypeName,
    required this.status,
    required this.fileName,
    required this.contentType,
    required this.sizeBytes,
    required this.canReadContent,
    this.rejectionReason,
    this.issuedOn,
    this.expiresOn,
    this.uploadedByUserId,
    this.uploadedByName,
    this.createdAtUtc,
    this.completedAtUtc,
    this.reviewedByUserId,
    this.reviewedByName,
    this.reviewedAtUtc,
  });

  final String id;
  final String clubId;
  final String memberId;
  final String memberName;
  final String documentTypeId;
  final String documentTypeCode;
  final String documentTypeName;
  final String status;
  final String fileName;
  final String contentType;
  final int sizeBytes;
  final String? rejectionReason;
  final DateTime? issuedOn;
  final DateTime? expiresOn;
  final String? uploadedByUserId;
  final String? uploadedByName;
  final DateTime? createdAtUtc;
  final DateTime? completedAtUtc;
  final String? reviewedByUserId;
  final String? reviewedByName;
  final DateTime? reviewedAtUtc;
  final bool canReadContent;

  bool get isPending => status.toLowerCase() == 'pending';
  bool get isVerified => status.toLowerCase() == 'verified';
  bool get isRejected => status.toLowerCase() == 'rejected';
  bool get isAwaitingUpload => status.toLowerCase() == 'awaitingupload';
  bool get isImage => contentType.toLowerCase().startsWith('image/');
  bool get isPdf => contentType.toLowerCase().contains('pdf');

  factory ComplianceDocument.fromJson(Map<String, dynamic> json) {
    return ComplianceDocument(
      id: json['id']?.toString() ?? '',
      clubId: json['clubId']?.toString() ?? '',
      memberId: json['memberId']?.toString() ?? '',
      memberName: json['memberName'] as String? ?? '',
      documentTypeId: json['documentTypeId']?.toString() ?? '',
      documentTypeCode: json['documentTypeCode'] as String? ?? '',
      documentTypeName: json['documentTypeName'] as String? ?? '',
      status: json['status'] as String? ?? '',
      fileName: json['fileName'] as String? ?? '',
      contentType: json['contentType'] as String? ?? '',
      sizeBytes: jsonInt(json['sizeBytes']),
      rejectionReason: json['rejectionReason'] as String?,
      issuedOn: jsonDate(json['issuedOn']),
      expiresOn: jsonDate(json['expiresOn']),
      uploadedByUserId: json['uploadedByUserId']?.toString(),
      uploadedByName: json['uploadedByName'] as String?,
      createdAtUtc: jsonDate(json['createdAtUtc']),
      completedAtUtc: jsonDate(json['completedAtUtc']),
      reviewedByUserId: json['reviewedByUserId']?.toString(),
      reviewedByName: json['reviewedByName'] as String?,
      reviewedAtUtc: jsonDate(json['reviewedAtUtc']),
      canReadContent: json['canReadContent'] as bool? ?? false,
    );
  }
}

class MemberRequirement {
  const MemberRequirement({
    required this.documentTypeId,
    required this.code,
    required this.name,
    required this.isRequired,
    required this.satisfied,
    this.validityMonths,
    this.expiresOn,
    this.latestDocument,
    this.lastAskedAtUtc,
  });

  final String documentTypeId;
  final String code;
  final String name;
  final bool isRequired;
  final int? validityMonths;
  final bool satisfied;
  final DateTime? expiresOn;
  final ComplianceDocument? latestDocument;
  final DateTime? lastAskedAtUtc;

  factory MemberRequirement.fromJson(Map<String, dynamic> json) {
    final latest = json['latestDocument'];
    return MemberRequirement(
      documentTypeId: json['documentTypeId']?.toString() ?? '',
      code: json['code'] as String? ?? '',
      name: json['name'] as String? ?? '',
      isRequired: json['required'] as bool? ?? false,
      validityMonths: jsonIntOrNull(json['validityMonths']),
      satisfied: json['satisfied'] as bool? ?? false,
      expiresOn: jsonDate(json['expiresOn']),
      latestDocument: latest is Map
          ? ComplianceDocument.fromJson(Map<String, dynamic>.from(latest))
          : null,
      lastAskedAtUtc: jsonDate(json['lastAskedAtUtc']),
    );
  }
}

class MemberCompliance {
  const MemberCompliance({
    required this.memberId,
    required this.memberName,
    required this.clubId,
    required this.status,
    required this.requirements,
  });

  final String memberId;
  final String memberName;
  final String clubId;
  final String status;
  final List<MemberRequirement> requirements;

  factory MemberCompliance.fromJson(Map<String, dynamic> json) {
    final raw = json['requirements'];
    return MemberCompliance(
      memberId: json['memberId']?.toString() ?? '',
      memberName: json['memberName'] as String? ?? '',
      clubId: json['clubId']?.toString() ?? '',
      status: json['status'] as String? ?? '',
      requirements: raw is List
          ? raw
              .whereType<Map>()
              .map(
                (e) => MemberRequirement.fromJson(Map<String, dynamic>.from(e)),
              )
              .toList()
          : const [],
    );
  }
}

class ComplianceIssue {
  const ComplianceIssue({
    required this.documentTypeId,
    required this.code,
    required this.name,
    required this.kind,
    this.expiresOn,
    this.daysUntilExpiry,
  });

  final String documentTypeId;
  final String code;
  final String name;
  final String kind;
  final DateTime? expiresOn;
  final int? daysUntilExpiry;

  factory ComplianceIssue.fromJson(Map<String, dynamic> json) {
    return ComplianceIssue(
      documentTypeId: json['documentTypeId']?.toString() ?? '',
      code: json['code'] as String? ?? '',
      name: json['name'] as String? ?? '',
      kind: json['kind'] as String? ?? '',
      expiresOn: jsonDate(json['expiresOn']),
      daysUntilExpiry: jsonIntOrNull(json['daysUntilExpiry']),
    );
  }
}

class ComplianceMemberRow {
  const ComplianceMemberRow({
    required this.memberId,
    required this.memberName,
    required this.status,
    required this.issues,
    this.teamId,
    this.teamName,
    this.sectionId,
    this.sectionName,
    this.nextExpiryOn,
  });

  final String memberId;
  final String memberName;
  final String? teamId;
  final String? teamName;
  final String? sectionId;
  final String? sectionName;
  final String status;
  final DateTime? nextExpiryOn;
  final List<ComplianceIssue> issues;

  factory ComplianceMemberRow.fromJson(Map<String, dynamic> json) {
    final raw = json['issues'];
    return ComplianceMemberRow(
      memberId: json['memberId']?.toString() ?? '',
      memberName: json['memberName'] as String? ?? '',
      teamId: json['teamId']?.toString(),
      teamName: json['teamName'] as String?,
      sectionId: json['sectionId']?.toString(),
      sectionName: json['sectionName'] as String?,
      status: json['status'] as String? ?? '',
      nextExpiryOn: jsonDate(json['nextExpiryOn']),
      issues: raw is List
          ? raw
              .whereType<Map>()
              .map((e) => ComplianceIssue.fromJson(Map<String, dynamic>.from(e)))
              .toList()
          : const [],
    );
  }
}

class ComplianceOverview {
  const ComplianceOverview({
    required this.clubId,
    required this.validCount,
    required this.expiringCount,
    required this.missingCount,
    required this.expiringWithinDays,
    required this.members,
    this.asOf,
  });

  final String clubId;
  final DateTime? asOf;
  final int expiringWithinDays;
  final int validCount;
  final int expiringCount;
  final int missingCount;
  final List<ComplianceMemberRow> members;

  factory ComplianceOverview.fromJson(Map<String, dynamic> json) {
    final raw = json['members'];
    return ComplianceOverview(
      clubId: json['clubId']?.toString() ?? '',
      asOf: jsonDate(json['asOf']),
      expiringWithinDays: jsonInt(json['expiringWithinDays'], 30),
      validCount: jsonInt(json['validCount']),
      expiringCount: jsonInt(json['expiringCount']),
      missingCount: jsonInt(json['missingCount']),
      members: raw is List
          ? raw
              .whereType<Map>()
              .map(
                (e) =>
                    ComplianceMemberRow.fromJson(Map<String, dynamic>.from(e)),
              )
              .toList()
          : const [],
    );
  }
}

class ComplianceDocumentsPage {
  const ComplianceDocumentsPage({
    required this.items,
    required this.page,
    required this.pageSize,
    required this.totalCount,
  });

  final List<ComplianceDocument> items;
  final int page;
  final int pageSize;
  final int totalCount;

  factory ComplianceDocumentsPage.fromJson(Map<String, dynamic> json) {
    final raw = json['items'];
    return ComplianceDocumentsPage(
      items: raw is List
          ? raw
              .whereType<Map>()
              .map(
                (e) =>
                    ComplianceDocument.fromJson(Map<String, dynamic>.from(e)),
              )
              .toList()
          : const [],
      page: jsonInt(json['page'], 1),
      pageSize: jsonInt(json['pageSize'], 50),
      totalCount: jsonInt(json['totalCount']),
    );
  }
}

class DocumentUploadTicket {
  const DocumentUploadTicket({
    required this.document,
    required this.uploadUrl,
    required this.uploadMethod,
    required this.uploadHeaders,
    required this.maxSizeBytes,
    this.uploadExpiresAtUtc,
  });

  final ComplianceDocument document;
  final String uploadUrl;
  final String uploadMethod;
  final Map<String, String> uploadHeaders;
  final DateTime? uploadExpiresAtUtc;
  final int maxSizeBytes;

  factory DocumentUploadTicket.fromJson(Map<String, dynamic> json) {
    final headersRaw = json['uploadHeaders'];
    final headers = <String, String>{};
    if (headersRaw is Map) {
      headersRaw.forEach((key, value) {
        if (value != null) headers['$key'] = '$value';
      });
    }
    final documentRaw = json['document'];
    return DocumentUploadTicket(
      document: documentRaw is Map
          ? ComplianceDocument.fromJson(Map<String, dynamic>.from(documentRaw))
          : ComplianceDocument.fromJson(const {}),
      uploadUrl: json['uploadUrl'] as String? ?? '',
      uploadMethod: json['uploadMethod'] as String? ?? 'PUT',
      uploadHeaders: headers,
      uploadExpiresAtUtc: jsonDate(json['uploadExpiresAtUtc']),
      maxSizeBytes: jsonInt(json['maxSizeBytes'], 15 * 1024 * 1024),
    );
  }
}

class DocumentContentUrl {
  const DocumentContentUrl({
    required this.url,
    required this.contentType,
    required this.audited,
    this.expiresAtUtc,
  });

  final String url;
  final DateTime? expiresAtUtc;
  final String contentType;
  final bool audited;

  factory DocumentContentUrl.fromJson(Map<String, dynamic> json) {
    return DocumentContentUrl(
      url: json['url'] as String? ?? '',
      expiresAtUtc: jsonDate(json['expiresAtUtc']),
      contentType: json['contentType'] as String? ?? '',
      audited: json['audited'] as bool? ?? true,
    );
  }
}

class AskFamilyResult {
  const AskFamilyResult({
    required this.sent,
    required this.recipients,
    required this.alreadyAskedToday,
  });

  final bool sent;
  final int recipients;
  final bool alreadyAskedToday;

  factory AskFamilyResult.fromJson(Map<String, dynamic> json) {
    return AskFamilyResult(
      sent: json['sent'] as bool? ?? false,
      recipients: jsonInt(json['recipients']),
      alreadyAskedToday: json['alreadyAskedToday'] as bool? ?? false,
    );
  }
}
