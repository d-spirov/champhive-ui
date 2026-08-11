import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../clubs/providers/clubs_provider.dart';
import '../../events/providers/events_provider.dart';
import '../../../shared/models/event_attendance.dart';
import '../../../shared/theme/app_theme.dart';
import '../../../shared/utils/api_error_message.dart';
import '../../../shared/widgets/ui_bits.dart';
import '../widgets/attendance_ui.dart';

class MarkAttendanceScreen extends ConsumerStatefulWidget {
  const MarkAttendanceScreen({super.key, required this.eventId});

  final String eventId;

  @override
  ConsumerState<MarkAttendanceScreen> createState() =>
      _MarkAttendanceScreenState();
}

class _MarkAttendanceScreenState extends ConsumerState<MarkAttendanceScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;
  Map<String, AttendanceParticipant>? _draft;
  AttendanceSession? _session;
  bool _saving = false;
  String? _localError;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  void _syncFromSession(AttendanceSession session) {
    _session = session;
    _draft = {
      for (final p in session.participants) p.id: p,
    };
  }

  AttendanceSummaryCounts _counts() {
    final players = _draft?.values.toList() ?? const [];
    var present = 0, absent = 0, late = 0, excused = 0, notMarked = 0;
    for (final p in players) {
      switch (p.status) {
        case AttendanceStatus.present:
          present++;
        case AttendanceStatus.absent:
          absent++;
        case AttendanceStatus.late:
          late++;
        case AttendanceStatus.excused:
          excused++;
        case AttendanceStatus.notMarked:
          notMarked++;
      }
    }
    return AttendanceSummaryCounts(
      total: players.length,
      present: present,
      absent: absent,
      late: late,
      excused: excused,
      notMarked: notMarked,
    );
  }

  Future<void> _cycleStatus(AttendanceParticipant player) async {
    final next = nextAttendanceStatus(player.status);
    if (statusNeedsNote(next)) {
      final result = await showModalBottomSheet<_NoteResult>(
        context: context,
        isScrollControlled: true,
        builder: (ctx) => _AttendanceNoteSheet(
          playerName: player.displayName,
          status: next,
          initialReason: player.reason,
          initialNote: player.note,
        ),
      );
      if (result == null || !mounted) return;
      setState(() {
        _draft![player.id] = player.copyWith(
          status: next,
          reason: result.reason,
          note: result.note,
        );
      });
      return;
    }
    setState(() {
      _draft![player.id] = player.copyWith(
        status: next,
        clearReason: true,
        clearNote: true,
      );
    });
  }

  Future<void> _ensureOpen(AttendanceSession session) async {
    if (session.attendanceState != AttendanceState.notOpen) return;
    if (!session.canOpen) {
      throw StateError('Attendance is not open for marking');
    }
    final clubId = ref.read(selectedClubIdProvider);
    if (clubId == null) throw StateError('No club selected');
    final opened = await ref.read(attendanceApiProvider).openAttendance(
          clubId: clubId,
          eventId: widget.eventId,
        );
    _syncFromSession(opened);
  }

  Future<void> _save() async {
    final session = _session;
    final draft = _draft;
    if (session == null || draft == null || _saving) return;

    setState(() {
      _saving = true;
      _localError = null;
    });

    try {
      await _ensureOpen(session);

      final updates = <AttendanceUpdate>[];
      for (final original in session.participants) {
        final edited = draft[original.id];
        if (edited == null) continue;
        final changed = edited.status != original.status ||
            edited.reason != original.reason ||
            (edited.note ?? '') != (original.note ?? '');
        if (!changed) continue;
        updates.add(
          AttendanceUpdate(
            participantId: edited.id,
            status: edited.status,
            version: edited.version,
            reason: edited.reason,
            note: edited.note,
          ),
        );
      }

      final clubId = ref.read(selectedClubIdProvider);
      if (clubId == null) throw StateError('No club selected');

      AttendanceSession saved = session;
      if (updates.isNotEmpty) {
        saved = await ref.read(attendanceApiProvider).saveAttendance(
              clubId: clubId,
              eventId: widget.eventId,
              updates: updates,
            );
      }

      ref.invalidate(attendanceSessionProvider(widget.eventId));
      if (!mounted) return;
      context.pushReplacement(
        '/events/${widget.eventId}/attendance/saved',
        extra: saved,
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _localError = apiErrorMessage(e, fallback: 'Could not save attendance');
        _saving = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(attendanceSessionProvider(widget.eventId));
    final eventAsync = ref.watch(eventDetailProvider(widget.eventId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mark Attendance'),
        bottom: TabBar(
          controller: _tabs,
          labelColor: Theme.of(context).colorScheme.primary,
          unselectedLabelColor:
              Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.55),
          indicatorColor: Theme.of(context).colorScheme.primary,
          tabs: [
            Tab(
              text: _draft == null
                  ? 'Players'
                  : 'Players (${_draft!.length})',
            ),
            const Tab(text: 'Summary'),
          ],
        ),
      ),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  apiErrorMessage(e, fallback: 'Could not load attendance'),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: () =>
                      ref.invalidate(attendanceSessionProvider(widget.eventId)),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
        data: (session) {
          if (_draft == null || _session?.eventId != session.eventId) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!mounted) return;
              setState(() => _syncFromSession(session));
            });
          }

          final event = eventAsync.valueOrNull;
          final counts = _counts();
          final players = (_draft?.values.toList() ?? session.participants)
            ..sort((a, b) => a.displayName.compareTo(b.displayName));

          return Column(
            children: [
              _SessionHeader(session: session, event: event),
              if (_localError != null)
                MaterialBanner(
                  content: Text(_localError!),
                  actions: [
                    TextButton(
                      onPressed: () => setState(() => _localError = null),
                      child: const Text('Dismiss'),
                    ),
                  ],
                ),
              Expanded(
                child: TabBarView(
                  controller: _tabs,
                  children: [
                    _PlayersTab(
                      players: players,
                      canMark: session.canMark ||
                          (session.attendanceState == AttendanceState.notOpen &&
                              session.canOpen),
                      onTap: _cycleStatus,
                    ),
                    _SummaryTab(players: players, counts: counts),
                  ],
                ),
              ),
              _StickyFooter(
                counts: counts,
                saving: _saving,
                enabled: (session.canMark || session.canOpen) && !_saving,
                onSave: _save,
              ),
            ],
          );
        },
      ),
    );
  }
}

class _SessionHeader extends StatelessWidget {
  const _SessionHeader({required this.session, this.event});

  final AttendanceSession session;
  final ClubEvent? event;

  @override
  Widget build(BuildContext context) {
    final muted = Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            session.title,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 4),
          Text(
            [
              formatEventDate(session.startAt),
              formatEventTimeRange(session.startAt, event?.endAt),
              if (event != null) event!.location.display,
            ].join(' · '),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: muted),
          ),
        ],
      ),
    );
  }
}

class _PlayersTab extends StatelessWidget {
  const _PlayersTab({
    required this.players,
    required this.canMark,
    required this.onTap,
  });

  final List<AttendanceParticipant> players;
  final bool canMark;
  final Future<void> Function(AttendanceParticipant) onTap;

  @override
  Widget build(BuildContext context) {
    if (players.isEmpty) {
      return const Center(child: Text('No participants for this event.'));
    }
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      itemCount: players.length,
      separatorBuilder: (_, _) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final p = players[index];
        return ListTile(
          contentPadding: EdgeInsets.zero,
          leading: AvatarCircle(label: p.displayName),
          title: Text(p.displayName),
          subtitle: p.teamName != null ? Text(p.teamName!) : null,
          trailing: AttendanceStatusBadge(status: p.status),
          onTap: canMark ? () => onTap(p) : null,
        );
      },
    );
  }
}

class _SummaryTab extends StatelessWidget {
  const _SummaryTab({required this.players, required this.counts});

  final List<AttendanceParticipant> players;
  final AttendanceSummaryCounts counts;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _Stat(label: 'Present', count: counts.present, color: AppColors.present),
            _Stat(label: 'Late', count: counts.late, color: AppColors.late),
            _Stat(label: 'Absent', count: counts.absent, color: AppColors.absent),
            _Stat(label: 'Excused', count: counts.excused, color: AppColors.excused),
          ],
        ),
        const SizedBox(height: 20),
        for (final status in [
          AttendanceStatus.present,
          AttendanceStatus.late,
          AttendanceStatus.absent,
          AttendanceStatus.excused,
          AttendanceStatus.notMarked,
        ]) ...[
          _Group(
            status: status,
            players: players.where((p) => p.status == status).toList(),
          ),
        ],
      ],
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({
    required this.label,
    required this.count,
    required this.color,
  });

  final String label;
  final int count;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          '$count',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: color,
                fontWeight: FontWeight.w800,
              ),
        ),
        Text(label, style: Theme.of(context).textTheme.labelMedium),
      ],
    );
  }
}

class _Group extends StatelessWidget {
  const _Group({required this.status, required this.players});

  final AttendanceStatus status;
  final List<AttendanceParticipant> players;

  @override
  Widget build(BuildContext context) {
    if (players.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              AttendanceStatusBadge(status: status, size: 22),
              const SizedBox(width: 8),
              Text(
                '${status.label} (${players.length})',
                style: Theme.of(context).textTheme.titleSmall,
              ),
            ],
          ),
          const SizedBox(height: 8),
          for (final p in players)
            Padding(
              padding: const EdgeInsets.only(left: 8, bottom: 6),
              child: Text(
                p.displayName,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
        ],
      ),
    );
  }
}

class _StickyFooter extends StatelessWidget {
  const _StickyFooter({
    required this.counts,
    required this.saving,
    required this.enabled,
    required this.onSave,
  });

  final AttendanceSummaryCounts counts;
  final bool saving;
  final bool enabled;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 8,
      color: Theme.of(context).cardTheme.color ??
          Theme.of(context).colorScheme.surface,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  AttendanceCountChip(
                    status: AttendanceStatus.present,
                    count: counts.present,
                  ),
                  AttendanceCountChip(
                    status: AttendanceStatus.late,
                    count: counts.late,
                  ),
                  AttendanceCountChip(
                    status: AttendanceStatus.absent,
                    count: counts.absent,
                  ),
                  AttendanceCountChip(
                    status: AttendanceStatus.excused,
                    count: counts.excused,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: enabled ? onSave : null,
                child: saving
                    ? const SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Save Attendance'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NoteResult {
  const _NoteResult({this.reason, this.note});

  final AbsenceReason? reason;
  final String? note;
}

class _AttendanceNoteSheet extends StatefulWidget {
  const _AttendanceNoteSheet({
    required this.playerName,
    required this.status,
    this.initialReason,
    this.initialNote,
  });

  final String playerName;
  final AttendanceStatus status;
  final AbsenceReason? initialReason;
  final String? initialNote;

  @override
  State<_AttendanceNoteSheet> createState() => _AttendanceNoteSheetState();
}

class _AttendanceNoteSheetState extends State<_AttendanceNoteSheet> {
  late AbsenceReason? _reason = widget.initialReason ?? AbsenceReason.injury;
  late final TextEditingController _note;

  @override
  void initState() {
    super.initState();
    _note = TextEditingController(text: widget.initialNote ?? '');
  }

  @override
  void dispose() {
    _note.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.viewInsetsOf(context).bottom;
    return Padding(
      padding: EdgeInsets.only(bottom: bottom),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                '${widget.playerName} · ${widget.status.label}',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<AbsenceReason>(
                initialValue: _reason,
                decoration: const InputDecoration(
                  labelText: 'Reason (Required)',
                ),
                items: [
                  for (final r in AbsenceReason.values)
                    DropdownMenuItem(value: r, child: Text(r.label)),
                ],
                onChanged: (v) => setState(() => _reason = v),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _note,
                maxLines: 3,
                maxLength: 500,
                decoration: const InputDecoration(
                  labelText: 'Notes (Optional)',
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: 8),
              FilledButton(
                onPressed: _reason == null
                    ? null
                    : () => Navigator.pop(
                          context,
                          _NoteResult(
                            reason: _reason,
                            note: _note.text.trim().isEmpty
                                ? null
                                : _note.text.trim(),
                          ),
                        ),
                child: const Text('Save Note'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
