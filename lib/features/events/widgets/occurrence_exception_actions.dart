import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../l10n/app_localizations.dart';
import '../../../shared/l10n/date_l10n.dart';
import '../../../shared/models/event_attendance.dart';
import '../../../shared/models/event_series.dart';
import '../../../shared/utils/api_error_message.dart';
import '../../auth/providers/auth_provider.dart';
import '../../calendar/schedule_timing.dart';
import '../../teams/providers/teams_provider.dart';
import '../providers/events_provider.dart';

Future<void> showCancelOccurrenceDialog({
  required BuildContext context,
  required WidgetRef ref,
  required ClubEvent occurrence,
}) {
  return _showNoteActionDialog(
    context: context,
    ref: ref,
    occurrence: occurrence,
    title: AppLocalizations.of(context)!.cancelSessionTitle,
    body: AppLocalizations.of(context)!.cancelSessionBody,
    confirmLabel: AppLocalizations.of(context)!.cancelSessionConfirm,
    successLabel: AppLocalizations.of(context)!.sessionCanceledToast,
    destructive: true,
    request: (note) => PatchOccurrenceRequest.cancel(note: note),
  );
}

Future<void> showRestoreOccurrenceDialog({
  required BuildContext context,
  required WidgetRef ref,
  required ClubEvent occurrence,
}) {
  return _showNoteActionDialog(
    context: context,
    ref: ref,
    occurrence: occurrence,
    title: AppLocalizations.of(context)!.restoreSessionTitle,
    body: AppLocalizations.of(context)!.restoreSessionBody,
    confirmLabel: AppLocalizations.of(context)!.restoreSessionConfirm,
    successLabel: AppLocalizations.of(context)!.sessionRestoredToast,
    destructive: false,
    request: (note) => PatchOccurrenceRequest.restore(note: note),
  );
}

Future<void> showRescheduleOccurrenceDialog({
  required BuildContext context,
  required WidgetRef ref,
  required ClubEvent occurrence,
}) async {
  final l10n = AppLocalizations.of(context)!;
  final user = ref.read(authNotifierProvider).user;
  if (user?.id == 'demo') {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(l10n.signInToCreateSchedule)));
    return;
  }

  final result = await showDialog<_RescheduleResult>(
    context: context,
    builder: (context) => _RescheduleDialog(occurrence: occurrence),
  );
  if (result == null || !context.mounted) return;
  await _patchOccurrence(
    context: context,
    ref: ref,
    occurrenceId: occurrence.id,
    request: PatchOccurrenceRequest.move(
      startUtc: formatUtcInstant(result.start),
      note: result.note,
    ),
    successLabel: l10n.sessionRescheduledToast,
  );
}

Future<void> _showNoteActionDialog({
  required BuildContext context,
  required WidgetRef ref,
  required ClubEvent occurrence,
  required String title,
  required String body,
  required String confirmLabel,
  required String successLabel,
  required bool destructive,
  required PatchOccurrenceRequest Function(String? note) request,
}) async {
  final l10n = AppLocalizations.of(context)!;
  final user = ref.read(authNotifierProvider).user;
  if (user?.id == 'demo') {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(l10n.signInToCreateSchedule)));
    return;
  }

  final noteCtrl = TextEditingController();
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text(title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(body),
            const SizedBox(height: 16),
            TextField(
              controller: noteCtrl,
              maxLines: 2,
              decoration: InputDecoration(
                labelText: l10n.reasonOptional,
                hintText: l10n.reasonHint,
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
            style: destructive
                ? FilledButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.error,
                  )
                : null,
            onPressed: () => Navigator.pop(context, true),
            child: Text(confirmLabel),
          ),
        ],
      );
    },
  );
  final note = noteCtrl.text.trim();
  noteCtrl.dispose();
  if (confirmed != true || !context.mounted) return;
  await _patchOccurrence(
    context: context,
    ref: ref,
    occurrenceId: occurrence.id,
    request: request(note.isEmpty ? null : note),
    successLabel: successLabel,
  );
}

Future<void> _patchOccurrence({
  required BuildContext context,
  required WidgetRef ref,
  required String occurrenceId,
  required PatchOccurrenceRequest request,
  required String successLabel,
}) async {
  final l10n = AppLocalizations.of(context)!;
  try {
    await ref
        .read(eventsApiProvider)
        .patchOccurrence(occurrenceId: occurrenceId, request: request);
    ref.invalidate(eventDetailProvider(occurrenceId));
    ref.invalidate(clubEventsProvider);
    ref.invalidate(pastClubEventsProvider);
    ref.invalidate(teamScheduleProvider);
    if (!context.mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(successLabel)));
  } catch (e) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(apiErrorMessage(e, fallback: l10n.couldNotUpdateSession)),
      ),
    );
  }
}

class _RescheduleResult {
  const _RescheduleResult({required this.start, this.note});

  final DateTime start;
  final String? note;
}

class _RescheduleDialog extends StatefulWidget {
  const _RescheduleDialog({required this.occurrence});

  final ClubEvent occurrence;

  @override
  State<_RescheduleDialog> createState() => _RescheduleDialogState();
}

class _RescheduleDialogState extends State<_RescheduleDialog> {
  late DateTime _date;
  late TimeOfDay _time;
  final _noteCtrl = TextEditingController();
  String? _error;

  @override
  void initState() {
    super.initState();
    final snapped = snapEventStartToNow(
      date: widget.occurrence.startAt,
      time: TimeOfDay.fromDateTime(widget.occurrence.startAt),
    );
    _date = snapped.date;
    _time = snapped.time;
  }

  @override
  void dispose() {
    _noteCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final l10n = AppLocalizations.of(context)!;
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
      setState(() => _error = l10n.cannotCreateEventInPast);
      return;
    }
    setState(() {
      _error = null;
      _date = dateOnly(picked);
      final snapped = snapEventStartToNow(date: _date, time: _time);
      _date = snapped.date;
      _time = snapped.time;
    });
  }

  Future<void> _pickTime() async {
    final l10n = AppLocalizations.of(context)!;
    final picked = await showTimePicker(context: context, initialTime: _time);
    if (picked == null) return;
    if (isPastEventStart(eventStartAt(_date, picked))) {
      if (!mounted) return;
      setState(() => _error = l10n.cannotCreateEventInPast);
      return;
    }
    setState(() {
      _error = null;
      _time = picked;
    });
  }

  void _submit() {
    final l10n = AppLocalizations.of(context)!;
    final start = eventStartAt(_date, _time);
    if (isPastEventStart(start) || isPastCalendarDay(_date)) {
      setState(() => _error = l10n.cannotCreateEventInPast);
      return;
    }
    final note = _noteCtrl.text.trim();
    Navigator.pop(
      context,
      _RescheduleResult(start: start, note: note.isEmpty ? null : note),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return AlertDialog(
      title: Text(l10n.rescheduleTitle),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.calendar_today_outlined),
              title: Text(
                appDateFormat(context, 'EEE, d MMM yyyy').format(_date),
              ),
              onTap: _pickDate,
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.schedule_outlined),
              title: Text(_time.format(context)),
              onTap: _pickTime,
            ),
            TextField(
              controller: _noteCtrl,
              maxLines: 2,
              decoration: InputDecoration(
                labelText: l10n.reasonOptional,
                hintText: l10n.reasonHint,
              ),
            ),
            if (_error != null) ...[
              const SizedBox(height: 12),
              Text(
                _error!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.cancel),
        ),
        FilledButton(onPressed: _submit, child: Text(l10n.saveNewTime)),
      ],
    );
  }
}
