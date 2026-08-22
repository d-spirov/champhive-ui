import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../l10n/app_localizations.dart';
import '../../../shared/demo/demo_data.dart';
import '../../../shared/models/chat.dart';
import '../../../shared/utils/api_error_message.dart';
import '../../../shared/widgets/ui_bits.dart';
import '../../auth/providers/auth_provider.dart';
import '../../shell/main_shell.dart';
import '../providers/chat_provider.dart';

class MessagesScreen extends ConsumerStatefulWidget {
  const MessagesScreen({super.key});

  @override
  ConsumerState<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends ConsumerState<MessagesScreen> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final auth = ref.watch(authNotifierProvider);
    final isDemo = auth.user?.id == 'demo';

    return Scaffold(
      appBar: shellAppBar(
        context,
        title: l10n.messages,
        actions: [
          IconButton(
            onPressed: () => context.push('/messages/new'),
            icon: const Icon(Icons.edit_square),
            tooltip: l10n.newMessage,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: AppSearchField(
              hintText: l10n.searchMessages,
              onChanged: (v) => setState(() => _query = v),
            ),
          ),
          Expanded(
            child: isDemo ? _demoList(l10n) : _liveList(l10n),
          ),
        ],
      ),
    );
  }

  Widget _demoList(AppLocalizations l10n) {
    final threads = DemoData.messages.where((m) {
      if (_query.isEmpty) return true;
      final q = _query.toLowerCase();
      return m.title.toLowerCase().contains(q) ||
          m.preview.toLowerCase().contains(q);
    }).toList();

    if (threads.isEmpty) {
      return Center(child: Text(l10n.noConversations));
    }

    return ListView.separated(
      itemCount: threads.length,
      separatorBuilder: (_, _) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final thread = threads[index];
        return ListTile(
          leading: AvatarCircle(
            label: thread.title,
            backgroundColor: thread.isGroup
                ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.25)
                : null,
          ),
          title: Text(
            thread.title,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          subtitle: Text(
            thread.preview,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                thread.timeLabel,
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 6),
              UnreadBadge(count: thread.unread),
            ],
          ),
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(l10n.signInToOpenChat)),
            );
          },
        );
      },
    );
  }

  Widget _liveList(AppLocalizations l10n) {
    final async = ref.watch(chatChannelsProvider);

    return async.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                apiErrorMessage(e, fallback: l10n.couldNotLoadConversations),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () => ref.invalidate(chatChannelsProvider),
                child: Text(l10n.retry),
              ),
            ],
          ),
        ),
      ),
      data: (channels) {
        final filtered = channels.where((c) {
          if (_query.isEmpty) return true;
          final q = _query.toLowerCase();
          final preview = c.lastMessage?.body ?? '';
          return c.name.toLowerCase().contains(q) ||
              preview.toLowerCase().contains(q);
        }).toList();

        if (filtered.isEmpty) {
          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(chatChannelsProvider);
              await ref.read(chatChannelsProvider.future);
            },
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                const SizedBox(height: 120),
                Center(child: Text(l10n.noConversationsYet)),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(chatChannelsProvider);
            await ref.read(chatChannelsProvider.future);
          },
          child: ListView.separated(
            physics: const AlwaysScrollableScrollPhysics(),
            itemCount: filtered.length,
            separatorBuilder: (_, _) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final channel = filtered[index];
              return _ChannelTile(
                channel: channel,
                onTap: () => context.push('/messages/${channel.channelId}'),
              );
            },
          ),
        );
      },
    );
  }
}

class _ChannelTile extends StatelessWidget {
  const _ChannelTile({required this.channel, required this.onTap});

  final ChatChannel channel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final preview = channel.lastMessage == null
        ? l10n.noMessagesYet
        : channel.lastMessage!.isDeleted
            ? l10n.messageDeleted
            : (channel.lastMessage!.body ?? '');
    final when = channel.lastMessage?.sentAtUtc ?? channel.updatedAtUtc;

    return ListTile(
      leading: AvatarCircle(
        label: channel.name,
        backgroundColor: channel.isGroup
            ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.25)
            : null,
      ),
      title: Row(
        children: [
          Expanded(
            child: Text(
              channel.name,
              style: TextStyle(
                fontWeight: channel.unreadCount > 0
                    ? FontWeight.w700
                    : FontWeight.w600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (channel.isMuted)
            Padding(
              padding: const EdgeInsets.only(left: 6),
              child: Icon(
                Icons.notifications_off_outlined,
                size: 16,
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withValues(alpha: 0.45),
              ),
            ),
        ],
      ),
      subtitle: Text(
        preview,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontWeight:
              channel.unreadCount > 0 ? FontWeight.w500 : FontWeight.w400,
        ),
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            _formatWhen(when, l10n),
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 6),
          UnreadBadge(count: channel.unreadCount),
        ],
      ),
      onTap: onTap,
    );
  }

  String _formatWhen(DateTime utc, AppLocalizations l10n) {
    final local = utc.toLocal();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final day = DateTime(local.year, local.month, local.day);
    if (day == today) return DateFormat('HH:mm').format(local);
    if (day == today.subtract(const Duration(days: 1))) return l10n.yesterday;
    if (now.difference(local).inDays < 7) {
      return DateFormat('EEE').format(local);
    }
    return DateFormat('d MMM').format(local);
  }
}
