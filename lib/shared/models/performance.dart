class BatteryMetric {
  const BatteryMetric({
    required this.code,
    required this.name,
    required this.valueKind,
    required this.isRetired,
    this.unit,
  });

  final String code;
  final String name;
  final String? unit;
  final String valueKind;
  final bool isRetired;

  factory BatteryMetric.fromJson(Map<String, dynamic> json) {
    return BatteryMetric(
      code: json['code'] as String? ?? '',
      name: json['name'] as String? ?? json['code'] as String? ?? '',
      unit: json['unit'] as String?,
      valueKind: json['valueKind'] as String? ?? 'scalar',
      isRetired: json['isRetired'] as bool? ?? false,
    );
  }
}

/// Named, ordered set of metrics a testing-day event points at.
class MetricBattery {
  const MetricBattery({
    required this.id,
    required this.clubId,
    required this.sportCode,
    required this.name,
    required this.metrics,
    this.isArchived = false,
  });

  final String id;
  final String clubId;
  final String sportCode;
  final String name;
  final List<BatteryMetric> metrics;
  final bool isArchived;

  factory MetricBattery.fromJson(Map<String, dynamic> json) {
    final raw = json['metrics'];
    final metrics = <BatteryMetric>[];
    if (raw is List) {
      for (final item in raw) {
        if (item is Map) {
          metrics.add(BatteryMetric.fromJson(Map<String, dynamic>.from(item)));
        }
      }
    }
    return MetricBattery(
      id: json['id']?.toString() ?? '',
      clubId: json['clubId']?.toString() ?? '',
      sportCode: json['sportCode'] as String? ?? '',
      name: json['name'] as String? ?? '',
      metrics: metrics,
      isArchived: json['isArchived'] as bool? ?? false,
    );
  }
}

class ClubMetric {
  const ClubMetric({
    required this.code,
    required this.name,
    required this.categoryCode,
    required this.categoryName,
    required this.valueKind,
    required this.isHiddenByClub,
    required this.isGroupRetired,
    this.unit,
  });

  final String code;
  final String name;
  final String categoryCode;
  final String categoryName;
  final String valueKind;
  final String? unit;
  final bool isHiddenByClub;
  final bool isGroupRetired;

  bool get canCollect => !isHiddenByClub && !isGroupRetired;

  factory ClubMetric.fromJson(
    Map<String, dynamic> json, {
    required String categoryCode,
    required String categoryName,
    required bool categoryRetired,
  }) {
    return ClubMetric(
      code: json['code'] as String? ?? '',
      name: json['name'] as String? ?? json['code'] as String? ?? '',
      categoryCode: categoryCode,
      categoryName: categoryName,
      valueKind: json['valueKind'] as String? ?? 'scalar',
      unit: json['unit'] as String?,
      isHiddenByClub: json['isHiddenByClub'] as bool? ?? false,
      isGroupRetired: json['isGroupRetired'] as bool? ?? categoryRetired,
    );
  }
}

class ClubMetricCatalogue {
  const ClubMetricCatalogue({required this.sportCode, required this.metrics});

  final String sportCode;
  final List<ClubMetric> metrics;

  factory ClubMetricCatalogue.fromJson(Map<String, dynamic> json) {
    final sportCode = json['sportCode'] as String? ?? '';
    final metrics = <ClubMetric>[];
    final categories = json['categories'];
    if (categories is List) {
      for (final raw in categories) {
        if (raw is! Map) continue;
        final cat = Map<String, dynamic>.from(raw);
        final categoryCode = cat['code'] as String? ?? '';
        final categoryName = cat['name'] as String? ?? categoryCode;
        final retired = cat['isRetired'] as bool? ?? false;
        final items = cat['metrics'];
        if (items is! List) continue;
        for (final item in items) {
          if (item is Map) {
            metrics.add(
              ClubMetric.fromJson(
                Map<String, dynamic>.from(item),
                categoryCode: categoryCode,
                categoryName: categoryName,
                categoryRetired: retired,
              ),
            );
          }
        }
      }
    }
    return ClubMetricCatalogue(sportCode: sportCode, metrics: metrics);
  }
}

int? _jsonInt(Object? value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value);
  return null;
}

double? _jsonDouble(Object? value) {
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value);
  return null;
}

class MetricOption {
  const MetricOption({required this.code, required this.name});

  final String code;
  final String name;

  factory MetricOption.fromJson(Map<String, dynamic> json) {
    return MetricOption(
      code: json['code'] as String? ?? '',
      name: json['name'] as String? ?? json['code'] as String? ?? '',
    );
  }
}

class RecordedValue {
  const RecordedValue({
    required this.metricCode,
    this.numericValue,
    this.attempted,
    this.made,
    this.optionCode,
    this.textValue,
  });

  final String metricCode;
  final double? numericValue;
  final int? attempted;
  final int? made;
  final String? optionCode;
  final String? textValue;

  factory RecordedValue.fromJson(Map<String, dynamic> json) {
    return RecordedValue(
      metricCode: json['metricCode'] as String? ?? '',
      numericValue: _jsonDouble(json['numericValue']),
      attempted: _jsonInt(json['attempted']),
      made: _jsonInt(json['made']),
      optionCode: json['optionCode'] as String?,
      textValue: json['textValue'] as String?,
    );
  }

  String display({String valueKind = 'scalar'}) {
    switch (valueKind) {
      case 'ratio':
        if (made != null && attempted != null) return '$made / $attempted';
        break;
      case 'choice':
        if (optionCode != null && optionCode!.isNotEmpty) return optionCode!;
        break;
      case 'text':
        if (textValue != null && textValue!.isNotEmpty) return textValue!;
        break;
    }
    if (numericValue != null) {
      final v = numericValue!;
      return v == v.roundToDouble() ? '${v.toInt()}' : '$v';
    }
    return '';
  }
}

class TestingDayStation {
  const TestingDayStation({
    required this.code,
    required this.name,
    required this.valueKind,
    required this.isRetired,
    this.unit,
    this.min,
    this.max,
    this.decimalPlaces = 0,
    this.options = const [],
  });

  final String code;
  final String name;
  final String? unit;
  final String valueKind;
  final bool isRetired;
  final double? min;
  final double? max;
  final int decimalPlaces;
  final List<MetricOption> options;

  bool get canRecord => !isRetired && valueKind != 'unknown';

  factory TestingDayStation.fromJson(Map<String, dynamic> json) {
    final raw = json['options'];
    final options = <MetricOption>[];
    if (raw is List) {
      for (final item in raw) {
        if (item is Map) {
          options.add(MetricOption.fromJson(Map<String, dynamic>.from(item)));
        }
      }
    }
    return TestingDayStation(
      code: json['code'] as String? ?? '',
      name: json['name'] as String? ?? json['code'] as String? ?? '',
      unit: json['unit'] as String?,
      valueKind: json['valueKind'] as String? ?? 'scalar',
      isRetired: json['isRetired'] as bool? ?? false,
      min: _jsonDouble(json['min']),
      max: _jsonDouble(json['max']),
      decimalPlaces: _jsonInt(json['decimalPlaces']) ?? 0,
      options: options,
    );
  }
}

class TestingDayPlayer {
  const TestingDayPlayer({
    required this.memberId,
    required this.firstName,
    required this.lastName,
    this.values = const {},
  });

  final String memberId;
  final String firstName;
  final String lastName;
  final Map<String, RecordedValue> values;

  String get displayName {
    final name = '$firstName $lastName'.trim();
    return name.isEmpty ? memberId : name;
  }

  factory TestingDayPlayer.fromJson(Map<String, dynamic> json) {
    final values = <String, RecordedValue>{};
    final raw = json['values'];
    if (raw is Map) {
      for (final entry in raw.entries) {
        final value = entry.value;
        if (value is Map) {
          final parsed = RecordedValue.fromJson(
            Map<String, dynamic>.from(value),
          );
          values[entry.key.toString()] = parsed;
        }
      }
    }
    return TestingDayPlayer(
      memberId: json['memberId']?.toString() ?? '',
      firstName: json['firstName'] as String? ?? '',
      lastName: json['lastName'] as String? ?? '',
      values: values,
    );
  }
}

class TestingDay {
  const TestingDay({
    required this.occurrenceId,
    required this.batteryId,
    required this.batteryName,
    required this.sportCode,
    required this.stations,
    this.teamId,
    this.date,
    this.hasRoster = false,
    this.players = const [],
  });

  final String occurrenceId;
  final String? teamId;
  final String batteryId;
  final String batteryName;
  final String sportCode;
  final DateTime? date;
  final List<TestingDayStation> stations;
  final List<TestingDayPlayer> players;
  final bool hasRoster;

  int recordedCount(String metricCode) =>
      players.where((p) => p.values.containsKey(metricCode)).length;

  factory TestingDay.fromJson(Map<String, dynamic> json) {
    final stations = <TestingDayStation>[];
    final stationsRaw = json['stations'];
    if (stationsRaw is List) {
      for (final item in stationsRaw) {
        if (item is Map) {
          stations.add(
            TestingDayStation.fromJson(Map<String, dynamic>.from(item)),
          );
        }
      }
    }
    final players = <TestingDayPlayer>[];
    final playersRaw = json['players'];
    if (playersRaw is List) {
      for (final item in playersRaw) {
        if (item is Map) {
          players.add(
            TestingDayPlayer.fromJson(Map<String, dynamic>.from(item)),
          );
        }
      }
    }
    return TestingDay(
      occurrenceId: json['occurrenceId']?.toString() ?? '',
      teamId: json['teamId']?.toString(),
      batteryId: json['batteryId']?.toString() ?? '',
      batteryName: json['batteryName'] as String? ?? '',
      sportCode: json['sportCode'] as String? ?? '',
      date: DateTime.tryParse(json['date'] as String? ?? ''),
      stations: stations,
      players: players,
      hasRoster: json['hasRoster'] as bool? ?? false,
    );
  }
}

class ColumnEntry {
  const ColumnEntry({
    required this.memberId,
    this.number,
    this.attempted,
    this.made,
    this.optionCode,
    this.text,
  });

  final String memberId;
  final double? number;
  final int? attempted;
  final int? made;
  final String? optionCode;
  final String? text;

  Map<String, dynamic> toJson() {
    return {
      'memberId': memberId,
      if (number != null) 'number': number,
      if (attempted != null) 'attempted': attempted,
      if (made != null) 'made': made,
      if (optionCode != null && optionCode!.isNotEmpty)
        'optionCode': optionCode,
      if (text != null && text!.isNotEmpty) 'text': text,
    };
  }
}

class ColumnOutcome {
  const ColumnOutcome({
    required this.memberId,
    required this.recorded,
    this.error,
  });

  final String memberId;
  final bool recorded;
  final String? error;

  factory ColumnOutcome.fromJson(Map<String, dynamic> json) {
    return ColumnOutcome(
      memberId: json['memberId']?.toString() ?? '',
      recorded: json['recorded'] as bool? ?? false,
      error: json['error'] as String?,
    );
  }
}

class ColumnRecorded {
  const ColumnRecorded({required this.outcomes});

  final List<ColumnOutcome> outcomes;

  int get recordedCount => outcomes.where((o) => o.recorded).length;
  List<ColumnOutcome> get failed => outcomes.where((o) => !o.recorded).toList();

  factory ColumnRecorded.fromJson(Map<String, dynamic> json) {
    final raw = json['outcomes'];
    final outcomes = <ColumnOutcome>[];
    if (raw is List) {
      for (final item in raw) {
        if (item is Map) {
          outcomes.add(ColumnOutcome.fromJson(Map<String, dynamic>.from(item)));
        }
      }
    }
    return ColumnRecorded(outcomes: outcomes);
  }
}

class PerformanceSitting {
  const PerformanceSitting({
    required this.id,
    required this.memberId,
    required this.status,
    this.occurrenceId,
    this.assessedOn,
  });

  final String id;
  final String memberId;
  final String status;
  final String? occurrenceId;
  final String? assessedOn;

  factory PerformanceSitting.fromJson(Map<String, dynamic> json) {
    return PerformanceSitting(
      id: json['id']?.toString() ?? json['assessmentId']?.toString() ?? '',
      memberId: json['memberId']?.toString() ?? '',
      status: json['status'] as String? ?? 'draft',
      occurrenceId: json['occurrenceId']?.toString(),
      assessedOn: json['assessedOn'] as String?,
    );
  }
}

class MetricPoint {
  const MetricPoint({required this.on, this.value, this.attempted, this.made});

  final DateTime? on;
  final double? value;
  final int? attempted;
  final int? made;

  factory MetricPoint.fromJson(Map<String, dynamic> json) {
    return MetricPoint(
      on: DateTime.tryParse(json['on'] as String? ?? ''),
      value: _jsonDouble(json['value']),
      attempted: _jsonInt(json['attempted']),
      made: _jsonInt(json['made']),
    );
  }

  String display({String valueKind = 'scalar', int decimalPlaces = 1}) {
    if (valueKind == 'ratio' && made != null && attempted != null) {
      return '$made / $attempted';
    }
    final v = value;
    if (v == null) return '';
    if (decimalPlaces <= 0 && v == v.roundToDouble()) return '${v.toInt()}';
    return v.toStringAsFixed(decimalPlaces);
  }
}

class PlayerMetricHistory {
  const PlayerMetricHistory({
    required this.metricCode,
    required this.name,
    required this.categoryName,
    required this.valueKind,
    required this.decimalPlaces,
    required this.direction,
    this.unit,
    this.latest,
    this.previous,
    this.series = const [],
  });

  final String metricCode;
  final String name;
  final String categoryName;
  final String valueKind;
  final String? unit;
  final int decimalPlaces;
  final String direction;
  final MetricPoint? latest;
  final MetricPoint? previous;
  final List<MetricPoint> series;

  bool get hasValue => latest != null;

  factory PlayerMetricHistory.fromJson(Map<String, dynamic> json) {
    MetricPoint? point(Object? raw) {
      if (raw is Map) {
        return MetricPoint.fromJson(Map<String, dynamic>.from(raw));
      }
      return null;
    }

    final series = <MetricPoint>[];
    final raw = json['series'];
    if (raw is List) {
      for (final item in raw) {
        if (item is Map) {
          series.add(MetricPoint.fromJson(Map<String, dynamic>.from(item)));
        }
      }
    }
    return PlayerMetricHistory(
      metricCode: json['metricCode'] as String? ?? '',
      name: json['name'] as String? ?? json['metricCode'] as String? ?? '',
      categoryName: json['categoryName'] as String? ?? '',
      valueKind: json['valueKind'] as String? ?? 'scalar',
      unit: json['unit'] as String?,
      decimalPlaces: _jsonInt(json['decimalPlaces']) ?? 1,
      direction: json['direction'] as String? ?? '',
      latest: point(json['latest']),
      previous: point(json['previous']),
      series: series,
    );
  }
}

class PlayerPerformance {
  const PlayerPerformance({
    required this.memberId,
    required this.sportCode,
    this.metrics = const [],
  });

  final String memberId;
  final String sportCode;
  final List<PlayerMetricHistory> metrics;

  List<PlayerMetricHistory> get measured =>
      metrics.where((m) => m.hasValue).toList();

  factory PlayerPerformance.fromJson(Map<String, dynamic> json) {
    final metrics = <PlayerMetricHistory>[];
    final raw = json['metrics'];
    if (raw is List) {
      for (final item in raw) {
        if (item is Map) {
          metrics.add(
            PlayerMetricHistory.fromJson(Map<String, dynamic>.from(item)),
          );
        }
      }
    }
    return PlayerPerformance(
      memberId: json['memberId']?.toString() ?? '',
      sportCode: json['sportCode'] as String? ?? '',
      metrics: metrics,
    );
  }
}
