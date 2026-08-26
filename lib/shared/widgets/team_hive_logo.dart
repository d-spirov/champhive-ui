import 'package:flutter/material.dart';

/// ChampHive brand mark (icon) or icon + wordmark lockup.
class TeamHiveLogo extends StatelessWidget {
  const TeamHiveLogo({
    super.key,
    required this.size,
    this.showShadow = true,
    this.showWordmark = false,
  });

  /// Height of the rounded-square icon. Lockup height is derived from this.
  final double size;
  final bool showShadow;
  final bool showWordmark;

  static const markAsset = 'assets/brand/champhive_mark.png';
  static const lockupAsset = 'assets/brand/champhive_lockup.png';

  @override
  Widget build(BuildContext context) {
    final image = Image.asset(
      showWordmark ? lockupAsset : markAsset,
      width: showWordmark ? size * 1.94 : size,
      height: showWordmark ? size * 1.50 : size,
      fit: BoxFit.contain,
      filterQuality: FilterQuality.high,
    );

    if (!showShadow) return image;

    return DecoratedBox(
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
      child: image,
    );
  }
}
