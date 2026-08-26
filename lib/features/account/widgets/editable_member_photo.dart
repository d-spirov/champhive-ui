import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../l10n/app_localizations.dart';
import '../../../shared/theme/app_theme.dart';
import '../../../shared/utils/api_error_message.dart';
import '../../clubs/providers/clubs_provider.dart';
import '../../players/providers/players_provider.dart';
import '../../players/widgets/player_avatar.dart';
import '../providers/account_extras_provider.dart';

/// Tappable member avatar: camera / library / remove.
class EditableMemberPhoto extends ConsumerStatefulWidget {
  const EditableMemberPhoto({
    super.key,
    required this.clubId,
    required this.memberId,
    required this.label,
    this.size = 48,
    this.sheetTitle,
  });

  final String clubId;
  final String memberId;
  final String label;
  final double size;
  final String? sheetTitle;

  @override
  ConsumerState<EditableMemberPhoto> createState() =>
      _EditableMemberPhotoState();
}

class _EditableMemberPhotoState extends ConsumerState<EditableMemberPhoto> {
  bool _busy = false;

  String _clubId() {
    if (widget.clubId.isNotEmpty) return widget.clubId;
    return ref.read(selectedClubIdProvider) ?? '';
  }

  Future<void> _openSheet() async {
    if (_busy) return;
    final l10n = AppLocalizations.of(context)!;
    if (widget.memberId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.photoNeedLinkedMember)),
      );
      return;
    }
    if (_clubId().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.photoSelectClubFirst)),
      );
      return;
    }
    final hasPhoto =
        (ref.read(memberPhotoBytesProvider(widget.memberId)).valueOrNull ??
                const [])
            .isNotEmpty;

    final action = await showModalBottomSheet<_PhotoAction>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                child: Text(
                  widget.sheetTitle ?? l10n.changePhoto,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera_outlined),
                title: Text(l10n.takePhoto),
                onTap: () => Navigator.pop(context, _PhotoAction.camera),
              ),
              ListTile(
                leading: const Icon(Icons.photo_library_outlined),
                title: Text(l10n.chooseFromLibrary),
                onTap: () => Navigator.pop(context, _PhotoAction.library),
              ),
              if (hasPhoto)
                ListTile(
                  leading: const Icon(
                    Icons.delete_outline_rounded,
                    color: AppColors.danger,
                  ),
                  title: Text(
                    l10n.removePhoto,
                    style: const TextStyle(color: AppColors.danger),
                  ),
                  onTap: () => Navigator.pop(context, _PhotoAction.remove),
                ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
    if (!mounted || action == null) return;

    switch (action) {
      case _PhotoAction.camera:
        await _pick(ImageSource.camera);
      case _PhotoAction.library:
        await _pick(ImageSource.gallery);
      case _PhotoAction.remove:
        await _remove();
    }
  }

  Future<void> _pick(ImageSource source) async {
    final l10n = AppLocalizations.of(context)!;
    try {
      final file = await ImagePicker().pickImage(
        source: source,
        maxWidth: 1600,
        maxHeight: 1600,
        imageQuality: 85,
        requestFullMetadata: false,
      );
      if (file == null || !mounted) return;

      setState(() => _busy = true);
      final bytes = await file.readAsBytes();
      await ref.read(accountExtrasControllerProvider).uploadMemberPhoto(
            clubId: _clubId(),
            memberId: widget.memberId,
            bytes: bytes,
            filename: file.name,
          );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.photoUpdated)),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_photoError(e, l10n))),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _remove() async {
    final l10n = AppLocalizations.of(context)!;
    setState(() => _busy = true);
    try {
      await ref.read(accountExtrasControllerProvider).deleteMemberPhoto(
            clubId: _clubId(),
            memberId: widget.memberId,
          );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.photoRemoved)),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_photoError(e, l10n))),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  String _photoError(Object error, AppLocalizations l10n) {
    if (error is DioException && error.response?.statusCode == 403) {
      return l10n.photoNoPermission;
    }
    return apiErrorMessage(error, fallback: l10n.photoUpdateFailed);
  }

  @override
  Widget build(BuildContext context) {
    final size = widget.size;
    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        onTap: _busy ? null : _openSheet,
        customBorder: const CircleBorder(),
        child: SizedBox(
          width: size,
          height: size,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              MemberPhotoAvatar(
                memberId: widget.memberId,
                label: widget.label,
                size: size,
              ),
              Positioned(
                right: 0,
                bottom: 0,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Theme.of(context).scaffoldBackgroundColor,
                      width: 2,
                    ),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(size >= 56 ? 5 : 3),
                    child: _busy
                        ? SizedBox(
                            width: size >= 56 ? 14 : 12,
                            height: size >= 56 ? 14 : 12,
                            child: const CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Icon(
                            Icons.camera_alt_rounded,
                            size: size >= 56 ? 14 : 12,
                            color: Colors.white,
                          ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

enum _PhotoAction { camera, library, remove }
