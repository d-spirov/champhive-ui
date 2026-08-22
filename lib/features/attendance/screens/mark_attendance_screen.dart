import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../l10n/app_localizations.dart';
import '../../auth/providers/auth_provider.dart';
import '../../events/providers/events_provider.dart';
import '../../../shared/models/event_attendance.dart';
import '../../../shared/theme/app_theme.dart';
import '../../../shared/utils/api_error_message.dart';
import '../widgets/attendance_ui.dart';
import '../../players/widgets/player_avatar.dart';

class MarkAttendanceScreen extends ConsumerStatefulWidget {
  const MarkAttendanceScreen({super.key, required this.eventId});

  /// Opaque occurrence id (route param still named eventId for go_router).
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

  String get _occurrenceId => widget.eventId;

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
    return AttendanceSummaryCounts.fromParticipants(
      _draft?.values.toList() ?? const [],
    );
  }

  Future<void> _pickStatus(AttendanceParticipant member) async {
    if (!(_session?.canMark ?? false) || _saving) return;

    final l10n = AppLocalizations.of(context)!;
    final selected = await showModalBottomSheet<AttendanceStatus>(
      context: context,
      builder: (ctx) => _StatusPickerSheet(
        memberName: member.displayName,
        current: member.status,
      ),
    );
    if (selected == null || !mounted) return;

    if (selected == AttendanceStatus.notMarked) {
      setState(() {
        _localError = l10n.unmarkedCannotBeSaved;
      });
      return;
    }

    String? note = member.note;
    if (statusOffersNote(selected)) {
      final result = await showModalBottomSheet<String?>(
        context: context,
        isScrollControlled: true,
        builder: (ctx) => _OptionalNoteSheet(
          memberName: member.displayName,
          status: selected,
          initialNote: member.note,
        ),
      );
      if (!mounted) return;
      if (result == null) return; // dismissed — don't save
      note = result.isEmpty ? null : result;
    } else {
      note = null;
    }

    // Optimistic UI, then persist via attendance batch API.
    setState(() {
      _draft![member.id] = member.copyWith(
        status: selected,
        note: note,
        clearReason: true,
        clearNote: note == null,
      );
      _saving = true;
      _localError = null;
    });

    try {
      await ref.watch(authApiProvider.future);
      final api = ref.read(attendanceApiProvider);
      final result = await api.saveMemberStatus(
        occurrenceId: _occurrenceId,
        memberId: member.memberId,
        status: selected,
        note: note,
      );

      if (!mounted) return;
      setState(() {
        _syncFromSession(result.session);
        _saving = false;
      });
      ref.invalidate(occurrenceAttendanceReportProvider(_occurrenceId));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${member.displayName} → ${attendanceStatusLabel(l10n, selected)}',
          ),
          duration: const Duration(seconds: 1),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      // Roll back optimistic mark to last known session.
      final baseline = _session;
      AttendanceParticipant? original;
      if (baseline != null) {
        for (final p in baseline.participants) {
          if (p.id == member.id) {
            original = p;
            break;
          }
        }
      }
      setState(() {
        if (original != null) {
          _draft![member.id] = original;
        }
        _saving = false;
        _localError = apiErrorMessage(e, fallback: l10n.couldNotSaveStatus);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_localError!)),
      );
    }
  }

  Future<void> _save() async {
    final baseline = _session;
    final draft = _draft;
    if (baseline == null || draft == null || _saving) return;

    final l10n = AppLocalizations.of(context)!;
    if (!baseline.canMark) {
      setState(() {
        _localError = l10n.attendanceLocked;
      });
      return;
    }

    final nowUtc = DateTime.now().toUtc();
    final updates = <AttendanceUpdate>[];
    for (final original in baseline.participants) {
      final edited = draft[original.id];
      if (edited == null) continue;
      if (!edited.status.isMarkable) continue;
      final changed = edited.status != original.status ||
          (edited.note ?? '') != (original.note ?? '');
      if (!changed) continue;
      updates.add(
        AttendanceUpdate(
          participantId: edited.memberId,
          status: edited.status,
          note: edited.note,
          recordedAtClientUtc: nowUtc,
          clientRecordId: newClientRecordId(),
        ),
      );
    }

    if (updates.isEmpty) {
      setState(() {
        _localError = l10n.allMarksAlreadySaved;
      });
      return;
    }

    setState(() {
      _saving = true;
      _localError = null;
    });

    try {
      await ref.watch(authApiProvider.future);
      final api = ref.read(attendanceApiProvider);
      final result = await api.saveAttendance(
        occurrenceId: _occurrenceId,
        updates: updates,
      );

      ref.invalidate(attendanceSessionProvider(_occurrenceId));
      ref.invalidate(occurrenceAttendanceReportProvider(_occurrenceId));
      if (!mounted) return;
      context.go(
        '/occurrences/$_occurrenceId/attendance/saved',
        extra: result,
      );
    } catch (e) {
      if (!mounted) return;
      final message = apiErrorMessage(
        e,
        fallback: l10n.couldNotSaveAttendance,
      );
      setState(() {
        _localError = message;
        _saving = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final async = ref.watch(attendanceSessionProvider(_occurrenceId));
    final occurrenceAsync = ref.watch(eventDetailProvider(_occurrenceId));

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/occurrences/$_occurrenceId');
            }
          },
        ),
        title: Text(l10n.takeAttendance),
        bottom: TabBar(
          controller: _tabs,
          labelColor: Theme.of(context).colorScheme.primary,
          unselectedLabelColor:
              Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.55),
          indicatorColor: Theme.of(context).colorScheme.primary,
          tabs: [
            Tab(
              text: _draft == null
                  ? l10n.roster
                  : l10n.rosterCount(_draft!.length),
            ),
            Tab(text: l10n.summary),
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
                  apiErrorMessage(e, fallback: l10n.couldNotLoadRoster),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: () =>
                      ref.invalidate(attendanceSessionProvider(_occurrenceId)),
                  child: Text(l10n.retry),
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

          final occurrence = occurrenceAsync.valueOrNull;
          final counts = _counts();
          final members = (_draft?.values.toList() ?? session.participants)
            ..sort((a, b) => a.displayName.compareTo(b.displayName));

          return Column(
            children: [
              _SessionHeader(session: session, occurrence: occurrence),
              if (!session.canMark)
                MaterialBanner(
                  content: Text(
                    session.isCanceled
                        ? l10n.sessionCanceled
                        : l10n.attendanceLocked,
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => context.push(
                        '/occurrences/$_occurrenceId/attendance/report',
                      ),
                      child: Text(l10n.report),
                    ),
                  ],
                ),
              if (_localError != null)
                MaterialBanner(
                  content: Text(_localError!),
                  actions: [
                    TextButton(
                      onPressed: () => setState(() => _localError = null),
                      child: Text(l10n.dismiss),
                    ),
                  ],
                ),
              Expanded(
                child: TabBarView(
                  controller: _tabs,
                  children: [
                    _RosterTab(
                      members: members,
                      canMark: session.canMark,
                      onTap: _pickStatus,
                      onRefresh: () => ref.invalidate(
                        attendanceSessionProvider(_occurrenceId),
                      ),
                      scopeName: session.scopeName ??
                          occurrence?.scopeName ??
                          (occurrence?.teams.isNotEmpty == true
                              ? occurrence!.teams.join(', ')
                              : null),
                    ),
                    _SummaryTab(members: members, counts: counts),
                  ],
                ),
              ),
              _StickyFooter(
                counts: counts,
                saving: _saving,
                enabled: !_saving && session.canMark,
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
  const _SessionHeader({required this.session, this.occurrence});

  final AttendanceSession session;
  final ClubEvent? occurrence;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final muted = Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6);
    final scope = session.scopeName ?? occurrence?.scopeName;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            session.title,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          if (scope != null && scope.isNotEmpty) ...[
            const SizedBox(height: 2),
            Text(
              scope,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                  ),
            ),
          ],
          const SizedBox(height: 4),
          Text(
            [
              formatEventDate(session.startAt),
              formatEventTimeRange(session.startAt, occurrence?.endAt ?? session.endAt),
              if (session.location != null && session.location!.isNotEmpty)
                session.location!
              else if (occurrence != null)
                occurrence!.location.display,
            ].join(' · '),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: muted),
          ),
          const SizedBox(height: 6),
          Text(
            session.canMark
                ? l10n.tapMemberToMark
                : session.isCanceled
                    ? l10n.sessionCanceled
                    : l10n.attendanceLocked,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(color: muted),
          ),
        ],
      ),
    );
  }
}

class _RosterTab extends StatelessWidget {
  const _RosterTab({
    required this.members,
    required this.canMark,
    required this.onTap,
    required this.onRefresh,
    this.scopeName,
  });

  final List<AttendanceParticipant> members;
  final bool canMark;
  final Future<void> Function(AttendanceParticipant) onTap;
  final VoidCallback onRefresh;
  final String? scopeName;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    if (members.isEmpty) {
      final scope = scopeName ?? l10n.thisSession;
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                l10n.noMembersOnRoster(scope),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              FilledButton.tonal(
                onPressed: onRefresh,
                child: Text(l10n.reloadRoster),
              ),
            ],
          ),
        ),
      );
    }
    return RefreshIndicator(
      onRefresh: () async => onRefresh(),
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        itemCount: members.length,
        separatorBuilder: (_, _) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final p = members[index];
          return ListTile(
            contentPadding: EdgeInsets.zero,
            leading: PlayerAvatar(
              playerId: p.playerId,
              label: p.displayName,
              hasPhoto: p.hasPhoto,
            ),
            title: Text(p.displayName),
            subtitle: Text(
              [
                if (p.rsvpStatus != null && p.rsvpStatus != 'noResponse')
                  l10n.rsvpStatus(p.rsvpStatus!),
                if (p.teamName != null) p.teamName!,
                attendanceStatusLabel(l10n, p.status),
              ].where((s) => s.isNotEmpty).join(' · '),
            ),
            trailing: AttendanceStatusBadge(status: p.status),
            onTap: canMark ? () => onTap(p) : null,
          );
        },
      ),
    );
  }
}

class _SummaryTab extends StatelessWidget {
  const _SummaryTab({required this.members, required this.counts});

  final List<AttendanceParticipant> members;
  final AttendanceSummaryCounts counts;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _Stat(label: l10n.statusPresent, count: counts.present, color: AppColors.present),
            _Stat(label: l10n.statusLate, count: counts.late, color: AppColors.late),
            _Stat(label: l10n.statusAbsent, count: counts.absent, color: AppColors.absent),
            _Stat(label: l10n.statusExcused, count: counts.excused, color: AppColors.excused),
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
            members: members.where((p) => p.status == status).toList(),
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
  const _Group({required this.status, required this.members});

  final AttendanceStatus status;
  final List<AttendanceParticipant> members;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    if (members.isEmpty) return const SizedBox.shrink();
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
                '${attendanceStatusLabel(l10n, status)} (${members.length})',
                style: Theme.of(context).textTheme.titleSmall,
              ),
            ],
          ),
          const SizedBox(height: 8),
          for (final p in members)
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
    final l10n = AppLocalizations.of(context)!;
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
                    : Text(l10n.saveRemaining),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusPickerSheet extends StatelessWidget {
  const _StatusPickerSheet({
    required this.memberName,
    required this.current,
  });

  final String memberName;
  final AttendanceStatus current;

  static const _options = [
    AttendanceStatus.present,
    AttendanceStatus.late,
    AttendanceStatus.absent,
    AttendanceStatus.excused,
    AttendanceStatus.notMarked,
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 12, 8, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
              child: Text(
                l10n.markNamed(memberName),
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            for (final status in _options)
              ListTile(
                leading: AttendanceStatusBadge(status: status),
                title: Text(attendanceStatusLabel(l10n, status)),
                trailing: current == status
                    ? Icon(
                        Icons.check_rounded,
                        color: Theme.of(context).colorScheme.primary,
                      )
                    : null,
                onTap: () => Navigator.pop(context, status),
              ),
          ],
        ),
      ),
    );
  }
}

class _OptionalNoteSheet extends StatefulWidget {
  const _OptionalNoteSheet({
    required this.memberName,
    required this.status,
    this.initialNote,
  });

  final String memberName;
  final AttendanceStatus status;
  final String? initialNote;

  @override
  State<_OptionalNoteSheet> createState() => _OptionalNoteSheetState();
}

class _OptionalNoteSheetState extends State<_OptionalNoteSheet> {
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
    final l10n = AppLocalizations.of(context)!;
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
                '${widget.memberName} · ${attendanceStatusLabel(l10n, widget.status)}',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(
                l10n.optionalNoteSynced,
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _note,
                maxLines: 3,
                maxLength: 500,
                decoration: InputDecoration(
                  labelText: l10n.note,
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: 8),
              FilledButton(
                onPressed: () => Navigator.pop(context, _note.text.trim()),
                child: Text(l10n.continueAction),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, ''),
                child: Text(l10n.skipNote),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
