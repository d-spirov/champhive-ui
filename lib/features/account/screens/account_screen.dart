import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../shared/models/user.dart';
import '../../../shared/theme/app_theme.dart';
import '../../../shared/widgets/ui_bits.dart';
import '../../auth/providers/auth_provider.dart';

const _localeOptions = <(String code, String label)>[
  ('en', 'English'),
  ('mk', 'Македонски'),
  ('sr-Latn', 'Srpski'),
];

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
    final first = _firstNameCtrl.text.trim();
    final last = _lastNameCtrl.text.trim();
    if (first.isEmpty || last.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('First and last name are required')),
      );
      return;
    }
    setState(() => _savingProfile = true);
    final ok = await ref.read(authNotifierProvider.notifier).updateProfile(
          firstName: first,
          lastName: last,
          locale: _locale,
        );
    if (!mounted) return;
    setState(() => _savingProfile = false);
    final err = ref.read(authNotifierProvider).error;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(ok ? 'Profile saved' : (err ?? 'Save failed'))),
    );
  }

  Future<void> _changePassword() async {
    final current = _currentPwCtrl.text;
    final next = _newPwCtrl.text;
    final confirm = _confirmPwCtrl.text;
    if (current.isEmpty || next.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter current and new password')),
      );
      return;
    }
    if (next != confirm) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('New passwords do not match')),
      );
      return;
    }
    if (next.length < 8) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('New password must be at least 8 characters')),
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
              ? 'Password changed. Other sessions were signed out.'
              : (err ?? 'Could not change password'),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authNotifierProvider);
    final user = auth.user;
    final isDemo = user?.id == 'demo';

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
        title: const Text('My Account'),
        actions: [
          if (!isDemo)
            IconButton(
              tooltip: 'Refresh',
              onPressed: auth.isLoading ? null : _reload,
              icon: const Icon(Icons.refresh_rounded),
            ),
        ],
      ),
      body: user == null
          ? const Center(child: Text('Not signed in'))
          : isDemo
              ? const Center(
                  child: Text('Sign in to manage your account.'),
                )
              : RefreshIndicator(
                  onRefresh: _reload,
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
                    children: [
                      _ProfileHeader(user: user),
                      const SizedBox(height: 20),
                      Text(
                        'Profile',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _firstNameCtrl,
                        textCapitalization: TextCapitalization.words,
                        decoration: const InputDecoration(
                          labelText: 'First name',
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _lastNameCtrl,
                        textCapitalization: TextCapitalization.words,
                        decoration: const InputDecoration(
                          labelText: 'Last name',
                        ),
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        // ignore: deprecated_member_use
                        value: _localeOptions.any((e) => e.$1 == _locale)
                            ? _locale
                            : (_localeOptions.first.$1),
                        decoration: const InputDecoration(labelText: 'Locale'),
                        items: [
                          for (final opt in _localeOptions)
                            DropdownMenuItem(
                              value: opt.$1,
                              child: Text('${opt.$2} (${opt.$1})'),
                            ),
                          if (_locale != null &&
                              _locale!.isNotEmpty &&
                              !_localeOptions.any((e) => e.$1 == _locale))
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
                            : const Text('Save profile'),
                      ),
                      const SizedBox(height: 28),
                      Text(
                        'Clubs & roles',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      if (user.roles.isEmpty)
                        const Text('No role grants on this account.')
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
                                'club ${r.clubId}',
                              ].join(' · '),
                            ),
                          ),
                        ),
                      const SizedBox(height: 20),
                      Text(
                        'Password',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _currentPwCtrl,
                        obscureText: _obscureCurrent,
                        decoration: InputDecoration(
                          labelText: 'Current password',
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
                          labelText: 'New password',
                          helperText: '≥8 chars with upper, lower, digit',
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
                        decoration: const InputDecoration(
                          labelText: 'Confirm new password',
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
                            : const Text('Change password'),
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
                          ? 'Email verified'
                          : user.emailVerificationPending
                              ? 'Verification pending'
                              : 'Email not verified',
                      ok: user.emailVerified,
                    ),
                    if (user.isPlatformRoot)
                      _chip(context, 'Platform root', ok: true),
                    if (created != null)
                      _chip(
                        context,
                        'Joined ${DateFormat('MMM yyyy').format(created.toLocal())}',
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
