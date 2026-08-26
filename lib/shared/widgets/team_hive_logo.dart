import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme/app_theme.dart';

/// ChampHive brand mark, optionally with a theme-aware ChampHive wordmark.
class TeamHiveLogo extends StatelessWidget {
  const TeamHiveLogo({
    super.key,
    required this.size,
    this.showShadow = true,
    this.showWordmark = false,
    this.onDarkBackground,
  });

  /// Height of the rounded-square icon.
  final double size;
  final bool showShadow;
  final bool showWordmark;

  /// Force a light wordmark. Login/splash are always dark even in light theme.
  final bool? onDarkBackground;

  static const markAsset = 'assets/brand/champhive_mark.png';

  @override
  Widget build(BuildContext context) {
    final onDark =
        onDarkBackground ?? Theme.of(context).brightness == Brightness.dark;

    Widget mark = Image.asset(
      markAsset,
      width: size,
      height: size,
      fit: BoxFit.contain,
      filterQuality: FilterQuality.high,
    );

    if (showShadow) {
      mark = DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(size * 0.22),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0F172A).withValues(alpha: 0.28),
              blurRadius: size * 0.18,
              offset: Offset(0, size * 0.06),
            ),
          ],
        ),
        child: mark,
      );
    }

    if (!showWordmark) return mark;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        mark,
        SizedBox(height: size * 0.12),
        _ChampHiveWordmark(fontSize: size * 0.24, onDark: onDark),
      ],
    );
  }
}

class _ChampHiveWordmark extends StatelessWidget {
  const _ChampHiveWordmark({required this.fontSize, required this.onDark});

  final double fontSize;
  final bool onDark;

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(
        style: GoogleFonts.inter(
          fontWeight: FontWeight.w800,
          fontSize: fontSize,
          height: 1.0,
          letterSpacing: -0.6,
        ),
        children: [
          TextSpan(
            text: 'Champ',
            style: TextStyle(
              color: onDark ? Colors.white : AppColors.primaryNavy,
            ),
          ),
          TextSpan(
            text: 'Hive',
            style: TextStyle(
              color: onDark ? const Color(0xFF7DD3FC) : AppColors.primaryBright,
            ),
          ),
        ],
      ),
    );
  }
}
