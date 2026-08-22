/// Club section from ClubPlatform (`GET /clubs/{id}/sections`).
///
/// Sport identity for visual theming lives here. The API field is `sportCode`;
/// we expose it as [sportType] so UI/theme code matches the product language.
class ClubSection {
  const ClubSection({
    required this.id,
    required this.clubId,
    required this.sportType,
    required this.name,
    this.federationCode,
  });

  final String id;
  final String clubId;

  /// Active sport for this section (API `sportCode`, e.g. `basketball`).
  final String sportType;

  final String name;
  final String? federationCode;

  factory ClubSection.fromJson(Map<String, dynamic> json) {
    final sport = (json['sportCode'] as String?)?.trim().isNotEmpty == true
        ? (json['sportCode'] as String).trim()
        : (json['sportType'] as String?)?.trim() ?? '';
    return ClubSection(
      id: json['id']?.toString() ?? '',
      clubId: json['clubId']?.toString() ?? '',
      sportType: sport,
      name: json['name'] as String? ?? '',
      federationCode: json['federationCode'] as String?,
    );
  }
}
