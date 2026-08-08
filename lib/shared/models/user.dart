class User {
  const User({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    this.phone,
    this.status,
    this.emailVerified = false,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String email;
  final String firstName;
  final String lastName;
  final String? phone;
  final String? status;
  final bool emailVerified;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  String get displayName {
    final parts = [firstName, lastName].where((p) => p.trim().isNotEmpty);
    if (parts.isNotEmpty) return parts.join(' ');
    return email.contains('@') ? email.split('@').first : email;
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id']?.toString() ?? '',
      email: json['email'] as String? ?? '',
      firstName: json['firstName'] as String? ?? '',
      lastName: json['lastName'] as String? ?? '',
      phone: json['phone'] as String?,
      status: json['status'] as String?,
      emailVerified: json['emailVerified'] as bool? ?? false,
      createdAt: _parseDate(json['createdAt']),
      updatedAt: _parseDate(json['updatedAt']),
    );
  }

  static DateTime? _parseDate(Object? value) {
    if (value is! String || value.isEmpty) return null;
    return DateTime.tryParse(value);
  }
}
