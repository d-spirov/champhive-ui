class ChatParticipant {
  const ChatParticipant({
    required this.userAccountId,
    required this.displayName,
    required this.role,
    this.onBehalfOfMemberId,
  });

  final String userAccountId;
  final String displayName;
  final String role;
  final String? onBehalfOfMemberId;

  factory ChatParticipant.fromJson(Map<String, dynamic> json) {
    return ChatParticipant(
      userAccountId: json['userAccountId']?.toString() ?? '',
      displayName: json['displayName'] as String? ?? '',
      role: json['role'] as String? ?? '',
      onBehalfOfMemberId: json['onBehalfOfMemberId']?.toString(),
    );
  }
}

class ChatMessage {
  const ChatMessage({
    required this.messageId,
    required this.channelId,
    required this.clientMessageId,
    required this.kind,
    required this.isDeleted,
    required this.sentAtUtc,
    this.senderUserAccountId,
    this.senderDisplayName,
    this.onBehalfOfMemberId,
    this.body,
    this.deletedAtUtc,
    this.editedAtUtc,
  });

  final String messageId;
  final String channelId;
  final String clientMessageId;
  final String? senderUserAccountId;
  final String? senderDisplayName;
  final String? onBehalfOfMemberId;
  final String? body;
  final String kind;
  final bool isDeleted;
  final DateTime? deletedAtUtc;
  final DateTime sentAtUtc;
  final DateTime? editedAtUtc;

  bool get isSystem => kind.toLowerCase() == 'system';

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      messageId: json['messageId']?.toString() ?? '',
      channelId: json['channelId']?.toString() ?? '',
      clientMessageId: json['clientMessageId']?.toString() ?? '',
      senderUserAccountId: json['senderUserAccountId']?.toString(),
      senderDisplayName: json['senderDisplayName'] as String?,
      onBehalfOfMemberId: json['onBehalfOfMemberId']?.toString(),
      body: json['body'] as String?,
      kind: json['kind'] as String? ?? 'text',
      isDeleted: json['isDeleted'] as bool? ?? false,
      deletedAtUtc:
          DateTime.tryParse(json['deletedAtUtc'] as String? ?? '')?.toUtc(),
      sentAtUtc: DateTime.tryParse(json['sentAtUtc'] as String? ?? '')?.toUtc() ??
          DateTime.now().toUtc(),
      editedAtUtc:
          DateTime.tryParse(json['editedAtUtc'] as String? ?? '')?.toUtc(),
    );
  }
}

class ChatMessagePage {
  const ChatMessagePage({
    required this.items,
    this.nextBefore,
  });

  final List<ChatMessage> items;
  final String? nextBefore;

  bool get hasMore => nextBefore != null;

  factory ChatMessagePage.fromJson(Map<String, dynamic> json) {
    final raw = json['items'];
    final items = <ChatMessage>[];
    if (raw is List) {
      for (final e in raw) {
        if (e is Map) {
          items.add(ChatMessage.fromJson(Map<String, dynamic>.from(e)));
        }
      }
    }
    final before = json['nextBefore'];
    return ChatMessagePage(
      items: items,
      nextBefore: before is String && before.isNotEmpty ? before : null,
    );
  }
}

class ChatChannel {
  const ChatChannel({
    required this.channelId,
    required this.clubId,
    required this.type,
    required this.name,
    required this.participants,
    required this.participantCount,
    required this.unreadCount,
    required this.isMuted,
    required this.canSend,
    required this.updatedAtUtc,
    required this.createdAtUtc,
    this.teamId,
    this.lastMessage,
    this.lastReadMessageId,
  });

  final String channelId;
  final String clubId;
  final String type;
  final String name;
  final String? teamId;
  final List<ChatParticipant> participants;
  final int participantCount;
  final ChatMessage? lastMessage;
  final int unreadCount;
  final String? lastReadMessageId;
  final bool isMuted;
  final bool canSend;
  final DateTime updatedAtUtc;
  final DateTime createdAtUtc;

  bool get isGroup => type.toLowerCase() == 'team';
  bool get isDirect => type.toLowerCase() == 'direct';

  factory ChatChannel.fromJson(Map<String, dynamic> json) {
    final partsRaw = json['participants'];
    final participants = <ChatParticipant>[];
    if (partsRaw is List) {
      for (final e in partsRaw) {
        if (e is Map) {
          participants.add(
            ChatParticipant.fromJson(Map<String, dynamic>.from(e)),
          );
        }
      }
    }
    final last = json['lastMessage'];
    return ChatChannel(
      channelId: json['channelId']?.toString() ?? '',
      clubId: json['clubId']?.toString() ?? '',
      type: json['type'] as String? ?? '',
      name: json['name'] as String? ?? '',
      teamId: json['teamId']?.toString(),
      participants: participants,
      participantCount: (json['participantCount'] as num?)?.toInt() ?? 0,
      lastMessage: last is Map
          ? ChatMessage.fromJson(Map<String, dynamic>.from(last))
          : null,
      unreadCount: (json['unreadCount'] as num?)?.toInt() ?? 0,
      lastReadMessageId: json['lastReadMessageId']?.toString(),
      isMuted: json['isMuted'] as bool? ?? false,
      canSend: json['canSend'] as bool? ?? true,
      updatedAtUtc:
          DateTime.tryParse(json['updatedAtUtc'] as String? ?? '')?.toUtc() ??
              DateTime.now().toUtc(),
      createdAtUtc:
          DateTime.tryParse(json['createdAtUtc'] as String? ?? '')?.toUtc() ??
              DateTime.now().toUtc(),
    );
  }
}

class ChatChannelPage {
  const ChatChannelPage({
    required this.items,
    required this.page,
    required this.pageSize,
    required this.totalCount,
  });

  final List<ChatChannel> items;
  final int page;
  final int pageSize;
  final int totalCount;

  factory ChatChannelPage.fromJson(Map<String, dynamic> json) {
    final raw = json['items'];
    final items = <ChatChannel>[];
    if (raw is List) {
      for (final e in raw) {
        if (e is Map) {
          items.add(ChatChannel.fromJson(Map<String, dynamic>.from(e)));
        }
      }
    }
    return ChatChannelPage(
      items: items,
      page: (json['page'] as num?)?.toInt() ?? 1,
      pageSize: (json['pageSize'] as num?)?.toInt() ?? 30,
      totalCount: (json['totalCount'] as num?)?.toInt() ?? items.length,
    );
  }
}
