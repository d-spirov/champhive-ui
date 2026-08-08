import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/auth_provider.dart';
import '../../../shared/theme/app_theme.dart';
import '../../../shared/widgets/team_hive_logo.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  bool _routed = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _tryRoute());
  }

  void _tryRoute() {
    if (!mounted || _routed) return;
    final auth = ref.read(authNotifierProvider);
    final apiReady = ref.read(authApiProvider).hasValue;
    if (!auth.initialized || !apiReady) return;

    _routed = true;
    context.go(auth.isAuthenticated ? '/home' : '/login');
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(authNotifierProvider, (previous, next) => _tryRoute());
    ref.listen(authApiProvider, (previous, next) => _tryRoute());

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.darkNavy : AppColors.lightPrimary;

    return Scaffold(
      body: Container(
        width: double.infinity,
        color: bg,
        child: const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TeamHiveLogo(
                size: 96,
                showWordmark: true,
                wordmarkColor: Colors.white,
              ),
              SizedBox(height: 28),
              CircularProgressIndicator(color: Colors.white),
            ],
          ),
        ),
      ),
    );
  }
}
