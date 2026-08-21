import 'dart:math';

import 'package:dio/dio.dart';

import '../models/chat.dart';

class ChatApi {
  ChatApi(this._dio);

  final Dio _dio;

  Future<ChatChannelPage> listChannels({
    int page = 1,
    int pageSize = 50,
  }) async {
    final response = await _dio.get<dynamic>(
      '/api/v1/chat/channels',
      queryParameters: {
        'page': page,
        'pageSize': pageSize,
      },
    );
    return ChatChannelPage.fromJson(_asMap(response, 'Empty channel list'));
  }

  Future<ChatChannel> getChannel(String channelId) async {
    final response = await _dio.get<dynamic>(
      '/api/v1/chat/channels/$channelId',
    );
    return ChatChannel.fromJson(_asMap(response, 'Empty channel'));
  }

  Future<ChatChannel> openDirect({
    required String participantUserAccountId,
    String? onBehalfOfMemberId,
  }) async {
    final response = await _dio.post<dynamic>(
      '/api/v1/chat/channels/direct',
      data: {
        'participantUserAccountId': participantUserAccountId,
        'onBehalfOfMemberId': onBehalfOfMemberId,
      },
    );
    return ChatChannel.fromJson(_asMap(response, 'Empty direct channel'));
  }

  /// Newest-first cursor feed. Pass [before] = previous [ChatMessagePage.nextBefore].
  Future<ChatMessagePage> listMessages(
    String channelId, {
    String? before,
    int limit = 40,
  }) async {
    final response = await _dio.get<dynamic>(
      '/api/v1/chat/channels/$channelId/messages',
      queryParameters: {
        'before': ?before,
        'limit': limit,
      },
    );
    return ChatMessagePage.fromJson(_asMap(response, 'Empty messages'));
  }

  Future<ChatMessage> sendMessage(
    String channelId, {
    required String body,
    String? clientMessageId,
    String? onBehalfOfMemberId,
  }) async {
    final response = await _dio.post<dynamic>(
      '/api/v1/chat/channels/$channelId/messages',
      data: {
        'body': body,
        'clientMessageId': clientMessageId ?? newClientMessageId(),
        'onBehalfOfMemberId': onBehalfOfMemberId,
      },
    );
    return ChatMessage.fromJson(_asMap(response, 'Empty send response'));
  }

  Future<void> markRead(String channelId, {required String messageId}) async {
    await _dio.put<dynamic>(
      '/api/v1/chat/channels/$channelId/read',
      data: {'messageId': messageId},
    );
  }

  Future<void> setMuted(String channelId, {required bool muted}) async {
    await _dio.put<dynamic>(
      '/api/v1/chat/channels/$channelId/mute',
      data: {'muted': muted},
    );
  }

  static String newClientMessageId() {
    final r = Random.secure();
    final bytes = List<int>.generate(16, (_) => r.nextInt(256));
    bytes[6] = (bytes[6] & 0x0f) | 0x40;
    bytes[8] = (bytes[8] & 0x3f) | 0x80;
    String hex(int b) => b.toRadixString(16).padLeft(2, '0');
    final h = bytes.map(hex).join();
    return '${h.substring(0, 8)}-${h.substring(8, 12)}-'
        '${h.substring(12, 16)}-${h.substring(16, 20)}-${h.substring(20)}';
  }

  Map<String, dynamic> _asMap(Response<dynamic> response, String emptyMessage) {
    final raw = response.data;
    if (raw is! Map) {
      throw DioException(
        requestOptions: response.requestOptions,
        type: DioExceptionType.badResponse,
        response: response,
        message: emptyMessage,
      );
    }
    return Map<String, dynamic>.from(raw);
  }
}
