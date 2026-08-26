import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../l10n/app_localizations.dart';
import '../../../shared/l10n/label_l10n.dart';
import '../../../shared/models/training_plan.dart';
import '../../../shared/theme/app_theme.dart';
import '../../../shared/utils/api_error_message.dart';
import '../../../shared/widgets/ui_bits.dart';
import '../providers/training_plans_provider.dart';

enum TrainingPlanPanelMode { summary, exercises }

class TrainingPlanPanel extends ConsumerWidget {
  const TrainingPlanPanel({
    super.key,
    required this.planId,
    this.fallbackName,
    this.mode = TrainingPlanPanelMode.summary,
  });

  final String planId;
  final String? fallbackName;
  final TrainingPlanPanelMode mode;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final async = ref.watch(trainingPlanDetailProvider(planId));

    return async.when(
      loading: () => const Padding(
        padding: EdgeInsets.symmetric(vertical: 12),
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => AppCard(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              fallbackName?.trim().isNotEmpty == true
                  ? fallbackName!.trim()
                  : l10n.trainingPlan,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              apiErrorMessage(e, fallback: l10n.couldNotLoadTrainingPlan),
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
      data: (plan) => mode == TrainingPlanPanelMode.exercises
          ? _ExercisesBody(plan: plan)
          : _PlanSummaryBody(plan: plan),
    );
  }
}

class _PlanSummaryBody extends StatelessWidget {
  const _PlanSummaryBody({required this.plan});

  final TrainingPlan plan;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final scope = [
      if ((plan.teamName ?? '').isNotEmpty) plan.teamName!,
      if ((plan.sectionName ?? '').isNotEmpty) plan.sectionName!,
    ].join(' · ');

    return AppCard(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(plan.name, style: Theme.of(context).textTheme.titleMedium),
          if (scope.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(scope, style: Theme.of(context).textTheme.bodySmall),
          ],
          const SizedBox(height: 6),
          Text(
            l10n.trainingPlanDurationSummary(
              durationMinutesLabel(l10n, plan.durationMinutes),
              durationMinutesLabel(l10n, plan.totalExerciseMinutes),
            ),
            style: Theme.of(context).textTheme.bodySmall,
          ),
          if ((plan.description ?? '').trim().isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(plan.description!.trim()),
          ],
        ],
      ),
    );
  }
}

class _ExercisesBody extends StatelessWidget {
  const _ExercisesBody({required this.plan});

  final TrainingPlan plan;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    if (plan.exercises.isEmpty) {
      return Center(child: Text(l10n.noExercisesInPlan));
    }
    return Column(
      children: [
        for (final exercise in plan.exercises) ...[
          _ExerciseCard(exercise: exercise),
          const SizedBox(height: 10),
        ],
      ],
    );
  }
}

class _ExerciseCard extends StatelessWidget {
  const _ExerciseCard({required this.exercise});

  final PlanExercise exercise;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final meta = [
      if (exercise.durationMinutes > 0)
        durationMinutesLabel(l10n, exercise.durationMinutes),
      if ((exercise.repetitions ?? '').trim().isNotEmpty)
        l10n.repetitionsValue(exercise.repetitions!.trim()),
    ].join(' · ');

    return AppCard(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            exercise.exerciseName,
            style: Theme.of(context).textTheme.titleSmall,
          ),
          if (meta.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(meta, style: Theme.of(context).textTheme.bodySmall),
          ],
          if ((exercise.purpose ?? '').trim().isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(exercise.purpose!.trim()),
          ],
          if ((exercise.description ?? '').trim().isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              exercise.description!.trim(),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
          if ((exercise.notes ?? '').trim().isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              '${l10n.note}: ${exercise.notes!.trim()}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
          if ((exercise.videoUrl ?? '').trim().isNotEmpty) ...[
            const SizedBox(height: 6),
            TextButton.icon(
              onPressed: () {
                final uri = Uri.tryParse(exercise.videoUrl!.trim());
                if (uri != null) {
                  launchUrl(uri, mode: LaunchMode.externalApplication);
                }
              },
              icon: const Icon(Icons.play_circle_outline_rounded, size: 18),
              label: Text(l10n.watchVideo),
            ),
          ],
          if (exercise.images.isNotEmpty) ...[
            const SizedBox(height: 10),
            SizedBox(
              height: 88,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: exercise.images.length,
                separatorBuilder: (_, _) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  return ExerciseImageThumb(image: exercise.images[index]);
                },
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class ExerciseImageThumb extends ConsumerWidget {
  const ExerciseImageThumb({super.key, required this.image});

  final ExerciseImage image;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(exerciseImageBytesProvider(image.id));
    return Material(
      color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.08),
      borderRadius: BorderRadius.circular(AppTheme.radiusSm),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          final bytes = async.valueOrNull;
          if (bytes == null || bytes.isEmpty) return;
          showDialog<void>(
            context: context,
            builder: (context) {
              return Dialog(
                insetPadding: const EdgeInsets.all(16),
                child: InteractiveViewer(
                  child: Image.memory(bytes, fit: BoxFit.contain),
                ),
              );
            },
          );
        },
        child: SizedBox(
          width: 88,
          height: 88,
          child: async.when(
            loading: () => const Center(
              child: SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
            error: (_, _) => Icon(
              Icons.broken_image_outlined,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            data: (bytes) {
              if (bytes == null || bytes.isEmpty) {
                return Icon(
                  Icons.image_outlined,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                );
              }
              return Image.memory(bytes, fit: BoxFit.cover);
            },
          ),
        ),
      ),
    );
  }
}
