import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';

/// Shared navigation destination (label + icons + route).
class AppDestination {
  const AppDestination({
    required this.label,
    required this.icon,
    required this.route,
    this.selectedIcon,
  });

  final String label;
  final IconData icon;
  final IconData? selectedIcon;
  final String route;

  IconData get effectiveSelectedIcon => selectedIcon ?? icon;
}

/// Primary bottom-nav tabs — single source for shell destinations.
List<AppDestination> primaryDestinations(AppLocalizations l10n) {
  return [
    AppDestination(
      label: l10n.home,
      icon: Icons.home_outlined,
      selectedIcon: Icons.home_rounded,
      route: '/home',
    ),
    AppDestination(
      label: l10n.calendar,
      icon: Icons.calendar_month_outlined,
      selectedIcon: Icons.calendar_month,
      route: '/calendar',
    ),
    AppDestination(
      label: l10n.teams,
      icon: Icons.groups_outlined,
      selectedIcon: Icons.groups_rounded,
      route: '/teams',
    ),
    AppDestination(
      label: l10n.messages,
      icon: Icons.chat_bubble_outline_rounded,
      selectedIcon: Icons.chat_bubble_rounded,
      route: '/messages',
    ),
    AppDestination(
      label: l10n.more,
      icon: Icons.more_horiz_rounded,
      selectedIcon: Icons.more_horiz_rounded,
      route: '/more',
    ),
  ];
}

/// Routes under More → Management, filtered by club role.
List<String> moreManagementRoutes({
  required bool isStaff,
  required bool isClubAdmin,
  required bool showPayments,
}) {
  return [
    if (isStaff) '/members',
    '/attendance/history',
    if (isClubAdmin) '/statistics',
    if (showPayments) '/payments',
    if (isClubAdmin) '/compliance',
  ];
}

/// Secondary destinations shown under More (excluding inline settings actions).
List<AppDestination> moreManagementDestinations(
  AppLocalizations l10n, {
  required bool isStaff,
  required bool isClubAdmin,
  required bool showPayments,
}) {
  final byRoute = <String, AppDestination>{
    '/members': AppDestination(
      label: l10n.members,
      icon: Icons.sports_outlined,
      route: '/members',
    ),
    '/attendance/history': AppDestination(
      label: l10n.attendance,
      icon: Icons.how_to_reg_outlined,
      route: '/attendance/history',
    ),
    '/statistics': AppDestination(
      label: l10n.statistics,
      icon: Icons.bar_chart_rounded,
      route: '/statistics',
    ),
    '/payments': AppDestination(
      label: l10n.payments,
      icon: Icons.payments_outlined,
      route: '/payments',
    ),
    '/compliance': AppDestination(
      label: l10n.documents,
      icon: Icons.folder_copy_outlined,
      route: '/compliance',
    ),
  };
  return [
    for (final route in moreManagementRoutes(
      isStaff: isStaff,
      isClubAdmin: isClubAdmin,
      showPayments: showPayments,
    ))
      if (byRoute[route] != null) byRoute[route]!,
  ];
}
