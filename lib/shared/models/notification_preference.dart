class NotificationPreference {
  const NotificationPreference({
    required this.key,
    required this.channel,
    required this.enabled,
    required this.isDefault,
  });

  final String key;
  final String channel;
  final bool enabled;
  final bool isDefault;

  bool get isPushChannel {
    final c = channel.toLowerCase();
    return c == 'push' || c == 'fcm' || c == 'apns';
  }

  NotificationPreference copyWith({bool? enabled}) {
    return NotificationPreference(
      key: key,
      channel: channel,
      enabled: enabled ?? this.enabled,
      isDefault: isDefault,
    );
  }

  Map<String, dynamic> toUpdateJson() => {
        'key': key,
        'channel': channel,
        'enabled': enabled,
      };

  factory NotificationPreference.fromJson(Map<String, dynamic> json) {
    return NotificationPreference(
      key: json['key'] as String? ?? '',
      channel: json['channel'] as String? ?? '',
      enabled: json['enabled'] as bool? ?? false,
      isDefault: json['isDefault'] as bool? ?? false,
    );
  }
}
