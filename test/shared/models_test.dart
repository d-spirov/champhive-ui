import 'package:flutter_test/flutter_test.dart';

import 'package:team_hive/features/teams/providers/teams_provider.dart';
import 'package:team_hive/shared/models/user.dart';
import 'package:team_hive/shared/models/club.dart';
import 'package:team_hive/shared/models/event_attendance.dart';
import 'package:team_hive/shared/models/family.dart';
import 'package:team_hive/shared/models/compliance.dart';
import 'package:team_hive/shared/models/training_plan.dart';
import 'package:team_hive/shared/models/team.dart';
import 'package:team_hive/shared/models/event_series.dart';
import 'package:team_hive/shared/models/performance.dart';

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
        {'role': 'coach', 'clubId': 'c1', 'scope': 'club', 'scopeId': 'c1'},
      ],
      'fam': <String>[],
      'clubPermissions': [
        {
          'clubId': 'c1',
          'permissions': ['attendance.mark'],
        },
      ],
      'createdAtUtc': '2024-01-01T00:00:00Z',
    });
    expect(user.displayName, 'Ada Lovelace');
    expect(user.emailVerified, isTrue);
    expect(user.clubIds, {'c1'});
    expect(user.rolesForClub('c1'), ['coach']);
    expect(user.hasClubPermission('c1', 'attendance.mark'), isTrue);
    expect(user.hasClubPermission('c1', 'DOCUMENT_VERIFY'), isFalse);
    expect(user.hasClubWideStaffGrant('c1'), isFalse);
    expect(user.staffTeamIdsForClub('c1'), isEmpty);
    expect(user.canWriteMembers('c1'), isFalse);
    expect(user.canSetMemberSectionPolicy('c1', 's1'), isFalse);
  });

  test('clubAdmin can set member section policy; team coach cannot', () {
    const admin = User(
      id: 'u4',
      email: 'admin@b.com',
      firstName: 'Ada',
      lastName: 'Admin',
      roles: [
        RoleGrant(
          role: 'clubAdmin',
          clubId: 'c1',
          scope: 'club',
          scopeId: 'c1',
        ),
      ],
      clubPermissions: [
        ClubPermissions(clubId: 'c1', permissions: ['MEMBER_WRITE']),
      ],
    );
    expect(admin.canWriteMembers('c1'), isTrue);
    expect(admin.canSetMemberSectionPolicy('c1', 's1'), isTrue);

    const coach = User(
      id: 'u2',
      email: 'coach@b.com',
      firstName: 'Ana',
      lastName: 'Coach',
      roles: [
        RoleGrant(role: 'coach', clubId: 'c1', scope: 'team', scopeId: 't1'),
      ],
      clubPermissions: [
        ClubPermissions(clubId: 'c1', permissions: ['MEMBER_WRITE']),
      ],
    );
    expect(coach.canWriteMembers('c1'), isTrue);
    expect(coach.canSetMemberSectionPolicy('c1', 's1'), isFalse);
  });

  test('role visibility: admin, coach, parent, combined, sectionAdmin', () {
    const admin = User(
      id: 'a1',
      email: 'admin@b.com',
      firstName: 'Ada',
      lastName: 'Admin',
      roles: [
        RoleGrant(
          role: 'clubAdmin',
          clubId: 'c1',
          scope: 'club',
          scopeId: 'c1',
        ),
      ],
      clubPermissions: [
        ClubPermissions(clubId: 'c1', permissions: ['MEMBER_WRITE']),
      ],
    );
    expect(admin.isStaff('c1'), isTrue);
    expect(admin.hasClubWideStaffGrant('c1'), isTrue);
    expect(admin.isParent('c1'), isFalse);
    expect(admin.canWriteMembers('c1'), isTrue);
    expect(admin.isStaff(null), isFalse);

    const coach = User(
      id: 'cch',
      email: 'coach@b.com',
      firstName: 'Ana',
      lastName: 'Coach',
      roles: [
        RoleGrant(role: 'coach', clubId: 'c1', scope: 'team', scopeId: 't1'),
      ],
    );
    expect(coach.isStaff('c1'), isTrue);
    expect(coach.hasClubWideStaffGrant('c1'), isFalse);
    expect(coach.canWriteMembers('c1'), isFalse);

    const coachWithWrite = User(
      id: 'cch2',
      email: 'coach2@b.com',
      firstName: 'Ana',
      lastName: 'Coach',
      roles: [
        RoleGrant(role: 'coach', clubId: 'c1', scope: 'team', scopeId: 't1'),
      ],
      clubPermissions: [
        ClubPermissions(clubId: 'c1', permissions: ['MEMBER_WRITE']),
      ],
    );
    expect(coachWithWrite.canWriteMembers('c1'), isTrue);

    const parent = User(
      id: 'p1',
      email: 'parent@b.com',
      firstName: 'Pat',
      lastName: 'Parent',
      roles: [
        RoleGrant(role: 'parent', clubId: 'c1', scope: 'club', scopeId: 'c1'),
      ],
    );
    expect(parent.isStaff('c1'), isFalse);
    expect(parent.hasClubWideStaffGrant('c1'), isFalse);
    expect(parent.isParent('c1'), isTrue);
    expect(parent.canWriteMembers('c1'), isFalse);

    const both = User(
      id: 'both',
      email: 'both@b.com',
      firstName: 'Bo',
      lastName: 'Both',
      roles: [
        RoleGrant(role: 'coach', clubId: 'c1', scope: 'team', scopeId: 't1'),
        RoleGrant(role: 'parent', clubId: 'c1', scope: 'club', scopeId: 'c1'),
      ],
      clubPermissions: [
        ClubPermissions(clubId: 'c1', permissions: ['MEMBER_WRITE']),
      ],
    );
    expect(both.isStaff('c1'), isTrue);
    expect(both.isParent('c1'), isTrue);
    expect(both.hasClubWideStaffGrant('c1'), isFalse);
    expect(both.canWriteMembers('c1'), isTrue);

    const sectionAdmin = User(
      id: 's1',
      email: 'sec@b.com',
      firstName: 'Sam',
      lastName: 'Section',
      roles: [
        RoleGrant(
          role: 'sectionAdmin',
          clubId: 'c1',
          scope: 'section',
          scopeId: 'sec1',
        ),
      ],
    );
    expect(sectionAdmin.isStaff('c1'), isTrue);
    expect(sectionAdmin.hasClubWideStaffGrant('c1'), isFalse);
  });

  test('teamsVisibleToUser keeps only the coach assigned teams', () {
    const coach = User(
      id: 'u2',
      email: 'coach@b.com',
      firstName: 'Ana',
      lastName: 'Coach',
      roles: [
        RoleGrant(role: 'coach', clubId: 'c1', scope: 'club', scopeId: 'c1'),
      ],
    );
    const teams = [
      ClubTeam(
        id: 't1',
        clubId: 'c1',
        name: 'U12',
        sectionId: 's1',
        coaches: [
          TeamCoach(userAccountId: 'u2', name: 'Ana Coach', scopeKind: 'team'),
        ],
      ),
      ClubTeam(
        id: 't2',
        clubId: 'c1',
        name: 'U14',
        sectionId: 's1',
        coaches: [
          TeamCoach(userAccountId: 'u2', name: 'Ana Coach', scopeKind: 'club'),
        ],
      ),
      ClubTeam(id: 't3', clubId: 'c1', name: 'U16', sectionId: 's2'),
    ];
    expect(
      teamsVisibleToUser(teams, user: coach, clubId: 'c1').map((t) => t.id),
      ['t1'],
    );

    const teamScoped = User(
      id: 'u5',
      email: 't@b.com',
      firstName: 'Tea',
      lastName: 'Coach',
      roles: [
        RoleGrant(role: 'coach', clubId: 'c1', scope: 'team', scopeId: 't3'),
      ],
    );
    expect(
      teamsVisibleToUser(
        teams,
        user: teamScoped,
        clubId: 'c1',
      ).map((t) => t.id),
      ['t3'],
    );

    const sectionAdmin = User(
      id: 'u3',
      email: 'sec@b.com',
      firstName: 'Sek',
      lastName: 'Admin',
      roles: [
        RoleGrant(
          role: 'sectionAdmin',
          clubId: 'c1',
          scope: 'section',
          scopeId: 's1',
        ),
      ],
    );
    expect(
      teamsVisibleToUser(
        teams,
        user: sectionAdmin,
        clubId: 'c1',
      ).map((t) => t.id),
      ['t1', 't2'],
    );

    const admin = User(
      id: 'u4',
      email: 'admin@b.com',
      firstName: 'Ada',
      lastName: 'Admin',
      roles: [
        RoleGrant(
          role: 'clubAdmin',
          clubId: 'c1',
          scope: 'club',
          scopeId: 'c1',
        ),
      ],
    );
    expect(teamsVisibleToUser(teams, user: admin, clubId: 'c1'), teams);

    const parent = User(
      id: 'p1',
      email: 'parent@b.com',
      firstName: 'Pat',
      lastName: 'Parent',
      roles: [
        RoleGrant(role: 'parent', clubId: 'c1', scope: 'club', scopeId: 'c1'),
      ],
    );
    expect(
      teamsVisibleToUser(teams, user: parent, clubId: 'c1').map((t) => t.id),
      isEmpty,
    );
    expect(
      teamsVisibleToUser(
        teams,
        user: parent,
        clubId: 'c1',
        familyTeams: const [
          ClubTeam(id: 't2', clubId: 'c1', name: 'U14', sectionId: 's1'),
        ],
      ).map((t) => t.id),
      ['t2'],
    );
    expect(
      teamsVisibleToUser(
        const [],
        user: parent,
        clubId: 'c1',
        familyTeams: const [
          ClubTeam(id: 't2', clubId: 'c1', name: 'U14', sectionId: 's1'),
        ],
      ).map((t) => t.id),
      ['t2'],
    );

    const both = User(
      id: 'both',
      email: 'both@b.com',
      firstName: 'Bo',
      lastName: 'Both',
      roles: [
        RoleGrant(role: 'coach', clubId: 'c1', scope: 'team', scopeId: 't3'),
        RoleGrant(role: 'parent', clubId: 'c1', scope: 'club', scopeId: 'c1'),
      ],
    );
    expect(
      teamsVisibleToUser(
        teams,
        user: both,
        clubId: 'c1',
        familyTeams: const [
          ClubTeam(id: 't1', clubId: 'c1', name: 'U12', sectionId: 's1'),
        ],
      ).map((t) => t.id),
      ['t1', 't3'],
    );
  });

  test('clubTeamsFromChildren keeps one row per child team in the club', () {
    final children = [
      FamilyChild(
        memberId: 'm1',
        firstName: 'A',
        lastName: 'B',
        dateOfBirth: DateTime(2012, 1, 1),
        status: 'Active',
        clubId: 'c1',
        clubName: 'Club',
        hasActiveEnrollment: true,
        consentGranted: true,
        isSelf: false,
        teamId: 't1',
        teamName: 'M16',
        sectionId: 's1',
      ),
      FamilyChild(
        memberId: 'm2',
        firstName: 'C',
        lastName: 'D',
        dateOfBirth: DateTime(2014, 1, 1),
        status: 'Active',
        clubId: 'c1',
        clubName: 'Club',
        hasActiveEnrollment: true,
        consentGranted: true,
        isSelf: false,
        teamId: 't1',
        teamName: 'M16',
        sectionId: 's1',
      ),
      FamilyChild(
        memberId: 'm3',
        firstName: 'E',
        lastName: 'F',
        dateOfBirth: DateTime(2010, 1, 1),
        status: 'Active',
        clubId: 'other',
        clubName: 'Other',
        hasActiveEnrollment: true,
        consentGranted: true,
        isSelf: false,
        teamId: 'tx',
        teamName: 'Skip',
      ),
    ];
    final teams = clubTeamsFromChildren(children, 'c1');
    expect(teams, hasLength(1));
    expect(teams.single.id, 't1');
    expect(teams.single.name, 'M16');
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
    expect(event.clubName, 'FC Example');
    expect(event.scopeKind, 'team');
    expect(event.durationMin, 90);
    expect(event.rsvpRequested, isFalse);
    expect(event.coaches, isEmpty);
    expect(event.purpose, isNull);
  });

  test(
    'ClubEvent.fromOccurrenceJson maps coaches, purpose and training plan',
    () {
      final event = ClubEvent.fromOccurrenceJson({
        'occurrenceId': 'o2',
        'clubId': 'c1',
        'type': 'training',
        'title': 'Tactics',
        'purpose': 'Pressing drill',
        'note': 'Moved indoors',
        'location': 'Hall B',
        'startsAtUtc': '2024-06-01T16:00:00Z',
        'endsAtUtc': '2024-06-01T17:00:00Z',
        'originalStartUtc': '2024-06-01T15:00:00Z',
        'durationMin': 60,
        'status': 'moved',
        'rsvpRequested': true,
        'coaches': [
          {'name': 'Ana Coach', 'userAccountId': 'u9', 'scopeKind': 'team'},
        ],
        'trainingPlanName': 'U12 block 3',
      });
      expect(event.purpose, 'Pressing drill');
      expect(event.note, 'Moved indoors');
      expect(event.rsvpRequested, isTrue);
      expect(event.coaches.single.name, 'Ana Coach');
      expect(event.trainingPlanName, 'U12 block 3');
      expect(event.wasMoved, isTrue);
      expect(event.resolvedDurationMin, 60);
    },
  );

  test('ClubEvent.fromOccurrenceJson maps testing type', () {
    final event = ClubEvent.fromOccurrenceJson({
      'occurrenceId': 'o3',
      'clubId': 'c1',
      'type': 'testing',
      'title': 'U16 physical',
      'startsAtUtc': '2024-06-01T16:00:00Z',
      'metricBatteryName': 'U16 physical',
    });
    expect(event.type, EventType.testing);
    expect(event.metricBatteryName, 'U16 physical');
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

  test('MemberCompliance.fromJson maps requirements', () {
    final picture = MemberCompliance.fromJson({
      'memberId': 'm1',
      'memberName': 'Kid',
      'clubId': 'c1',
      'status': 'missing',
      'requirements': [
        {
          'documentTypeId': 't1',
          'code': 'medical-cert',
          'name': 'Medical certificate',
          'required': true,
          'validityMonths': 12,
          'satisfied': false,
          'expiresOn': null,
          'latestDocument': null,
        },
      ],
    });
    expect(picture.status, 'missing');
    expect(picture.requirements.single.isRequired, isTrue);
    expect(picture.requirements.single.satisfied, isFalse);
  });

  test('TrainingPlan.fromJson maps drills and attached images', () {
    final plan = TrainingPlan.fromJson({
      'id': 'p1',
      'clubId': 'c1',
      'name': 'U12 pressing',
      'description': 'High press',
      'durationMinutes': '90',
      'totalExerciseMinutes': 75,
      'authorUserId': 'u1',
      'teamName': 'U12',
      'exercises': [
        {
          'id': 'slot1',
          'exerciseId': 'ex1',
          'exerciseName': 'Rondo',
          'purpose': 'Warm-up',
          'position': 1,
          'durationMinutes': 15,
          'repetitions': '3x',
          'images': [
            {
              'id': 'img1',
              'exerciseId': 'ex1',
              'contentType': 'image/jpeg',
              'sizeBytes': 12000,
              'position': 0,
            },
          ],
        },
      ],
    });
    expect(plan.name, 'U12 pressing');
    expect(plan.durationMinutes, 90);
    expect(plan.exercises.single.exerciseName, 'Rondo');
    expect(plan.exercises.single.images.single.id, 'img1');
  });

  test('TeamRosterEntry.shortDisplayName uses first name and last initial', () {
    const filip = TeamRosterEntry(
      memberId: 'm1',
      firstName: 'Filip',
      lastName: 'Angelov',
      status: 'active',
      shirtNumber: '12',
    );
    expect(filip.shortDisplayName, 'Filip A.');
    expect(filip.displayName, 'Filip Angelov');

    const firstOnly = TeamRosterEntry(
      memberId: 'm2',
      firstName: 'Ana',
      lastName: '',
      status: 'active',
    );
    expect(firstOnly.shortDisplayName, 'Ana');
  });

  test('parseEventType maps testing', () {
    expect(parseEventType('testing'), EventType.testing);
    expect(EventType.testing.apiValue, 'testing');
  });

  test('SaveEventSeriesRequest sends metricBatteryId for testing', () {
    const request = SaveEventSeriesRequest(
      scopeKind: 'team',
      scopeId: 't1',
      type: 'testing',
      title: 'U14 physical',
      firstStartLocal: '2026-09-02T17:00:00',
      durationMin: 90,
      metricBatteryId: 'b1',
    );
    final json = request.toJson();
    expect(json['type'], 'testing');
    expect(json['metricBatteryId'], 'b1');
    expect(json.containsKey('trainingPlanId'), isFalse);
  });

  test('MetricBattery.fromJson maps stations in order', () {
    final battery = MetricBattery.fromJson({
      'id': 'b1',
      'clubId': 'c1',
      'sportCode': 'football',
      'name': 'U16 physical',
      'isArchived': false,
      'metrics': [
        {
          'code': 'sprint_10m',
          'name': '10m sprint',
          'unit': 's',
          'valueKind': 'scalar',
          'isRetired': false,
        },
        {
          'code': 'yo_yo',
          'name': 'Yo-Yo',
          'valueKind': 'scalar',
          'isRetired': true,
        },
      ],
    });
    expect(battery.name, 'U16 physical');
    expect(battery.metrics.map((m) => m.code).toList(), [
      'sprint_10m',
      'yo_yo',
    ]);
    expect(battery.metrics.last.isRetired, isTrue);
  });

  test('TestingDay.fromJson maps players and recorded values', () {
    final day = TestingDay.fromJson({
      'occurrenceId': 'o1',
      'teamId': 't1',
      'batteryId': 'b1',
      'batteryName': 'U16 physical',
      'sportCode': 'football',
      'date': '2026-09-02',
      'hasRoster': true,
      'stations': [
        {
          'code': 'sprint_10m',
          'name': '10m sprint',
          'unit': 's',
          'valueKind': 'scalar',
          'decimalPlaces': 2,
          'isRetired': false,
          'options': <Map<String, dynamic>>[],
        },
      ],
      'players': [
        {
          'memberId': 'm1',
          'firstName': 'Ana',
          'lastName': 'Kovač',
          'values': {
            'sprint_10m': {'metricCode': 'sprint_10m', 'numericValue': 1.72},
          },
        },
        {
          'memberId': 'm2',
          'firstName': 'Leo',
          'lastName': 'N.',
          'values': <String, dynamic>{},
        },
      ],
    });
    expect(day.players, hasLength(2));
    expect(day.recordedCount('sprint_10m'), 1);
    expect(day.players.first.values['sprint_10m']!.numericValue, 1.72);
    expect(day.stations.single.canRecord, isTrue);
  });

  test('PlayerPerformance.fromJson maps latest values', () {
    final history = PlayerPerformance.fromJson({
      'memberId': 'm1',
      'sportCode': 'football',
      'sittings': <Map<String, dynamic>>[],
      'metrics': [
        {
          'metricCode': 'sprint_10m',
          'name': '10m sprint',
          'categoryCode': 'physical',
          'categoryName': 'Physical',
          'valueKind': 'scalar',
          'unit': 's',
          'decimalPlaces': 2,
          'direction': 'lower_is_better',
          'isHiddenByClub': false,
          'isGroupRetired': false,
          'latest': {'on': '2026-09-02', 'value': 1.72},
          'previous': null,
          'series': [
            {'on': '2026-09-02', 'value': 1.72},
          ],
        },
      ],
    });
    expect(history.measured, hasLength(1));
    expect(history.measured.single.latest!.value, 1.72);
    expect(
      history.measured.single.latest!.display(
        valueKind: 'scalar',
        decimalPlaces: 2,
      ),
      '1.72',
    );
  });

  test('ClubSeason.fromJson maps current window', () {
    final season = ClubSeason.fromJson({
      'id': 's1',
      'clubId': 'c1',
      'label': '2026/2027',
      'startsOn': '2026-08-01',
      'endsOn': '2027-06-30',
    });
    expect(season.label, '2026/2027');
    expect(season.contains(DateTime(2026, 9, 12)), isTrue);
    expect(season.contains(DateTime(2026, 7, 1)), isFalse);
  });
}
