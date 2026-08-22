import 'sport_theme_config.dart';

/// Parses API `sportCode` / section sport strings into a known [SectionSportType].
///
/// Unknown or empty values safely fall back to [SectionSportType.generic].
SectionSportType parseSectionSportType(String? raw) {
  final code = raw?.trim().toLowerCase() ?? '';
  switch (code) {
    case 'basketball':
      return SectionSportType.basketball;
    case 'football':
    case 'soccer':
      return SectionSportType.football;
    case 'volleyball':
      return SectionSportType.volleyball;
    default:
      return SectionSportType.generic;
  }
}

/// Resolves the visual pack for a section sport. Never throws on unknown sports.
SportThemeConfig sportThemeFor(SectionSportType sportType) {
  switch (sportType) {
    case SectionSportType.basketball:
      return kBasketballSportTheme;
    case SectionSportType.football:
      return kFootballSportTheme;
    case SectionSportType.volleyball:
      return kVolleyballSportTheme;
    case SectionSportType.generic:
      return kGenericSportTheme;
  }
}

SportThemeConfig sportThemeForCode(String? sportTypeOrCode) {
  return sportThemeFor(parseSectionSportType(sportTypeOrCode));
}
