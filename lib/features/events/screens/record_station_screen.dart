import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../l10n/app_localizations.dart';
import '../../../shared/models/event_attendance.dart';
import '../../../shared/models/performance.dart';
import '../../../shared/utils/api_error_message.dart';
import '../../clubs/providers/clubs_provider.dart';
import '../providers/events_provider.dart';
import '../providers/performance_provider.dart';

class RecordStationScreen extends ConsumerStatefulWidget {
  const RecordStationScreen({
    super.key,
    required this.occurrenceId,
    required this.metricCode,
  });

  final String occurrenceId;
  final String metricCode;

  @override
  ConsumerState<RecordStationScreen> createState() =>
      _RecordStationScreenState();
}

class _RecordStationScreenState extends ConsumerState<RecordStationScreen> {
  final _rows = <String, _PlayerDraft>{};
  String? _boundTo;
  bool _saving = false;
  String? _error;
  Map<String, String> _rowErrors = {};

  @override
  void dispose() {
    for (final row in _rows.values) {
      row.dispose();
    }
    super.dispose();
  }

  void _ensureRows(TestingDay day, TestingDayStation station) {
    final key = '${day.occurrenceId}:${station.code}';
    if (_boundTo != key) {
      for (final row in _rows.values) {
        row.dispose();
      }
      _rows.clear();
      _boundTo = key;
    }
    for (final player in day.players) {
      _rows.putIfAbsent(
        player.memberId,
        () => _PlayerDraft.fromValue(
          player: player,
          existing: player.values[station.code],
          valueKind: station.valueKind,
        ),
      );
    }
  }

  Future<void> _save({
    required TestingDay day,
    required TestingDayStation station,
    ClubEvent? occurrence,
  }) async {
    final l10n = AppLocalizations.of(context)!;
    final clubId = ref.read(selectedClubIdProvider);
    final teamId =
        day.teamId ??
        (occurrence?.scopeKind == 'team' ? occurrence?.scopeId : null);
    if (clubId == null || clubId.isEmpty) {
      setState(() => _error = l10n.selectClubFirst);
      return;
    }
    if (teamId == null || teamId.isEmpty) {
      setState(() => _error = l10n.teamRequiredForRecording);
      return;
    }

    final entries = <ColumnEntry>[];
    for (final row in _rows.values) {
      final entry = row.toEntry(station);
      if (entry != null) entries.add(entry);
    }
    if (entries.isEmpty) {
      setState(() => _error = l10n.noValuesToSave);
      return;
    }

    setState(() {
      _saving = true;
      _error = null;
      _rowErrors = {};
    });

    try {
      final when =
          (day.date ?? occurrence?.startAt.toLocal()) ?? DateTime.now();
      String two(int n) => n.toString().padLeft(2, '0');
      final assessedOn = '${when.year}-${two(when.month)}-${two(when.day)}';
      final result = await ref
          .read(performanceApiProvider)
          .recordColumn(
            clubId: clubId,
            teamId: teamId,
            metricCode: station.code,
            assessedOn: assessedOn,
            occurrenceId: widget.occurrenceId,
            entries: entries,
          );
      ref.invalidate(testingDayProvider(widget.occurrenceId));
      if (!mounted) return;
      final failed = result.failed;
      setState(() {
        _saving = false;
        _rowErrors = {
          for (final f in failed)
            if ((f.error ?? '').isNotEmpty) f.memberId: f.error!,
        };
      });
      if (failed.isEmpty) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.resultsSaved)));
      } else {
        setState(() {
          _error = l10n.someResultsFailed(
            failed.length,
            result.outcomes.length,
          );
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _saving = false;
        _error = apiErrorMessage(e, fallback: l10n.couldNotRecordResults);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final dayAsync = ref.watch(testingDayProvider(widget.occurrenceId));
    final occurrenceAsync = ref.watch(eventDetailProvider(widget.occurrenceId));

    return Scaffold(
      appBar: AppBar(title: Text(l10n.recordStation)),
      body: dayAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              apiErrorMessage(e, fallback: l10n.couldNotLoadTestingDay),
              textAlign: TextAlign.center,
            ),
          ),
        ),
        data: (day) {
          TestingDayStation? station;
          for (final s in day.stations) {
            if (s.code == widget.metricCode) {
              station = s;
              break;
            }
          }
          if (station == null) {
            return Center(child: Text(l10n.couldNotLoadTestingDay));
          }
          final current = station;
          _ensureRows(day, current);
          final occurrence = occurrenceAsync.valueOrNull;
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        current.name,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      if ((current.unit ?? '').isNotEmpty)
                        Text(
                          current.unit!,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                    ],
                  ),
                ),
              ),
              if (!current.canRecord)
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(l10n.stationRetiredCannotRecord),
                )
              else if (day.players.isEmpty)
                Expanded(child: Center(child: Text(l10n.noPlayersOnTestingDay)))
              else
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                    itemCount: day.players.length,
                    separatorBuilder: (_, _) => const Divider(height: 1),
                    itemBuilder: (context, i) {
                      final player = day.players[i];
                      final row = _rows[player.memberId];
                      if (row == null) return const SizedBox.shrink();
                      return _PlayerValueTile(
                        player: player,
                        station: current,
                        draft: row,
                        error: _rowErrors[player.memberId],
                      );
                    },
                  ),
                ),
              if (_error != null)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                  child: Text(
                    _error!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ),
              if (current.canRecord && day.players.isNotEmpty)
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                    child: SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: _saving
                            ? null
                            : () => _save(
                                day: day,
                                station: current,
                                occurrence: occurrence,
                              ),
                        child: _saving
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(l10n.saveResults),
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _PlayerDraft {
  _PlayerDraft({
    required this.memberId,
    required this.number,
    required this.made,
    required this.attempted,
    required this.text,
    this.optionCode,
  });

  factory _PlayerDraft.fromValue({
    required TestingDayPlayer player,
    required RecordedValue? existing,
    required String valueKind,
  }) {
    return _PlayerDraft(
      memberId: player.memberId,
      number: TextEditingController(
        text: existing == null || valueKind == 'ratio' || valueKind == 'choice'
            ? ''
            : existing.display(valueKind: valueKind),
      ),
      made: TextEditingController(text: existing?.made?.toString() ?? ''),
      attempted: TextEditingController(
        text: existing?.attempted?.toString() ?? '',
      ),
      text: TextEditingController(text: existing?.textValue ?? ''),
      optionCode: existing?.optionCode,
    );
  }

  final String memberId;
  final TextEditingController number;
  final TextEditingController made;
  final TextEditingController attempted;
  final TextEditingController text;
  String? optionCode;

  void dispose() {
    number.dispose();
    made.dispose();
    attempted.dispose();
    text.dispose();
  }

  ColumnEntry? toEntry(TestingDayStation station) {
    switch (station.valueKind) {
      case 'ratio':
        final madeVal = int.tryParse(made.text.trim());
        final attemptedVal = int.tryParse(attempted.text.trim());
        if (madeVal == null || attemptedVal == null) return null;
        return ColumnEntry(
          memberId: memberId,
          made: madeVal,
          attempted: attemptedVal,
        );
      case 'choice':
        final code = optionCode?.trim();
        if (code == null || code.isEmpty) return null;
        return ColumnEntry(memberId: memberId, optionCode: code);
      case 'text':
        final value = text.text.trim();
        if (value.isEmpty) return null;
        return ColumnEntry(memberId: memberId, text: value);
      default:
        final parsed = double.tryParse(number.text.trim().replaceAll(',', '.'));
        if (parsed == null) return null;
        return ColumnEntry(memberId: memberId, number: parsed);
    }
  }
}

class _PlayerValueTile extends StatelessWidget {
  const _PlayerValueTile({
    required this.player,
    required this.station,
    required this.draft,
    this.error,
  });

  final TestingDayPlayer player;
  final TestingDayStation station;
  final _PlayerDraft draft;
  final String? error;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            player.displayName,
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 6),
          _ValueField(station: station, draft: draft),
          if (error != null) ...[
            const SizedBox(height: 4),
            Text(
              error!,
              style: TextStyle(
                color: Theme.of(context).colorScheme.error,
                fontSize: 12,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ValueField extends StatelessWidget {
  const _ValueField({required this.station, required this.draft});

  final TestingDayStation station;
  final _PlayerDraft draft;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final decimal = station.decimalPlaces > 0;
    switch (station.valueKind) {
      case 'ratio':
        return Row(
          children: [
            Expanded(
              child: TextField(
                controller: draft.made,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: InputDecoration(labelText: l10n.madeLabel),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                controller: draft.attempted,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: InputDecoration(labelText: l10n.attemptedLabel),
              ),
            ),
          ],
        );
      case 'choice':
        return DropdownButtonFormField<String>(
          // ignore: deprecated_member_use
          value: station.options.any((o) => o.code == draft.optionCode)
              ? draft.optionCode
              : null,
          decoration: InputDecoration(labelText: station.name),
          items: [
            for (final option in station.options)
              DropdownMenuItem(value: option.code, child: Text(option.name)),
          ],
          onChanged: (v) => draft.optionCode = v,
        );
      case 'text':
        return TextField(
          controller: draft.text,
          textCapitalization: TextCapitalization.sentences,
          decoration: InputDecoration(labelText: station.name),
        );
      default:
        return TextField(
          controller: draft.number,
          keyboardType: TextInputType.numberWithOptions(decimal: decimal),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[0-9.,\-]')),
          ],
          decoration: InputDecoration(
            labelText: station.unit == null || station.unit!.isEmpty
                ? station.name
                : '${station.name} (${station.unit})',
          ),
        );
    }
  }
}
