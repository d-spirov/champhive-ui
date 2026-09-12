import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../l10n/app_localizations.dart';
import '../../../shared/l10n/date_l10n.dart';
import '../../../shared/models/event_series.dart';
import '../../../shared/models/team.dart';
import '../../../shared/utils/api_error_message.dart';
import '../../auth/providers/auth_provider.dart';
import '../../clubs/providers/clubs_provider.dart';
import '../../events/providers/events_provider.dart';
import '../../events/providers/training_plans_provider.dart';
import '../../teams/providers/teams_provider.dart';
import '../schedule_timing.dart';
import '../widgets/test_set_picker.dart';

class CreateScheduleScreen extends ConsumerStatefulWidget {
  const CreateScheduleScreen({super.key, this.initialDate, this.initialTeamId});

  final DateTime? initialDate;
  final String? initialTeamId;

  @override
  ConsumerState<CreateScheduleScreen> createState() =>
      _CreateScheduleScreenState();
}

class _CreateScheduleScreenState extends ConsumerState<CreateScheduleScreen> {
  final _titleCtrl = TextEditingController();
  final _purposeCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();

  String _type = 'training';
  String _scopeKind = 'team';
  String? _teamId;
  late DateTime _date;
  TimeOfDay _time = const TimeOfDay(hour: 18, minute: 0);
  int _durationMin = 90;
  String _recurrence = 'once'; // once | weekly | daily
  int _repeatCount = 8;
  bool _rsvpRequested = false;
  String? _trainingPlanId;
  String? _metricBatteryId;
  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    final seed = widget.initialDate ?? DateTime.now();
    _teamId = widget.initialTeamId;
    final now = TimeOfDay.now();
    final defaultTime = widget.initialDate == null
        ? TimeOfDay(hour: (now.hour + 1).clamp(0, 23), minute: 0)
        : _time;
    final snapped = snapEventStartToNow(date: seed, time: defaultTime);
    _date = snapped.date;
    _time = snapped.time;
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _purposeCtrl.dispose();
    _locationCtrl.dispose();
    super.dispose();
  }

  String? _buildRrule() {
    switch (_recurrence) {
      case 'weekly':
        return 'FREQ=WEEKLY;BYDAY=${weekdayToRrule(_date.weekday)};COUNT=$_repeatCount';
      case 'daily':
        return 'FREQ=DAILY;COUNT=$_repeatCount';
      default:
        return null;
    }
  }

  Future<void> _pickDate() async {
    final today = dateOnly(DateTime.now());
    final initial = _date.isBefore(today) ? today : _date;
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: today,
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
    );
    if (picked == null) return;
    if (isPastCalendarDay(picked)) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.cannotCreateEventInPast),
        ),
      );
      return;
    }
    setState(() {
      _date = dateOnly(picked);
      final snapped = snapEventStartToNow(date: _date, time: _time);
      _date = snapped.date;
      _time = snapped.time;
    });
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(context: context, initialTime: _time);
    if (picked == null) return;
    final start = eventStartAt(_date, picked);
    if (isPastEventStart(start)) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.cannotCreateEventInPast),
        ),
      );
      return;
    }
    setState(() => _time = picked);
  }

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context)!;
    final clubId = ref.read(selectedClubIdProvider);
    if (clubId == null) {
      setState(() => _error = l10n.selectClubFirst);
      return;
    }
    final title = _titleCtrl.text.trim();
    if (title.isEmpty) {
      setState(() => _error = l10n.titleRequired);
      return;
    }
    if (_type == 'testing' &&
        (_metricBatteryId == null || _metricBatteryId!.isEmpty)) {
      setState(() => _error = l10n.testSetRequired);
      return;
    }

    final user = ref.read(authNotifierProvider).user;
    final canScopeClub = user?.hasClubWideStaffGrant(clubId) ?? false;
    final scopeKind = canScopeClub ? _scopeKind : 'team';
    if (scopeKind == 'team' && (_teamId == null || _teamId!.isEmpty)) {
      setState(() => _error = l10n.pickATeam);
      return;
    }

    final club = ref.read(selectedClubProvider);
    final localStart = DateTime(
      _date.year,
      _date.month,
      _date.day,
      _time.hour,
      _time.minute,
    );
    if (isPastEventStart(localStart) || isPastCalendarDay(_date)) {
      setState(() => _error = l10n.cannotCreateEventInPast);
      return;
    }

    setState(() {
      _saving = true;
      _error = null;
    });

    try {
      final series = await ref
          .read(eventsApiProvider)
          .createSeries(
            clubId: clubId,
            request: SaveEventSeriesRequest(
              scopeKind: scopeKind,
              scopeId: scopeKind == 'club' ? null : _teamId,
              type: _type,
              title: title,
              purpose: _purposeCtrl.text.trim().isEmpty
                  ? null
                  : _purposeCtrl.text.trim(),
              location: _locationCtrl.text.trim().isEmpty
                  ? null
                  : _locationCtrl.text.trim(),
              timeZone: club?.timeZone ?? 'Europe/Skopje',
              firstStartLocal: formatFirstStartLocal(localStart),
              durationMin: _durationMin,
              rrule: _buildRrule(),
              rsvpRequested: _rsvpRequested,
              visibility: 'scope',
              trainingPlanId: _type == 'testing' ? null : _trainingPlanId,
              metricBatteryId: _type == 'testing' ? _metricBatteryId : null,
            ),
          );
      ref.invalidate(clubEventsProvider);
      ref.invalidate(teamScheduleProvider);
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.createdNamed(series.title))));
      if (context.canPop()) {
        context.pop(true);
      } else {
        context.go('/calendar');
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _saving = false;
        _error = apiErrorMessage(e, fallback: l10n.couldNotCreateSchedule);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final user = ref.watch(authNotifierProvider).user;
    final isDemo = user?.id == 'demo';
    final clubId = ref.watch(selectedClubIdProvider);
    final teamsAsync = ref.watch(clubTeamsProvider);
    final teams = teamsAsync.valueOrNull ?? const <ClubTeam>[];
    final canScopeClub =
        clubId != null && (user?.hasClubWideStaffGrant(clubId) ?? false);
    final scopeKind = canScopeClub ? _scopeKind : 'team';

    if (_teamId == null && teams.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted || _teamId != null) return;
        setState(() => _teamId = teams.first.id);
      });
    }

    if (widget.initialTeamId != null &&
        _locationCtrl.text.isEmpty &&
        teams.isNotEmpty) {
      for (final t in teams) {
        final location = t.trainingLocation?.trim();
        if (t.id == widget.initialTeamId &&
            location != null &&
            location.isNotEmpty) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted || _locationCtrl.text.isNotEmpty) return;
            _locationCtrl.text = location;
          });
          break;
        }
      }
    }

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/calendar');
            }
          },
        ),
        title: Text(l10n.newSchedule),
      ),
      body: isDemo
          ? Center(child: Text(l10n.signInToCreateSchedule))
          : clubId == null
          ? Center(child: Text(l10n.selectClubFirst))
          : ListView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
              children: [
                Text(l10n.type, style: Theme.of(context).textTheme.titleSmall),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final t in [
                      ('training', l10n.eventTypeTraining),
                      ('testing', l10n.eventTypeTesting),
                      ('match', l10n.eventTypeMatch),
                      ('clubEvent', l10n.eventTypeClubEvent),
                      ('tournament', l10n.eventTypeTournament),
                    ])
                      ChoiceChip(
                        label: Text(t.$2),
                        selected: _type == t.$1,
                        onSelected: (_) => setState(() {
                          _type = t.$1;
                          if (_type == 'testing') {
                            _trainingPlanId = null;
                          } else {
                            _metricBatteryId = null;
                          }
                        }),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _titleCtrl,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: InputDecoration(
                    labelText: l10n.title,
                    hintText: _type == 'testing'
                        ? l10n.titleHintTesting
                        : l10n.titleHintTraining,
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _purposeCtrl,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: InputDecoration(labelText: l10n.purposeOptional),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _locationCtrl,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: InputDecoration(labelText: l10n.locationOptional),
                ),
                const SizedBox(height: 20),
                Text(l10n.scope, style: Theme.of(context).textTheme.titleSmall),
                const SizedBox(height: 8),
                if (canScopeClub)
                  SegmentedButton<String>(
                    segments: [
                      ButtonSegment(value: 'team', label: Text(l10n.team)),
                      ButtonSegment(value: 'club', label: Text(l10n.wholeClub)),
                    ],
                    selected: {scopeKind},
                    onSelectionChanged: (s) =>
                        setState(() => _scopeKind = s.first),
                  ),
                if (scopeKind == 'team') ...[
                  if (canScopeClub) const SizedBox(height: 12),
                  teamsAsync.when(
                    loading: () => const LinearProgressIndicator(),
                    error: (e, _) => Text(
                      apiErrorMessage(e, fallback: l10n.couldNotLoadTeams),
                    ),
                    data: (list) {
                      if (list.isEmpty) {
                        return Text(l10n.noTeamsCreateOrClub);
                      }
                      return DropdownButtonFormField<String>(
                        // ignore: deprecated_member_use
                        value: list.any((t) => t.id == _teamId)
                            ? _teamId
                            : list.first.id,
                        decoration: InputDecoration(labelText: l10n.team),
                        items: [
                          for (final t in list)
                            DropdownMenuItem(value: t.id, child: Text(t.name)),
                        ],
                        onChanged: (v) => setState(() => _teamId = v),
                      );
                    },
                  ),
                ],
                const SizedBox(height: 20),
                Text(l10n.when, style: Theme.of(context).textTheme.titleSmall),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _pickDate,
                        icon: const Icon(Icons.calendar_today_outlined),
                        label: Text(
                          appDateFormat(
                            context,
                            'EEE d MMM yyyy',
                          ).format(_date),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _pickTime,
                        icon: const Icon(Icons.schedule_outlined),
                        label: Text(_time.format(context)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<int>(
                  // ignore: deprecated_member_use
                  value: _durationMin,
                  decoration: InputDecoration(labelText: l10n.duration),
                  items: [
                    DropdownMenuItem(value: 45, child: Text(l10n.duration45)),
                    DropdownMenuItem(value: 60, child: Text(l10n.duration60)),
                    DropdownMenuItem(value: 75, child: Text(l10n.duration75)),
                    DropdownMenuItem(value: 90, child: Text(l10n.duration90)),
                    DropdownMenuItem(value: 120, child: Text(l10n.duration2h)),
                    DropdownMenuItem(value: 180, child: Text(l10n.duration3h)),
                  ],
                  onChanged: (v) {
                    if (v != null) setState(() => _durationMin = v);
                  },
                ),
                const SizedBox(height: 20),
                Text(
                  l10n.repeat,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: [
                    for (final r in [
                      ('once', l10n.oneOff),
                      ('weekly', l10n.weekly),
                      ('daily', l10n.daily),
                    ])
                      ChoiceChip(
                        label: Text(r.$2),
                        selected: _recurrence == r.$1,
                        onSelected: (_) => setState(() => _recurrence = r.$1),
                      ),
                  ],
                ),
                if (_recurrence != 'once') ...[
                  const SizedBox(height: 12),
                  DropdownButtonFormField<int>(
                    // ignore: deprecated_member_use
                    value: _repeatCount,
                    decoration: InputDecoration(
                      labelText: l10n.numberOfOccurrences,
                    ),
                    items: const [
                      DropdownMenuItem(value: 4, child: Text('4')),
                      DropdownMenuItem(value: 8, child: Text('8')),
                      DropdownMenuItem(value: 12, child: Text('12')),
                      DropdownMenuItem(value: 16, child: Text('16')),
                      DropdownMenuItem(value: 24, child: Text('24')),
                    ],
                    onChanged: (v) {
                      if (v != null) setState(() => _repeatCount = v);
                    },
                  ),
                ],
                const SizedBox(height: 12),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(l10n.requestRsvp),
                  subtitle: Text(l10n.requestRsvpSubtitle),
                  value: _rsvpRequested,
                  onChanged: (v) => setState(() => _rsvpRequested = v),
                ),
                const SizedBox(height: 8),
                if (_type == 'testing')
                  TestSetPicker(
                    selectedId: _metricBatteryId,
                    onChanged: (id) => setState(() => _metricBatteryId = id),
                  )
                else
                  _TrainingPlanPicker(
                    teamId: scopeKind == 'team' ? _teamId : null,
                    selectedId: _trainingPlanId,
                    onChanged: (id) => setState(() => _trainingPlanId = id),
                  ),
                if (_error != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    _error!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ],
                const SizedBox(height: 20),
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

class _TrainingPlanPicker extends ConsumerWidget {
  const _TrainingPlanPicker({
    required this.teamId,
    required this.selectedId,
    required this.onChanged,
  });

  final String? teamId;
  final String? selectedId;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final async = ref.watch(trainingPlansProvider(teamId));
    return async.when(
      loading: () => const Padding(
        padding: EdgeInsets.symmetric(vertical: 8),
        child: LinearProgressIndicator(),
      ),
      error: (e, _) =>
          Text(apiErrorMessage(e, fallback: l10n.couldNotLoadTrainingPlan)),
      data: (plans) {
        if (plans.isEmpty) {
          return Text(
            l10n.noTrainingPlansYet,
            style: Theme.of(context).textTheme.bodySmall,
          );
        }
        final current = plans.any((p) => p.id == selectedId)
            ? selectedId ?? ''
            : '';
        return DropdownButtonFormField<String>(
          // ignore: deprecated_member_use
          value: current,
          decoration: InputDecoration(labelText: l10n.pickTrainingPlan),
          items: [
            DropdownMenuItem(value: '', child: Text(l10n.noTrainingPlan)),
            for (final plan in plans)
              DropdownMenuItem(value: plan.id, child: Text(plan.name)),
          ],
          onChanged: (v) => onChanged(v == null || v.isEmpty ? null : v),
        );
      },
    );
  }
}
