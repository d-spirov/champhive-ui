/// Adds safe-zone padding to app icon for iOS (avoids rounded-corner clipping).
/// Run: dart run tools/add_icon_padding.dart
///
/// Then: dart run flutter_launcher_icons

import 'dart:io';

import 'package:image/image.dart' as img;

void main() async {
  const outputPath = 'assets/icon/icon.png';
  const canvasSize = 1024;
  const scale = 0.72;

  const iconSource = 'assets/icon/icon_source.png';
  const assetsIcon = 'assets/icon/icon.png';

  final inputPath = await File(iconSource).exists() ? iconSource : assetsIcon;
  final file = File(inputPath);
  if (!await file.exists()) {
    print('Error: No icon found. Run: flutter test test/generate_app_icon_test.dart');
    exit(1);
  }

  final bytes = await file.readAsBytes();
  var original = img.decodeImage(bytes);
  if (original == null) {
    print('Error: Could not decode $inputPath');
    exit(1);
  }

  final w = original.width;
  final h = original.height;
  if (w != h) {
    final size = w < h ? w : h;
    final x = (w - size) ~/ 2;
    final y = (h - size) ~/ 2;
    original = img.copyCrop(original, x: x, y: y, width: size, height: size);
  }

  final maxLogoSize = (canvasSize * scale).round();
  final scaleFactor = (maxLogoSize / original.width).clamp(0.1, 1.0);
  final newSize = (original.width * scaleFactor).round();
  final pad = (canvasSize - newSize) ~/ 2;

  final scaled = img.copyResize(original, width: newSize, height: newSize);
  final padded = img.Image(width: canvasSize, height: canvasSize);
  img.fill(padded, color: img.ColorRgb8(255, 255, 255));
  img.compositeImage(padded, scaled, dstX: pad, dstY: pad);

  await Directory('assets/icon').create(recursive: true);
  await File(outputPath).writeAsBytes(img.encodePng(padded));
  print('✓ Icon ${canvasSize}x$canvasSize saved to $outputPath');
  print('  Run: dart run flutter_launcher_icons');
}
