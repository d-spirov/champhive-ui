import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../l10n/app_localizations.dart';
import '../../../shared/l10n/date_l10n.dart';
import '../../../shared/utils/api_error_message.dart';
import '../../events/providers/performance_provider.dart';

class PlayerPerformanceTab extends ConsumerWidget {
  const PlayerPerformanceTab({super.key, required this.memberId});

  final String memberId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final sportsAsync = ref.watch(performanceSportsProvider);
    return sportsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            apiErrorMessage(e, fallback: l10n.couldNotLoadPerformance),
            textAlign: TextAlign.center,
          ),
        ),
      ),
      data: (sports) {
        if (sports.isEmpty) {
          return Center(child: Text(l10n.noPerformanceYet));
        }
        return _SportHistory(memberId: memberId, sports: sports);
      },
    );
  }
}

class _SportHistory extends ConsumerStatefulWidget {
  const _SportHistory({required this.memberId, required this.sports});

  final String memberId;
  final List<String> sports;

  @override
  ConsumerState<_SportHistory> createState() => _SportHistoryState();
}

class _SportHistoryState extends ConsumerState<_SportHistory> {
  late String _sport = widget.sports.first;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final async = ref.watch(
      memberPerformanceProvider((memberId: widget.memberId, sportCode: _sport)),
    );
    return Column(
      children: [
        if (widget.sports.length > 1)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: DropdownButtonFormField<String>(
              // ignore: deprecated_member_use
              value: _sport,
              decoration: InputDecoration(labelText: l10n.sport),
              items: [
                for (final code in widget.sports)
                  DropdownMenuItem(value: code, child: Text(code)),
              ],
              onChanged: (v) {
                if (v != null) setState(() => _sport = v);
              },
            ),
          ),
        Expanded(
          child: async.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      apiErrorMessage(
                        e,
                        fallback: l10n.couldNotLoadPerformance,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    FilledButton(
                      onPressed: () => ref.invalidate(
                        memberPerformanceProvider((
                          memberId: widget.memberId,
                          sportCode: _sport,
                        )),
                      ),
                      child: Text(l10n.retry),
                    ),
                  ],
                ),
              ),
            ),
            data: (history) {
              final measured = history.measured;
              if (measured.isEmpty) {
                return Center(child: Text(l10n.noPerformanceYet));
              }
              return ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                itemCount: measured.length,
                separatorBuilder: (_, _) => const Divider(height: 1),
                itemBuilder: (context, i) {
                  final metric = measured[i];
                  final latest = metric.latest!;
                  final prev = metric.previous;
                  final unit = metric.unit;
                  final value = latest.display(
                    valueKind: metric.valueKind,
                    decimalPlaces: metric.decimalPlaces,
                  );
                  final date = latest.on == null
                      ? null
                      : appYMMMd(context).format(latest.on!);
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(metric.name),
                    subtitle: Text(
                      [
                        metric.categoryName,
                        ?date,
                        if (prev != null)
                          l10n.previousResult(
                            prev.display(
                              valueKind: metric.valueKind,
                              decimalPlaces: metric.decimalPlaces,
                            ),
                          ),
                      ].where((s) => s.isNotEmpty).join(' · '),
                    ),
                    trailing: Text(
                      [
                        value,
                        if (unit != null && unit.isNotEmpty) unit,
                      ].join(' '),
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
