import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../l10n/app_localizations.dart';
import '../providers/clubs_provider.dart';
import '../../../shared/models/club.dart';
import '../../../shared/utils/api_error_message.dart';
import '../../../shared/widgets/ui_bits.dart';

class ClubDetailsScreen extends ConsumerWidget {
  const ClubDetailsScreen({super.key, required this.clubId});

  final String clubId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final asyncClub = ref.watch(clubDetailProvider(clubId));

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.club),
      ),
      body: asyncClub.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(apiErrorMessage(e, fallback: l10n.couldNotLoadClub)),
                const SizedBox(height: 12),
                FilledButton(
                  onPressed: () => ref.invalidate(clubDetailProvider(clubId)),
                  child: Text(l10n.retry),
                ),
              ],
            ),
          ),
        ),
        data: (club) => _ClubBody(club: club),
      ),
    );
  }
}

class _ClubBody extends ConsumerWidget {
  const _ClubBody({required this.club});

  final Club club;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final location = [
      if (club.city != null && club.city!.isNotEmpty) club.city!,
      if (club.countryCode != null && club.countryCode!.isNotEmpty) club.countryCode!,
    ].join(', ');

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                AvatarCircle(label: club.name, size: 64),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(club.name, style: Theme.of(context).textTheme.titleLarge),
                      if (club.sportType != null) ...[
                        const SizedBox(height: 4),
                        Text(club.sportType!),
                      ],
                      if (location.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          location,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Card(
          child: Column(
            children: [
              ListTile(
                title: Text(l10n.status),
                trailing: Text(club.status ?? '—'),
              ),
              const Divider(height: 1),
              ListTile(
                title: Text(l10n.timezone),
                trailing: Text(club.timezone ?? '—'),
              ),
              const Divider(height: 1),
              ListTile(
                title: Text(l10n.yourRoles),
                subtitle: Text(
                  club.currentUserRoles.isEmpty
                      ? '—'
                      : club.currentUserRoles.join(', '),
                ),
              ),
              if (club.contactEmail != null) ...[
                const Divider(height: 1),
                ListTile(
                  title: Text(l10n.contact),
                  subtitle: Text(club.contactEmail!),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 16),
        FilledButton.icon(
          onPressed: () async {
            await ref.read(selectedClubIdProvider.notifier).select(club.id);
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(l10n.clubSelected(club.name))),
              );
              context.go('/home');
            }
          },
          icon: const Icon(Icons.check_circle_outline),
          label: Text(l10n.useThisClub),
        ),
      ],
    );
  }
}
