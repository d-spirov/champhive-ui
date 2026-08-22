import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/sport_theme_config.dart';
import '../../../core/theme/sport_theme_resolver.dart';
import '../../../shared/models/section.dart';
import '../../auth/providers/auth_provider.dart';
import '../../teams/providers/teams_provider.dart';
import 'clubs_provider.dart';

/// Sections for the currently selected club.
final clubSectionsProvider =
    FutureProvider.autoDispose<List<ClubSection>>((ref) async {
  final auth = ref.watch(authNotifierProvider);
  if (!auth.isAuthenticated || auth.user?.id == 'demo') {
    return const [];
  }
  final clubId = ref.watch(selectedClubProvider)?.id;
  if (clubId == null || clubId.isEmpty) return const [];

  await ref.watch(authApiProvider.future);
  return ref.watch(clubsApiProvider).listSections(clubId);
});

/// Active section for sport theming — derived from the selected club.
///
/// Prefers the section most teams belong to; otherwise the first section.
/// Never invents a parallel "selected sport" state.
final activeSectionProvider = Provider.autoDispose<ClubSection?>((ref) {
  final sections =
      ref.watch(clubSectionsProvider).valueOrNull ?? const <ClubSection>[];
  if (sections.isEmpty) return null;

  final teams = ref.watch(clubTeamsProvider).valueOrNull;
  if (teams != null && teams.isNotEmpty) {
    final counts = <String, int>{};
    for (final team in teams) {
      final sid = team.sectionId;
      if (sid == null || sid.isEmpty) continue;
      counts[sid] = (counts[sid] ?? 0) + 1;
    }
    if (counts.isNotEmpty) {
      final bestId = counts.entries
          .reduce((a, b) => a.value >= b.value ? a : b)
          .key;
      for (final section in sections) {
        if (section.id == bestId) return section;
      }
    }
  }

  return sections.first;
});

/// Sport visual pack for the active section (generic when unknown / missing).
final sportThemeProvider = Provider.autoDispose<SportThemeConfig>((ref) {
  final section = ref.watch(activeSectionProvider);
  return sportThemeForCode(section?.sportType);
});

/// Resolve theme for an explicit section id (e.g. team detail).
final sportThemeForSectionProvider =
    Provider.autoDispose.family<SportThemeConfig, String?>((ref, sectionId) {
  if (sectionId == null || sectionId.isEmpty) {
    return ref.watch(sportThemeProvider);
  }
  final sections =
      ref.watch(clubSectionsProvider).valueOrNull ?? const <ClubSection>[];
  for (final section in sections) {
    if (section.id == sectionId) {
      return sportThemeForCode(section.sportType);
    }
  }
  return ref.watch(sportThemeProvider);
});
