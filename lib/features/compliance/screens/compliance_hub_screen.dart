import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../l10n/app_localizations.dart';
import '../../../shared/l10n/date_l10n.dart';
import '../../../shared/theme/app_theme.dart';
import '../../../shared/utils/api_error_message.dart';
import '../../../shared/widgets/ui_bits.dart';
import '../../auth/providers/auth_provider.dart';
import '../../clubs/providers/clubs_provider.dart';
import '../providers/compliance_provider.dart';
import '../widgets/compliance_status.dart';

class ComplianceHubScreen extends ConsumerStatefulWidget {
  const ComplianceHubScreen({super.key});

  @override
  ConsumerState<ComplianceHubScreen> createState() =>
      _ComplianceHubScreenState();
}

class _ComplianceHubScreenState extends ConsumerState<ComplianceHubScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs = TabController(length: 2, vsync: this);

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDemo = ref.watch(authNotifierProvider).user?.id == 'demo';
    final club = ref.watch(selectedClubProvider);

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
          club == null ? l10n.documents : l10n.clubDocumentsTitle(club.name),
        ),
        bottom: TabBar(
          controller: _tabs,
          labelColor: Theme.of(context).colorScheme.primary,
          unselectedLabelColor: Theme.of(
            context,
          ).colorScheme.onSurface.withValues(alpha: 0.55),
          indicatorColor: Theme.of(context).colorScheme.primary,
          tabs: [
            Tab(text: l10n.complianceOverview),
            Tab(text: l10n.reviewQueue),
          ],
        ),
      ),
      body: isDemo
          ? Center(child: Text(l10n.signInToSeeDocuments))
          : TabBarView(
              controller: _tabs,
              children: const [_OverviewTab(), _QueueTab()],
            ),
    );
  }
}

class _OverviewTab extends ConsumerWidget {
  const _OverviewTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final clubId = ref.watch(selectedClubIdProvider);
    final async = ref.watch(complianceOverviewProvider);

    if (clubId == null) {
      return Center(child: Text(l10n.selectClubFirst));
    }

    return async.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => _ErrorBody(
        message: apiErrorMessage(e, fallback: l10n.couldNotLoadCompliance),
        onRetry: () => ref.invalidate(complianceOverviewProvider),
      ),
      data: (data) {
        if (data == null) {
          return Center(child: Text(l10n.signInToSeeDocuments));
        }
        return RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(complianceOverviewProvider);
            await ref.read(complianceOverviewProvider.future);
          },
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
            children: [
              Row(
                children: [
                  Expanded(
                    child: _CountCard(
                      label: l10n.complianceValid,
                      value: '${data.validCount}',
                      color: AppColors.present,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _CountCard(
                      label: l10n.complianceExpiring,
                      value: '${data.expiringCount}',
                      color: AppColors.late,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _CountCard(
                      label: l10n.complianceMissing,
                      value: '${data.missingCount}',
                      color: AppColors.absent,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (data.members.isEmpty)
                Text(l10n.noComplianceMembers)
              else
                for (final row in data.members)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: AppCard(
                      onTap: () => context.push(
                        '/compliance/members/${row.memberId}'
                        '?name=${Uri.encodeComponent(row.memberName)}',
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 4,
                        vertical: 4,
                      ),
                      child: ListTile(
                        title: Text(row.memberName),
                        subtitle: Text(
                          [
                            if ((row.teamName ?? '').isNotEmpty) row.teamName!,
                            if (row.issues.isNotEmpty)
                              row.issues.map((i) => i.name).join(' · '),
                          ].join(' · '),
                        ),
                        trailing: ComplianceStatusChip(status: row.status),
                      ),
                    ),
                  ),
            ],
          ),
        );
      },
    );
  }
}

class _QueueTab extends ConsumerWidget {
  const _QueueTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final clubId = ref.watch(selectedClubIdProvider);
    final async = ref.watch(pendingComplianceDocumentsProvider);

    if (clubId == null) {
      return Center(child: Text(l10n.selectClubFirst));
    }

    return async.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => _ErrorBody(
        message: apiErrorMessage(e, fallback: l10n.couldNotLoadCompliance),
        onRetry: () => ref.invalidate(pendingComplianceDocumentsProvider),
      ),
      data: (page) {
        final items = page?.items ?? const [];
        if (items.isEmpty) {
          return Center(child: Text(l10n.noDocumentsPending));
        }
        final fmt = appYMMMd(context);
        return RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(pendingComplianceDocumentsProvider);
            await ref.read(pendingComplianceDocumentsProvider.future);
          },
          child: ListView.separated(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
            itemCount: items.length,
            separatorBuilder: (_, _) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final doc = items[index];
              return AppCard(
                onTap: () => context.push(
                  '/compliance/members/${doc.memberId}'
                  '?name=${Uri.encodeComponent(doc.memberName)}',
                ),
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                child: ListTile(
                  leading: Icon(
                    doc.isPdf
                        ? Icons.picture_as_pdf_outlined
                        : Icons.image_outlined,
                  ),
                  title: Text(doc.memberName),
                  subtitle: Text(
                    [
                      doc.documentTypeName,
                      if (doc.createdAtUtc != null)
                        fmt.format(doc.createdAtUtc!.toLocal()),
                    ].join(' · '),
                  ),
                  trailing: Text(documentStatusLabel(l10n, doc.status)),
                ),
              );
            },
          ),
        );
      },
    );
  }
}

class _CountCard extends StatelessWidget {
  const _CountCard({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
      child: Column(
        children: [
          Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.labelSmall,
          ),
        ],
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
