import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../l10n/app_localizations.dart';
import '../../../shared/models/performance.dart';
import '../../../shared/utils/api_error_message.dart';
import '../../clubs/providers/clubs_provider.dart';
import '../../events/providers/performance_provider.dart';

class TestSetPicker extends ConsumerWidget {
  const TestSetPicker({
    super.key,
    required this.selectedId,
    required this.onChanged,
  });

  final String? selectedId;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final async = ref.watch(metricBatteriesProvider(null));
    return async.when(
      loading: () => const Padding(
        padding: EdgeInsets.symmetric(vertical: 8),
        child: LinearProgressIndicator(),
      ),
      error: (e, _) =>
          Text(apiErrorMessage(e, fallback: l10n.couldNotLoadTestSets)),
      data: (sets) {
        final current = sets.any((s) => s.id == selectedId) ? selectedId : null;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (sets.isEmpty)
              Text(
                l10n.noTestSetsYet,
                style: Theme.of(context).textTheme.bodySmall,
              )
            else
              DropdownButtonFormField<String>(
                // ignore: deprecated_member_use
                value: current,
                decoration: InputDecoration(labelText: l10n.pickTestSet),
                items: [
                  for (final set in sets)
                    DropdownMenuItem(
                      value: set.id,
                      child: Text(
                        '${set.name} (${l10n.stationCount(set.metrics.length)})',
                      ),
                    ),
                ],
                onChanged: onChanged,
              ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: () => _openCreate(context, ref),
              icon: const Icon(Icons.add_rounded),
              label: Text(l10n.createTestSet),
            ),
          ],
        );
      },
    );
  }

  Future<void> _openCreate(BuildContext context, WidgetRef ref) async {
    final created = await showModalBottomSheet<MetricBattery>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) => const _CreateTestSetSheet(),
    );
    if (created == null) return;
    ref.invalidate(metricBatteriesProvider(null));
    onChanged(created.id);
  }
}

class _CreateTestSetSheet extends ConsumerStatefulWidget {
  const _CreateTestSetSheet();

  @override
  ConsumerState<_CreateTestSetSheet> createState() =>
      _CreateTestSetSheetState();
}

class _CreateTestSetSheetState extends ConsumerState<_CreateTestSetSheet> {
  final _nameCtrl = TextEditingController();
  String? _sportCode;
  final _selected = <String>{};
  bool _saving = false;
  String? _error;

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context)!;
    final clubId = ref.read(selectedClubIdProvider);
    final name = _nameCtrl.text.trim();
    final sport = _sportCode;
    if (clubId == null) {
      setState(() => _error = l10n.selectClubFirst);
      return;
    }
    if (name.isEmpty) {
      setState(() => _error = l10n.testSetNameRequired);
      return;
    }
    if (sport == null || sport.isEmpty) {
      setState(() => _error = l10n.pickASport);
      return;
    }
    if (_selected.isEmpty) {
      setState(() => _error = l10n.pickAtLeastOneMetric);
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      final created = await ref
          .read(performanceApiProvider)
          .createBattery(
            clubId: clubId,
            sportCode: sport,
            name: name,
            metricCodes: _selected.toList(),
          );
      if (!mounted) return;
      Navigator.of(context).pop(created);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _saving = false;
        _error = apiErrorMessage(e, fallback: l10n.couldNotCreateTestSet);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final sportsAsync = ref.watch(performanceSportsProvider);
    final sports = sportsAsync.valueOrNull ?? const <String>[];
    if (_sportCode == null && sports.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted || _sportCode != null) return;
        setState(() => _sportCode = sports.first);
      });
    }
    final sport = _sportCode;
    final catalogueAsync = sport == null
        ? null
        : ref.watch(metricCatalogueProvider(sport));
    final bottom = MediaQuery.viewInsetsOf(context).bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(16, 0, 16, 16 + bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            l10n.createTestSet,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _nameCtrl,
            textCapitalization: TextCapitalization.sentences,
            decoration: InputDecoration(labelText: l10n.testSetName),
          ),
          const SizedBox(height: 12),
          sportsAsync.when(
            loading: () => const LinearProgressIndicator(),
            error: (e, _) =>
                Text(apiErrorMessage(e, fallback: l10n.couldNotLoadTestSets)),
            data: (list) {
              if (list.isEmpty) {
                return Text(l10n.noSportsForTestSets);
              }
              return DropdownButtonFormField<String>(
                // ignore: deprecated_member_use
                value: list.contains(_sportCode) ? _sportCode : list.first,
                decoration: InputDecoration(labelText: l10n.sport),
                items: [
                  for (final code in list)
                    DropdownMenuItem(value: code, child: Text(code)),
                ],
                onChanged: (v) {
                  setState(() {
                    _sportCode = v;
                    _selected.clear();
                  });
                },
              );
            },
          ),
          const SizedBox(height: 12),
          Text(l10n.pickMetrics, style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 8),
          SizedBox(
            height: 280,
            child: catalogueAsync == null
                ? Center(child: Text(l10n.pickASport))
                : catalogueAsync.when(
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (e, _) => Center(
                      child: Text(
                        apiErrorMessage(e, fallback: l10n.couldNotLoadTestSets),
                      ),
                    ),
                    data: (catalogue) {
                      final metrics = catalogue.metrics
                          .where((m) => m.canCollect)
                          .toList();
                      if (metrics.isEmpty) {
                        return Center(child: Text(l10n.noMetricsForSport));
                      }
                      return ListView.builder(
                        itemCount: metrics.length,
                        itemBuilder: (context, i) {
                          final metric = metrics[i];
                          final checked = _selected.contains(metric.code);
                          final unit = metric.unit;
                          return CheckboxListTile(
                            dense: true,
                            value: checked,
                            onChanged: (v) {
                              setState(() {
                                if (v == true) {
                                  _selected.add(metric.code);
                                } else {
                                  _selected.remove(metric.code);
                                }
                              });
                            },
                            title: Text(metric.name),
                            subtitle: Text(
                              [
                                metric.categoryName,
                                if (unit != null && unit.isNotEmpty) unit,
                              ].join(' · '),
                            ),
                          );
                        },
                      );
                    },
                  ),
          ),
          if (_error != null) ...[
            const SizedBox(height: 8),
            Text(
              _error!,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ],
          const SizedBox(height: 12),
          FilledButton(
            onPressed: _saving ? null : _save,
            child: _saving
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(l10n.create),
          ),
        ],
      ),
    );
  }
}
