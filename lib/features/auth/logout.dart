import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'providers/auth_provider.dart';
import '../clubs/providers/clubs_provider.dart';

/// Shared logout used by More / account flows.
Future<void> performLogout(WidgetRef ref, BuildContext context) async {
  final router = GoRouter.of(context);
  // Close drawer/sheet first if this context is under one.
  final navigator = Navigator.maybeOf(context);
  if (navigator != null && navigator.canPop()) {
    navigator.pop();
  }

  await ref.read(authNotifierProvider.notifier).logout();
  ref.invalidate(myClubsProvider);
  await ref.read(selectedClubIdProvider.notifier).clear();
  router.go('/login');
}
