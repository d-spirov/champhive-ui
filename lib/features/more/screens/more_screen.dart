import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../l10n/app_localizations.dart';
import '../../../shared/providers/locale_provider.dart';
import '../../../shared/providers/theme_mode_provider.dart';
import '../../../shared/theme/app_theme.dart';
import '../../../shared/widgets/ui_bits.dart';
import '../../auth/logout.dart';
import '../../shell/app_destinations.dart';
import '../../shell/main_shell.dart';

class MoreScreen extends ConsumerWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final themeMode = ref.watch(themeModeProvider) ?? ThemeMode.system;
    final locale = ref.watch(localeProvider);

    final management = moreManagementDestinations(l10n);

    return Scaffold(
      appBar: shellAppBar(context, title: l10n.more),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          _sectionHeader(context, l10n.moreManagement),
          AppCard(
            child: Column(
              children: [
                for (var i = 0; i < management.length; i++) ...[
                  if (i > 0) const Divider(height: 1, indent: 56),
                  _routeTile(context, management[i]),
                ],
              ],
            ),
          ),
          const SizedBox(height: 8),
          _sectionHeader(context, l10n.moreAccount),
          AppCard(
            child: Column(
              children: [
                _routeTile(
                  context,
                  AppDestination(
                    label: l10n.myAccount,
                    icon: Icons.person_outline_rounded,
                    route: '/account',
                  ),
                ),
                const Divider(height: 1, indent: 56),
                ListTile(
                  leading: const Icon(Icons.brightness_6_outlined),
                  title: Text(l10n.appearance),
                  subtitle: Text(_themeLabel(l10n, themeMode)),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => _pickTheme(context, ref, l10n, themeMode),
                ),
                const Divider(height: 1, indent: 56),
                ListTile(
                  leading: const Icon(Icons.language_rounded),
                  title: Text(l10n.language),
                  subtitle: Text(_languageLabel(l10n, locale)),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => _pickLanguage(context, ref, l10n, locale),
                ),
                const Divider(height: 1, indent: 56),
                _routeTile(
                  context,
                  AppDestination(
                    label: l10n.notifications,
                    icon: Icons.notifications_outlined,
                    route: '/notifications',
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          _sectionHeader(context, l10n.moreSupport),
          AppCard(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.help_outline_rounded),
                  title: Text(l10n.helpSupport),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () {},
                ),
                const Divider(height: 1, indent: 56),
                ListTile(
                  leading: const Icon(Icons.info_outline_rounded),
                  title: Text(l10n.aboutApp),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () {
                    showAboutDialog(
                      context: context,
                      applicationName: 'ChampHive',
                      applicationVersion: '1.0.0',
                      applicationLegalese: '© Codeantech',
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          AppCard(
            child: ListTile(
              leading: const Icon(
                Icons.logout_rounded,
                color: AppColors.danger,
              ),
              title: Text(
                l10n.logOut,
                style: const TextStyle(
                  color: AppColors.danger,
                  fontWeight: FontWeight.w600,
                ),
              ),
              onTap: () => performLogout(ref, context),
            ),
          ),
          const SizedBox(height: 24),
          Center(
            child: Text(
              'v1.0.0',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.5),
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _sectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 16, 4, 8),
      child: Text(
        title.toUpperCase(),
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
          color: Theme.of(context).colorScheme.onSurfaceVariant,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.8,
        ),
      ),
    );
  }

  Widget _routeTile(BuildContext context, AppDestination destination) {
    return ListTile(
      leading: Icon(destination.icon),
      title: Text(destination.label),
      trailing: const Icon(Icons.chevron_right_rounded),
      onTap: () => context.push(destination.route),
    );
  }

  String _themeLabel(AppLocalizations l10n, ThemeMode mode) {
    return switch (mode) {
      ThemeMode.light => l10n.themeLight,
      ThemeMode.dark => l10n.themeDark,
      ThemeMode.system => l10n.themeSystem,
    };
  }

  String _languageLabel(AppLocalizations l10n, Locale? locale) {
    if (locale == null) return l10n.languageSystem;
    return switch (locale.languageCode) {
      'mk' => l10n.languageMacedonian,
      'sr' => l10n.languageSerbian,
      'it' => l10n.languageItalian,
      'bs' => l10n.languageBosnian,
      'tr' => l10n.languageTurkish,
      _ => l10n.languageEnglish,
    };
  }

  Future<void> _pickTheme(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
    ThemeMode current,
  ) async {
    final selected = await showModalBottomSheet<ThemeMode>(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: Text(l10n.themeLight),
                trailing: current == ThemeMode.light
                    ? const Icon(Icons.check_rounded)
                    : null,
                onTap: () => Navigator.pop(context, ThemeMode.light),
              ),
              ListTile(
                title: Text(l10n.themeDark),
                trailing: current == ThemeMode.dark
                    ? const Icon(Icons.check_rounded)
                    : null,
                onTap: () => Navigator.pop(context, ThemeMode.dark),
              ),
              ListTile(
                title: Text(l10n.themeSystem),
                trailing: current == ThemeMode.system
                    ? const Icon(Icons.check_rounded)
                    : null,
                onTap: () => Navigator.pop(context, ThemeMode.system),
              ),
            ],
          ),
        );
      },
    );
    if (selected != null) {
      await ref.read(themeModeProvider.notifier).setMode(selected);
    }
  }

  Future<void> _pickLanguage(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
    Locale? current,
  ) async {
    final selected = await showModalBottomSheet<String>(
      context: context,
      builder: (context) {
        Widget row(String key, String label, bool checked) {
          return ListTile(
            title: Text(label),
            trailing: checked ? const Icon(Icons.check_rounded) : null,
            onTap: () => Navigator.pop(context, key),
          );
        }

        return SafeArea(
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                row('system', l10n.languageSystem, current == null),
                row('en', l10n.languageEnglish, current?.languageCode == 'en'),
                row(
                  'mk',
                  l10n.languageMacedonian,
                  current?.languageCode == 'mk',
                ),
                row(
                  'sr-Latn',
                  l10n.languageSerbian,
                  current?.languageCode == 'sr',
                ),
                row('it', l10n.languageItalian, current?.languageCode == 'it'),
                row('bs', l10n.languageBosnian, current?.languageCode == 'bs'),
                row('tr', l10n.languageTurkish, current?.languageCode == 'tr'),
              ],
            ),
          ),
        );
      },
    );
    if (selected == null) return;
    await ref
        .read(localeProvider.notifier)
        .setLocale(selected == 'system' ? null : AppLocales.tryParse(selected));
  }
}
