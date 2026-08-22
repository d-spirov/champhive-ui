import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../l10n/app_localizations.dart';
import '../../../shared/models/staff.dart';
import '../../../shared/utils/api_error_message.dart';
import '../../../shared/widgets/ui_bits.dart';
import '../providers/chat_provider.dart';

class ComposeDirectMessageScreen extends ConsumerStatefulWidget {
  const ComposeDirectMessageScreen({super.key});

  @override
  ConsumerState<ComposeDirectMessageScreen> createState() =>
      _ComposeDirectMessageScreenState();
}

class _ComposeDirectMessageScreenState
    extends ConsumerState<ComposeDirectMessageScreen> {
  String _query = '';
  String? _openingUserId;

  Future<void> _open(DirectMessageCandidate candidate) async {
    if (_openingUserId != null) return;
    setState(() => _openingUserId = candidate.userAccountId);
    try {
      final channel = await ref.read(chatApiProvider).openDirect(
            participantUserAccountId: candidate.userAccountId,
          );
      ref.invalidate(chatChannelsProvider);
      if (!mounted) return;
      context.pushReplacement('/messages/${channel.channelId}');
    } catch (e) {
      if (!mounted) return;
      final l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            apiErrorMessage(e, fallback: l10n.couldNotOpenConversation),
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => _openingUserId = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final async = ref.watch(directMessageCandidatesProvider);

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
        title: Text(l10n.newMessage),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: AppSearchField(
              hintText: l10n.searchPeople,
              onChanged: (v) => setState(() => _query = v),
            ),
          ),
          Expanded(
            child: async.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        apiErrorMessage(
                          e,
                          fallback: l10n.couldNotLoadPeople,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      FilledButton(
                        onPressed: () =>
                            ref.invalidate(directMessageCandidatesProvider),
                        child: Text(l10n.retry),
                      ),
                    ],
                  ),
                ),
              ),
              data: (candidates) {
                final q = _query.trim().toLowerCase();
                final filtered = q.isEmpty
                    ? candidates
                    : candidates.where((c) {
                        return c.name.toLowerCase().contains(q) ||
                            (c.email?.toLowerCase().contains(q) ?? false) ||
                            (c.subtitle?.toLowerCase().contains(q) ?? false);
                      }).toList();

                if (candidates.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(
                        l10n.noAdultsToMessage,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                }

                if (filtered.isEmpty) {
                  return Center(child: Text(l10n.noMatches));
                }

                return ListView.separated(
                  itemCount: filtered.length,
                  separatorBuilder: (_, _) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final c = filtered[index];
                    final opening = _openingUserId == c.userAccountId;
                    return ListTile(
                      leading: AvatarCircle(label: c.name),
                      title: Text(c.name),
                      subtitle: Text(
                        [
                          if (c.subtitle != null && c.subtitle!.isNotEmpty)
                            c.subtitle!,
                          if (c.email != null && c.email!.isNotEmpty) c.email!,
                        ].join(' · '),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: opening
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.chat_bubble_outline_rounded),
                      onTap: _openingUserId == null ? () => _open(c) : null,
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
