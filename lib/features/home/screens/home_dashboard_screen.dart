import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../l10n/app_localizations.dart';
import '../../attendance/widgets/attendance_ui.dart';
import '../../auth/providers/auth_provider.dart';
import '../../clubs/providers/clubs_provider.dart';
import '../../events/providers/events_provider.dart';
import '../../notifications/providers/notifications_provider.dart';
import '../../shell/main_shell.dart';
import '../../../shared/demo/demo_data.dart';
import '../../../shared/models/club.dart';
import '../../../shared/theme/app_theme.dart';
import '../../../shared/utils/api_error_message.dart';
import '../../../shared/widgets/ui_bits.dart';

class HomeDashboardScreen extends ConsumerWidget {
  const HomeDashboardScreen({super.key});

  String _greeting(AppLocalizations l10n) {
    final hour = DateTime.now().hour;
    if (hour < 12) return l10n.goodMorning;
    if (hour < 18) return l10n.goodAfternoon;
    return l10n.goodEvening;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final auth = ref.watch(authNotifierProvider);
    final user = auth.user;
    final isDemo = user?.id == 'demo';
    final first = user?.firstName.isNotEmpty == true
        ? user!.firstName
        : (user?.displayName ?? l10n.coachFallback);
    final clubsAsync = ref.watch(myClubsProvider);
    final eventsAsync = ref.watch(clubEventsProvider);
    final unread = ref.watch(unreadNotificationCountProvider);
    final clubId = ref.watch(selectedClubIdProvider);
    final isStaff = isDemo || (user?.isStaff(clubId) ?? false);

    return Scaffold(
      appBar: shellAppBar(
        context,
        title: '${_greeting(l10n)}, $first! 👋',
        actions: [
          if (isStaff)
            IconButton(
              onPressed: () => context.push('/attendance/history'),
              icon: Icon(
                Icons.how_to_reg_outlined,
                color: Theme.of(context).colorScheme.onSurface,
              ),
              tooltip: l10n.attendance,
            ),
          IconButton(
            onPressed: () => context.push('/notifications'),
            tooltip: l10n.notifications,
            icon: unread > 0
                ? Badge(
                    smallSize: 8,
                    backgroundColor: AppColors.badge,
                    child: Icon(
                      Icons.notifications_outlined,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  )
                : Icon(
                    Icons.notifications_outlined,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          if (!isDemo) {
            ref.invalidate(myClubsProvider);
            ref.invalidate(clubEventsProvider);
            await Future.wait([
              ref.read(myClubsProvider.future),
              ref.read(clubEventsProvider.future),
            ]);
          }
        },
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          children: [
            if (isDemo) ...[
              _YourTeamCard(team: DemoData.teams.first),
            ] else ...[
              clubsAsync.when(
                loading: () => const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (e, _) => AppCard(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Text(
                        apiErrorMessage(e, fallback: l10n.couldNotLoadClubs),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      GradientButton(
                        onPressed: () => ref.invalidate(myClubsProvider),
                        child: Text(l10n.retry),
                      ),
                    ],
                  ),
                ),
                data: (clubs) {
                  if (clubs.isEmpty) {
                    return AppCard(
                      padding: const EdgeInsets.all(20),
                      child: Text(
                        l10n.noClubsYet,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    );
                  }
                  return Column(
                    children: [
                      for (final club in clubs) ...[
                        _ClubCard(club: club),
                        const SizedBox(height: 10),
                      ],
                    ],
                  );
                },
              ),
            ],
            const SizedBox(height: 24),
            SectionHeader(
              title: l10n.upcoming,
              actionLabel: isStaff && !isDemo ? l10n.history : null,
              onAction: isStaff && !isDemo
                  ? () => context.push('/attendance/history')
                  : null,
            ),
            if (isDemo)
              AppCard(
                padding: const EdgeInsets.fromLTRB(14, 14, 14, 6),
                child: Column(
                  children: [
                    for (final e in DemoData.events.take(3))
                      EventListTile(event: e),
                  ],
                ),
              )
            else
              eventsAsync.when(
                loading: () => const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (e, _) => AppCard(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    apiErrorMessage(e, fallback: l10n.couldNotLoadSchedule),
                    textAlign: TextAlign.center,
                  ),
                ),
                data: (events) {
                  final now = DateTime.now();
                  final startOfToday = DateTime(now.year, now.month, now.day);
                  final endOfToday = startOfToday.add(const Duration(days: 1));

                  final today = events
                      .where(
                        (e) =>
                            !e.startAt.isBefore(startOfToday) &&
                            e.startAt.isBefore(endOfToday),
                      )
                      .toList();

                  // Prefer today's events; otherwise next few upcoming.
                  final shown = today.isNotEmpty
                      ? today
                      : events
                            .where((e) => !e.startAt.isBefore(now))
                            .take(5)
                            .toList();

                  if (shown.isEmpty) {
                    return AppCard(
                      padding: const EdgeInsets.all(20),
                      child: Text(
                        l10n.nothingOnScheduleToday,
                        textAlign: TextAlign.center,
                      ),
                    );
                  }
                  return AppCard(
                    padding: const EdgeInsets.fromLTRB(14, 8, 14, 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (today.isEmpty)
                          Padding(
                            padding: const EdgeInsets.fromLTRB(0, 4, 0, 8),
                            child: Text(
                              l10n.nothingTodayNextUp,
                              style: Theme.of(context).textTheme.labelMedium
                                  ?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface
                                        .withValues(alpha: 0.55),
                                  ),
                            ),
                          ),
                        for (final e in shown)
                          ClubEventListTile(
                            event: e,
                            onTap: () => context.push('/occurrences/${e.id}'),
                          ),
                      ],
                    ),
                  );
                },
              ),
            if (isDemo) ...[
              const SizedBox(height: 24),
              SectionHeader(title: l10n.recentActivity),
              AppCard(
                child: Column(
                  children: [
                    for (var i = 0; i < DemoData.activities.length; i++) ...[
                      if (i > 0) const Divider(height: 1),
                      ListTile(
                        leading: AvatarCircle(
                          label: DemoData.activities[i].playerName,
                        ),
                        title: Text(DemoData.activities[i].playerName),
                        subtitle: Text(DemoData.activities[i].status),
                        trailing: Text(
                          DemoData.activities[i].whenLabel,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        onTap: () =>
                            context.push('/members/${DemoData.player.id}'),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ClubCard extends ConsumerWidget {
  const _ClubCard({required this.club});

  final ClubSummary club;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final selectedId = ref.watch(selectedClubIdProvider);
    final isSelected = selectedId == club.id;
    final subtitle = [
      if (club.sportType != null && club.sportType!.isNotEmpty) club.sportType!,
      if (club.city != null && club.city!.isNotEmpty) club.city!,
      if (club.currentUserRoles.isNotEmpty) club.currentUserRoles.first,
    ].join(' · ');

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: AppGradients.heroCard,
        borderRadius: BorderRadius.circular(AppTheme.radius),
        boxShadow: AppTheme.softShadow,
      ),
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: () async {
            await ref.read(selectedClubIdProvider.notifier).select(club.id);
            if (context.mounted) context.push('/clubs/${club.id}');
          },
          borderRadius: BorderRadius.circular(AppTheme.radius),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: Colors.white.withValues(alpha: 0.2),
                  child: Text(
                    club.name.isEmpty ? '?' : club.name[0].toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 20,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.yourClubs,
                        style: GoogleFonts.inter(
                          color: Colors.white.withValues(alpha: 0.78),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.6,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              club.name,
                              style: GoogleFonts.inter(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: 18,
                              ),
                            ),
                          ),
                          if (isSelected)
                            const Icon(
                              Icons.check_circle,
                              size: 18,
                              color: Colors.white,
                            ),
                        ],
                      ),
                      if (subtitle.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          subtitle,
                          style: GoogleFonts.inter(
                            color: Colors.white.withValues(alpha: 0.82),
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right_rounded, color: Colors.white),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _YourTeamCard extends StatelessWidget {
  const _YourTeamCard({required this.team});

  final DemoTeam team;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final next = team.nextMatchAt;
    final opponent = team.nextOpponent ?? l10n.tbd;

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: AppGradients.heroCard,
        borderRadius: BorderRadius.circular(AppTheme.radius),
        boxShadow: AppTheme.softShadow,
      ),
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: () => context.push('/teams/${team.id}'),
          borderRadius: BorderRadius.circular(AppTheme.radius),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.yourTeams.toUpperCase(),
                        style: GoogleFonts.inter(
                          color: Colors.white.withValues(alpha: 0.78),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.6,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        team.name,
                        style: GoogleFonts.inter(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        team.season,
                        style: GoogleFonts.inter(
                          color: Colors.white.withValues(alpha: 0.82),
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        l10n.nextMatch,
                        style: GoogleFonts.inter(
                          color: Colors.white.withValues(alpha: 0.78),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        next == null
                            ? 'vs $opponent'
                            : 'vs $opponent · ${appDateFormat(context, 'd MMM, HH:mm').format(next)}',
                        style: GoogleFonts.inter(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right_rounded, color: Colors.white),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
