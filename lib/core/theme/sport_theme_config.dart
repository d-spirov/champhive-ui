import 'package:flutter/material.dart';

/// Known sports with dedicated visual packs. Unknown API codes map to [generic].
enum SectionSportType {
  basketball,
  football,
  volleyball,
  generic,
}

/// Lightweight sport visual pack — does not change ChampHive brand colors.
class SportThemeConfig {
  const SportThemeConfig({
    required this.name,
    required this.icon,
    required this.heroImage,
    required this.eventImage,
    required this.backgroundImage,
  });

  final String name;
  final IconData icon;
  final String heroImage;
  final String eventImage;
  final String backgroundImage;
}

const SportThemeConfig kBasketballSportTheme = SportThemeConfig(
  name: 'Basketball',
  icon: Icons.sports_basketball_rounded,
  heroImage: 'assets/images/sports/basketball/hero.jpg',
  eventImage: 'assets/images/sports/basketball/event.jpg',
  backgroundImage: 'assets/images/sports/basketball/background.jpg',
);

const SportThemeConfig kFootballSportTheme = SportThemeConfig(
  name: 'Football',
  icon: Icons.sports_soccer_rounded,
  heroImage: 'assets/images/sports/football/hero.jpg',
  eventImage: 'assets/images/sports/football/event.jpg',
  backgroundImage: 'assets/images/sports/football/background.jpg',
);

const SportThemeConfig kVolleyballSportTheme = SportThemeConfig(
  name: 'Volleyball',
  icon: Icons.sports_volleyball_rounded,
  heroImage: 'assets/images/sports/volleyball/hero.jpg',
  eventImage: 'assets/images/sports/volleyball/event.jpg',
  backgroundImage: 'assets/images/sports/volleyball/background.jpg',
);

const SportThemeConfig kGenericSportTheme = SportThemeConfig(
  name: 'Sport',
  icon: Icons.sports_outlined,
  heroImage: 'assets/images/sports/generic/hero.jpg',
  eventImage: 'assets/images/sports/generic/event.jpg',
  backgroundImage: 'assets/images/sports/generic/background.jpg',
);

/// Sport-neutral login / welcome imagery (no active section yet).
const String kCommonWelcomeImage = 'assets/images/common/welcome.jpg';
