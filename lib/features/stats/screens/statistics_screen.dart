import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../l10n/app_localizations.dart';
import '../../../shared/l10n/date_l10n.dart';
import '../../../shared/models/analytics.dart';
import '../../../shared/models/payment.dart';
import '../../../shared/theme/app_theme.dart';
import '../../../shared/utils/api_error_message.dart';
import '../../../shared/widgets/ui_bits.dart';
import '../../auth/providers/auth_provider.dart';
import '../../clubs/providers/clubs_provider.dart';
import '../providers/stats_provider.dart';

class StatisticsScreen extends ConsumerStatefulWidget {
  const StatisticsScreen({super.key});

  @override
  ConsumerState<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends ConsumerState<StatisticsScreen>
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
          club == null ? l10n.statistics : l10n.clubStatsTitle(club.name),
        ),
        bottom: TabBar(
          controller: _tabs,
          labelColor: Theme.of(context).colorScheme.primary,
          unselectedLabelColor: Theme.of(
            context,
          ).colorScheme.onSurface.withValues(alpha: 0.55),
          indicatorColor: Theme.of(context).colorScheme.primary,
          tabs: [
            Tab(text: l10n.membership),
            Tab(text: l10n.revenue),
          ],
        ),
      ),
      body: isDemo
          ? Center(child: Text(l10n.signInToSeeStats))
          : TabBarView(
              controller: _tabs,
              children: const [_MembershipTab(), _RevenueTab()],
            ),
    );
  }
}

class _MembershipTab extends ConsumerWidget {
  const _MembershipTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final clubId = ref.watch(selectedClubIdProvider);
    final async = ref.watch(membershipAnalyticsProvider);

    if (clubId == null) {
      return Center(child: Text(l10n.selectClubToViewMembershipStats));
    }

    return async.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => _ErrorBody(
        message: apiErrorMessage(e, fallback: l10n.couldNotLoadMembershipStats),
        onRetry: () => ref.invalidate(membershipAnalyticsProvider),
      ),
      data: (data) {
        if (data == null) {
          return Center(child: Text(l10n.noMembershipData));
        }
        return RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(membershipAnalyticsProvider);
            await ref.read(membershipAnalyticsProvider.future);
          },
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
            children: [
              if (data.asOf != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    l10n.asOfDate(
                      appDateFormat(context, 'd MMM yyyy').format(data.asOf!),
                    ),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
              Row(
                children: [
                  Expanded(
                    child: StatCard(
                      label: l10n.activeNow,
                      value: '${data.activeNow}',
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: StatCard(
                      label: l10n.onTheBooks,
                      value: '${data.registeredCount}',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: StatCard(
                      label: l10n.joined12Mo,
                      value: '${data.joinedInWindow}',
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: StatCard(
                      label: l10n.left12Mo,
                      value: '${data.leftInWindow}',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              StatCard(
                label: l10n.unenrolledNoTeam,
                value: '${data.unenrolledCount}',
              ),
              const SizedBox(height: 24),
              SectionHeader(title: l10n.monthlyEnrollment),
              const SizedBox(height: 8),
              if (data.trend.isEmpty)
                Text(l10n.noTrendDataYet)
              else
                ...data.trend.reversed
                    .take(12)
                    .map(
                      (p) => _TrendRow(
                        period: p.period,
                        primary: l10n.activeCount(p.active),
                        secondary: l10n.joinedLeftDelta(p.joined, p.left),
                        barValue: p.active.toDouble(),
                        barMax: _maxActive(data.trend).toDouble(),
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
            ],
          ),
        );
      },
    );
  }

  int _maxActive(List<MembershipPeriod> trend) {
    var max = 1;
    for (final p in trend) {
      if (p.active > max) max = p.active;
    }
    return max;
  }
}

class _RevenueTab extends ConsumerWidget {
  const _RevenueTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final clubId = ref.watch(selectedClubIdProvider);
    final async = ref.watch(revenueAnalyticsProvider);

    if (clubId == null) {
      return Center(child: Text(l10n.selectClubToViewRevenueStats));
    }

    return async.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => _ErrorBody(
        message: apiErrorMessage(e, fallback: l10n.couldNotLoadRevenueStats),
        onRetry: () => ref.invalidate(revenueAnalyticsProvider),
      ),
      data: (data) {
        if (data == null) {
          return Center(child: Text(l10n.noRevenueData));
        }
        final c = data.currency;
        final t = data.totals;
        final rate = t.collectionRate;
        final rateLabel = rate == null
            ? '—'
            : '${(rate * 100).toStringAsFixed(1)}%';

        return RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(revenueAnalyticsProvider);
            await ref.read(revenueAnalyticsProvider.future);
          },
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
            children: [
              if (data.asOf != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    l10n.asOfDateCurrency(
                      appDateFormat(context, 'd MMM yyyy').format(data.asOf!),
                      c,
                    ),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
              Row(
                children: [
                  Expanded(
                    child: StatCard(
                      label: l10n.collected,
                      value: MoneyAmount(t.collected, c).formatted,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: StatCard(
                      label: l10n.outstanding,
                      value: MoneyAmount(t.outstanding, c).formatted,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: StatCard(
                      label: l10n.expected,
                      value: MoneyAmount(t.expected, c).formatted,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: StatCard(
                      label: l10n.collectionRate,
                      value: rateLabel,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: StatCard(
                      label: l10n.cash,
                      value: MoneyAmount(t.cashCollected, c).formatted,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: StatCard(
                      label: l10n.bank,
                      value: MoneyAmount(t.bankCollected, c).formatted,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: StatCard(
                      label: l10n.membersBilled,
                      value: '${t.memberCount}',
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: StatCard(
                      label: l10n.inDebt,
                      value: '${t.membersInDebt}',
                    ),
                  ),
                ],
              ),
              if (t.waived > 0) ...[
                const SizedBox(height: 10),
                StatCard(
                  label: l10n.waived,
                  value: MoneyAmount(t.waived, c).formatted,
                ),
              ],
              const SizedBox(height: 24),
              SectionHeader(title: l10n.agingOutstanding),
              const SizedBox(height: 8),
              _AgingBars(aging: data.aging, currency: c),
              const SizedBox(height: 24),
              SectionHeader(title: l10n.monthlyTrend),
              const SizedBox(height: 8),
              if (data.trend.isEmpty)
                Text(l10n.noRevenueTrendYet)
              else
                ...data.trend.reversed.take(12).map((p) {
                  final max = _maxCollected(data.trend);
                  return _TrendRow(
                    period: p.period,
                    primary: MoneyAmount(p.collected, c).formatted,
                    secondary: l10n.owedAmount(
                      MoneyAmount(p.outstanding, c).formatted,
                    ),
                    barValue: p.collected,
                    barMax: max <= 0 ? 1 : max,
                    color: AppColors.present,
                  );
                }),
              if (data.teams.isNotEmpty) ...[
                const SizedBox(height: 24),
                SectionHeader(title: l10n.byTeam),
                const SizedBox(height: 8),
                ...data.teams.map(
                  (b) => ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(b.name),
                    subtitle: Text(
                      l10n.membersOwed(
                        b.memberCount,
                        MoneyAmount(b.outstanding, c).formatted,
                      ),
                    ),
                    trailing: Text(
                      MoneyAmount(b.collected, c).formatted,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              ],
              if (data.sections.isNotEmpty) ...[
                const SizedBox(height: 24),
                SectionHeader(title: l10n.bySection),
                const SizedBox(height: 8),
                ...data.sections.map(
                  (b) => ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(b.name),
                    subtitle: Text(
                      l10n.membersOwed(
                        b.memberCount,
                        MoneyAmount(b.outstanding, c).formatted,
                      ),
                    ),
                    trailing: Text(
                      MoneyAmount(b.collected, c).formatted,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  double _maxCollected(List<RevenuePeriod> trend) {
    var max = 0.0;
    for (final p in trend) {
      if (p.collected > max) max = p.collected;
    }
    return max;
  }
}

class _AgingBars extends StatelessWidget {
  const _AgingBars({required this.aging, required this.currency});

  final RevenueAging aging;
  final String currency;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final max = aging.total <= 0 ? 1.0 : aging.total;
    final rows = [
      (l10n.notDue, aging.current, Theme.of(context).colorScheme.primary),
      (l10n.days1To30, aging.days1To30, AppColors.late),
      (l10n.days31To60, aging.days31To60, AppColors.late),
      (l10n.days61To90, aging.days61To90, AppColors.danger),
      (l10n.days90Plus, aging.days90Plus, AppColors.danger),
    ];
    return Column(
      children: [
        for (final row in rows)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _TrendRow(
              period: row.$1,
              primary: MoneyAmount(row.$2, currency).formatted,
              secondary: '',
              barValue: row.$2,
              barMax: max,
              color: row.$3,
            ),
          ),
      ],
    );
  }
}

class _TrendRow extends StatelessWidget {
  const _TrendRow({
    required this.period,
    required this.primary,
    required this.secondary,
    required this.barValue,
    required this.barMax,
    required this.color,
  });

  final String period;
  final String primary;
  final String secondary;
  final double barValue;
  final double barMax;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final ratio = barMax <= 0 ? 0.0 : (barValue / barMax).clamp(0.0, 1.0);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  period,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
              Text(
                primary,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ],
          ),
          if (secondary.isNotEmpty) ...[
            const SizedBox(height: 2),
            Text(secondary, style: Theme.of(context).textTheme.bodySmall),
          ],
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: ratio,
              minHeight: 8,
              color: color,
              backgroundColor: color.withValues(alpha: 0.15),
            ),
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
