import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../l10n/app_localizations.dart';
import '../../../shared/l10n/date_l10n.dart';
import '../../../shared/models/notification.dart';
import '../../../shared/theme/app_theme.dart';
import '../../../shared/utils/api_error_message.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/notifications_provider.dart';

class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() =>
      _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> {
  final _items = <AppNotification>[];
  DateTime? _nextBefore;
  int _unreadCount = 0;
  bool _loadingMore = false;
  bool _initialLoadDone = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _reload());
  }

  void _applyFeed(NotificationFeed feed, {required bool replace}) {
    setState(() {
      if (replace) {
        _items
          ..clear()
          ..addAll(feed.items);
      } else {
        final seen = _items.map((e) => e.id).toSet();
        for (final n in feed.items) {
          if (seen.add(n.id)) _items.add(n);
        }
      }
      _nextBefore = feed.nextBefore;
      _unreadCount = feed.unreadCount;
      _error = null;
      _initialLoadDone = true;
    });
  }

  Future<void> _reload() async {
    final auth = ref.read(authNotifierProvider);
    if (!auth.isAuthenticated || auth.user?.id == 'demo') {
      setState(() {
        _items.clear();
        _unreadCount = 0;
        _nextBefore = null;
        _initialLoadDone = true;
      });
      return;
    }

    setState(() => _error = null);
    try {
      await ref.read(authApiProvider.future);
      final feed = await ref.read(notificationsApiProvider).listMine(limit: 30);
      if (!mounted) return;
      _applyFeed(feed, replace: true);
      ref.invalidate(notificationFeedProvider);
    } catch (e) {
      if (!mounted) return;
      final l10n = AppLocalizations.of(context)!;
      setState(() {
        _initialLoadDone = true;
        _error = apiErrorMessage(e, fallback: l10n.couldNotLoadNotifications);
      });
    }
  }

  Future<void> _loadMore() async {
    final cursor = _nextBefore;
    if (cursor == null || _loadingMore) return;
    setState(() => _loadingMore = true);
    try {
      final feed = await ref
          .read(notificationsApiProvider)
          .listMine(before: cursor, limit: 30);
      if (!mounted) return;
      _applyFeed(feed, replace: false);
    } catch (e) {
      if (!mounted) return;
      final l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(apiErrorMessage(e, fallback: l10n.couldNotLoadMore)),
        ),
      );
    } finally {
      if (mounted) setState(() => _loadingMore = false);
    }
  }

  Future<void> _markAllRead() async {
    try {
      final result = await ref.read(notificationsApiProvider).markRead();
      if (!mounted) return;
      setState(() {
        _unreadCount = result.unreadCount;
        final now = DateTime.now().toUtc();
        for (var i = 0; i < _items.length; i++) {
          if (!_items[i].isRead) {
            _items[i] = _items[i].copyWith(readAtUtc: now);
          }
        }
      });
      ref.invalidate(notificationFeedProvider);
    } catch (e) {
      if (!mounted) return;
      final l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(apiErrorMessage(e, fallback: l10n.couldNotMarkAsRead)),
        ),
      );
    }
  }

  Future<void> _open(AppNotification n) async {
    if (!n.isRead) {
      try {
        final result = await ref
            .read(notificationsApiProvider)
            .markRead(notificationIds: [n.id]);
        if (mounted) {
          setState(() {
            _unreadCount = result.unreadCount;
            final i = _items.indexWhere((e) => e.id == n.id);
            if (i >= 0) {
              _items[i] = _items[i].copyWith(readAtUtc: DateTime.now().toUtc());
            }
          });
          ref.invalidate(notificationFeedProvider);
        }
      } catch (_) {}
    }

    final link = n.deepLink?.trim();
    if (link == null || link.isEmpty || !mounted) return;
    if (link.startsWith('/')) {
      context.push(link);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDemo = ref.watch(authNotifierProvider).user?.id == 'demo';

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/home');
            }
          },
        ),
        title: Text(l10n.notifications),
        actions: [
          if (_unreadCount > 0)
            TextButton(onPressed: _markAllRead, child: Text(l10n.markAllRead)),
        ],
      ),
      body: isDemo
          ? Center(child: Text(l10n.signInToSeeNotifications))
          : !_initialLoadDone
          ? const Center(child: CircularProgressIndicator())
          : _error != null && _items.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(_error!, textAlign: TextAlign.center),
                    const SizedBox(height: 16),
                    FilledButton(onPressed: _reload, child: Text(l10n.retry)),
                  ],
                ),
              ),
            )
          : _buildList(l10n),
    );
  }

  Widget _buildList(AppLocalizations l10n) {
    if (_items.isEmpty) {
      return RefreshIndicator(
        onRefresh: _reload,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            const SizedBox(height: 120),
            Center(child: Text(l10n.noNotificationsYet)),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _reload,
      child: NotificationListener<ScrollNotification>(
        onNotification: (scroll) {
          if (scroll.metrics.pixels >= scroll.metrics.maxScrollExtent - 200) {
            _loadMore();
          }
          return false;
        },
        child: ListView.separated(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          itemCount: _items.length + (_nextBefore != null ? 1 : 0),
          separatorBuilder: (_, _) => const Divider(height: 1),
          itemBuilder: (context, index) {
            if (index >= _items.length) {
              return Padding(
                padding: const EdgeInsets.all(16),
                child: Center(
                  child: _loadingMore
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : TextButton(
                          onPressed: _loadMore,
                          child: Text(l10n.loadMore),
                        ),
                ),
              );
            }
            final n = _items[index];
            return _NotificationTile(notification: n, onTap: () => _open(n));
          },
        ),
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  const _NotificationTile({required this.notification, required this.onTap});

  final AppNotification notification;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final muted = Theme.of(
      context,
    ).colorScheme.onSurface.withValues(alpha: 0.55);
    final when = appDateFormat(
      context,
      'd MMM · HH:mm',
    ).format(notification.createdAtUtc.toLocal());

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
      leading: CircleAvatar(
        backgroundColor: notification.isRead
            ? Theme.of(context).colorScheme.surfaceContainerHighest
            : AppColors.training.withValues(alpha: 0.15),
        child: Icon(
          _iconForKind(notification.kind),
          color: notification.isRead
              ? muted
              : Theme.of(context).colorScheme.primary,
          size: 22,
        ),
      ),
      title: Text(
        notification.title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
          fontWeight: notification.isRead ? FontWeight.w500 : FontWeight.w700,
        ),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (notification.body.isNotEmpty) ...[
            const SizedBox(height: 2),
            Text(
              notification.body,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          const SizedBox(height: 4),
          Text(
            [
              when,
              if (notification.kind.isNotEmpty) notification.kind,
            ].join(' · '),
            style: Theme.of(
              context,
            ).textTheme.labelSmall?.copyWith(color: muted),
          ),
        ],
      ),
      trailing: notification.isRead
          ? null
          : Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: AppColors.badge,
                shape: BoxShape.circle,
              ),
            ),
      onTap: onTap,
    );
  }

  IconData _iconForKind(String kind) {
    final k = kind.toLowerCase();
    if (k.contains('attendance')) return Icons.how_to_reg_outlined;
    if (k.contains('payment') || k.contains('fee')) {
      return Icons.payments_outlined;
    }
    if (k.contains('chat') || k.contains('message')) {
      return Icons.chat_bubble_outline_rounded;
    }
    if (k.contains('schedule') || k.contains('event') || k.contains('cancel')) {
      return Icons.event_outlined;
    }
    if (k.contains('document') || k.contains('compliance')) {
      return Icons.description_outlined;
    }
    return Icons.notifications_outlined;
  }
}
