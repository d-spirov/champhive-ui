import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../l10n/app_localizations.dart';
import '../../../shared/providers/locale_provider.dart';
import '../../../shared/providers/theme_mode_provider.dart';
import '../../../shared/theme/app_theme.dart';
import '../../auth/logout.dart';

class MoreScreen extends ConsumerWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final themeMode = ref.watch(themeModeProvider) ?? ThemeMode.system;
    final locale = ref.watch(localeProvider);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.menu_rounded),
          onPressed: () => Scaffold.of(context).openDrawer(),
        ),
        title: Text(l10n.more),
      ),
      body: ListView(
        children: [
          _tile(
            context,
            Icons.payments_outlined,
            l10n.payments,
            () => context.push('/payments'),
          ),
          _tile(
            context,
            Icons.person_outline_rounded,
            l10n.myAccount,
            () => context.push('/account'),
          ),
          ListTile(
            leading: const Icon(Icons.brightness_6_outlined),
            title: Text(l10n.appearance),
            subtitle: Text(_themeLabel(l10n, themeMode)),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () => _pickTheme(context, ref, l10n, themeMode),
          ),
          ListTile(
            leading: const Icon(Icons.language_rounded),
            title: Text(l10n.language),
            subtitle: Text(_languageLabel(l10n, locale)),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () => _pickLanguage(context, ref, l10n, locale),
          ),
          _tile(
            context,
            Icons.notifications_outlined,
            l10n.notifications,
            () => context.push('/notifications'),
          ),
          _tile(
            context,
            Icons.how_to_reg_outlined,
            l10n.attendance,
            () => context.push('/attendance/history'),
          ),
          _tile(
            context,
            Icons.bar_chart_rounded,
            l10n.statistics,
            () => context.push('/statistics'),
          ),
          _tile(context, Icons.help_outline_rounded, l10n.helpSupport, () {}),
          _tile(context, Icons.info_outline_rounded, l10n.aboutApp, () {
            showAboutDialog(
              context: context,
              applicationName: l10n.appTitle,
              applicationVersion: '1.0.0',
              applicationLegalese: '© Codeantech',
            );
          }),
          const Divider(height: 24),
          ListTile(
            leading: const Icon(Icons.logout_rounded, color: AppColors.danger),
            title: Text(
              l10n.logOut,
              style: const TextStyle(
                color: AppColors.danger,
                fontWeight: FontWeight.w600,
              ),
            ),
            onTap: () => performLogout(ref, context),
          ),
          const SizedBox(height: 24),
          Center(
            child: Text(
              'v1.0.0',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.5),
                  ),
            ),
          ),
        ],
      ),
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
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              row('system', l10n.languageSystem, current == null),
              row(
                'en',
                l10n.languageEnglish,
                current?.languageCode == 'en',
              ),
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
              row(
                'it',
                l10n.languageItalian,
                current?.languageCode == 'it',
              ),
            ],
          ),
        );
      },
    );
    if (selected == null) return;
    await ref.read(localeProvider.notifier).setLocale(
          selected == 'system' ? null : AppLocales.tryParse(selected),
        );
  }

  Widget _tile(
    BuildContext context,
    IconData icon,
    String title,
    VoidCallback onTap,
  ) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      trailing: const Icon(Icons.chevron_right_rounded),
      onTap: onTap,
    );
  }
}
