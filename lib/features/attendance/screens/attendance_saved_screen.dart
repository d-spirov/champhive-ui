import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../shared/models/event_attendance.dart';
import '../../../shared/theme/app_theme.dart';
import '../widgets/attendance_ui.dart';

class AttendanceSavedScreen extends StatelessWidget {
  const AttendanceSavedScreen({
    super.key,
    required this.eventId,
    this.session,
  });

  final String eventId;
  final AttendanceSession? session;

  @override
  Widget build(BuildContext context) {
    final summary = session?.summary ?? const AttendanceSummaryCounts();

    return Scaffold(
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
                  color: AppColors.present.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Icon(
                      Icons.sports_basketball_rounded,
                      size: 56,
                      color: AppColors.training,
                    ),
                    Positioned(
                      right: 18,
                      bottom: 18,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: AppColors.present,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.check_rounded,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),
              Text(
                'Attendance Saved!',
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Text(
                'Training attendance has been successfully recorded.',
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
                onPressed: () => context.go('/events/$eventId'),
                child: const Text('Done'),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => context.push('/attendance/history'),
                child: const Text('View Attendance History'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
