import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// TeamHive logo: vector hexagon ring + bold "H" (ParkHive-style geometry).
///
/// Used in splash/login and for app-icon generation.
class TeamHiveLogo extends StatelessWidget {
  const TeamHiveLogo({
    super.key,
    required this.size,
    this.showShadow = true,
    this.isDark = false,
    this.backgroundColor,
    this.showWordmark = false,
    this.wordmarkColor,
  });

  final double size;
  final bool showShadow;
  final bool isDark;

  /// Hexagon interior fill — match the surface behind the logo.
  final Color? backgroundColor;
  final bool showWordmark;
  final Color? wordmarkColor;

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
          fillColor: backgroundColor ??
              (dark ? const Color(0xFF0E1F3D) : Colors.white),
          showShadow: showShadow,
          isDark: dark,
        ),
      ),
    );

    if (!showWordmark) return mark;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        mark,
        SizedBox(height: size * 0.14),
        Text(
          'TEAMHIVE',
          style: TextStyle(
            fontSize: size * 0.22,
            fontWeight: FontWeight.w800,
            letterSpacing: 2.4,
            color: wordmarkColor ??
                (dark ? AppColors.darkPrimary : const Color(0xFF111827)),
          ),
        ),
      ],
    );
  }
}

/// Flat-top? No — pointy-top regular hexagon, same math as ParkHive.
Path createTeamHiveHexagonPath(Size size) {
  final contentSize = size.width;
  final center = Offset(contentSize / 2, contentSize / 2);
  final radius = contentSize / 2 - 2;
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
  });

  final Color fillColor;
  final bool showShadow;
  final bool isDark;

  static const _lightStroke = [
    Color(0xFF86EFAC),
    Color(0xFF4ADE80),
    Color(0xFF22C55E),
    Color(0xFF15803D),
  ];

  static const _darkStroke = [
    Color(0xFFFDE68A),
    Color(0xFFF5C518),
    Color(0xFFE0B000),
    Color(0xFFA16207),
  ];

  static const _lightLetter = [
    Color(0xFF16A34A),
    Color(0xFF0D9488),
    Color(0xFF14532D),
  ];

  static const _darkLetter = [
    Color(0xFFF5C518),
    Color(0xFFE0B000),
    Color(0xFF854D0E),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final path = createTeamHiveHexagonPath(size);
    final contentSize = size.width;
    final center = Offset(contentSize / 2, contentSize / 2);
    final strokeColors = isDark ? _darkStroke : _lightStroke;
    final letterColors = isDark ? _darkLetter : _lightLetter;

    // 1. Hexagon fill (blends with background)
    canvas.drawPath(
      path,
      Paint()
        ..color = fillColor
        ..style = PaintingStyle.fill,
    );

    // 2. Thick rounded hexagon stroke with vertical brand gradient
    final strokeGradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: strokeColors,
      stops: const [0.0, 0.35, 0.65, 1.0],
    ).createShader(Rect.fromLTWH(0, 0, contentSize, contentSize));

    canvas.drawPath(
      path,
      Paint()
        ..shader = strokeGradient
        ..style = PaintingStyle.stroke
        ..strokeWidth = contentSize * 0.13
        ..strokeJoin = StrokeJoin.round,
    );

    // 3. Soft interior shadow (UI only — off for app icons)
    if (showShadow) {
      final shadowRect =
          Rect.fromLTRB(0, contentSize * 0.25, contentSize, contentSize);
      canvas.save();
      canvas.clipPath(path);
      canvas.drawRect(
        shadowRect,
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.transparent,
              (isDark ? Colors.white : Colors.black)
                  .withValues(alpha: isDark ? 0.28 : 0.35),
            ],
          ).createShader(shadowRect),
      );
      canvas.restore();
    }

    // 4. Bold geometric H (vector bars — same construction as app icon tool)
    final letterGradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: letterColors,
    );
    final paint = Paint()
      ..shader =
          letterGradient.createShader(Rect.fromLTWH(0, 0, contentSize, contentSize))
      ..style = PaintingStyle.fill;

    final bar = contentSize * 0.12;
    final left = contentSize * 0.30;
    final right = contentSize * 0.70;
    final top = contentSize * 0.26;
    final bottom = contentSize * 0.74;
    final midY = center.dy;
    final r = bar / 2;

    canvas.drawRRect(
      RRect.fromLTRBR(left - r, top, left + r, bottom, Radius.circular(r)),
      paint,
    );
    canvas.drawRRect(
      RRect.fromLTRBR(right - r, top, right + r, bottom, Radius.circular(r)),
      paint,
    );
    canvas.drawRRect(
      RRect.fromLTRBR(left - r, midY - r, right + r, midY + r, Radius.circular(r)),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant TeamHiveLogoPainter oldDelegate) =>
      fillColor != oldDelegate.fillColor ||
      showShadow != oldDelegate.showShadow ||
      isDark != oldDelegate.isDark;
}
