import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../l10n/app_localizations.dart';
import '../../../shared/l10n/date_l10n.dart';
import '../../../shared/models/compliance.dart';
import '../../../shared/theme/app_theme.dart';
import '../../../shared/utils/api_error_message.dart';
import '../../../shared/widgets/ui_bits.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/compliance_provider.dart';
import '../widgets/compliance_status.dart';

const _maxUploadBytes = 15 * 1024 * 1024;

class MemberComplianceScreen extends ConsumerStatefulWidget {
  const MemberComplianceScreen({
    super.key,
    required this.memberId,
    this.memberName,
  });

  final String memberId;
  final String? memberName;

  @override
  ConsumerState<MemberComplianceScreen> createState() =>
      _MemberComplianceScreenState();
}

class _MemberComplianceScreenState
    extends ConsumerState<MemberComplianceScreen> {
  String? _busyKey;

  Future<void> _pickAndUpload(MemberRequirement requirement) async {
    final l10n = AppLocalizations.of(context)!;
    final source = await showModalBottomSheet<_PickSource>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.photo_camera_outlined),
                title: Text(l10n.takePhoto),
                onTap: () => Navigator.pop(context, _PickSource.camera),
              ),
              ListTile(
                leading: const Icon(Icons.photo_library_outlined),
                title: Text(l10n.chooseFromLibrary),
                onTap: () => Navigator.pop(context, _PickSource.library),
              ),
              ListTile(
                leading: const Icon(Icons.picture_as_pdf_outlined),
                title: Text(l10n.choosePdf),
                onTap: () => Navigator.pop(context, _PickSource.pdf),
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
    if (!mounted || source == null) return;

    String name = 'document';
    late String contentType;
    List<int>? bytes;
    try {
      switch (source) {
        case _PickSource.camera:
        case _PickSource.library:
          final file = await ImagePicker().pickImage(
            source: source == _PickSource.camera
                ? ImageSource.camera
                : ImageSource.gallery,
            maxWidth: 2000,
            maxHeight: 2000,
            imageQuality: 85,
          );
          if (file == null) return;
          bytes = await file.readAsBytes();
          name = file.name.isNotEmpty ? file.name : 'photo.jpg';
          contentType = _contentTypeFor(name, fallback: 'image/jpeg');
        case _PickSource.pdf:
          final result = await FilePicker.platform.pickFiles(
            type: FileType.custom,
            allowedExtensions: const ['pdf', 'jpg', 'jpeg', 'png', 'heic'],
            withData: true,
          );
          if (result == null || result.files.isEmpty) return;
          final f = result.files.first;
          bytes = f.bytes;
          name = f.name;
          contentType = _contentTypeFor(name, fallback: 'application/pdf');
      }
    } catch (e) {
      if (!mounted) return;
      _snack(apiErrorMessage(e, fallback: l10n.uploadFailed));
      return;
    }

    if (!mounted || bytes == null) return;
    if (bytes.length > _maxUploadBytes) {
      _snack(l10n.documentTooLarge);
      return;
    }

    final issuedOn = await _confirmIssuedOn(name);
    if (!mounted || issuedOn == null || issuedOn == false) return;
    final date = issuedOn is DateTime ? issuedOn : null;

    setState(() => _busyKey = 'upload:${requirement.documentTypeId}');
    try {
      await ref
          .read(complianceControllerProvider)
          .upload(
            memberId: widget.memberId,
            documentTypeId: requirement.documentTypeId,
            fileName: name,
            contentType: contentType,
            bytes: bytes,
            issuedOn: date,
          );
      if (!mounted) return;
      _snack(l10n.documentUploaded);
    } catch (e) {
      if (!mounted) return;
      _snack(apiErrorMessage(e, fallback: l10n.uploadFailed));
    } finally {
      if (mounted) setState(() => _busyKey = null);
    }
  }

  /// `false` cancelled, `null` upload without date, [DateTime] with date.
  Future<Object?> _confirmIssuedOn(String fileName) async {
    final l10n = AppLocalizations.of(context)!;
    DateTime? issuedOn;
    return showDialog<Object?>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setLocal) {
            return AlertDialog(
              title: Text(l10n.uploadDocument),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(fileName),
                  const SizedBox(height: 12),
                  Text(l10n.issuedOnHint),
                  const SizedBox(height: 8),
                  OutlinedButton.icon(
                    onPressed: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: issuedOn ?? DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime.now(),
                      );
                      if (picked != null) setLocal(() => issuedOn = picked);
                    },
                    icon: const Icon(Icons.event_outlined),
                    label: Text(
                      issuedOn == null
                          ? l10n.issuedOn
                          : appYMMMd(context).format(issuedOn!),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: Text(l10n.cancel),
                ),
                FilledButton(
                  onPressed: () => Navigator.pop(context, issuedOn ?? 'nodate'),
                  child: Text(l10n.uploadDocument),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _view(ComplianceDocument doc) async {
    final l10n = AppLocalizations.of(context)!;
    setState(() => _busyKey = 'view:${doc.id}');
    try {
      final ticket = await ref
          .read(complianceControllerProvider)
          .contentUrl(doc.id);
      if (!mounted) return;
      if (ticket.audited) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.contentViewAudited)));
      }
      final uri = Uri.tryParse(ticket.url);
      if (uri != null && uri.hasScheme && (doc.isPdf || !doc.isImage)) {
        final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
        if (!ok && mounted) _snack(l10n.couldNotOpenDocument);
        return;
      }
      if (uri == null || !uri.hasScheme) {
        _snack(l10n.couldNotOpenDocument);
        return;
      }
      final bytes = await Dio().get<List<int>>(
        ticket.url,
        options: Options(responseType: ResponseType.bytes),
      );
      if (!mounted) return;
      final data = bytes.data;
      if (data == null || data.isEmpty) {
        _snack(l10n.couldNotOpenDocument);
        return;
      }
      await showDialog<void>(
        context: context,
        builder: (context) {
          return Dialog(
            child: InteractiveViewer(
              child: Image.memory(
                Uint8List.fromList(data),
                fit: BoxFit.contain,
              ),
            ),
          );
        },
      );
    } catch (e) {
      if (!mounted) return;
      _snack(apiErrorMessage(e, fallback: l10n.couldNotOpenDocument));
    } finally {
      if (mounted) setState(() => _busyKey = null);
    }
  }

  Future<void> _delete(ComplianceDocument doc) async {
    final l10n = AppLocalizations.of(context)!;
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.deleteDocument),
        content: Text(l10n.confirmDeleteDocument),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.deleteDocument),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    setState(() => _busyKey = 'del:${doc.id}');
    try {
      await ref
          .read(complianceControllerProvider)
          .delete(doc.id, memberId: widget.memberId);
      if (!mounted) return;
      _snack(l10n.documentDeleted);
    } catch (e) {
      if (!mounted) return;
      _snack(apiErrorMessage(e, fallback: l10n.photoUpdateFailed));
    } finally {
      if (mounted) setState(() => _busyKey = null);
    }
  }

  Future<void> _review(ComplianceDocument doc, {required bool approved}) async {
    final l10n = AppLocalizations.of(context)!;
    final reasonCtrl = TextEditingController();
    DateTime? expiresOn = doc.expiresOn;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setLocal) {
            return AlertDialog(
              title: Text(approved ? l10n.verifyDocument : l10n.rejectDocument),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (!approved)
                    TextField(
                      controller: reasonCtrl,
                      maxLines: 3,
                      decoration: InputDecoration(
                        labelText: l10n.rejectionReason,
                      ),
                    ),
                  if (approved) ...[
                    const SizedBox(height: 8),
                    OutlinedButton.icon(
                      onPressed: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: expiresOn ?? DateTime.now(),
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now().add(
                            const Duration(days: 365 * 8),
                          ),
                        );
                        if (picked != null) {
                          setLocal(() => expiresOn = picked);
                        }
                      },
                      icon: const Icon(Icons.event_outlined),
                      label: Text(
                        expiresOn == null
                            ? l10n.expiresOn
                            : appYMMMd(context).format(expiresOn!),
                      ),
                    ),
                  ],
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: Text(l10n.cancel),
                ),
                FilledButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: Text(
                    approved ? l10n.verifyDocument : l10n.rejectDocument,
                  ),
                ),
              ],
            );
          },
        );
      },
    );
    final reason = reasonCtrl.text.trim();
    reasonCtrl.dispose();
    if (confirmed != true || !mounted) return;
    if (!approved && reason.isEmpty) {
      _snack(l10n.rejectReasonRequired);
      return;
    }
    setState(() => _busyKey = 'rev:${doc.id}');
    try {
      await ref
          .read(complianceControllerProvider)
          .review(
            documentId: doc.id,
            memberId: widget.memberId,
            approved: approved,
            reason: approved ? null : reason,
            expiresOn: approved ? expiresOn : null,
          );
      if (!mounted) return;
      _snack(
        approved ? l10n.documentVerifiedSnack : l10n.documentRejectedSnack,
      );
    } catch (e) {
      if (!mounted) return;
      _snack(apiErrorMessage(e, fallback: l10n.photoUpdateFailed));
    } finally {
      if (mounted) setState(() => _busyKey = null);
    }
  }

  Future<void> _ask(MemberCompliance picture, MemberRequirement req) async {
    final l10n = AppLocalizations.of(context)!;
    setState(() => _busyKey = 'ask:${req.documentTypeId}');
    try {
      final result = await ref
          .read(complianceControllerProvider)
          .askFamily(
            clubId: picture.clubId,
            memberId: widget.memberId,
            documentTypeId: req.documentTypeId,
          );
      if (!mounted) return;
      if (result.alreadyAskedToday) {
        _snack(l10n.familyAlreadyAsked);
      } else {
        _snack(l10n.familyAsked(result.recipients));
      }
    } catch (e) {
      if (!mounted) return;
      _snack(apiErrorMessage(e, fallback: l10n.photoUpdateFailed));
    } finally {
      if (mounted) setState(() => _busyKey = null);
    }
  }

  void _snack(String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final async = ref.watch(memberComplianceProvider(widget.memberId));
    final user = ref.watch(authNotifierProvider).user;
    final isDemo = user?.id == 'demo';

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/more');
            }
          },
        ),
        title: Text(
          widget.memberName?.isNotEmpty == true
              ? widget.memberName!
              : l10n.documents,
        ),
      ),
      body: isDemo
          ? Center(child: Text(l10n.signInToSeeDocuments))
          : async.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => _ErrorBody(
                message: apiErrorMessage(
                  e,
                  fallback: l10n.couldNotLoadCompliance,
                ),
                onRetry: () =>
                    ref.invalidate(memberComplianceProvider(widget.memberId)),
              ),
              data: (picture) {
                final canVerify =
                    user?.hasClubPermission(
                      picture.clubId,
                      'DOCUMENT_VERIFY',
                    ) ??
                    false;
                if (picture.requirements.isEmpty) {
                  return Center(child: Text(l10n.noRequirements));
                }
                return RefreshIndicator(
                  onRefresh: () async {
                    ref.invalidate(memberComplianceProvider(widget.memberId));
                    await ref.read(
                      memberComplianceProvider(widget.memberId).future,
                    );
                  },
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              picture.memberName,
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(fontWeight: FontWeight.w700),
                            ),
                          ),
                          ComplianceStatusChip(status: picture.status),
                        ],
                      ),
                      const SizedBox(height: 16),
                      for (final req in picture.requirements)
                        _RequirementCard(
                          requirement: req,
                          busy: _busyKey,
                          canVerify: canVerify,
                          onUpload: () => _pickAndUpload(req),
                          onView: req.latestDocument == null
                              ? null
                              : () => _view(req.latestDocument!),
                          onDelete: req.latestDocument == null
                              ? null
                              : () => _delete(req.latestDocument!),
                          onVerify: req.latestDocument?.isPending == true
                              ? () =>
                                    _review(req.latestDocument!, approved: true)
                              : null,
                          onReject: req.latestDocument?.isPending == true
                              ? () => _review(
                                  req.latestDocument!,
                                  approved: false,
                                )
                              : null,
                          onAsk: canVerify && !req.satisfied
                              ? () => _ask(picture, req)
                              : null,
                        ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}

class _RequirementCard extends StatelessWidget {
  const _RequirementCard({
    required this.requirement,
    required this.busy,
    required this.canVerify,
    required this.onUpload,
    this.onView,
    this.onDelete,
    this.onVerify,
    this.onReject,
    this.onAsk,
  });

  final MemberRequirement requirement;
  final String? busy;
  final bool canVerify;
  final VoidCallback onUpload;
  final VoidCallback? onView;
  final VoidCallback? onDelete;
  final VoidCallback? onVerify;
  final VoidCallback? onReject;
  final VoidCallback? onAsk;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final doc = requirement.latestDocument;
    final uploading = busy == 'upload:${requirement.documentTypeId}';
    final asking = busy == 'ask:${requirement.documentTypeId}';
    final viewing = doc != null && busy == 'view:${doc.id}';
    final dateFmt = appYMMMd(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: AppCard(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    requirement.name,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
                Icon(
                  requirement.satisfied
                      ? Icons.check_circle_rounded
                      : Icons.error_outline_rounded,
                  color: requirement.satisfied
                      ? AppColors.present
                      : AppColors.absent,
                  size: 20,
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              [
                requirement.isRequired
                    ? l10n.requirementRequired
                    : l10n.requirementOptional,
                if (requirement.expiresOn != null)
                  l10n.expiresOnDate(dateFmt.format(requirement.expiresOn!)),
              ].join(' · '),
              style: Theme.of(context).textTheme.bodySmall,
            ),
            if (doc != null) ...[
              const SizedBox(height: 8),
              Text(
                '${documentStatusLabel(l10n, doc.status)} · ${doc.fileName}',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              if (doc.isRejected && (doc.rejectionReason ?? '').isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    doc.rejectionReason!,
                    style: const TextStyle(color: AppColors.danger),
                  ),
                ),
            ],
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: [
                TextButton.icon(
                  onPressed: uploading ? null : onUpload,
                  icon: uploading
                      ? const SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.upload_file_outlined, size: 18),
                  label: Text(l10n.uploadDocument),
                ),
                if (doc != null && doc.canReadContent)
                  TextButton.icon(
                    onPressed: viewing ? null : onView,
                    icon: const Icon(Icons.visibility_outlined, size: 18),
                    label: Text(l10n.viewDocument),
                  ),
                if (doc != null && (doc.isPending || doc.isRejected))
                  TextButton.icon(
                    onPressed: onDelete,
                    icon: const Icon(Icons.delete_outline, size: 18),
                    label: Text(l10n.deleteDocument),
                  ),
                if (canVerify && onVerify != null)
                  TextButton.icon(
                    onPressed: onVerify,
                    icon: const Icon(Icons.verified_outlined, size: 18),
                    label: Text(l10n.verifyDocument),
                  ),
                if (canVerify && onReject != null)
                  TextButton.icon(
                    onPressed: onReject,
                    icon: const Icon(Icons.close_rounded, size: 18),
                    label: Text(l10n.rejectDocument),
                  ),
                if (onAsk != null)
                  TextButton.icon(
                    onPressed: asking ? null : onAsk,
                    icon: const Icon(Icons.outgoing_mail, size: 18),
                    label: Text(l10n.askFamily),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorBody extends StatelessWidget {
  const _ErrorBody({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            FilledButton(onPressed: onRetry, child: Text(l10n.retry)),
          ],
        ),
      ),
    );
  }
}

enum _PickSource { camera, library, pdf }

String _contentTypeFor(String fileName, {required String fallback}) {
  final lower = fileName.toLowerCase();
  if (lower.endsWith('.pdf')) return 'application/pdf';
  if (lower.endsWith('.png')) return 'image/png';
  if (lower.endsWith('.heic') || lower.endsWith('.heif')) return 'image/heic';
  if (lower.endsWith('.jpg') || lower.endsWith('.jpeg')) return 'image/jpeg';
  return fallback;
}
