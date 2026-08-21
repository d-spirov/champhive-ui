import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../shared/providers/theme_mode_provider.dart';
import '../../../shared/theme/app_theme.dart';
import '../../auth/logout.dart';

class MoreScreen extends ConsumerWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider) ?? ThemeMode.system;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.menu_rounded),
          onPressed: () => Scaffold.of(context).openDrawer(),
        ),
        title: const Text('More'),
      ),
      body: ListView(
        children: [
          _tile(
            context,
            Icons.payments_outlined,
            'Payments',
            () => context.push('/payments'),
          ),
          _tile(
            context,
            Icons.person_outline_rounded,
            'My Account',
            () => context.push('/account'),
          ),
          ListTile(
            leading: const Icon(Icons.brightness_6_outlined),
            title: const Text('Appearance'),
            subtitle: Text(_themeLabel(themeMode)),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () => _pickTheme(context, ref, themeMode),
          ),
          _tile(
            context,
            Icons.notifications_outlined,
            'Notifications',
            () => context.push('/notifications'),
          ),
          _tile(
            context,
            Icons.how_to_reg_outlined,
            'Attendance',
            () => context.push('/attendance/history'),
          ),
          _tile(
            context,
            Icons.bar_chart_rounded,
            'Statistics',
            () => context.push('/statistics'),
          ),
          _tile(context, Icons.help_outline_rounded, 'Help & Support', () {}),
          _tile(context, Icons.info_outline_rounded, 'About TeamHive', () {
            showAboutDialog(
              context: context,
              applicationName: 'TeamHive',
              applicationVersion: '1.0.0',
              applicationLegalese: '© Codeantech',
            );
          }),
          const Divider(height: 24),
          ListTile(
            leading: const Icon(Icons.logout_rounded, color: AppColors.danger),
            title: const Text(
              'Log out',
              style: TextStyle(
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
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
            ),
          ),
        ],
      ),
    );
  }

  String _themeLabel(ThemeMode mode) {
    return switch (mode) {
      ThemeMode.light => 'Light (orange)',
      ThemeMode.dark => 'Dark (court)',
      ThemeMode.system => 'System',
    };
  }

  Future<void> _pickTheme(
    BuildContext context,
    WidgetRef ref,
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
                title: const Text('Light (green)'),
                trailing: current == ThemeMode.light
                    ? const Icon(Icons.check_rounded)
                    : null,
                onTap: () => Navigator.pop(context, ThemeMode.light),
              ),
              ListTile(
                title: const Text('Dark (navy & gold)'),
                trailing: current == ThemeMode.dark
                    ? const Icon(Icons.check_rounded)
                    : null,
                onTap: () => Navigator.pop(context, ThemeMode.dark),
              ),
              ListTile(
                title: const Text('System'),
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
