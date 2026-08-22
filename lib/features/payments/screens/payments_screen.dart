import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../l10n/app_localizations.dart';
import '../../../shared/models/payment.dart';
import '../../../shared/theme/app_theme.dart';
import '../../../shared/utils/api_error_message.dart';
import '../../../shared/widgets/ui_bits.dart';
import '../../auth/providers/auth_provider.dart';
import '../../clubs/providers/clubs_provider.dart';
import '../providers/payments_provider.dart';

class PaymentsScreen extends ConsumerStatefulWidget {
  const PaymentsScreen({super.key});

  @override
  ConsumerState<PaymentsScreen> createState() => _PaymentsScreenState();
}

class _PaymentsScreenState extends ConsumerState<PaymentsScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDemo = ref.watch(authNotifierProvider).user?.id == 'demo';

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
        title: Text(l10n.payments),
        bottom: TabBar(
          controller: _tabs,
          labelColor: Theme.of(context).colorScheme.primary,
          unselectedLabelColor:
              Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.55),
          indicatorColor: Theme.of(context).colorScheme.primary,
          tabs: [
            Tab(text: l10n.outstanding),
            Tab(text: l10n.cash),
            Tab(text: l10n.myFees),
          ],
        ),
        actions: [
          if (!isDemo)
            IconButton(
              tooltip: l10n.recordPayment,
              onPressed: () => _openRecordPayment(context),
              icon: const Icon(Icons.add_card_outlined),
            ),
        ],
      ),
      body: isDemo
          ? Center(child: Text(l10n.signInToManagePayments))
          : TabBarView(
              controller: _tabs,
              children: const [
                _OutstandingTab(),
                _CashTab(),
                _MyFeesTab(),
              ],
            ),
    );
  }

  Future<void> _openRecordPayment(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final clubId = ref.read(selectedClubIdProvider);
    if (clubId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.selectClubFirst)),
      );
      return;
    }
    final obligations =
        ref.read(clubObligationsProvider).valueOrNull?.items ?? const [];
    final members = <_PayeeOption>[];
    final seen = <String>{};
    for (final o in obligations) {
      if (seen.add(o.memberId)) {
        members.add(
          _PayeeOption(
            memberId: o.memberId,
            name: o.memberName?.isNotEmpty == true
                ? o.memberName!
                : l10n.member,
            hintOutstanding: o.outstandingAmount,
            currency: o.currency,
          ),
        );
      }
    }

    final saved = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (context) => _RecordPaymentSheet(
        clubId: clubId,
        payees: members,
      ),
    );
    if (saved == true && mounted) {
      ref.invalidate(clubObligationsProvider);
      ref.invalidate(clubPaymentsProvider);
      ref.invalidate(myFeesProvider);
      ref.invalidate(myFeeHistoryProvider);
    }
  }
}

class _PayeeOption {
  const _PayeeOption({
    required this.memberId,
    required this.name,
    required this.hintOutstanding,
    required this.currency,
  });

  final String memberId;
  final String name;
  final double hintOutstanding;
  final String currency;
}

class _OutstandingTab extends ConsumerWidget {
  const _OutstandingTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final clubId = ref.watch(selectedClubIdProvider);
    final async = ref.watch(clubObligationsProvider);

    if (clubId == null) {
      return Center(child: Text(l10n.selectClubToViewCharges));
    }

    return async.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => _ErrorBody(
        message: apiErrorMessage(e, fallback: l10n.couldNotLoadObligations),
        onRetry: () => ref.invalidate(clubObligationsProvider),
      ),
      data: (page) {
        if (page == null) {
          return Center(child: Text(l10n.noClubSelected));
        }
        return RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(clubObligationsProvider);
            await ref.read(clubObligationsProvider.future);
          },
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            children: [
              _SummaryCard(
                title: l10n.openCharges,
                value: MoneyAmount(page.totalOutstanding, page.currency)
                    .formatted,
                subtitle: l10n.openListedSummary(page.openCount, page.totalCount),
              ),
              const SizedBox(height: 16),
              if (page.items.isEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 48),
                  child: Center(child: Text(l10n.nothingOutstanding)),
                )
              else
                ...page.items.map((o) => _ObligationTile(obligation: o)),
            ],
          ),
        );
      },
    );
  }
}

class _CashTab extends ConsumerWidget {
  const _CashTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final clubId = ref.watch(selectedClubIdProvider);
    final async = ref.watch(clubPaymentsProvider);

    if (clubId == null) {
      return Center(child: Text(l10n.selectClubToViewPayments));
    }

    return async.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => _ErrorBody(
        message: apiErrorMessage(e, fallback: l10n.couldNotLoadPayments),
        onRetry: () => ref.invalidate(clubPaymentsProvider),
      ),
      data: (page) {
        if (page == null) {
          return Center(child: Text(l10n.noClubSelected));
        }
        return RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(clubPaymentsProvider);
            await ref.read(clubPaymentsProvider.future);
          },
          child: page.items.isEmpty
              ? ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: [
                    const SizedBox(height: 120),
                    Center(child: Text(l10n.noPaymentsYet)),
                  ],
                )
              : ListView.separated(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                  itemCount: page.items.length,
                  separatorBuilder: (_, _) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    return _PaymentTile(payment: page.items[index]);
                  },
                ),
        );
      },
    );
  }
}

class _MyFeesTab extends ConsumerWidget {
  const _MyFeesTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final feesAsync = ref.watch(myFeesProvider);
    final historyAsync = ref.watch(myFeeHistoryProvider);

    return feesAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => _ErrorBody(
        message: apiErrorMessage(e, fallback: l10n.couldNotLoadFees),
        onRetry: () {
          ref.invalidate(myFeesProvider);
          ref.invalidate(myFeeHistoryProvider);
        },
      ),
      data: (fees) {
        if (fees == null) {
          return Center(child: Text(l10n.signInToSeeFees));
        }
        return RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(myFeesProvider);
            ref.invalidate(myFeeHistoryProvider);
            await Future.wait([
              ref.read(myFeesProvider.future),
              ref.read(myFeeHistoryProvider.future),
            ]);
          },
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            children: [
              _SummaryCard(
                title: l10n.youOwe,
                value: fees.mixedCurrency
                    ? l10n.mixedCurrencies
                    : MoneyAmount(fees.totalOutstanding, fees.currency)
                        .formatted,
                subtitle: fees.members.isEmpty
                    ? l10n.noFamilyMembersLinked
                    : l10n.membersCountLabel(fees.members.length),
              ),
              const SizedBox(height: 16),
              if (fees.members.isEmpty)
                Center(child: Text(l10n.noOpenFamilyFees))
              else
                ...fees.members.map((m) => _FamilyMemberCard(member: m)),
              const SizedBox(height: 20),
              Text(
                l10n.history,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              historyAsync.when(
                loading: () => const Padding(
                  padding: EdgeInsets.all(16),
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (e, _) => Text(
                  apiErrorMessage(e, fallback: l10n.couldNotLoadHistory),
                ),
                data: (history) {
                  if (history == null ||
                      (history.obligations.isEmpty &&
                          history.payments.isEmpty)) {
                    return Text(l10n.noFeeHistoryYet);
                  }
                  return Column(
                    children: [
                      ...history.payments.take(10).map(
                            (p) => _PaymentTile(payment: p, compact: true),
                          ),
                      ...history.obligations.take(10).map(
                            (o) => _ObligationTile(
                              obligation: o,
                              showMember: false,
                            ),
                          ),
                    ],
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

class _FamilyMemberCard extends StatelessWidget {
  const _FamilyMemberCard({required this.member});

  final FamilyMemberFees member;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        member.displayName,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                      Text(
                        '${member.clubName} · ${member.relationship}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                Text(
                  MoneyAmount(member.totalOutstanding, member.currency)
                      .formatted,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ],
            ),
            if (member.referenceNumber != null &&
                member.referenceNumber!.isNotEmpty) ...[
              const SizedBox(height: 10),
              _CopyRow(
                label: l10n.paymentReference,
                value: member.referenceNumber!,
              ),
            ],
            for (final o in member.openObligations) ...[
              const Divider(height: 20),
              Text(
                o.description,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 4),
              Text(
                '${MoneyAmount(o.outstandingAmount, o.currency).formatted}'
                '${o.isOverdue ? ' · ${l10n.overdue}' : ''}',
                style: TextStyle(
                  color: o.isOverdue ? AppColors.danger : null,
                ),
              ),
              if (o.paymentInstruction != null) ...[
                const SizedBox(height: 8),
                ...o.paymentInstruction!.copyBlocks.map(
                  (b) => Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: _CopyRow(label: b.label, value: b.value),
                  ),
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }
}

class _CopyRow extends StatelessWidget {
  const _CopyRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return InkWell(
      onTap: () async {
        await Clipboard.setData(ClipboardData(text: value));
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.copiedLabel(label))),
          );
        }
      },
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                  Text(
                    value,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.copy_rounded,
              size: 18,
              color: Theme.of(context)
                  .colorScheme
                  .onSurface
                  .withValues(alpha: 0.45),
            ),
          ],
        ),
      ),
    );
  }
}

class _ObligationTile extends StatelessWidget {
  const _ObligationTile({
    required this.obligation,
    this.showMember = true,
  });

  final FeeObligation obligation;
  final bool showMember;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final due = obligation.dueDate;
    final dueLabel = due == null
        ? obligation.period
        : DateFormat('d MMM yyyy').format(due);
    final overdue = obligation.isOverdue ||
        (obligation.isOpen &&
            due != null &&
            due.isBefore(DateTime.now().subtract(const Duration(days: 1))));

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 0, vertical: 4),
      leading: CircleAvatar(
        backgroundColor: overdue
            ? AppColors.danger.withValues(alpha: 0.15)
            : Theme.of(context).colorScheme.primary.withValues(alpha: 0.12),
        child: Icon(
          Icons.receipt_long_outlined,
          color: overdue
              ? AppColors.danger
              : Theme.of(context).colorScheme.primary,
          size: 20,
        ),
      ),
      title: Text(
        showMember && (obligation.memberName?.isNotEmpty ?? false)
            ? obligation.memberName!
            : obligation.description,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        [
          if (showMember && (obligation.memberName?.isNotEmpty ?? false))
            obligation.description,
          dueLabel,
          obligation.status,
          if (overdue) l10n.overdue,
        ].where((e) => e.isNotEmpty).join(' · '),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Text(
        obligation.moneyLabel,
        style: TextStyle(
          fontWeight: FontWeight.w700,
          color: overdue ? AppColors.danger : null,
        ),
      ),
    );
  }
}

class _PaymentTile extends StatelessWidget {
  const _PaymentTile({required this.payment, this.compact = false});

  final ClubPayment payment;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final when = payment.paidOn ?? payment.recordedAtUtc.toLocal();
    final method = switch (payment.method) {
      'cash' => l10n.cash,
      'bankManual' => l10n.bank,
      'bankImport' => l10n.importMethod,
      _ => payment.method,
    };
    final muted = payment.isVoid || payment.isVoided;

    return ListTile(
      contentPadding: EdgeInsets.symmetric(
        horizontal: compact ? 0 : 0,
        vertical: compact ? 2 : 4,
      ),
      leading: AvatarCircle(
        label: payment.memberName.isNotEmpty ? payment.memberName : 'P',
      ),
      title: Text(
        payment.memberName.isNotEmpty ? payment.memberName : l10n.payment,
        style: TextStyle(
          decoration: muted ? TextDecoration.lineThrough : null,
        ),
      ),
      subtitle: Text(
        [
          method,
          DateFormat('d MMM yyyy').format(when),
          if (payment.recordedByName != null &&
              payment.recordedByName!.isNotEmpty)
            payment.recordedByName!,
          if (payment.isVoided) l10n.voided,
          if (payment.isVoid) l10n.voidLabel,
        ].join(' · '),
      ),
      trailing: Text(
        payment.moneyLabel,
        style: TextStyle(
          fontWeight: FontWeight.w700,
          color: muted
              ? Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.45)
              : AppColors.present,
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.title,
    required this.value,
    required this.subtitle,
  });

  final String title;
  final String value;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppTheme.radius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: Theme.of(context).textTheme.bodySmall,
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
            const SizedBox(height: 16),
            FilledButton(onPressed: onRetry, child: Text(l10n.retry)),
          ],
        ),
      ),
    );
  }
}

class _RecordPaymentSheet extends ConsumerStatefulWidget {
  const _RecordPaymentSheet({
    required this.clubId,
    required this.payees,
  });

  final String clubId;
  final List<_PayeeOption> payees;

  @override
  ConsumerState<_RecordPaymentSheet> createState() =>
      _RecordPaymentSheetState();
}

class _RecordPaymentSheetState extends ConsumerState<_RecordPaymentSheet> {
  final _amountCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  final _memberIdCtrl = TextEditingController();
  _PayeeOption? _selected;
  String _method = 'cash';
  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    if (widget.payees.isNotEmpty) {
      _selected = widget.payees.first;
      _amountCtrl.text =
          widget.payees.first.hintOutstanding.toStringAsFixed(2);
    }
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    _notesCtrl.dispose();
    _memberIdCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context)!;
    final memberId = _selected?.memberId ?? _memberIdCtrl.text.trim();
    final amount = double.tryParse(_amountCtrl.text.trim().replaceAll(',', '.'));
    if (memberId.isEmpty) {
      setState(() => _error = l10n.pickAMember);
      return;
    }
    if (amount == null || amount <= 0) {
      setState(() => _error = l10n.enterValidAmount);
      return;
    }

    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await ref.read(paymentsApiProvider).recordPayment(
            widget.clubId,
            memberId: memberId,
            amount: amount,
            method: _method,
            currency: _selected?.currency,
            notes: _notesCtrl.text.trim().isEmpty
                ? null
                : _notesCtrl.text.trim(),
          );
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _saving = false;
        _error = apiErrorMessage(e, fallback: l10n.couldNotRecordPayment);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final bottom = MediaQuery.viewInsetsOf(context).bottom;
    return Padding(
      padding: EdgeInsets.fromLTRB(16, 12, 16, 16 + bottom),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l10n.recordPayment,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            if (widget.payees.isNotEmpty)
              DropdownButtonFormField<_PayeeOption>(
                // ignore: deprecated_member_use
                value: _selected,
                decoration: InputDecoration(labelText: l10n.member),
                items: [
                  for (final p in widget.payees)
                    DropdownMenuItem(
                      value: p,
                      child: Text(
                        '${p.name} · ${MoneyAmount(p.hintOutstanding, p.currency).formatted}',
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                ],
                onChanged: (v) {
                  setState(() {
                    _selected = v;
                    if (v != null) {
                      _amountCtrl.text = v.hintOutstanding.toStringAsFixed(2);
                    }
                  });
                },
              )
            else
              TextField(
                controller: _memberIdCtrl,
                decoration: InputDecoration(
                  labelText: l10n.memberId,
                  hintText: l10n.pasteMemberIdHint,
                ),
              ),
            const SizedBox(height: 12),
            TextField(
              controller: _amountCtrl,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(labelText: l10n.amount),
            ),
            const SizedBox(height: 12),
            SegmentedButton<String>(
              segments: [
                ButtonSegment(
                  value: 'cash',
                  label: Text(l10n.cash),
                  icon: const Icon(Icons.payments_outlined),
                ),
                ButtonSegment(
                  value: 'bankManual',
                  label: Text(l10n.bank),
                  icon: const Icon(Icons.account_balance_outlined),
                ),
              ],
              selected: {_method},
              onSelectionChanged: (s) => setState(() => _method = s.first),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _notesCtrl,
              decoration: InputDecoration(labelText: l10n.notesOptional),
              maxLines: 2,
            ),
            if (_error != null) ...[
              const SizedBox(height: 8),
              Text(_error!, style: const TextStyle(color: AppColors.danger)),
            ],
            const SizedBox(height: 16),
            FilledButton(
              onPressed: _saving ? null : _save,
              child: _saving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(l10n.savePayment),
            ),
          ],
        ),
      ),
    );
  }
}
