import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/widgets/ui_bits.dart';
import '../providers/players_provider.dart';

/// Circle avatar that loads the club player photo via the authenticated API.
class PlayerAvatar extends ConsumerWidget {
  const PlayerAvatar({
    super.key,
    required this.playerId,
    required this.label,
    this.hasPhoto = false,
    this.size = 48,
  });

  final String playerId;
  final String label;
  final bool hasPhoto;
  final double size;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!hasPhoto || playerId.isEmpty) {
      return AvatarCircle(label: label, size: size);
    }

    final photoAsync = ref.watch(playerPhotoProvider(playerId));
    return photoAsync.when(
      loading: () => AvatarCircle(label: label, size: size),
      error: (_, _) => AvatarCircle(label: label, size: size),
      data: (bytes) {
        if (bytes == null || bytes.isEmpty) {
          return AvatarCircle(label: label, size: size);
        }
        return CircleAvatar(
          radius: size / 2,
          backgroundColor:
              Theme.of(context).colorScheme.primary.withValues(alpha: 0.12),
          backgroundImage: MemoryImage(bytes),
        );
      },
    );
  }
}
