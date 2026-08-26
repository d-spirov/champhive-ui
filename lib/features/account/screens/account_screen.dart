import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../l10n/app_localizations.dart';
import '../../../shared/models/family.dart';
import '../../../shared/models/notification_preference.dart';
import '../../../shared/models/user.dart';
import '../../../shared/providers/locale_provider.dart';
import '../../../shared/theme/app_theme.dart';
import '../../../shared/utils/api_error_message.dart';
import '../../../shared/widgets/ui_bits.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/account_extras_provider.dart';
import '../widgets/editable_member_photo.dart';

List<(String code, String label)> _profileLocaleOptions(AppLocalizations l10n) {
  return [
    ('en', l10n.languageEnglish),
    ('mk', l10n.languageMacedonian),
    ('sr-Latn', l10n.languageSerbian),
    ('it', l10n.languageItalian),
    ('bs', l10n.languageBosnian),
    ('tr', l10n.languageTurkish),
  ];
}


String _humanizeKey(String raw) {
  if (raw.isEmpty) return raw;
  return raw
      .replaceAll('.', ' ')
      .replaceAll('_', ' ')
      .replaceAll('-', ' ')
      .split(RegExp(r'\s+'))
      .where((w) => w.isNotEmpty)
      .map((w) => '${w[0].toUpperCase()}${w.substring(1)}')
      .join(' ');
}

String _consentReasonLabel(AppLocalizations l10n, String reason) {
  switch (reason) {
    case 'never_granted':
      return l10n.consentReasonNeverGranted;
    case 'withdrawn':
      return l10n.consentReasonWithdrawn;
    case 'new_version':
      return l10n.consentReasonNewVersion;
    default:
      return l10n.consentReasonOther;
  }
}

String _channelLabel(AppLocalizations l10n, String channel) {
  switch (channel.toLowerCase()) {
    case 'email':
      return l10n.channelEmail;
    default:
      return l10n.channelOther(channel);
  }
}

class AccountScreen extends ConsumerStatefulWidget {
  const AccountScreen({super.key});

  @override
  ConsumerState<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends ConsumerState<AccountScreen> {
  final _firstNameCtrl = TextEditingController();
  final _lastNameCtrl = TextEditingController();
  String? _locale;
  bool _hydrated = false;
  bool _savingProfile = false;
  bool _changingPassword = false;
  String? _togglingPrefId;
  String? _grantingConsentId;

  final _currentPwCtrl = TextEditingController();
  final _newPwCtrl = TextEditingController();
  final _confirmPwCtrl = TextEditingController();
  bool _obscureCurrent = true;
  bool _obscureNew = true;

  @override
  void dispose() {
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _currentPwCtrl.dispose();
    _newPwCtrl.dispose();
    _confirmPwCtrl.dispose();
    super.dispose();
  }

  void _hydrateFrom(User user) {
    _firstNameCtrl.text = user.firstName;
    _lastNameCtrl.text = user.lastName;
    _locale = user.locale.isNotEmpty ? user.locale : 'en';
    _hydrated = true;
  }

  Future<void> _reload() async {
    final user = await ref
        .read(authNotifierProvider.notifier)
        .refreshCurrentUser();
    await ref.read(accountExtrasControllerProvider).refreshAll();
    if (!mounted || user == null) return;
    setState(() => _hydrateFrom(user));
  }

  Future<void> _saveProfile() async {
    final l10n = AppLocalizations.of(context)!;
    final first = _firstNameCtrl.text.trim();
    final last = _lastNameCtrl.text.trim();
    if (first.isEmpty || last.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.namesRequired)));
      return;
    }
    setState(() => _savingProfile = true);
    final ok = await ref
        .read(authNotifierProvider.notifier)
        .updateProfile(firstName: first, lastName: last, locale: _locale);
    if (ok && _locale != null) {
      await ref
          .read(localeProvider.notifier)
          .setLocale(AppLocales.tryParse(_locale));
    }
    if (!mounted) return;
    setState(() => _savingProfile = false);
    final err = ref.read(authNotifierProvider).error;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(ok ? l10n.profileSaved : (err ?? l10n.saveFailed)),
      ),
    );
  }

  Future<void> _changePassword() async {
    final l10n = AppLocalizations.of(context)!;
    final current = _currentPwCtrl.text;
    final next = _newPwCtrl.text;
    final confirm = _confirmPwCtrl.text;
    if (current.isEmpty || next.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.enterCurrentAndNewPassword)));
      return;
    }
    if (next != confirm) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.newPasswordsDoNotMatch)));
      return;
    }
    if (next.length < 8) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.newPasswordMinLength)));
      return;
    }

    setState(() => _changingPassword = true);
    final ok = await ref
        .read(authNotifierProvider.notifier)
        .changePassword(currentPassword: current, newPassword: next);
    if (!mounted) return;
    setState(() => _changingPassword = false);
    if (ok) {
      _currentPwCtrl.clear();
      _newPwCtrl.clear();
      _confirmPwCtrl.clear();
    }
    final err = ref.read(authNotifierProvider).error;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          ok
              ? l10n.passwordChangedSessionsSignedOut
              : (err ?? l10n.couldNotChangePassword),
        ),
      ),
    );
  }

  Future<void> _togglePreference(
    NotificationPreference pref,
    bool enabled,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    final id = '${pref.key}|${pref.channel}';
    setState(() => _togglingPrefId = id);
    try {
      await ref
          .read(accountExtrasControllerProvider)
          .setPreferenceEnabled(
            key: pref.key,
            channel: pref.channel,
            enabled: enabled,
          );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(apiErrorMessage(e, fallback: l10n.saveFailed)),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _togglingPrefId = null);
    }
  }

  Future<void> _openGrantConsent(PendingConsent consent) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text(l10n.consentForMember(consent.memberFirstName)),
          content: SizedBox(
            width: double.maxFinite,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _humanizeKey(consent.kind),
                    style: Theme.of(ctx).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    [
                      l10n.consentVersion(consent.version),
                      _consentReasonLabel(l10n, consent.reason),
                    ].join(' · '),
                    style: Theme.of(ctx).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 12),
                  Text(consent.body),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: Text(l10n.cancel),
            ),
            FilledButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: Text(l10n.grantConsent),
            ),
          ],
        );
      },
    );
    if (confirmed != true || !mounted) return;

    final id = '${consent.memberId}|${consent.kind}|${consent.version}';
    setState(() => _grantingConsentId = id);
    try {
      await ref
          .read(accountExtrasControllerProvider)
          .grantConsent(memberId: consent.memberId, kind: consent.kind);
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.consentGrantedSnack)));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(apiErrorMessage(e, fallback: l10n.consentGrantFailed)),
        ),
      );
    } finally {
      if (mounted) setState(() => _grantingConsentId = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final auth = ref.watch(authNotifierProvider);
    final user = auth.user;
    final isDemo = user?.id == 'demo';
    final localeOptions = _profileLocaleOptions(l10n);
    final pendingAsync = ref.watch(pendingConsentsProvider);
    final familyAsync = ref.watch(familyChildrenProvider);
    final prefsAsync = ref.watch(notificationPreferencesProvider);

    if (user != null && !isDemo && !_hydrated) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted || _hydrated) return;
        setState(() => _hydrateFrom(user));
      });
    }

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/more');
            }
          },
        ),
        title: Text(l10n.myAccount),
        actions: [
          if (!isDemo)
            IconButton(
              tooltip: l10n.refresh,
              onPressed: auth.isLoading ? null : _reload,
              icon: const Icon(Icons.refresh_rounded),
            ),
        ],
      ),
      body: user == null
          ? Center(child: Text(l10n.signInToContinue))
          : isDemo
          ? Center(child: Text(l10n.signInToContinue))
          : RefreshIndicator(
              onRefresh: _reload,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
                children: [
                  _ProfileHeader(
                    user: user,
                    photoTarget: ref.watch(selfPhotoTargetProvider),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    l10n.profile,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _firstNameCtrl,
                    textCapitalization: TextCapitalization.words,
                    decoration: InputDecoration(labelText: l10n.firstName),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _lastNameCtrl,
                    textCapitalization: TextCapitalization.words,
                    decoration: InputDecoration(labelText: l10n.lastName),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    // ignore: deprecated_member_use
                    value: localeOptions.any((e) => e.$1 == _locale)
                        ? _locale
                        : localeOptions.first.$1,
                    decoration: InputDecoration(labelText: l10n.language),
                    items: [
                      for (final opt in localeOptions)
                        DropdownMenuItem(
                          value: opt.$1,
                          child: Text('${opt.$2} (${opt.$1})'),
                        ),
                      if (_locale != null &&
                          _locale!.isNotEmpty &&
                          !localeOptions.any((e) => e.$1 == _locale))
                        DropdownMenuItem(value: _locale, child: Text(_locale!)),
                    ],
                    onChanged: (v) => setState(() => _locale = v),
                  ),
                  const SizedBox(height: 16),
                  GradientButton(
                    onPressed: _savingProfile || auth.isLoading
                        ? null
                        : _saveProfile,
                    child: _savingProfile
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Text(l10n.saveProfile),
                  ),
                  const SizedBox(height: 28),
                  _sectionTitle(context, l10n.pendingConsents),
                  const SizedBox(height: 8),
                  pendingAsync.when(
                    loading: () => const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Center(
                        child: SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ),
                    ),
                    error: (e, _) => Text(
                      apiErrorMessage(e, fallback: l10n.consentsLoadFailed),
                    ),
                    data: (items) {
                      if (items.isEmpty) {
                        return Text(l10n.noPendingConsents);
                      }
                      return Column(
                        children: [
                          for (final c in items)
                            _PendingConsentTile(
                              consent: c,
                              busy:
                                  _grantingConsentId ==
                                  '${c.memberId}|${c.kind}|${c.version}',
                              onReview: () => _openGrantConsent(c),
                            ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 28),
                  _sectionTitle(context, l10n.familyMembers),
                  const SizedBox(height: 8),
                  familyAsync.when(
                    loading: () => const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Center(
                        child: SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ),
                    ),
                    error: (e, _) => Text(
                      apiErrorMessage(e, fallback: l10n.familyLoadFailed),
                    ),
                    data: (items) {
                      final children =
                          items.where((c) => !c.isSelf).toList();
                      if (children.isEmpty) {
                        return Text(l10n.noFamilyMembers);
                      }
                      return Column(
                        children: [
                          for (final child in children)
                            _FamilyChildTile(child: child),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 28),
                  _sectionTitle(context, l10n.notificationPreferences),
                  const SizedBox(height: 8),
                  prefsAsync.when(
                    loading: () => const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Center(
                        child: SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ),
                    ),
                    error: (e, _) => Text(
                      apiErrorMessage(e, fallback: l10n.prefsLoadFailed),
                    ),
                    data: (items) {
                      if (items.isEmpty) {
                        return Text(l10n.noNotificationPreferences);
                      }
                      return Column(
                        children: [
                          for (final pref in items)
                            SwitchListTile(
                              contentPadding: EdgeInsets.zero,
                              title: Text(_humanizeKey(pref.key)),
                              subtitle: Text(
                                [
                                  _channelLabel(l10n, pref.channel),
                                  if (pref.isDefault) l10n.preferenceDefault,
                                ].join(' · '),
                              ),
                              value: pref.enabled,
                              onChanged:
                                  _togglingPrefId ==
                                      '${pref.key}|${pref.channel}'
                                  ? null
                                  : (v) => _togglePreference(pref, v),
                            ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 28),
                  Text(
                    l10n.clubsAndRoles,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  if (user.roles.isEmpty)
                    Text(l10n.noRoleGrants)
                  else
                    ...user.roles.map(
                      (r) => ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(Icons.badge_outlined),
                        title: Text(r.role),
                        subtitle: Text(
                          [
                            if (r.scope.isNotEmpty) r.scope,
                            if (r.scopeId.isNotEmpty) r.scopeId,
                            '${l10n.club} ${r.clubId}',
                          ].join(' · '),
                        ),
                      ),
                    ),
                  const SizedBox(height: 20),
                  Text(
                    l10n.password,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _currentPwCtrl,
                    obscureText: _obscureCurrent,
                    decoration: InputDecoration(
                      labelText: l10n.currentPassword,
                      suffixIcon: IconButton(
                        onPressed: () =>
                            setState(() => _obscureCurrent = !_obscureCurrent),
                        icon: Icon(
                          _obscureCurrent
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _newPwCtrl,
                    obscureText: _obscureNew,
                    decoration: InputDecoration(
                      labelText: l10n.newPassword,
                      helperText: l10n.passwordRequirementsHint,
                      suffixIcon: IconButton(
                        onPressed: () =>
                            setState(() => _obscureNew = !_obscureNew),
                        icon: Icon(
                          _obscureNew
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _confirmPwCtrl,
                    obscureText: _obscureNew,
                    decoration: InputDecoration(
                      labelText: l10n.confirmNewPassword,
                    ),
                  ),
                  const SizedBox(height: 16),
                  OutlinedButton(
                    onPressed: _changingPassword || auth.isLoading
                        ? null
                        : _changePassword,
                    child: _changingPassword
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(l10n.changePassword),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _sectionTitle(BuildContext context, String title) {
    return Text(title, style: Theme.of(context).textTheme.titleMedium);
  }
}

class _PendingConsentTile extends StatelessWidget {
  const _PendingConsentTile({
    required this.consent,
    required this.busy,
    required this.onReview,
  });

  final PendingConsent consent;
  final bool busy;
  final VoidCallback onReview;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: const Icon(Icons.fact_check_outlined),
        title: Text(_humanizeKey(consent.kind)),
        subtitle: Text(
          [
            consent.memberFirstName,
            l10n.consentVersion(consent.version),
            _consentReasonLabel(l10n, consent.reason),
          ].join(' · '),
        ),
        trailing: busy
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : TextButton(
                onPressed: onReview,
                child: Text(l10n.reviewAndGrantConsent),
              ),
      ),
    );
  }
}

class _FamilyChildTile extends StatelessWidget {
  const _FamilyChildTile({required this.child});

  final FamilyChild child;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final teamOrSection = [
      if ((child.teamName ?? '').isNotEmpty) child.teamName!,
      if ((child.sectionName ?? '').isNotEmpty) child.sectionName!,
    ].join(' · ');
    final subtitle = [
      child.clubName.isNotEmpty ? child.clubName : child.clubId,
      if (teamOrSection.isNotEmpty) teamOrSection,
      child.isSelf ? l10n.relationshipSelf : l10n.relationshipGuardian,
      child.hasActiveEnrollment ? l10n.enrolled : l10n.notEnrolled,
      child.consentGranted ? l10n.consentOk : l10n.consentMissing,
    ].join(' · ');

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        EditableMemberPhoto(
          clubId: child.clubId,
          memberId: child.memberId,
          label: child.displayName,
          size: 44,
          sheetTitle: l10n.changeChildPhoto(child.firstName.isEmpty
              ? child.displayName
              : child.firstName),
        ),
        Expanded(
          child: ListTile(
            contentPadding: const EdgeInsets.only(left: 12),
            title: Text(child.displayName),
            subtitle: Text(subtitle),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () => context.push(
              '/compliance/members/${child.memberId}'
              '?name=${Uri.encodeComponent(child.displayName)}',
            ),
          ),
        ),
      ],
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({required this.user, required this.photoTarget});

  final User user;
  final AsyncValue<MemberPhotoTarget?> photoTarget;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final created = user.createdAt;
    final target = photoTarget.valueOrNull;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppTheme.radius),
      ),
      child: Row(
        children: [
          if (target != null)
            EditableMemberPhoto(
              clubId: target.clubId,
              memberId: target.memberId,
              label: user.displayName,
              size: 64,
              sheetTitle: l10n.changeYourPhoto,
            )
          else
            _UnlinkedAccountPhoto(
              label: user.displayName,
              loading: photoTarget.isLoading,
            ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.displayName,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(user.email),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: [
                    _chip(
                      context,
                      user.emailVerified
                          ? l10n.emailVerified
                          : user.emailVerificationPending
                          ? l10n.verificationPending
                          : l10n.emailNotVerified,
                      ok: user.emailVerified,
                    ),
                    if (user.isPlatformRoot)
                      _chip(context, l10n.platformRoot, ok: true),
                    if (created != null)
                      _chip(
                        context,
                        l10n.joinedMonthYear(
                          DateFormat('MMM yyyy').format(created.toLocal()),
                        ),
                        ok: true,
                      ),
                  ],
                ),
                if (target != null)
                  TextButton(
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      visualDensity: VisualDensity.compact,
                    ),
                    onPressed: () => context.push(
                      '/compliance/members/${target.memberId}'
                      '?name=${Uri.encodeComponent(user.displayName)}',
                    ),
                    child: Text(l10n.yourDocuments),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _chip(BuildContext context, String label, {required bool ok}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: (ok ? AppColors.present : AppColors.late).withValues(
          alpha: 0.15,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: ok ? AppColors.present : AppColors.late,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _UnlinkedAccountPhoto extends StatelessWidget {
  const _UnlinkedAccountPhoto({required this.label, required this.loading});

  final String label;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return InkWell(
      onTap: loading
          ? null
          : () => ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(l10n.photoNeedLinkedMember)),
              ),
      customBorder: const CircleBorder(),
      child: SizedBox(
        width: 64,
        height: 64,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            AvatarCircle(label: label, size: 64),
            if (loading)
              const Positioned.fill(
                child: Center(
                  child: SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
