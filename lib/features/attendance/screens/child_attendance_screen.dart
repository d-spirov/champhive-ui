import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../l10n/app_localizations.dart';
import '../../../shared/models/member_attendance.dart';
import '../../../shared/theme/app_theme.dart';
import '../../../shared/utils/api_error_message.dart';
import '../../account/providers/account_extras_provider.dart';
import '../widgets/attendance_ui.dart';

/// Read-only attendance for one family member (`GET /me/children/{id}/attendance`).
class ChildAttendanceScreen extends ConsumerWidget {
  const ChildAttendanceScreen({
    super.key,
    required this.memberId,
    this.memberName,
  });

  final String memberId;
  final String? memberName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final async = ref.watch(childAttendanceProvider(memberId));
    final title = (memberName ?? '').trim().isEmpty
        ? l10n.attendance
        : memberName!.trim();

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/home');
            }
          },
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
                  apiErrorMessage(e, fallback: l10n.couldNotLoadHistory),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: () =>
                      ref.invalidate(childAttendanceProvider(memberId)),
                  child: Text(l10n.retry),
                ),
              ],
            ),
          ),
        ),
        data: (history) {
          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(childAttendanceProvider(memberId));
              await ref.read(childAttendanceProvider(memberId).future);
            },
            child: history.entries.isEmpty
                ? ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                    children: [
                      _Summary(history: history),
                      const SizedBox(height: 32),
                      Center(child: Text(l10n.noPastSessions)),
                    ],
                  )
                : ListView.separated(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                    itemCount: history.entries.length + 1,
                    separatorBuilder: (_, index) => index == 0
                        ? const SizedBox(height: 16)
                        : const Divider(height: 1),
                    itemBuilder: (context, index) {
                      if (index == 0) return _Summary(history: history);
                      final entry = history.entries[index - 1];
                      final sessionTitle = entry.title.trim().isEmpty
                          ? eventTypeLabel(l10n, entry.type)
                          : entry.title;
                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(sessionTitle),
                        subtitle: Text(
                          [
                            formatEventDate(context, entry.startsAt),
                            if (entry.scopeName != null) entry.scopeName!,
                            if (entry.note != null) entry.note!,
                          ].join(' · '),
                        ),
                        trailing: AttendanceStatusBadge(status: entry.status),
                        onTap: entry.occurrenceId.isEmpty
                            ? null
                            : () => context.push(
                                '/occurrences/${entry.occurrenceId}',
                              ),
                      );
                    },
                  ),
          );
        },
      ),
    );
  }
}

class _Summary extends StatelessWidget {
  const _Summary({required this.history});

  final MemberAttendance history;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final rate = history.attendanceRate;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.attendance, style: Theme.of(context).textTheme.titleLarge),
        if (rate != null) ...[
          const SizedBox(height: 4),
          Text(
            '${(rate * 100).round()}%',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _Stat(l10n.statusPresent, history.present, AppColors.present),
            _Stat(l10n.statusLate, history.late, AppColors.late),
            _Stat(l10n.statusAbsent, history.absent, AppColors.absent),
            _Stat(l10n.statusExcused, history.excused, AppColors.excused),
          ],
        ),
      ],
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat(this.label, this.count, this.color);

  final String label;
  final int count;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          '$count',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: color,
            fontWeight: FontWeight.w800,
          ),
        ),
        Text(label, style: Theme.of(context).textTheme.labelSmall),
      ],
    );
  }
}
