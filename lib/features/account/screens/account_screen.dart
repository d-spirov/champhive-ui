import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../l10n/app_localizations.dart';
import '../../../shared/models/user.dart';
import '../../../shared/providers/locale_provider.dart';
import '../../../shared/theme/app_theme.dart';
import '../../../shared/widgets/ui_bits.dart';
import '../../auth/providers/auth_provider.dart';

List<(String code, String label)> _profileLocaleOptions(AppLocalizations l10n) {
  return [
    ('en', l10n.languageEnglish),
    ('mk', l10n.languageMacedonian),
    ('sr-Latn', l10n.languageSerbian),
    ('it', l10n.languageItalian),
  ];
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
    final user = await ref.read(authNotifierProvider.notifier).refreshCurrentUser();
    if (!mounted || user == null) return;
    setState(() => _hydrateFrom(user));
  }

  Future<void> _saveProfile() async {
    final l10n = AppLocalizations.of(context)!;
    final first = _firstNameCtrl.text.trim();
    final last = _lastNameCtrl.text.trim();
    if (first.isEmpty || last.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.namesRequired)),
      );
      return;
    }
    setState(() => _savingProfile = true);
    final ok = await ref.read(authNotifierProvider.notifier).updateProfile(
          firstName: first,
          lastName: last,
          locale: _locale,
        );
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.enterCurrentAndNewPassword)),
      );
      return;
    }
    if (next != confirm) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.newPasswordsDoNotMatch)),
      );
      return;
    }
    if (next.length < 8) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.newPasswordMinLength)),
      );
      return;
    }

    setState(() => _changingPassword = true);
    final ok = await ref.read(authNotifierProvider.notifier).changePassword(
          currentPassword: current,
          newPassword: next,
        );
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

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final auth = ref.watch(authNotifierProvider);
    final user = auth.user;
    final isDemo = user?.id == 'demo';
    final localeOptions = _profileLocaleOptions(l10n);

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
                      _ProfileHeader(user: user),
                      const SizedBox(height: 20),
                      Text(
                        l10n.profile,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _firstNameCtrl,
                        textCapitalization: TextCapitalization.words,
                        decoration: InputDecoration(
                          labelText: l10n.firstName,
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _lastNameCtrl,
                        textCapitalization: TextCapitalization.words,
                        decoration: InputDecoration(
                          labelText: l10n.lastName,
                        ),
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
                            DropdownMenuItem(
                              value: _locale,
                              child: Text(_locale!),
                            ),
                        ],
                        onChanged: (v) => setState(() => _locale = v),
                      ),
                      const SizedBox(height: 16),
                      FilledButton(
                        onPressed: _savingProfile || auth.isLoading
                            ? null
                            : _saveProfile,
                        child: _savingProfile
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(l10n.saveProfile),
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
                            onPressed: () => setState(
                              () => _obscureCurrent = !_obscureCurrent,
                            ),
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
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(l10n.changePassword),
                      ),
                    ],
                  ),
                ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({required this.user});

  final User user;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final created = user.createdAt;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppTheme.radius),
      ),
      child: Row(
        children: [
          AvatarCircle(label: user.displayName, size: 64),
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
        color: (ok ? AppColors.present : AppColors.late).withValues(alpha: 0.15),
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
