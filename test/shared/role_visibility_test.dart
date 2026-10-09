import 'package:flutter_test/flutter_test.dart';

import 'package:team_hive/features/shell/app_destinations.dart';
import 'package:team_hive/shared/utils/staff_write_routes.dart';

void main() {
  group('moreManagementRoutes', () {
    test('admin sees members, attendance, stats, payments, documents', () {
      expect(
        moreManagementRoutes(
          isStaff: true,
          isClubAdmin: true,
          showPayments: true,
        ),
        [
          '/members',
          '/attendance/history',
          '/statistics',
          '/payments',
          '/compliance',
        ],
      );
    });

    test('coach sees members and attendance, not club admin menus', () {
      expect(
        moreManagementRoutes(
          isStaff: true,
          isClubAdmin: false,
          showPayments: false,
        ),
        ['/members', '/attendance/history'],
      );
    });

    test('parent sees attendance and personal fees, not members or admin', () {
      expect(
        moreManagementRoutes(
          isStaff: false,
          isClubAdmin: false,
          showPayments: true,
        ),
        ['/attendance/history', '/payments'],
      );
    });

    test('coach+parent keeps members and can also see payments', () {
      expect(
        moreManagementRoutes(
          isStaff: true,
          isClubAdmin: false,
          showPayments: true,
        ),
        ['/members', '/attendance/history', '/payments'],
      );
    });

    test('sectionAdmin is staff, not club admin', () {
      expect(
        moreManagementRoutes(
          isStaff: true,
          isClubAdmin: false,
          showPayments: false,
        ),
        ['/members', '/attendance/history'],
      );
    });
  });

  group('staffWriteRedirect', () {
    test('parent is sent home from staff write routes', () {
      const parent = (
        isStaff: false,
        isClubAdmin: false,
        canWriteMembers: false,
      );
      expect(
        staffWriteRedirect(
          '/schedule/create',
          isStaff: parent.isStaff,
          isClubAdmin: parent.isClubAdmin,
          canWriteMembers: parent.canWriteMembers,
        ),
        '/home',
      );
      expect(
        staffWriteRedirect(
          '/messages/new',
          isStaff: parent.isStaff,
          isClubAdmin: parent.isClubAdmin,
          canWriteMembers: parent.canWriteMembers,
        ),
        '/home',
      );
      expect(
        staffWriteRedirect(
          '/teams/t1/members/add',
          isStaff: parent.isStaff,
          isClubAdmin: parent.isClubAdmin,
          canWriteMembers: parent.canWriteMembers,
        ),
        '/home',
      );
      expect(
        staffWriteRedirect(
          '/occurrences/o1/attendance',
          isStaff: parent.isStaff,
          isClubAdmin: parent.isClubAdmin,
          canWriteMembers: parent.canWriteMembers,
        ),
        '/home',
      );
      expect(
        staffWriteRedirect(
          '/members',
          isStaff: parent.isStaff,
          isClubAdmin: parent.isClubAdmin,
          canWriteMembers: parent.canWriteMembers,
        ),
        '/home',
      );
      expect(
        staffWriteRedirect(
          '/statistics',
          isStaff: parent.isStaff,
          isClubAdmin: parent.isClubAdmin,
          canWriteMembers: parent.canWriteMembers,
        ),
        '/home',
      );
    });

    test('parent may open attendance history and event details', () {
      expect(
        staffWriteRedirect(
          '/attendance/history',
          isStaff: false,
          isClubAdmin: false,
          canWriteMembers: false,
        ),
        isNull,
      );
      expect(
        staffWriteRedirect(
          '/occurrences/o1',
          isStaff: false,
          isClubAdmin: false,
          canWriteMembers: false,
        ),
        isNull,
      );
      expect(
        staffWriteRedirect(
          '/occurrences/o1/attendance/report',
          isStaff: false,
          isClubAdmin: false,
          canWriteMembers: false,
        ),
        isNull,
      );
    });

    test('coach without MEMBER_WRITE cannot open add member', () {
      expect(
        staffWriteRedirect(
          '/teams/t1/members/add',
          isStaff: true,
          isClubAdmin: false,
          canWriteMembers: false,
        ),
        '/home',
      );
      expect(
        staffWriteRedirect(
          '/schedule/create',
          isStaff: true,
          isClubAdmin: false,
          canWriteMembers: false,
        ),
        isNull,
      );
    });

    test('coach with MEMBER_WRITE can open add member', () {
      expect(
        staffWriteRedirect(
          '/teams/t1/members/add',
          isStaff: true,
          isClubAdmin: false,
          canWriteMembers: true,
        ),
        isNull,
      );
    });

    test('admin can open club admin routes', () {
      expect(
        staffWriteRedirect(
          '/statistics',
          isStaff: true,
          isClubAdmin: true,
          canWriteMembers: true,
        ),
        isNull,
      );
      expect(
        staffWriteRedirect(
          '/teams/t1/members/add',
          isStaff: true,
          isClubAdmin: true,
          canWriteMembers: true,
        ),
        isNull,
      );
    });
  });
}
