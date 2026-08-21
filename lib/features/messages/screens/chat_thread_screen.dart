import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../shared/models/chat.dart';
import '../../../shared/services/chat_api.dart';
import '../../../shared/theme/app_theme.dart';
import '../../../shared/utils/api_error_message.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/chat_provider.dart';

class ChatThreadScreen extends ConsumerStatefulWidget {
  const ChatThreadScreen({super.key, required this.channelId});

  final String channelId;

  @override
  ConsumerState<ChatThreadScreen> createState() => _ChatThreadScreenState();
}

class _ChatThreadScreenState extends ConsumerState<ChatThreadScreen> {
  final _controller = TextEditingController();
  final _scroll = ScrollController();

  /// Chronological (oldest → newest) for chat bubbles.
  final _messages = <ChatMessage>[];
  String? _nextBefore;
  bool _loading = true;
  bool _loadingMore = false;
  bool _sending = false;
  String? _error;
  ChatChannel? _channel;

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) => _bootstrap());
  }

  @override
  void dispose() {
    _scroll.removeListener(_onScroll);
    _scroll.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scroll.hasClients || _loadingMore || _nextBefore == null) return;
    // List is reversed visually via reverse:true — near maxScrollExtent is older.
    if (_scroll.position.pixels >= _scroll.position.maxScrollExtent - 120) {
      _loadOlder();
    }
  }

  Future<void> _bootstrap() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await ref.read(authApiProvider.future);
      final api = ref.read(chatApiProvider);
      final channel = await api.getChannel(widget.channelId);
      final page = await api.listMessages(widget.channelId, limit: 40);
      if (!mounted) return;

      final chronological = page.items.reversed.toList();
      setState(() {
        _channel = channel;
        _messages
          ..clear()
          ..addAll(chronological);
        _nextBefore = page.nextBefore;
        _loading = false;
      });

      await _markNewestRead();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = apiErrorMessage(e, fallback: 'Could not load chat');
      });
    }
  }

  Future<void> _loadOlder() async {
    final cursor = _nextBefore;
    if (cursor == null || _loadingMore) return;
    setState(() => _loadingMore = true);
    try {
      final page = await ref.read(chatApiProvider).listMessages(
            widget.channelId,
            before: cursor,
            limit: 40,
          );
      if (!mounted) return;
      final older = page.items.reversed.toList();
      setState(() {
        _messages.insertAll(0, older);
        _nextBefore = page.nextBefore;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(apiErrorMessage(e, fallback: 'Could not load older')),
        ),
      );
    } finally {
      if (mounted) setState(() => _loadingMore = false);
    }
  }

  Future<void> _markNewestRead() async {
    if (_messages.isEmpty) return;
    final newest = _messages.last;
    try {
      await ref.read(chatApiProvider).markRead(
            widget.channelId,
            messageId: newest.messageId,
          );
      ref.invalidate(chatChannelsProvider);
    } catch (_) {}
  }

  Future<void> _send() async {
    final text = _controller.text.trim();
    if (text.isEmpty || _sending) return;
    if (_channel?.canSend == false) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You cannot send in this channel')),
      );
      return;
    }

    final clientId = ChatApi.newClientMessageId();
    final me = ref.read(authNotifierProvider).user;
    final optimistic = ChatMessage(
      messageId: 'local-$clientId',
      channelId: widget.channelId,
      clientMessageId: clientId,
      senderUserAccountId: me?.id,
      senderDisplayName: me?.displayName,
      body: text,
      kind: 'text',
      isDeleted: false,
      sentAtUtc: DateTime.now().toUtc(),
    );

    setState(() {
      _sending = true;
      _messages.add(optimistic);
      _controller.clear();
    });

    try {
      final sent = await ref.read(chatApiProvider).sendMessage(
            widget.channelId,
            body: text,
            clientMessageId: clientId,
          );
      if (!mounted) return;
      setState(() {
        final i = _messages.indexWhere((m) => m.clientMessageId == clientId);
        if (i >= 0) {
          _messages[i] = sent;
        } else {
          _messages.add(sent);
        }
      });
      await _markNewestRead();
      ref.invalidate(chatChannelsProvider);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _messages.removeWhere((m) => m.clientMessageId == clientId);
        _controller.text = text;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(apiErrorMessage(e, fallback: 'Could not send message')),
        ),
      );
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = _channel?.name ?? 'Chat';
    final canSend = _channel?.canSend ?? true;
    final myId = ref.watch(authNotifierProvider).user?.id;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/messages');
            }
          },
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, maxLines: 1, overflow: TextOverflow.ellipsis),
            if (_channel != null)
              Text(
                _channel!.isGroup
                    ? '${_channel!.participantCount} members'
                    : (_channel!.type),
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withValues(alpha: 0.55),
                    ),
              ),
          ],
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null && _messages.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(_error!, textAlign: TextAlign.center),
                        const SizedBox(height: 16),
                        FilledButton(
                          onPressed: _bootstrap,
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                )
              : Column(
                  children: [
                    if (_loadingMore)
                      const LinearProgressIndicator(minHeight: 2),
                    Expanded(
                      child: _messages.isEmpty
                          ? const Center(child: Text('Say hello'))
                          : ListView.builder(
                              controller: _scroll,
                              reverse: true,
                              padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
                              itemCount: _messages.length,
                              itemBuilder: (context, index) {
                                // reverse:true → index 0 is newest
                                final msg =
                                    _messages[_messages.length - 1 - index];
                                final mine = myId != null &&
                                    msg.senderUserAccountId == myId;
                                return _Bubble(message: msg, mine: mine);
                              },
                            ),
                    ),
                    SafeArea(
                      top: false,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _controller,
                                enabled: canSend && !_sending,
                                minLines: 1,
                                maxLines: 4,
                                textInputAction: TextInputAction.send,
                                onSubmitted: (_) => _send(),
                                decoration: InputDecoration(
                                  hintText: canSend
                                      ? 'Message'
                                      : 'Read only',
                                  filled: true,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(
                                      AppTheme.radiusSm,
                                    ),
                                    borderSide: BorderSide.none,
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 10,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            IconButton.filled(
                              onPressed:
                                  canSend && !_sending ? _send : null,
                              icon: _sending
                                  ? const SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : const Icon(Icons.send_rounded),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
    );
  }
}

class _Bubble extends StatelessWidget {
  const _Bubble({required this.message, required this.mine});

  final ChatMessage message;
  final bool mine;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isSystem = message.isSystem;
    final deleted = message.isDeleted;
    final body = deleted
        ? 'Message deleted'
        : (message.body ?? '');
    final when = DateFormat('HH:mm').format(message.sentAtUtc.toLocal());

    if (isSystem) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Center(
          child: Text(
            body.isEmpty ? 'System' : body,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: scheme.onSurface.withValues(alpha: 0.55),
                ),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    final bg = mine
        ? scheme.primary
        : scheme.surfaceContainerHighest;
    final fg = mine ? scheme.onPrimary : scheme.onSurface;

    return Align(
      alignment: mine ? Alignment.centerRight : Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.sizeOf(context).width * 0.78,
        ),
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 4),
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 6),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(14),
              topRight: const Radius.circular(14),
              bottomLeft: Radius.circular(mine ? 14 : 4),
              bottomRight: Radius.circular(mine ? 4 : 14),
            ),
          ),
          child: Column(
            crossAxisAlignment:
                mine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              if (!mine && (message.senderDisplayName?.isNotEmpty ?? false))
                Padding(
                  padding: const EdgeInsets.only(bottom: 2),
                  child: Text(
                    message.senderDisplayName!,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: fg.withValues(alpha: 0.75),
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ),
              Text(
                body,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: fg,
                      fontStyle: deleted ? FontStyle.italic : null,
                    ),
              ),
              const SizedBox(height: 2),
              Text(
                when,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: fg.withValues(alpha: 0.65),
                      fontSize: 10,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
