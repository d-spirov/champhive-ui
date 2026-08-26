/// Crops the ChampHive brand sheet into in-app assets and a 1024 app icon.
///
/// Run from project root:
///   dart run tools/generate_app_icon.dart
///   dart run flutter_launcher_icons
///
/// Source: assets/brand/champhive_lockup_source.png
library;

import 'dart:io';
import 'dart:math' as math;

import 'package:image/image.dart' as img;

bool _isBg(img.Pixel p) => p.r < 22 && p.g < 22 && p.b < 22;

({int minX, int minY, int maxX, int maxY}) _bbox(
  img.Image image, {
  required int y0,
  required int y1,
}) {
  var minX = image.width, minY = image.height, maxX = 0, maxY = 0;
  for (var y = y0; y <= y1; y++) {
    for (var x = 0; x < image.width; x++) {
      if (_isBg(image.getPixel(x, y))) continue;
      if (x < minX) minX = x;
      if (y < minY) minY = y;
      if (x > maxX) maxX = x;
      if (y > maxY) maxY = y;
    }
  }
  return (minX: minX, minY: minY, maxX: maxX, maxY: maxY);
}

/// Knock out true black backdrop only — keep navy “Champ”.
img.Image _knockoutBlack(img.Image src) {
  final out = img.Image(
    width: src.width,
    height: src.height,
    numChannels: 4,
  );
  for (final p in src) {
    final r = p.r.toInt();
    final g = p.g.toInt();
    final b = p.b.toInt();
    final black = r < 10 && g < 10 && b < 10;
    final a = black
        ? 0
        : r < 22 && g < 22 && b < 22
        ? (((r + g + b) / 3 - 8) / 14 * 255).round().clamp(0, 255)
        : 255;
    out.setPixelRgba(p.x, p.y, r, g, b, a);
  }
  return out;
}

img.Image _squarePad(img.Image src, {required img.Color bg, int pad = 0}) {
  final size = math.max(src.width, src.height) + pad * 2;
  final out = img.Image(
    width: size,
    height: size,
    numChannels: src.numChannels,
  );
  img.fill(out, color: bg);
  final dx = (size - src.width) ~/ 2;
  final dy = (size - src.height) ~/ 2;
  img.compositeImage(out, src, dstX: dx, dstY: dy);
  return out;
}

img.Image _to1024(img.Image src, {required img.Color bg, double scale = 1.0}) {
  const canvas = 1024;
  final target = (canvas * scale).round();
  final resized = img.copyResize(
    src,
    width: target,
    height: target,
    interpolation: img.Interpolation.cubic,
  );
  final out = img.Image(width: canvas, height: canvas, numChannels: 4);
  img.fill(out, color: bg);
  final pad = (canvas - target) ~/ 2;
  img.compositeImage(out, resized, dstX: pad, dstY: pad);
  return out;
}

void main() {
  final src = img.decodeImage(
    File('assets/brand/champhive_lockup_source.png').readAsBytesSync(),
  )!;

  final iconBox = _bbox(src, y0: 134, y1: 611);
  final lockupBox = _bbox(src, y0: 134, y1: 819);

  final icon = img.copyCrop(
    src,
    x: iconBox.minX,
    y: iconBox.minY,
    width: iconBox.maxX - iconBox.minX + 1,
    height: iconBox.maxY - iconBox.minY + 1,
  );

  Directory('assets/brand').createSync(recursive: true);
  Directory('assets/icon').createSync(recursive: true);

  final mark = _knockoutBlack(icon);
  File('assets/brand/champhive_mark.png').writeAsBytesSync(img.encodePng(mark));

  const lockupPad = 12;
  final lockup = img.copyCrop(
    src,
    x: math.max(0, lockupBox.minX - lockupPad),
    y: math.max(0, lockupBox.minY - lockupPad),
    width: (lockupBox.maxX - lockupBox.minX + 1) + lockupPad * 2,
    height: (lockupBox.maxY - lockupBox.minY + 1) + lockupPad * 2,
  );
  File(
    'assets/brand/champhive_lockup.png',
  ).writeAsBytesSync(img.encodePng(_knockoutBlack(lockup)));

  final sample = src.getPixel(
    (iconBox.minX + iconBox.maxX) ~/ 2,
    iconBox.minY + 8,
  );
  final blueBg = img.ColorRgba8(
    sample.r.toInt(),
    sample.g.toInt(),
    sample.b.toInt(),
    255,
  );
  final iconSquare = _squarePad(icon, bg: blueBg, pad: 4);
  final source1024 = _to1024(iconSquare, bg: blueBg);
  File('assets/icon/icon_source.png').writeAsBytesSync(img.encodePng(source1024));
  File('assets/icon/icon.png').writeAsBytesSync(img.encodePng(source1024));

  stdout.writeln('✓ Brand assets and 1024 app icon written');
  stdout.writeln('  Next: dart run flutter_launcher_icons');
}
