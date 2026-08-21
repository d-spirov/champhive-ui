import 'payment.dart';

class MembershipPeriod {
  const MembershipPeriod({
    required this.period,
    required this.active,
    required this.joined,
    required this.left,
  });

  final String period;
  final int active;
  final int joined;
  final int left;

  factory MembershipPeriod.fromJson(Map<String, dynamic> json) {
    return MembershipPeriod(
      period: json['period'] as String? ?? '',
      active: (json['active'] as num?)?.toInt() ?? 0,
      joined: (json['joined'] as num?)?.toInt() ?? 0,
      left: (json['left'] as num?)?.toInt() ?? 0,
    );
  }
}

class MembershipAnalytics {
  const MembershipAnalytics({
    required this.clubId,
    required this.asOf,
    required this.trend,
    required this.activeNow,
    required this.joinedInWindow,
    required this.leftInWindow,
    required this.registeredCount,
    required this.unenrolledCount,
  });

  final String clubId;
  final DateTime? asOf;
  final List<MembershipPeriod> trend;
  final int activeNow;
  final int joinedInWindow;
  final int leftInWindow;
  final int registeredCount;
  final int unenrolledCount;

  factory MembershipAnalytics.fromJson(Map<String, dynamic> json) {
    final trend = <MembershipPeriod>[];
    final raw = json['trend'];
    if (raw is List) {
      for (final e in raw) {
        if (e is Map) {
          trend.add(MembershipPeriod.fromJson(Map<String, dynamic>.from(e)));
        }
      }
    }
    return MembershipAnalytics(
      clubId: json['clubId']?.toString() ?? '',
      asOf: DateTime.tryParse(json['asOf'] as String? ?? ''),
      trend: trend,
      activeNow: (json['activeNow'] as num?)?.toInt() ?? 0,
      joinedInWindow: (json['joinedInWindow'] as num?)?.toInt() ?? 0,
      leftInWindow: (json['leftInWindow'] as num?)?.toInt() ?? 0,
      registeredCount: (json['registeredCount'] as num?)?.toInt() ?? 0,
      unenrolledCount: (json['unenrolledCount'] as num?)?.toInt() ?? 0,
    );
  }
}

class RevenueTotals {
  const RevenueTotals({
    required this.expected,
    required this.collected,
    required this.waived,
    required this.outstanding,
    required this.cashCollected,
    required this.bankCollected,
    required this.memberCount,
    required this.membersInDebt,
    this.collectionRate,
  });

  final double expected;
  final double collected;
  final double waived;
  final double outstanding;
  final double? collectionRate;
  final double cashCollected;
  final double bankCollected;
  final int memberCount;
  final int membersInDebt;

  factory RevenueTotals.fromJson(Map<String, dynamic> json) {
    return RevenueTotals(
      expected: MoneyAmount.parse(json['expected']),
      collected: MoneyAmount.parse(json['collected']),
      waived: MoneyAmount.parse(json['waived']),
      outstanding: MoneyAmount.parse(json['outstanding']),
      collectionRate: json['collectionRate'] == null
          ? null
          : MoneyAmount.parse(json['collectionRate']),
      cashCollected: MoneyAmount.parse(json['cashCollected']),
      bankCollected: MoneyAmount.parse(json['bankCollected']),
      memberCount: (json['memberCount'] as num?)?.toInt() ?? 0,
      membersInDebt: (json['membersInDebt'] as num?)?.toInt() ?? 0,
    );
  }
}

class RevenuePeriod {
  const RevenuePeriod({
    required this.period,
    required this.expected,
    required this.collected,
    required this.waived,
    required this.outstanding,
  });

  final String period;
  final double expected;
  final double collected;
  final double waived;
  final double outstanding;

  factory RevenuePeriod.fromJson(Map<String, dynamic> json) {
    return RevenuePeriod(
      period: json['period'] as String? ?? '',
      expected: MoneyAmount.parse(json['expected']),
      collected: MoneyAmount.parse(json['collected']),
      waived: MoneyAmount.parse(json['waived']),
      outstanding: MoneyAmount.parse(json['outstanding']),
    );
  }
}

class RevenueAging {
  const RevenueAging({
    required this.current,
    required this.days1To30,
    required this.days31To60,
    required this.days61To90,
    required this.days90Plus,
  });

  final double current;
  final double days1To30;
  final double days31To60;
  final double days61To90;
  final double days90Plus;

  double get total =>
      current + days1To30 + days31To60 + days61To90 + days90Plus;

  factory RevenueAging.fromJson(Map<String, dynamic> json) {
    return RevenueAging(
      current: MoneyAmount.parse(json['current']),
      days1To30: MoneyAmount.parse(json['days1To30']),
      days31To60: MoneyAmount.parse(json['days31To60']),
      days61To90: MoneyAmount.parse(json['days61To90']),
      days90Plus: MoneyAmount.parse(json['days90Plus']),
    );
  }
}

class RevenueBreakdown {
  const RevenueBreakdown({
    required this.id,
    required this.name,
    required this.expected,
    required this.collected,
    required this.waived,
    required this.outstanding,
    required this.memberCount,
  });

  final String id;
  final String name;
  final double expected;
  final double collected;
  final double waived;
  final double outstanding;
  final int memberCount;

  factory RevenueBreakdown.fromJson(Map<String, dynamic> json) {
    return RevenueBreakdown(
      id: json['id']?.toString() ?? '',
      name: json['name'] as String? ?? '',
      expected: MoneyAmount.parse(json['expected']),
      collected: MoneyAmount.parse(json['collected']),
      waived: MoneyAmount.parse(json['waived']),
      outstanding: MoneyAmount.parse(json['outstanding']),
      memberCount: (json['memberCount'] as num?)?.toInt() ?? 0,
    );
  }
}

class RevenueAnalytics {
  const RevenueAnalytics({
    required this.clubId,
    required this.currency,
    required this.asOf,
    required this.totals,
    required this.trend,
    required this.aging,
    required this.sections,
    required this.teams,
    required this.generatedAtUtc,
  });

  final String clubId;
  final String currency;
  final DateTime? asOf;
  final RevenueTotals totals;
  final List<RevenuePeriod> trend;
  final RevenueAging aging;
  final List<RevenueBreakdown> sections;
  final List<RevenueBreakdown> teams;
  final DateTime generatedAtUtc;

  factory RevenueAnalytics.fromJson(Map<String, dynamic> json) {
    final trend = <RevenuePeriod>[];
    final tRaw = json['trend'];
    if (tRaw is List) {
      for (final e in tRaw) {
        if (e is Map) {
          trend.add(RevenuePeriod.fromJson(Map<String, dynamic>.from(e)));
        }
      }
    }
    final sections = <RevenueBreakdown>[];
    final sRaw = json['sections'];
    if (sRaw is List) {
      for (final e in sRaw) {
        if (e is Map) {
          sections.add(RevenueBreakdown.fromJson(Map<String, dynamic>.from(e)));
        }
      }
    }
    final teams = <RevenueBreakdown>[];
    final tmRaw = json['teams'];
    if (tmRaw is List) {
      for (final e in tmRaw) {
        if (e is Map) {
          teams.add(RevenueBreakdown.fromJson(Map<String, dynamic>.from(e)));
        }
      }
    }
    final totalsRaw = json['totals'];
    final agingRaw = json['aging'];
    return RevenueAnalytics(
      clubId: json['clubId']?.toString() ?? '',
      currency: json['currency'] as String? ?? '',
      asOf: DateTime.tryParse(json['asOf'] as String? ?? ''),
      totals: totalsRaw is Map
          ? RevenueTotals.fromJson(Map<String, dynamic>.from(totalsRaw))
          : const RevenueTotals(
              expected: 0,
              collected: 0,
              waived: 0,
              outstanding: 0,
              cashCollected: 0,
              bankCollected: 0,
              memberCount: 0,
              membersInDebt: 0,
            ),
      trend: trend,
      aging: agingRaw is Map
          ? RevenueAging.fromJson(Map<String, dynamic>.from(agingRaw))
          : const RevenueAging(
              current: 0,
              days1To30: 0,
              days31To60: 0,
              days61To90: 0,
              days90Plus: 0,
            ),
      sections: sections,
      teams: teams,
      generatedAtUtc:
          DateTime.tryParse(json['generatedAtUtc'] as String? ?? '')?.toUtc() ??
              DateTime.now().toUtc(),
    );
  }
}
