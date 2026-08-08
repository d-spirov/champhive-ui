import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../auth/logout.dart';
import '../auth/providers/auth_provider.dart';
import '../../shared/theme/app_theme.dart';
import '../../shared/widgets/ui_bits.dart';

class AppDrawer extends ConsumerWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authNotifierProvider).user;
    final name = user?.displayName ?? 'Coach';
    final email = user?.email ?? '';
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Drawer(
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
              color: isDark
                  ? AppColors.darkNavy
                  : AppColors.lightPrimary.withValues(alpha: 0.08),
              child: Row(
                children: [
                  AvatarCircle(label: name, size: 56),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(name, style: Theme.of(context).textTheme.titleMedium),
                        if (email.isNotEmpty)
                          Text(
                            email,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurface
                                      .withValues(alpha: 0.65),
                                ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 8),
                children: [
                  _item(context, Icons.home_outlined, 'Home', '/home'),
                  _item(context, Icons.calendar_month_outlined, 'Calendar', '/calendar'),
                  _item(context, Icons.groups_outlined, 'Teams', '/teams'),
                  _item(context, Icons.sports_outlined, 'Players', '/players'),
                  _item(context, Icons.fitness_center_outlined, 'Training', '/calendar'),
                  _item(context, Icons.sports_soccer_outlined, 'Matches', '/calendar'),
                  _item(context, Icons.bar_chart_rounded, 'Statistics', '/statistics'),
                  _item(context, Icons.payments_outlined, 'Payments', '/more'),
                  _item(
                    context,
                    Icons.chat_bubble_outline_rounded,
                    'Messages',
                    '/messages',
                    badge: 3,
                  ),
                  _item(context, Icons.notifications_outlined, 'Notifications', '/more'),
                  _item(context, Icons.settings_outlined, 'Settings', '/more'),
                  _item(context, Icons.help_outline_rounded, 'Help & Support', '/more'),
                ],
              ),
            ),
            const Divider(height: 1),
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
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _item(
    BuildContext context,
    IconData icon,
    String label,
    String path, {
    int badge = 0,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(label),
      trailing: badge > 0
          ? UnreadBadge(count: badge)
          : const Icon(Icons.chevron_right, size: 18),
      onTap: () {
        Navigator.of(context).pop();
        context.go(path);
      },
    );
  }
}
