import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:team_hive/app.dart';
import 'package:team_hive/shared/widgets/team_hive_logo.dart';

void main() {
  testWidgets('App boots to splash', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: App()));
    expect(find.byType(TeamHiveLogo), findsOneWidget);
    await tester.pump();
  });
}
