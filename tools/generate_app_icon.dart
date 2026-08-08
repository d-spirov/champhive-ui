/// Generates a precise TeamHive hexagon+H icon (ParkHive-style geometry).
///
/// Run from project root:
///   dart run tools/generate_app_icon.dart
///   dart run tools/add_icon_padding.dart
///   dart run flutter_launcher_icons

import 'dart:io';
import 'dart:math' as math;

import 'package:image/image.dart' as img;

void main() {
  // Full-bleed logo — padding is applied by tools/add_icon_padding.dart
  const size = 1024;

  final logo = img.Image(width: size, height: size);
  img.fill(logo, color: img.ColorRgb8(255, 255, 255));
  _paintLogo(logo);

  Directory('assets/icon').createSync(recursive: true);
  final bytes = img.encodePng(logo);
  File('assets/icon/icon_source.png').writeAsBytesSync(bytes);
  File('assets/icon/icon.png').writeAsBytesSync(bytes);
  stdout.writeln('✓ App icon source saved to assets/icon/icon_source.png (${bytes.length} bytes)');
  stdout.writeln('  Next: dart run tools/add_icon_padding.dart && dart run flutter_launcher_icons');
}

void _paintLogo(img.Image logo) {
  final s = logo.width.toDouble();
  final cx = s / 2;
  final cy = s / 2;
  final outerR = s / 2 - 2;
  final strokeW = s * 0.13;
  final innerR = outerR - strokeW;

  final outer = _hexPoints(cx, cy, outerR);
  final inner = _hexPoints(cx, cy, innerR);

  // Gradient ring = outer hex filled with stroke colors, then punch white inner
  _fillPolygonXY(logo, outer, (x, y) => _strokeColorAtY(y.toDouble(), s));
  _fillPolygonXY(logo, inner, (x, y) => img.ColorRgb8(255, 255, 255));

  // Geometric H
  final bar = s * 0.12;
  final left = s * 0.30;
  final right = s * 0.70;
  final top = s * 0.26;
  final bottom = s * 0.74;
  final r = bar / 2;

  _fillRoundRectGradient(logo, left - r, top, left + r, bottom, r);
  _fillRoundRectGradient(logo, right - r, top, right + r, bottom, r);
  _fillRoundRectGradient(logo, left - r, cy - r, right + r, cy + r, r);
}

List<math.Point<double>> _hexPoints(double cx, double cy, double radius) {
  // Pointy-top regular hexagon — same angles as ParkHive
  final pts = <math.Point<double>>[];
  for (var i = 0; i < 6; i++) {
    final angle = (math.pi / 3 * i) - (math.pi / 6);
    pts.add(math.Point(cx + radius * math.cos(angle), cy + radius * math.sin(angle)));
  }
  return pts;
}

img.ColorRgb8 _strokeColorAtY(double y, double height) {
  const stops = [0.0, 0.35, 0.65, 1.0];
  const colors = [
    [0x86, 0xEF, 0xAC],
    [0x4A, 0xDE, 0x80],
    [0x22, 0xC5, 0x5E],
    [0x15, 0x80, 0x3D],
  ];
  final t = (y / height).clamp(0.0, 1.0);
  var i = 0;
  while (i < stops.length - 1 && t > stops[i + 1]) {
    i++;
  }
  final local = ((t - stops[i]) / (stops[i + 1] - stops[i])).clamp(0.0, 1.0);
  final a = colors[i];
  final b = colors[i + 1];
  return img.ColorRgb8(
    (a[0] + (b[0] - a[0]) * local).round(),
    (a[1] + (b[1] - a[1]) * local).round(),
    (a[2] + (b[2] - a[2]) * local).round(),
  );
}

img.ColorRgb8 _letterColorAt(double x, double y, double size) {
  final t = ((x + y) / (2 * size)).clamp(0.0, 1.0);
  if (t < 0.5) {
    final local = t / 0.5;
    return img.ColorRgb8(
      (0x16 + (0x0D - 0x16) * local).round(),
      (0xA3 + (0x94 - 0xA3) * local).round(),
      (0x4A + (0x88 - 0x4A) * local).round(),
    );
  }
  final local = (t - 0.5) / 0.5;
  return img.ColorRgb8(
    (0x0D + (0x14 - 0x0D) * local).round(),
    (0x94 + (0x53 - 0x94) * local).round(),
    (0x88 + (0x2D - 0x88) * local).round(),
  );
}

void _fillPolygonXY(
  img.Image image,
  List<math.Point<double>> pts,
  img.Color Function(int x, int y) colorAt,
) {
  final minY = pts.map((p) => p.y).reduce(math.min).floor();
  final maxY = pts.map((p) => p.y).reduce(math.max).ceil();
  for (var y = minY; y <= maxY; y++) {
    final nodes = <double>[];
    for (var i = 0, j = pts.length - 1; i < pts.length; j = i++) {
      final yi = pts[i].y;
      final yj = pts[j].y;
      if ((yi < y && yj >= y) || (yj < y && yi >= y)) {
        nodes.add(pts[i].x + (y - yi) / (yj - yi) * (pts[j].x - pts[i].x));
      }
    }
    nodes.sort();
    for (var i = 0; i + 1 < nodes.length; i += 2) {
      final x0 = nodes[i].ceil();
      final x1 = nodes[i + 1].floor();
      for (var x = x0; x <= x1; x++) {
        if (x >= 0 && y >= 0 && x < image.width && y < image.height) {
          image.setPixel(x, y, colorAt(x, y));
        }
      }
    }
  }
}

void _fillRoundRectGradient(
  img.Image image,
  double left,
  double top,
  double right,
  double bottom,
  double radius,
) {
  final l = left.floor();
  final t = top.floor();
  final rgt = right.ceil();
  final b = bottom.ceil();
  for (var y = t; y <= b; y++) {
    for (var x = l; x <= rgt; x++) {
      if (x < 0 || y < 0 || x >= image.width || y >= image.height) continue;
      final px = x + 0.5;
      final py = y + 0.5;
      if (!_insideRoundRect(px, py, left, top, right, bottom, radius)) continue;
      image.setPixel(
        x,
        y,
        _letterColorAt(px, py, image.width.toDouble()),
      );
    }
  }
}

bool _insideRoundRect(
  double x,
  double y,
  double left,
  double top,
  double right,
  double bottom,
  double radius,
) {
  if (x < left || x > right || y < top || y > bottom) return false;

  // Straight mid sections
  if (x >= left + radius && x <= right - radius) return true;
  if (y >= top + radius && y <= bottom - radius) return true;

  // Corner discs
  final corners = <List<double>>[
    [left + radius, top + radius],
    [right - radius, top + radius],
    [left + radius, bottom - radius],
    [right - radius, bottom - radius],
  ];
  for (final c in corners) {
    final dx = x - c[0];
    final dy = y - c[1];
    if (dx * dx + dy * dy <= radius * radius) return true;
  }
  return false;
}
