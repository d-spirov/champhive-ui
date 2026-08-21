class AppNotification {
  const AppNotification({
    required this.id,
    required this.clubId,
    required this.kind,
    required this.title,
    required this.body,
    required this.createdAtUtc,
    this.deepLink,
    this.sourceId,
    this.readAtUtc,
    this.pushStatus,
    this.emailStatus,
  });

  final String id;
  final String clubId;
  final String kind;
  final String title;
  final String body;
  final String? deepLink;
  final String? sourceId;
  final DateTime createdAtUtc;
  final DateTime? readAtUtc;
  final String? pushStatus;
  final String? emailStatus;

  bool get isRead => readAtUtc != null;

  AppNotification copyWith({
    DateTime? readAtUtc,
    bool clearReadAt = false,
  }) {
    return AppNotification(
      id: id,
      clubId: clubId,
      kind: kind,
      title: title,
      body: body,
      deepLink: deepLink,
      sourceId: sourceId,
      createdAtUtc: createdAtUtc,
      readAtUtc: clearReadAt ? null : (readAtUtc ?? this.readAtUtc),
      pushStatus: pushStatus,
      emailStatus: emailStatus,
    );
  }

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: json['id']?.toString() ?? '',
      clubId: json['clubId']?.toString() ?? '',
      kind: json['kind'] as String? ?? '',
      title: json['title'] as String? ?? '',
      body: json['body'] as String? ?? '',
      deepLink: json['deepLink'] as String?,
      sourceId: json['sourceId']?.toString(),
      createdAtUtc: DateTime.tryParse(json['createdAtUtc'] as String? ?? '')
              ?.toUtc() ??
          DateTime.now().toUtc(),
      readAtUtc: DateTime.tryParse(json['readAtUtc'] as String? ?? '')?.toUtc(),
      pushStatus: json['pushStatus'] as String?,
      emailStatus: json['emailStatus'] as String?,
    );
  }
}

class NotificationFeed {
  const NotificationFeed({
    required this.items,
    required this.unreadCount,
    this.nextBefore,
  });

  final List<AppNotification> items;
  final int unreadCount;
  final DateTime? nextBefore;

  bool get hasMore => nextBefore != null;

  factory NotificationFeed.fromJson(Map<String, dynamic> json) {
    final raw = json['items'];
    final items = <AppNotification>[];
    if (raw is List) {
      for (final e in raw) {
        if (e is Map) {
          items.add(AppNotification.fromJson(Map<String, dynamic>.from(e)));
        }
      }
    }
    final before = json['nextBefore'];
    return NotificationFeed(
      items: items,
      unreadCount: (json['unreadCount'] as num?)?.toInt() ?? 0,
      nextBefore: before is String && before.isNotEmpty
          ? DateTime.tryParse(before)?.toUtc()
          : null,
    );
  }
}

class MarkNotificationsReadResult {
  const MarkNotificationsReadResult({
    required this.markedCount,
    required this.unreadCount,
  });

  final int markedCount;
  final int unreadCount;

  factory MarkNotificationsReadResult.fromJson(Map<String, dynamic> json) {
    return MarkNotificationsReadResult(
      markedCount: (json['markedCount'] as num?)?.toInt() ?? 0,
      unreadCount: (json['unreadCount'] as num?)?.toInt() ?? 0,
    );
  }
}
