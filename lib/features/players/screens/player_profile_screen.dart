import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../l10n/app_localizations.dart';
import '../../../shared/demo/demo_data.dart';
import '../../../shared/models/player.dart';
import '../../../shared/utils/api_error_message.dart';
import '../../../shared/widgets/ui_bits.dart';
import '../../auth/providers/auth_provider.dart';
import '../../account/widgets/editable_member_photo.dart';
import '../../clubs/providers/clubs_provider.dart';
import '../providers/players_provider.dart';

class PlayerProfileScreen extends ConsumerWidget {
  const PlayerProfileScreen({super.key, required this.playerId});

  final String playerId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final isDemo = ref.watch(authNotifierProvider).user?.id == 'demo';
    if (isDemo) {
      return _DemoProfile(player: DemoData.player);
    }

    final async = ref.watch(playerDetailProvider(playerId));

    return async.when(
      loading: () => Scaffold(
        appBar: AppBar(title: Text(l10n.member)),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Scaffold(
        appBar: AppBar(title: Text(l10n.member)),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  apiErrorMessage(e, fallback: l10n.couldNotLoadMember),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                FilledButton(
                  onPressed: () =>
                      ref.invalidate(playerDetailProvider(playerId)),
                  child: Text(l10n.retry),
                ),
              ],
            ),
          ),
        ),
      ),
      data: (player) => _PlayerProfileBody(player: player),
    );
  }
}

class _PlayerProfileBody extends ConsumerWidget {
  const _PlayerProfileBody({required this.player});

  final ClubPlayer player;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final clubId = player.clubId ?? ref.watch(selectedClubIdProvider) ?? '';
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.playerProfile),
          bottom: TabBar(
            tabs: [
              Tab(text: l10n.info),
              Tab(text: l10n.teams),
              Tab(text: l10n.notes),
            ],
          ),
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Row(
                children: [
                  EditableMemberPhoto(
                    clubId: clubId,
                    memberId: player.id,
                    label: player.name,
                    size: 72,
                    sheetTitle: l10n.changePhoto,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          player.name,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          player.teamsLabel,
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface
                                        .withValues(alpha: 0.65),
                                  ),
                        ),
                        const SizedBox(height: 8),
                        Chip(label: Text(_statusLabel(l10n, player.status))),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                children: [
                  _InfoTab(player: player),
                  _TeamsTab(player: player),
                  _NotesTab(notes: player.notes),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _statusLabel(AppLocalizations l10n, String status) {
    if (status.toLowerCase() == 'active') return l10n.active;
    if (status.isEmpty) return status;
    return status[0].toUpperCase() + status.substring(1).toLowerCase();
  }
}

class _InfoTab extends StatelessWidget {
  const _InfoTab({required this.player});

  final ClubPlayer player;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final dob = player.dateOfBirth == null
        ? null
        : DateFormat.yMMMd().format(player.dateOfBirth!);
    final rows = <(String, String)>[
      if (dob != null) (l10n.dateOfBirth, dob),
      if (player.age != null) (l10n.age, '${player.age}'),
      if (player.gender != null) (l10n.gender, player.gender!),
      if (player.registrationNumber != null &&
          player.registrationNumber!.isNotEmpty)
        (l10n.registrationNumber, player.registrationNumber!),
      if (player.email != null && player.email!.isNotEmpty)
        (l10n.email, player.email!),
      if (player.phone != null && player.phone!.isNotEmpty)
        (l10n.phone, player.phone!),
      if (player.primaryShirtNumber != null)
        (l10n.shirtNumber, '#${player.primaryShirtNumber}'),
    ];

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const Icon(Icons.folder_copy_outlined),
          title: Text(l10n.documents),
          trailing: const Icon(Icons.chevron_right_rounded),
          onTap: () => context.push(
            '/compliance/members/${player.id}'
            '?name=${Uri.encodeComponent(player.name)}',
          ),
        ),
        const Divider(height: 1),
        if (rows.isEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 24),
            child: Center(child: Text(l10n.noProfileDetailsYet)),
          )
        else
          for (var i = 0; i < rows.length; i++) ...[
            if (i > 0) const Divider(height: 1),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(
                rows[i].$1,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withValues(alpha: 0.55),
                    ),
              ),
              subtitle: Text(
                rows[i].$2,
                style: Theme.of(context).textTheme.titleSmall,
              ),
            ),
          ],
      ],
    );
  }
}

class _TeamsTab extends StatelessWidget {
  const _TeamsTab({required this.player});

  final ClubPlayer player;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    if (player.activeTeams.isEmpty) {
      return Center(child: Text(l10n.notAssignedToTeam));
    }
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: player.activeTeams.length,
      separatorBuilder: (_, _) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final t = player.activeTeams[index];
        return Card(
          child: ListTile(
            leading: AvatarCircle(label: t.teamName),
            title: Text(t.teamName),
            subtitle: t.shirtNumber == null || t.shirtNumber!.isEmpty
                ? null
                : Text(l10n.shirtNumberValue(t.shirtNumber!)),
          ),
        );
      },
    );
  }
}

class _NotesTab extends StatelessWidget {
  const _NotesTab({this.notes});

  final String? notes;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    if (notes == null || notes!.trim().isEmpty) {
      return Center(child: Text(l10n.noNotesYet));
    }
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(notes!, style: Theme.of(context).textTheme.bodyLarge),
      ],
    );
  }
}

class _DemoProfile extends StatelessWidget {
  const _DemoProfile({required this.player});

  final DemoPlayer player;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.playerProfile),
          bottom: TabBar(
            tabs: [
              Tab(text: l10n.info),
              Tab(text: l10n.notes),
            ],
          ),
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Row(
                children: [
                  AvatarCircle(label: player.name, size: 72),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          player.name,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        Text('${player.position} · #${player.number}'),
                        const SizedBox(height: 8),
                        Chip(
                          label: Text(
                            player.status.toLowerCase() == 'active'
                                ? l10n.active
                                : player.status,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                children: [
                  ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      ListTile(
                        title: Text(l10n.email),
                        subtitle: Text(player.email),
                      ),
                      ListTile(
                        title: Text(l10n.phone),
                        subtitle: Text(player.phone),
                      ),
                    ],
                  ),
                  Center(child: Text(l10n.demoNotes)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
