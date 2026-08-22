import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme/app_theme.dart';

/// ChampHive crest: dual-ring hexagon + geometric H with a blue accent stem.
class TeamHiveLogo extends StatelessWidget {
  const TeamHiveLogo({
    super.key,
    required this.size,
    this.showShadow = true,
    this.isDark = false,
    this.backgroundColor,
    this.showWordmark = false,
    this.wordmarkColor,
    this.solidWhiteMark = false,
  });

  final double size;
  final bool showShadow;
  final bool isDark;

  /// Hexagon interior fill. Ignored for the on-dark outline crest.
  final Color? backgroundColor;
  final bool showWordmark;
  final Color? wordmarkColor;

  /// White outline crest + white H with blue right stem (login / splash).
  final bool solidWhiteMark;

  @override
  Widget build(BuildContext context) {
    final themeDark = Theme.of(context).brightness == Brightness.dark;
    final dark = isDark || themeDark;

    final mark = SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        size: Size.square(size),
        painter: TeamHiveLogoPainter(
          fillColor:
              backgroundColor ??
              (solidWhiteMark
                  ? Colors.transparent
                  : (dark ? const Color(0xFF0E1F3D) : Colors.white)),
          showShadow: showShadow,
          isDark: dark,
          solidWhiteMark: solidWhiteMark,
        ),
      ),
    );

    if (!showWordmark) return mark;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        mark,
        SizedBox(height: size * 0.12),
        Text(
          'CHAMPHIVE',
          style: GoogleFonts.inter(
            fontSize: size * 0.20,
            fontWeight: FontWeight.w800,
            letterSpacing: size * 0.048,
            height: 1.0,
            color:
                wordmarkColor ??
                (dark ? AppColors.darkPrimary : AppColors.primaryNavy),
          ),
        ),
      ],
    );
  }
}

/// Pointy-top regular hexagon.
Path createTeamHiveHexagonPath(Size size, {double inset = 2}) {
  final contentSize = size.width;
  final center = Offset(contentSize / 2, contentSize / 2);
  final radius = contentSize / 2 - inset;
  final path = Path();
  for (var i = 0; i < 6; i++) {
    final angle = (math.pi / 3 * i) - (math.pi / 6);
    final x = center.dx + radius * math.cos(angle);
    final y = center.dy + radius * math.sin(angle);
    if (i == 0) {
      path.moveTo(x, y);
    } else {
      path.lineTo(x, y);
    }
  }
  path.close();
  return path;
}

class TeamHiveLogoPainter extends CustomPainter {
  TeamHiveLogoPainter({
    required this.fillColor,
    this.showShadow = true,
    this.isDark = false,
    this.solidWhiteMark = false,
  });

  final Color fillColor;
  final bool showShadow;
  final bool isDark;
  final bool solidWhiteMark;

  static const _lightStroke = [
    Color(0xFF93C5FD),
    Color(0xFF3B82F6),
    Color(0xFF1E42AF),
    Color(0xFF0F265D),
  ];

  static const _darkStroke = [
    Color(0xFFBFDBFE),
    Color(0xFF60A5FA),
    Color(0xFF3B82F6),
    Color(0xFF1E42AF),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final contentSize = size.width;
    final center = Offset(contentSize / 2, contentSize / 2);
    final outer = createTeamHiveHexagonPath(size, inset: contentSize * 0.06);
    final inner = createTeamHiveHexagonPath(size, inset: contentSize * 0.155);

    if (fillColor.a > 0) {
      canvas.drawPath(
        outer,
        Paint()
          ..color = fillColor
          ..style = PaintingStyle.fill,
      );
    }

    if (solidWhiteMark) {
      _paintOnDarkCrest(canvas, size, outer, inner, center, contentSize);
    } else {
      _paintBrandCrest(canvas, size, outer, inner, center, contentSize);
    }
  }

  void _paintOnDarkCrest(
    Canvas canvas,
    Size size,
    Path outer,
    Path inner,
    Offset center,
    double contentSize,
  ) {
    if (showShadow) {
      canvas.drawPath(
        outer,
        Paint()
          ..color = Colors.white.withValues(alpha: 0.28)
          ..style = PaintingStyle.stroke
          ..strokeWidth = contentSize * 0.18
          ..strokeJoin = StrokeJoin.round
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10),
      );
    }

    canvas.drawPath(
      outer,
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = contentSize * 0.078
        ..strokeJoin = StrokeJoin.round
        ..strokeCap = StrokeCap.round,
    );

    canvas.drawPath(
      inner,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.42)
        ..style = PaintingStyle.stroke
        ..strokeWidth = contentSize * 0.018
        ..strokeJoin = StrokeJoin.round,
    );

    _paintLetterH(
      canvas,
      contentSize,
      center,
      stem: Colors.white,
      accent: AppColors.primaryBright,
      glow: true,
    );
  }

  void _paintBrandCrest(
    Canvas canvas,
    Size size,
    Path outer,
    Path inner,
    Offset center,
    double contentSize,
  ) {
    final strokeColors = isDark ? _darkStroke : _lightStroke;
    final strokeGradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: strokeColors,
      stops: const [0.0, 0.32, 0.68, 1.0],
    ).createShader(Rect.fromLTWH(0, 0, contentSize, contentSize));

    if (showShadow) {
      canvas.drawPath(
        outer,
        Paint()
          ..color = AppColors.primary.withValues(alpha: 0.22)
          ..style = PaintingStyle.stroke
          ..strokeWidth = contentSize * 0.16
          ..strokeJoin = StrokeJoin.round
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
      );
    }

    canvas.drawPath(
      outer,
      Paint()
        ..shader = strokeGradient
        ..style = PaintingStyle.stroke
        ..strokeWidth = contentSize * 0.10
        ..strokeJoin = StrokeJoin.round,
    );

    canvas.drawPath(
      inner,
      Paint()
        ..color = (isDark ? Colors.white : AppColors.primaryNavy).withValues(
          alpha: 0.28,
        )
        ..style = PaintingStyle.stroke
        ..strokeWidth = contentSize * 0.016
        ..strokeJoin = StrokeJoin.round,
    );

    _paintLetterH(
      canvas,
      contentSize,
      center,
      stem: isDark ? const Color(0xFFEFF6FF) : AppColors.primaryNavy,
      accent: AppColors.primaryBright,
      glow: false,
    );
  }

  void _paintLetterH(
    Canvas canvas,
    double contentSize,
    Offset center, {
    required Color stem,
    required Color accent,
    required bool glow,
  }) {
    final bar = contentSize * 0.078;
    final left = contentSize * 0.335;
    final right = contentSize * 0.665;
    final top = contentSize * 0.30;
    final bottom = contentSize * 0.70;
    final midY = center.dy;
    final r = bar / 2;
    // Blue only on the upper part of the right stem (mockup: top half).
    final splitY = top + (midY - top) * 0.92;

    RRect stemRect(double x) =>
        RRect.fromLTRBR(x - r, top, x + r, bottom, Radius.circular(r));

    final cross = RRect.fromLTRBR(
      left - r,
      midY - r * 0.85,
      right + r,
      midY + r * 0.85,
      Radius.circular(r),
    );

    canvas.drawRRect(stemRect(left), Paint()..color = stem);
    canvas.drawRRect(stemRect(right), Paint()..color = stem);

    final accentRect = Rect.fromLTRB(
      right - r - 1,
      top - 1,
      right + r + 1,
      splitY,
    );
    if (glow) {
      canvas.save();
      canvas.clipRect(accentRect);
      canvas.drawRRect(
        stemRect(right),
        Paint()
          ..color = accent.withValues(alpha: 0.5)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5),
      );
      canvas.restore();
    }

    canvas.save();
    canvas.clipRect(accentRect);
    canvas.drawRRect(stemRect(right), Paint()..color = accent);
    canvas.restore();

    canvas.drawRRect(cross, Paint()..color = stem);
  }

  @override
  bool shouldRepaint(covariant TeamHiveLogoPainter oldDelegate) =>
      fillColor != oldDelegate.fillColor ||
      showShadow != oldDelegate.showShadow ||
      isDark != oldDelegate.isDark ||
      solidWhiteMark != oldDelegate.solidWhiteMark;
}
