class ClubSummary {
  const ClubSummary({
    required this.id,
    required this.name,
    this.slug,
    this.sportType,
    this.city,
    this.countryCode,
    this.status,
    this.currentUserRoles = const [],
    this.hasLogo = false,
    this.logoUrl,
    this.timeZone,
  });

  final String id;
  final String name;
  final String? slug;
  final String? sportType;
  final String? city;
  final String? countryCode;
  final String? status;
  final List<String> currentUserRoles;
  final bool hasLogo;
  final String? logoUrl;
  final String? timeZone;

  factory ClubSummary.fromJson(Map<String, dynamic> json) {
    final roles = json['currentUserRoles'];
    final logoUrl = json['logoUrl'] as String?;
    return ClubSummary(
      id: json['id']?.toString() ?? '',
      name: json['name'] as String? ?? '',
      slug: json['slug'] as String?,
      sportType: json['sportType'] as String?,
      city: json['city'] as String?,
      countryCode: json['countryCode'] as String?,
      status: json['status'] as String?,
      currentUserRoles: roles is List
          ? roles.map((e) => e.toString()).toList()
          : const [],
      logoUrl: logoUrl,
      hasLogo: json['hasLogo'] as bool? ??
          (logoUrl != null && logoUrl.isNotEmpty),
      timeZone: json['timeZone'] as String? ?? json['timezone'] as String?,
    );
  }

  factory ClubSummary.fromClub(Club club, {List<String> roles = const []}) {
    return ClubSummary(
      id: club.id,
      name: club.name,
      city: club.city,
      countryCode: club.countryCode,
      currentUserRoles: roles.isNotEmpty ? roles : club.currentUserRoles,
      logoUrl: club.logoUrl,
      hasLogo: club.hasLogo,
      timeZone: club.timezone,
    );
  }
}

class Club {
  const Club({
    required this.id,
    required this.name,
    this.slug,
    this.sportType,
    this.countryCode,
    this.city,
    this.timezone,
    this.currency,
    this.contactEmail,
    this.contactPhone,
    this.status,
    this.currentUserRoles = const [],
    this.hasLogo = false,
    this.logoUrl,
    this.address,
    this.defaultLocale,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String name;
  final String? slug;
  final String? sportType;
  final String? countryCode;
  final String? city;
  final String? timezone;
  final String? currency;
  final String? contactEmail;
  final String? contactPhone;
  final String? status;
  final List<String> currentUserRoles;
  final bool hasLogo;
  final String? logoUrl;
  final String? address;
  final String? defaultLocale;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  factory Club.fromJson(Map<String, dynamic> json) {
    final roles = json['currentUserRoles'];
    final logoUrl = json['logoUrl'] as String?;
    return Club(
      id: json['id']?.toString() ?? '',
      name: json['name'] as String? ?? '',
      slug: json['slug'] as String?,
      sportType: json['sportType'] as String?,
      countryCode: json['countryCode'] as String?,
      city: json['city'] as String?,
      timezone: json['timeZone'] as String? ?? json['timezone'] as String?,
      currency:
          json['defaultCurrency'] as String? ?? json['currency'] as String?,
      contactEmail: json['email'] as String? ?? json['contactEmail'] as String?,
      contactPhone: json['phone'] as String? ?? json['contactPhone'] as String?,
      status: json['status'] as String?,
      currentUserRoles: roles is List
          ? roles.map((e) => e.toString()).toList()
          : const [],
      logoUrl: logoUrl,
      hasLogo: json['hasLogo'] as bool? ??
          (logoUrl != null && logoUrl.isNotEmpty),
      address: json['address'] as String?,
      defaultLocale: json['defaultLocale'] as String?,
      createdAt: _parseDate(json['createdAtUtc'] ?? json['createdAt']),
      updatedAt: _parseDate(json['updatedAtUtc'] ?? json['updatedAt']),
    );
  }

  static DateTime? _parseDate(Object? value) {
    if (value is! String || value.isEmpty) return null;
    return DateTime.tryParse(value);
  }
}
