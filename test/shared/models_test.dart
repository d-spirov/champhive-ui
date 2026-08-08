import 'package:flutter_test/flutter_test.dart';

import 'package:team_hive/shared/models/user.dart';
import 'package:team_hive/shared/models/club.dart';

void main() {
  test('User.fromJson maps ChampHive fields', () {
    final user = User.fromJson({
      'id': 'u1',
      'email': 'a@b.com',
      'firstName': 'Ada',
      'lastName': 'Lovelace',
      'phone': null,
      'status': 'ACTIVE',
      'emailVerified': true,
    });
    expect(user.displayName, 'Ada Lovelace');
    expect(user.emailVerified, isTrue);
  });

  test('ClubSummary.fromJson maps roles list', () {
    final club = ClubSummary.fromJson({
      'id': 'c1',
      'name': 'FC Example',
      'sportType': 'FOOTBALL',
      'city': 'Skopje',
      'currentUserRoles': ['CLUB_ADMIN', 'TRAINER'],
      'hasLogo': false,
    });
    expect(club.name, 'FC Example');
    expect(club.currentUserRoles, ['CLUB_ADMIN', 'TRAINER']);
  });
}
