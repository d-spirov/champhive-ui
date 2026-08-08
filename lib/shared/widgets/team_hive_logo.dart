import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Hexagonal shield logo with stylized H (ChampHive / TeamHive).
class TeamHiveLogo extends StatelessWidget {
  const TeamHiveLogo({
    super.key,
    this.size = 72,
    this.showWordmark = false,
    this.wordmarkColor,
  });

  final double size;
  final bool showWordmark;
  final Color? wordmarkColor;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = isDark ? AppColors.darkPrimary : AppColors.lightPrimary;
    final stroke = isDark ? AppColors.darkPrimary : const Color(0xFF111827);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CustomPaint(
          size: Size.square(size),
          painter: _HexLogoPainter(fill: primary, stroke: stroke),
        ),
        if (showWordmark) ...[
          SizedBox(height: size * 0.18),
          Text(
            'TEAMHIVE',
            style: TextStyle(
              fontSize: size * 0.28,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.4,
              color: wordmarkColor ??
                  (isDark ? AppColors.darkPrimary : const Color(0xFF111827)),
            ),
          ),
        ],
      ],
    );
  }
}

class _HexLogoPainter extends CustomPainter {
  _HexLogoPainter({required this.fill, required this.stroke});

  final Color fill;
  final Color stroke;

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path();
    final w = size.width;
    final h = size.height;
    path.moveTo(w * 0.5, h * 0.02);
    path.lineTo(w * 0.93, h * 0.25);
    path.lineTo(w * 0.93, h * 0.72);
    path.lineTo(w * 0.5, h * 0.98);
    path.lineTo(w * 0.07, h * 0.72);
    path.lineTo(w * 0.07, h * 0.25);
    path.close();

    canvas.drawPath(
      path,
      Paint()
        ..color = fill
        ..style = PaintingStyle.fill,
    );
    canvas.drawPath(
      path,
      Paint()
        ..color = stroke
        ..style = PaintingStyle.stroke
        ..strokeWidth = size.width * 0.045,
    );

    final hPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.09
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final left = w * 0.32;
    final right = w * 0.68;
    final top = h * 0.32;
    final bottom = h * 0.68;
    final mid = h * 0.5;
    canvas.drawLine(Offset(left, top), Offset(left, bottom), hPaint);
    canvas.drawLine(Offset(right, top), Offset(right, bottom), hPaint);
    canvas.drawLine(Offset(left, mid), Offset(right, mid), hPaint);
  }

  @override
  bool shouldRepaint(covariant _HexLogoPainter oldDelegate) =>
      oldDelegate.fill != fill || oldDelegate.stroke != stroke;
}
