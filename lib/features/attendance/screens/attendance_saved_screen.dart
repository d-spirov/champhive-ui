import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../shared/models/event_attendance.dart';
import '../../../shared/theme/app_theme.dart';
import '../widgets/attendance_ui.dart';

class AttendanceSavedScreen extends StatelessWidget {
  const AttendanceSavedScreen({
    super.key,
    required this.eventId,
    this.result,
    this.session,
  });

  final String eventId;
  final AttendanceSaveResult? result;
  final AttendanceSession? session;

  @override
  Widget build(BuildContext context) {
    final summary =
        result?.session.summary ?? session?.summary ?? const AttendanceSummaryCounts();
    final batch = result?.batch;
    final rejected = batch?.rejected ?? 0;
    final applied = (batch?.applied ?? 0) + (batch?.alreadyApplied ?? 0);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => context.go('/occurrences/$eventId'),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
          child: Column(
            children: [
              const Spacer(),
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: (rejected > 0 ? AppColors.late : AppColors.present)
                      .withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  rejected > 0
                      ? Icons.warning_amber_rounded
                      : Icons.check_circle_rounded,
                  size: 64,
                  color: rejected > 0 ? AppColors.late : AppColors.present,
                ),
              ),
              const SizedBox(height: 28),
              Text(
                rejected > 0 ? 'Attendance partially synced' : 'Attendance synced',
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Text(
                batch == null
                    ? 'Marks were sent to the club platform.'
                    : rejected > 0
                        ? '$applied applied · $rejected rejected'
                            '${batch.supersededByNewer > 0 ? ' · ${batch.supersededByNewer} superseded' : ''}'
                        : '$applied mark${applied == 1 ? '' : 's'} applied to the server.',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withValues(alpha: 0.65),
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 28),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  AttendanceCountChip(
                    status: AttendanceStatus.present,
                    count: summary.present,
                  ),
                  AttendanceCountChip(
                    status: AttendanceStatus.late,
                    count: summary.late,
                  ),
                  AttendanceCountChip(
                    status: AttendanceStatus.absent,
                    count: summary.absent,
                  ),
                  AttendanceCountChip(
                    status: AttendanceStatus.excused,
                    count: summary.excused,
                  ),
                ],
              ),
              const Spacer(),
              FilledButton(
                onPressed: () => context.go('/occurrences/$eventId'),
                child: const Text('Back to session'),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () =>
                    context.push('/occurrences/$eventId/attendance/report'),
                child: const Text('View report'),
              ),
              TextButton(
                onPressed: () => context.push('/attendance/history'),
                child: const Text('Attendance history'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
