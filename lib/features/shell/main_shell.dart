import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../l10n/app_localizations.dart';
import 'app_drawer.dart';

class MainShell extends StatelessWidget {
  const MainShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final destinations = [
      (
        icon: Icons.home_outlined,
        selected: Icons.home_rounded,
        label: l10n.home,
      ),
      (
        icon: Icons.calendar_month_outlined,
        selected: Icons.calendar_month,
        label: l10n.calendar,
      ),
      (
        icon: Icons.groups_outlined,
        selected: Icons.groups_rounded,
        label: l10n.teams,
      ),
      (
        icon: Icons.chat_bubble_outline_rounded,
        selected: Icons.chat_bubble_rounded,
        label: l10n.messages,
      ),
      (
        icon: Icons.more_horiz_rounded,
        selected: Icons.more_horiz_rounded,
        label: l10n.more,
      ),
    ];

    return Scaffold(
      drawer: const AppDrawer(),
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: (index) {
          navigationShell.goBranch(
            index,
            initialLocation: index == navigationShell.currentIndex,
          );
        },
        destinations: [
          for (final d in destinations)
            NavigationDestination(
              icon: Icon(d.icon),
              selectedIcon: Icon(d.selected),
              label: d.label,
            ),
        ],
      ),
    );
  }
}

/// Shared app bar used by tab roots (opens the drawer).
PreferredSizeWidget shellAppBar(
  BuildContext context, {
  required String title,
  List<Widget>? actions,
  bool showMenu = true,
}) {
  return AppBar(
    title: Text(title),
    leading: showMenu
        ? IconButton(
            icon: const Icon(Icons.menu_rounded),
            onPressed: () => Scaffold.of(context).openDrawer(),
          )
        : null,
    actions: actions,
  );
}
