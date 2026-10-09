import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../l10n/app_localizations.dart';
import '../../../shared/l10n/label_l10n.dart';
import '../../../shared/models/event_attendance.dart';
import '../../../shared/theme/app_theme.dart';
import '../../../shared/utils/api_error_message.dart';
import '../../../shared/widgets/ui_bits.dart';
import '../../attendance/widgets/attendance_ui.dart';
import '../../auth/providers/auth_provider.dart';
import '../../clubs/providers/clubs_provider.dart';
import '../providers/events_provider.dart';
import '../providers/performance_provider.dart';
import '../providers/training_plans_provider.dart';
import '../widgets/training_plan_panel.dart';
import 'event_detail_screen.dart';

/// Tabbed occurrence details: overview, training plan, exercises.
class EventDetailsScreen extends ConsumerWidget {
  const EventDetailsScreen({
    super.key,
    required this.occurrenceId,
    this.openTestSet = false,
  });

  final String occurrenceId;
  final bool openTestSet;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final async = ref.watch(eventDetailProvider(occurrenceId));

    return async.when(
      loading: () => Scaffold(
        appBar: AppBar(centerTitle: true, title: Text(l10n.sessionDetails)),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Scaffold(
        appBar: AppBar(centerTitle: true, title: Text(l10n.sessionDetails)),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  apiErrorMessage(e, fallback: l10n.couldNotLoadSession),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: () =>
                      ref.invalidate(eventDetailProvider(occurrenceId)),
                  child: Text(l10n.retry),
                ),
              ],
            ),
          ),
        ),
      ),
      data: (occurrence) => _SessionDetailsBody(
        occurrence: occurrence,
        occurrenceId: occurrenceId,
        openTestSet: openTestSet,
      ),
    );
  }
}

class _SessionDetailsBody extends ConsumerWidget {
  const _SessionDetailsBody({
    required this.occurrence,
    required this.occurrenceId,
    this.openTestSet = false,
  });

  final ClubEvent occurrence;
  final String occurrenceId;
  final bool openTestSet;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final isTesting = occurrence.type == EventType.testing;
    return DefaultTabController(
      length: isTesting ? 2 : 3,
      initialIndex: isTesting && openTestSet ? 1 : 0,
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text(l10n.sessionDetails),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            onPressed: () => popOrGoHome(context),
          ),
          actions: [
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'refresh') {
                  ref.invalidate(eventDetailProvider(occurrenceId));
                  final planId = occurrence.trainingPlanId;
                  if (planId != null && planId.isNotEmpty) {
                    ref.invalidate(trainingPlanDetailProvider(planId));
                  }
                  if (isTesting) {
                    ref.invalidate(testingDayProvider(occurrenceId));
                  }
                }
              },
              itemBuilder: (context) => [
                PopupMenuItem(value: 'refresh', child: Text(l10n.refresh)),
              ],
            ),
          ],
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: _SessionHero(occurrence: occurrence),
            ),
            const SizedBox(height: 8),
            TabBar(
              tabs: [
                Tab(text: l10n.overview),
                if (isTesting)
                  Tab(text: l10n.testSet)
                else
                  Tab(text: l10n.trainingPlan),
                if (!isTesting) Tab(text: l10n.exercises),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  _OverviewTab(occurrence: occurrence),
                  if (isTesting)
                    _TestSetTab(occurrence: occurrence)
                  else
                    _PlanTab(occurrence: occurrence),
                  if (!isTesting) _ExercisesTab(occurrence: occurrence),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SessionHero extends StatelessWidget {
  const _SessionHero({required this.occurrence});

  final ClubEvent occurrence;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final date = appDateFormat(
      context,
      'EEE, d MMM yyyy',
    ).format(occurrence.startAt);
    final time = formatEventTimeRange(
      context,
      occurrence.startAt,
      occurrence.endAt,
    );
    final duration = occurrence.resolvedDurationMin;
    final scope =
        occurrence.scopeName ??
        (occurrence.teams.isEmpty ? null : occurrence.teams.join(', '));
    final club = occurrence.clubName?.trim();
    final teamLine = [
      if (scope != null && scope.isNotEmpty)
        '${scopeKindLabel(l10n, occurrence.scopeKind)} $scope',
      if (club != null && club.isNotEmpty) '${l10n.club} $club',
    ].join(' • ');
    final location = occurrence.location.name;
    final title = occurrence.title.isNotEmpty
        ? occurrence.title
        : eventTypeLabel(l10n, occurrence.type);

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1E4BB8), AppColors.primaryNavy],
        ),
        boxShadow: AppTheme.mediumShadow,
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _HeroChip(
                  label: eventTypeLabel(l10n, occurrence.type).toUpperCase(),
                  background: Colors.white.withValues(alpha: 0.18),
                ),
                _HeroChip(
                  label: occurrenceStatusLabel(
                    l10n,
                    occurrence.status,
                  ).toUpperCase(),
                  background: _statusColor(occurrence.status),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: GoogleFonts.inter(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 22,
                height: 1.25,
              ),
            ),
            const SizedBox(height: 14),
            _HeroMetaRow(
              children: [
                const Icon(
                  Icons.calendar_today_outlined,
                  size: 16,
                  color: Colors.white,
                ),
                const SizedBox(width: 8),
                Flexible(child: _HeroText(date)),
                const SizedBox(width: 12),
                const Icon(
                  Icons.schedule_outlined,
                  size: 16,
                  color: Colors.white,
                ),
                const SizedBox(width: 6),
                Flexible(child: _HeroText(time)),
                if (duration != null) ...[
                  const SizedBox(width: 8),
                  _DurationBadge(label: durationMinutesLabel(l10n, duration)),
                ],
              ],
            ),
            if (location != null && location.isNotEmpty) ...[
              const SizedBox(height: 8),
              _HeroMetaRow(
                children: [
                  const Icon(
                    Icons.place_outlined,
                    size: 16,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 8),
                  Expanded(child: _HeroText(location)),
                ],
              ),
            ],
            if (teamLine.isNotEmpty) ...[
              const SizedBox(height: 8),
              _HeroMetaRow(
                children: [
                  const Icon(
                    Icons.groups_outlined,
                    size: 16,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 8),
                  Expanded(child: _HeroText(teamLine)),
                ],
              ),
            ],
            const SizedBox(height: 8),
            _HeroMetaRow(
              children: [
                const Icon(
                  Icons.public_outlined,
                  size: 16,
                  color: Colors.white,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _HeroText(
                    (occurrence.timezone ?? '').isEmpty
                        ? '—'
                        : occurrence.timezone!,
                  ),
                ),
                const SizedBox(width: 12),
                const Icon(
                  Icons.event_available_outlined,
                  size: 16,
                  color: Colors.white,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: _HeroText(
                    occurrence.rsvpRequested
                        ? l10n.rsvpYes
                        : l10n.rsvpNotRequestedLabel,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _statusColor(String? status) {
    switch ((status ?? '').toLowerCase()) {
      case 'canceled':
      case 'cancelled':
        return AppColors.danger;
      case 'moved':
        return AppColors.warning;
      case 'completed':
        return AppColors.primaryBright;
      default:
        return AppColors.success;
    }
  }
}

class _HeroChip extends StatelessWidget {
  const _HeroChip({required this.label, required this.background});

  final String label;
  final Color background;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Text(
          label,
          style: GoogleFonts.inter(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 10,
            letterSpacing: 0.4,
          ),
        ),
      ),
    );
  }
}

class _DurationBadge extends StatelessWidget {
  const _DurationBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white.withValues(alpha: 0.35)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.timer_outlined, size: 14, color: Colors.white),
            const SizedBox(width: 4),
            Text(
              label,
              style: GoogleFonts.inter(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeroMetaRow extends StatelessWidget {
  const _HeroMetaRow({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Row(children: children);
  }
}

class _HeroText extends StatelessWidget {
  const _HeroText(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      style: GoogleFonts.inter(
        color: Colors.white.withValues(alpha: 0.92),
        fontSize: 13,
        height: 1.3,
      ),
    );
  }
}

class _OverviewTab extends StatelessWidget {
  const _OverviewTab({required this.occurrence});

  final ClubEvent occurrence;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final cells = _detailCells(context, l10n, occurrence);
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      children: [
        Text(l10n.coaches, style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 8),
        if (occurrence.coaches.isEmpty)
          AppCard(
            padding: const EdgeInsets.all(16),
            child: Text(l10n.noCoachesYet),
          )
        else
          AppCard(
            child: Column(
              children: [
                for (var i = 0; i < occurrence.coaches.length; i++) ...[
                  if (i > 0) const Divider(height: 1, indent: 64),
                  ListTile(
                    leading: CircleAvatar(
                      backgroundColor:
                          Theme.of(context).brightness == Brightness.dark
                          ? Colors.white
                          : AppColors.primaryLight,
                      child: Icon(
                        Icons.sports_rounded,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    title: Text(occurrence.coaches[i].name),
                    trailing: const Icon(Icons.chevron_right_rounded),
                  ),
                ],
              ],
            ),
          ),
        const SizedBox(height: 20),
        Text(
          l10n.sessionDetails,
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(height: 8),
        AppCard(
          padding: const EdgeInsets.fromLTRB(16, 14, 8, 14),
          child: Column(
            children: [
              for (var i = 0; i < cells.length; i += 2) ...[
                if (i > 0) const SizedBox(height: 16),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: cells[i]),
                    Expanded(
                      child: i + 1 < cells.length
                          ? cells[i + 1]
                          : const SizedBox.shrink(),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
        if ((occurrence.purpose ?? '').trim().isNotEmpty) ...[
          const SizedBox(height: 16),
          Text(l10n.purpose, style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 8),
          AppCard(
            padding: const EdgeInsets.all(16),
            child: Text(occurrence.purpose!.trim()),
          ),
        ],
        if ((occurrence.note ?? '').trim().isNotEmpty) ...[
          const SizedBox(height: 16),
          Text(l10n.note, style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 8),
          AppCard(
            padding: const EdgeInsets.all(16),
            child: Text(occurrence.note!.trim()),
          ),
        ],
      ],
    );
  }

  List<_DetailCell> _detailCells(
    BuildContext context,
    AppLocalizations l10n,
    ClubEvent event,
  ) {
    final date = appDateFormat(
      context,
      'EEE, d MMM yyyy',
    ).format(event.startAt);
    final time = formatEventTimeRange(context, event.startAt, event.endAt);
    final duration = event.resolvedDurationMin;
    final scope =
        event.scopeName ??
        (event.teams.isEmpty ? null : event.teams.join(', '));
    return [
      _DetailCell(
        icon: Icons.category_outlined,
        label: l10n.type,
        value: eventTypeLabel(l10n, event.type),
      ),
      _DetailCell(
        icon: Icons.flag_outlined,
        label: l10n.status,
        value: occurrenceStatusLabel(l10n, event.status),
      ),
      _DetailCell(
        icon: Icons.title_rounded,
        label: l10n.title,
        value: event.title.isEmpty ? '—' : event.title,
      ),
      if ((event.clubName ?? '').trim().isNotEmpty)
        _DetailCell(
          icon: Icons.apartment_outlined,
          label: l10n.club,
          value: event.clubName!.trim(),
        ),
      if ((event.scopeKind ?? '').isNotEmpty)
        _DetailCell(
          icon: Icons.hub_outlined,
          label: l10n.scope,
          value: scopeKindLabel(l10n, event.scopeKind),
        ),
      if (scope != null && scope.isNotEmpty)
        _DetailCell(
          icon: Icons.groups_outlined,
          label: l10n.team,
          value: scope,
        ),
      _DetailCell(
        icon: Icons.event_outlined,
        label: l10n.when,
        value: '$date, $time',
      ),
      if (duration != null)
        _DetailCell(
          icon: Icons.timer_outlined,
          label: l10n.duration,
          value: durationMinutesLabel(l10n, duration),
        ),
      if ((event.timezone ?? '').isNotEmpty)
        _DetailCell(
          icon: Icons.public_outlined,
          label: l10n.timezone,
          value: event.timezone!,
        ),
      if ((event.location.name ?? '').isNotEmpty)
        _DetailCell(
          icon: Icons.place_outlined,
          label: l10n.location,
          value: event.location.display,
        ),
      if (event.wasMoved && event.originalStartUtc != null)
        _DetailCell(
          icon: Icons.update_outlined,
          label: l10n.originallyScheduled,
          value:
              '${appDateFormat(context, 'EEE, d MMM yyyy').format(event.originalStartUtc!)}, ${formatEventTimeRange(context, event.originalStartUtc!, null)}',
        ),
      _DetailCell(
        icon: Icons.event_available_outlined,
        label: l10n.requestRsvp,
        value: event.rsvpRequested ? l10n.rsvpYes : l10n.rsvpNo,
      ),
      if ((event.metricBatteryName ?? '').trim().isNotEmpty)
        _DetailCell(
          icon: Icons.speed_rounded,
          label: l10n.testSet,
          value: event.metricBatteryName!.trim(),
        ),
    ];
  }
}

class _DetailCell extends StatelessWidget {
  const _DetailCell({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final muted = Theme.of(context).colorScheme.onSurfaceVariant;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: muted,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TestSetTab extends ConsumerWidget {
  const _TestSetTab({required this.occurrence});

  final ClubEvent occurrence;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final user = ref.watch(authNotifierProvider).user;
    final clubId = ref.watch(selectedClubIdProvider);
    final isDemo = user?.id == 'demo';
    final isStaff = isDemo || (user?.isStaff(clubId) ?? false);
    final async = ref.watch(testingDayProvider(occurrence.id));
    return async.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => _EmptyTab(
        icon: Icons.speed_rounded,
        message: apiErrorMessage(e, fallback: l10n.couldNotLoadTestingDay),
      ),
      data: (day) {
        final name = day.batteryName.isNotEmpty
            ? day.batteryName
            : (occurrence.metricBatteryName ?? l10n.testSet);
        if (day.stations.isEmpty) {
          return _EmptyTab(
            icon: Icons.speed_rounded,
            message: l10n.noStationsInTestSet,
          );
        }
        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          children: [
            Text(name, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 4),
            Text(
              l10n.stationCount(day.stations.length),
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 8),
            if (isStaff)
              Text(
                l10n.tapStationToRecord,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            const SizedBox(height: 12),
            for (var i = 0; i < day.stations.length; i++) ...[
              if (i > 0) const Divider(height: 1),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: CircleAvatar(child: Text('${i + 1}')),
                title: Text(
                  day.stations[i].name,
                  style: TextStyle(
                    decoration: day.stations[i].isRetired
                        ? TextDecoration.lineThrough
                        : null,
                  ),
                ),
                subtitle: Text(
                  [
                    if ((day.stations[i].unit ?? '').isNotEmpty)
                      day.stations[i].unit!,
                    l10n.recordedOf(
                      day.recordedCount(day.stations[i].code),
                      day.players.length,
                    ),
                    if (day.stations[i].isRetired) l10n.retiredStation,
                  ].join(' · '),
                ),
                trailing: isStaff && day.stations[i].canRecord
                    ? const Icon(Icons.chevron_right_rounded)
                    : null,
                onTap: isStaff && day.stations[i].canRecord
                    ? () => context.push(
                        '/occurrences/${occurrence.id}/testing/${Uri.encodeComponent(day.stations[i].code)}',
                      )
                    : null,
              ),
            ],
            if (day.players.isNotEmpty) ...[
              const SizedBox(height: 24),
              Text(
                l10n.resultsThisSession,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 4),
              Text(
                l10n.releaseResultsHint,
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 8),
              for (final player in day.players) ...[
                const Divider(height: 1),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(player.displayName),
                  subtitle: Text(
                    day.stations
                        .map((station) {
                          final value = player.values[station.code];
                          final shown = value?.display(
                            valueKind: station.valueKind,
                          );
                          final unit = station.unit;
                          if (shown == null || shown.isEmpty) {
                            return '${station.name}: —';
                          }
                          return [
                            station.name,
                            shown,
                            if (unit != null && unit.isNotEmpty) unit,
                          ].join(' ');
                        })
                        .join('\n'),
                  ),
                  isThreeLine: day.stations.length > 1,
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => context.push('/members/${player.memberId}'),
                ),
              ],
            ],
            if (isStaff) ...[
              const SizedBox(height: 20),
              _ReleaseResultsButton(occurrence: occurrence),
            ],
          ],
        );
      },
    );
  }
}

class _ReleaseResultsButton extends ConsumerStatefulWidget {
  const _ReleaseResultsButton({required this.occurrence});

  final ClubEvent occurrence;

  @override
  ConsumerState<_ReleaseResultsButton> createState() =>
      _ReleaseResultsButtonState();
}

class _ReleaseResultsButtonState extends ConsumerState<_ReleaseResultsButton> {
  bool _busy = false;

  String _dateKey(DateTime d) {
    String two(int n) => n.toString().padLeft(2, '0');
    return '${d.year}-${two(d.month)}-${two(d.day)}';
  }

  Future<void> _release() async {
    final l10n = AppLocalizations.of(context)!;
    final clubId = ref.read(selectedClubIdProvider);
    if (clubId == null || clubId.isEmpty) return;
    setState(() => _busy = true);
    try {
      final api = ref.read(performanceApiProvider);
      final drafts = await api.listMyDrafts(clubId: clubId);
      final occurrenceId = widget.occurrence.id;
      final day = _dateKey(widget.occurrence.startAt);
      final mine = drafts.where((d) {
        if (d.occurrenceId == occurrenceId) return true;
        final on = d.assessedOn;
        return on != null && on.length >= 10 && on.substring(0, 10) == day;
      }).toList();
      if (mine.isEmpty) {
        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.noDraftsToRelease)));
        setState(() => _busy = false);
        return;
      }
      for (final draft in mine) {
        await api.finalizeSitting(clubId: clubId, assessmentId: draft.id);
      }
      ref.invalidate(testingDayProvider(occurrenceId));
      if (!mounted) return;
      setState(() => _busy = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.resultsReleasedCount(mine.length))),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _busy = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            apiErrorMessage(e, fallback: l10n.couldNotRecordResults),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return OutlinedButton.icon(
      onPressed: _busy ? null : _release,
      icon: _busy
          ? const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : const Icon(Icons.publish_rounded),
      label: Text(l10n.releaseResults),
    );
  }
}

class _PlanTab extends StatelessWidget {
  const _PlanTab({required this.occurrence});

  final ClubEvent occurrence;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final planId = occurrence.trainingPlanId;
    if (planId == null || planId.isEmpty) {
      return _EmptyTab(
        icon: Icons.assignment_outlined,
        message: l10n.noTrainingPlanAttached,
      );
    }
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      children: [
        TrainingPlanPanel(
          planId: planId,
          fallbackName: occurrence.trainingPlanName,
          mode: TrainingPlanPanelMode.summary,
        ),
      ],
    );
  }
}

class _ExercisesTab extends StatelessWidget {
  const _ExercisesTab({required this.occurrence});

  final ClubEvent occurrence;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final planId = occurrence.trainingPlanId;
    if (planId == null || planId.isEmpty) {
      return _EmptyTab(
        icon: Icons.fitness_center_outlined,
        message: l10n.noTrainingPlanAttached,
      );
    }
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      children: [
        TrainingPlanPanel(
          planId: planId,
          fallbackName: occurrence.trainingPlanName,
          mode: TrainingPlanPanelMode.exercises,
        ),
      ],
    );
  }
}

class _EmptyTab extends StatelessWidget {
  const _EmptyTab({required this.icon, required this.message});

  final IconData icon;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 40,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
