import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:team_hive/features/more/screens/about_screen.dart';
import 'package:team_hive/features/more/screens/about_topic_screen.dart';
import 'package:team_hive/l10n/app_localizations.dart';

Widget _wrap(Widget child) {
  return MaterialApp(
    locale: const Locale('en'),
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: child,
  );
}

void main() {
  testWidgets('About screen shows localized intro and three topic links', (
    tester,
  ) async {
    await tester.pumpWidget(_wrap(const AboutScreen()));

    expect(find.text('About ChampHive'), findsOneWidget);
    expect(find.text('ChampHive'), findsOneWidget);
    expect(find.text('Manage. Inspire. Win together.'), findsOneWidget);
    expect(find.text('Our Mission'), findsOneWidget);
    expect(find.text('Built for Teams'), findsOneWidget);
    expect(find.text('Your Data Matters'), findsOneWidget);
    expect(find.textContaining('all-in-one platform'), findsOneWidget);
  });

  testWidgets('Mission topic screen shows localized body', (tester) async {
    await tester.pumpWidget(
      _wrap(const AboutTopicScreen(topic: AboutTopic.mission)),
    );

    expect(find.text('Our Mission'), findsWidgets);
    expect(find.textContaining('energy on the pitch'), findsOneWidget);
  });
}
