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

  factory ClubSummary.fromJson(Map<String, dynamic> json) {
    final roles = json['currentUserRoles'];
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
      hasLogo: json['hasLogo'] as bool? ?? false,
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
  final DateTime? createdAt;
  final DateTime? updatedAt;

  factory Club.fromJson(Map<String, dynamic> json) {
    final roles = json['currentUserRoles'];
    return Club(
      id: json['id']?.toString() ?? '',
      name: json['name'] as String? ?? '',
      slug: json['slug'] as String?,
      sportType: json['sportType'] as String?,
      countryCode: json['countryCode'] as String?,
      city: json['city'] as String?,
      timezone: json['timezone'] as String?,
      currency: json['currency'] as String?,
      contactEmail: json['contactEmail'] as String?,
      contactPhone: json['contactPhone'] as String?,
      status: json['status'] as String?,
      currentUserRoles: roles is List
          ? roles.map((e) => e.toString()).toList()
          : const [],
      hasLogo: json['hasLogo'] as bool? ?? false,
      createdAt: _parseDate(json['createdAt']),
      updatedAt: _parseDate(json['updatedAt']),
    );
  }

  static DateTime? _parseDate(Object? value) {
    if (value is! String || value.isEmpty) return null;
    return DateTime.tryParse(value);
  }
}
