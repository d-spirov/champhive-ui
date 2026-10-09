import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../l10n/app_localizations.dart';
import '../../../shared/models/club.dart';
import '../../../shared/models/permission_toggle.dart';
import '../../../shared/utils/api_error_message.dart';
import '../../../shared/widgets/ui_bits.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/clubs_provider.dart';

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
        _ClubPermissionToggles(clubId: club.id),
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

class _ClubPermissionToggles extends ConsumerWidget {
  const _ClubPermissionToggles({required this.clubId});

  final String clubId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authNotifierProvider).user;
    if (user == null || !user.hasClubWideStaffGrant(clubId)) {
      return const SizedBox.shrink();
    }

    final l10n = AppLocalizations.of(context)!;
    final async = ref.watch(clubPermissionTogglesProvider(clubId));

    return async.when(
      loading: () => const Padding(
        padding: EdgeInsets.symmetric(vertical: 12),
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Card(
        child: ListTile(
          title: Text(l10n.clubPermissions),
          subtitle: Text(
            apiErrorMessage(e, fallback: l10n.couldNotLoadClubPermissions),
          ),
        ),
      ),
      data: (toggles) {
        if (toggles.isEmpty) return const SizedBox.shrink();
        return Card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
                child: Text(
                  l10n.clubPermissions,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              for (var i = 0; i < toggles.length; i++) ...[
                if (i > 0) const Divider(height: 1),
                _PermissionToggleTile(clubId: clubId, toggle: toggles[i]),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _PermissionToggleTile extends ConsumerStatefulWidget {
  const _PermissionToggleTile({required this.clubId, required this.toggle});

  final String clubId;
  final PermissionToggle toggle;

  @override
  ConsumerState<_PermissionToggleTile> createState() =>
      _PermissionToggleTileState();
}

class _PermissionToggleTileState extends ConsumerState<_PermissionToggleTile> {
  bool _saving = false;

  (String, String?) _copy(AppLocalizations l10n, String key) {
    switch (key) {
      case 'coachCreatesMembers':
        return (l10n.coachCreatesMembers, l10n.coachCreatesMembersHint);
      case 'coachSeesPaymentStatus':
        return (l10n.coachSeesPaymentStatus, l10n.coachSeesPaymentStatusHint);
      case 'trainingPlanCoachScope':
        return (l10n.trainingPlanCoachScope, l10n.trainingPlanCoachScopeHint);
      default:
        return (key, null);
    }
  }

  Future<void> _setEnabled(bool enabled) async {
    if (_saving) return;
    setState(() => _saving = true);
    try {
      final api = ref.read(clubsApiProvider);
      await api.setPermissionToggles(
        clubId: widget.clubId,
        toggles: {widget.toggle.key: enabled},
      );
      ref.invalidate(clubPermissionTogglesProvider(widget.clubId));
    } catch (e) {
      if (!mounted) return;
      final l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            apiErrorMessage(e, fallback: l10n.couldNotSaveClubPermissions),
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final (title, hint) = _copy(l10n, widget.toggle.key);
    return SwitchListTile(
      title: Text(title),
      subtitle: hint == null ? null : Text(hint),
      value: widget.toggle.enabled,
      onChanged: _saving ? null : _setEnabled,
    );
  }
}
