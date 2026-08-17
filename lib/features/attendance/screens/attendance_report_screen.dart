import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../events/providers/events_provider.dart';
import '../../../shared/theme/app_theme.dart';
import '../../../shared/utils/api_error_message.dart';
import '../widgets/attendance_ui.dart';

/// Read-only attendance report for one occurrence.
class AttendanceReportScreen extends ConsumerWidget {
  const AttendanceReportScreen({super.key, required this.occurrenceId});

  final String occurrenceId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(occurrenceAttendanceReportProvider(occurrenceId));
    final occurrenceAsync = ref.watch(eventDetailProvider(occurrenceId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Attendance report'),
        actions: [
          IconButton(
            tooltip: 'Take attendance',
            onPressed: () =>
                context.push('/occurrences/$occurrenceId/attendance'),
            icon: const Icon(Icons.how_to_reg_outlined),
          ),
        ],
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
                  apiErrorMessage(e, fallback: 'Could not load report'),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: () => ref.invalidate(
                    occurrenceAttendanceReportProvider(occurrenceId),
                  ),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
        data: (report) {
          final occurrence = occurrenceAsync.valueOrNull;
          final members = [...report.participants]
            ..sort((a, b) => a.displayName.compareTo(b.displayName));
          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(occurrenceAttendanceReportProvider(occurrenceId));
              await ref.read(
                occurrenceAttendanceReportProvider(occurrenceId).future,
              );
            },
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              children: [
                Text(
                  report.title,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 4),
                Text(
                  [
                    formatEventDate(report.startAt),
                    formatEventTimeRange(
                      report.startAt,
                      occurrence?.endAt ?? report.endAt,
                    ),
                    report.lockStatusLabel,
                  ].join(' · '),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _Stat('Present', report.summary.present, AppColors.present),
                    _Stat('Late', report.summary.late, AppColors.late),
                    _Stat('Absent', report.summary.absent, AppColors.absent),
                    _Stat('Excused', report.summary.excused, AppColors.excused),
                    _Stat(
                      'Open',
                      report.summary.notMarked,
                      const Color(0xFFCBD5E1),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                for (final p in members) ...[
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(p.displayName),
                    subtitle: p.note == null || p.note!.isEmpty
                        ? null
                        : Text(p.note!),
                    trailing: AttendanceStatusBadge(status: p.status),
                  ),
                  const Divider(height: 1),
                ],
              ],
            ),
          );
        },
      ),
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
