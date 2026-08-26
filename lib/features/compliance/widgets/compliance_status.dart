import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../../../shared/theme/app_theme.dart';

Color complianceStatusColor(String status) {
  switch (status.toLowerCase()) {
    case 'valid':
    case 'verified':
      return AppColors.present;
    case 'expiring':
    case 'pending':
      return AppColors.late;
    case 'missing':
    case 'rejected':
      return AppColors.absent;
    default:
      return AppColors.excused;
  }
}

String complianceRollupLabel(AppLocalizations l10n, String status) {
  switch (status.toLowerCase()) {
    case 'valid':
      return l10n.complianceValid;
    case 'expiring':
      return l10n.complianceExpiring;
    case 'missing':
      return l10n.complianceMissing;
    default:
      return l10n.complianceUnknown;
  }
}

String documentStatusLabel(AppLocalizations l10n, String status) {
  switch (status.toLowerCase()) {
    case 'pending':
      return l10n.documentPending;
    case 'verified':
      return l10n.documentVerified;
    case 'rejected':
      return l10n.documentRejected;
    case 'awaitingupload':
      return l10n.documentAwaitingUpload;
    default:
      return status;
  }
}

class ComplianceStatusChip extends StatelessWidget {
  const ComplianceStatusChip({super.key, required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final color = complianceStatusColor(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        complianceRollupLabel(l10n, status),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
            ),
      ),
    );
  }
}
