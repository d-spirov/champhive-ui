import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../shared/models/event_series.dart';
import '../../../shared/models/team.dart';
import '../../../shared/utils/api_error_message.dart';
import '../../auth/providers/auth_provider.dart';
import '../../clubs/providers/clubs_provider.dart';
import '../../events/providers/events_provider.dart';
import '../../teams/providers/teams_provider.dart';

class CreateScheduleScreen extends ConsumerStatefulWidget {
  const CreateScheduleScreen({super.key, this.initialDate});

  final DateTime? initialDate;

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
  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    final seed = widget.initialDate ?? DateTime.now();
    _date = DateTime(seed.year, seed.month, seed.day);
    final now = TimeOfDay.now();
    if (widget.initialDate == null) {
      _time = TimeOfDay(hour: (now.hour + 1).clamp(0, 23), minute: 0);
    }
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
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime.now().subtract(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(context: context, initialTime: _time);
    if (picked != null) setState(() => _time = picked);
  }

  Future<void> _save() async {
    final clubId = ref.read(selectedClubIdProvider);
    if (clubId == null) {
      setState(() => _error = 'Select a club first');
      return;
    }
    final title = _titleCtrl.text.trim();
    if (title.isEmpty) {
      setState(() => _error = 'Title is required');
      return;
    }
    if (_scopeKind == 'team' && (_teamId == null || _teamId!.isEmpty)) {
      setState(() => _error = 'Pick a team');
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

    setState(() {
      _saving = true;
      _error = null;
    });

    try {
      final series = await ref.read(eventsApiProvider).createSeries(
            clubId: clubId,
            request: SaveEventSeriesRequest(
              scopeKind: _scopeKind,
              scopeId: _scopeKind == 'club' ? null : _teamId,
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
            ),
          );
      ref.invalidate(clubEventsProvider);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Created “${series.title}”')),
      );
      if (context.canPop()) {
        context.pop(true);
      } else {
        context.go('/calendar');
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _saving = false;
        _error = apiErrorMessage(e, fallback: 'Could not create schedule');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDemo = ref.watch(authNotifierProvider).user?.id == 'demo';
    final clubId = ref.watch(selectedClubIdProvider);
    final teamsAsync = ref.watch(clubTeamsProvider);
    final teams = teamsAsync.valueOrNull ?? const <ClubTeam>[];

    if (_teamId == null && teams.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted || _teamId != null) return;
        setState(() => _teamId = teams.first.id);
      });
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
        title: const Text('New schedule'),
      ),
      body: isDemo
          ? const Center(child: Text('Sign in to create schedule items.'))
          : clubId == null
              ? const Center(child: Text('Select a club first.'))
              : ListView(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
                  children: [
                    Text(
                      'Type',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final t in const [
                          ('training', 'Training'),
                          ('match', 'Match'),
                          ('clubEvent', 'Club event'),
                          ('tournament', 'Tournament'),
                        ])
                          ChoiceChip(
                            label: Text(t.$2),
                            selected: _type == t.$1,
                            onSelected: (_) => setState(() => _type = t.$1),
                          ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _titleCtrl,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: const InputDecoration(
                        labelText: 'Title',
                        hintText: 'e.g. U14 training',
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _purposeCtrl,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: const InputDecoration(
                        labelText: 'Purpose (optional)',
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _locationCtrl,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: const InputDecoration(
                        labelText: 'Location (optional)',
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Scope',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const SizedBox(height: 8),
                    SegmentedButton<String>(
                      segments: const [
                        ButtonSegment(value: 'team', label: Text('Team')),
                        ButtonSegment(value: 'club', label: Text('Whole club')),
                      ],
                      selected: {_scopeKind},
                      onSelectionChanged: (s) =>
                          setState(() => _scopeKind = s.first),
                    ),
                    if (_scopeKind == 'team') ...[
                      const SizedBox(height: 12),
                      teamsAsync.when(
                        loading: () => const LinearProgressIndicator(),
                        error: (e, _) => Text(
                          apiErrorMessage(e, fallback: 'Could not load teams'),
                        ),
                        data: (list) {
                          if (list.isEmpty) {
                            return const Text(
                              'No teams in this club. Create a team first, or use Whole club.',
                            );
                          }
                          return DropdownButtonFormField<String>(
                            // ignore: deprecated_member_use
                            value: list.any((t) => t.id == _teamId)
                                ? _teamId
                                : list.first.id,
                            decoration:
                                const InputDecoration(labelText: 'Team'),
                            items: [
                              for (final t in list)
                                DropdownMenuItem(
                                  value: t.id,
                                  child: Text(t.name),
                                ),
                            ],
                            onChanged: (v) => setState(() => _teamId = v),
                          );
                        },
                      ),
                    ],
                    const SizedBox(height: 20),
                    Text(
                      'When',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _pickDate,
                            icon: const Icon(Icons.calendar_today_outlined),
                            label: Text(DateFormat('EEE d MMM yyyy').format(_date)),
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
                      decoration:
                          const InputDecoration(labelText: 'Duration'),
                      items: const [
                        DropdownMenuItem(value: 45, child: Text('45 min')),
                        DropdownMenuItem(value: 60, child: Text('60 min')),
                        DropdownMenuItem(value: 75, child: Text('75 min')),
                        DropdownMenuItem(value: 90, child: Text('90 min')),
                        DropdownMenuItem(value: 120, child: Text('2 hours')),
                        DropdownMenuItem(value: 180, child: Text('3 hours')),
                      ],
                      onChanged: (v) {
                        if (v != null) setState(() => _durationMin = v);
                      },
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Repeat',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: [
                        for (final r in const [
                          ('once', 'One-off'),
                          ('weekly', 'Weekly'),
                          ('daily', 'Daily'),
                        ])
                          ChoiceChip(
                            label: Text(r.$2),
                            selected: _recurrence == r.$1,
                            onSelected: (_) =>
                                setState(() => _recurrence = r.$1),
                          ),
                      ],
                    ),
                    if (_recurrence != 'once') ...[
                      const SizedBox(height: 12),
                      DropdownButtonFormField<int>(
                        // ignore: deprecated_member_use
                        value: _repeatCount,
                        decoration: const InputDecoration(
                          labelText: 'Number of occurrences',
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
                      title: const Text('Request RSVP'),
                      subtitle: const Text(
                        'Families can confirm attendance beforehand',
                      ),
                      value: _rsvpRequested,
                      onChanged: (v) => setState(() => _rsvpRequested = v),
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
                          : const Text('Create'),
                    ),
                  ],
                ),
    );
  }
}
