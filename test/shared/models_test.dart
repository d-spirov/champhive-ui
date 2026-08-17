import 'package:flutter_test/flutter_test.dart';

import 'package:team_hive/shared/models/user.dart';
import 'package:team_hive/shared/models/club.dart';
import 'package:team_hive/shared/models/event_attendance.dart';

void main() {
  test('User.fromMeJson maps ClubPlatform fields', () {
    final user = User.fromMeJson({
      'id': 'u1',
      'email': 'a@b.com',
      'firstName': 'Ada',
      'lastName': 'Lovelace',
      'locale': 'en',
      'emailVerified': true,
      'emailVerificationPending': false,
      'isPlatformRoot': false,
      'roles': [
        {
          'role': 'coach',
          'clubId': 'c1',
          'scope': 'club',
          'scopeId': 'c1',
        }
      ],
      'fam': <String>[],
      'clubPermissions': [
        {
          'clubId': 'c1',
          'permissions': ['attendance.mark'],
        }
      ],
      'createdAtUtc': '2024-01-01T00:00:00Z',
    });
    expect(user.displayName, 'Ada Lovelace');
    expect(user.emailVerified, isTrue);
    expect(user.clubIds, {'c1'});
    expect(user.rolesForClub('c1'), ['coach']);
  });

  test('Club.fromJson maps ClubResponse fields', () {
    final club = Club.fromJson({
      'id': 'c1',
      'name': 'FC Example',
      'countryCode': 'MK',
      'city': 'Skopje',
      'logoUrl': 'https://cdn.example/logo.png',
      'defaultCurrency': 'EUR',
      'defaultLocale': 'en',
      'timeZone': 'Europe/Skopje',
      'email': 'club@example.com',
      'phone': null,
      'address': null,
      'federationCode': null,
      'settings': null,
      'createdAtUtc': '2024-01-01T00:00:00Z',
    });
    expect(club.name, 'FC Example');
    expect(club.timezone, 'Europe/Skopje');
    expect(club.currency, 'EUR');
    expect(club.hasLogo, isTrue);
  });

  test('ClubEvent.fromOccurrenceJson maps schedule occurrence', () {
    final event = ClubEvent.fromOccurrenceJson({
      'occurrenceId': 'o1',
      'seriesId': 's1',
      'clubId': 'c1',
      'clubName': 'FC Example',
      'scopeKind': 'team',
      'scopeId': 't1',
      'scopeName': 'U12',
      'type': 'training',
      'title': 'Practice',
      'purpose': null,
      'location': 'Hall A',
      'timeZone': 'Europe/Skopje',
      'startsAtUtc': '2024-06-01T16:00:00Z',
      'endsAtUtc': '2024-06-01T17:30:00Z',
      'originalStartUtc': '2024-06-01T16:00:00Z',
      'durationMin': 90,
      'status': 'scheduled',
      'rsvpRequested': false,
      'note': null,
      'isMaterialized': false,
      'relatedMemberIds': <String>[],
    });
    expect(event.id, 'o1');
    expect(event.type, EventType.training);
    expect(event.teams, ['U12']);
    expect(event.location.display, 'Hall A');
  });

  test('Attendance batch entry uses lowercase status', () {
    final update = AttendanceUpdate(
      participantId: 'm1',
      status: AttendanceStatus.present,
      clientRecordId: '11111111-1111-4111-8111-111111111111',
      recordedAtClientUtc: DateTime.utc(2024, 6, 1, 16, 5),
    );
    final entry = update.toBatchEntry(occurrenceId: 'o1');
    expect(entry['status'], 'present');
    expect(entry['memberId'], 'm1');
    expect(entry['occurrenceId'], 'o1');
    expect(entry['clientRecordId'], '11111111-1111-4111-8111-111111111111');
  });
}
