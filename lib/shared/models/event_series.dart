class SaveEventSeriesRequest {
  const SaveEventSeriesRequest({
    required this.scopeKind,
    required this.type,
    required this.title,
    required this.firstStartLocal,
    required this.durationMin,
    this.scopeId,
    this.purpose,
    this.location,
    this.timeZone,
    this.rrule,
    this.rsvpRequested = false,
    this.visibility,
    this.trainingPlanId,
    this.metricBatteryId,
  });

  final String scopeKind;
  final String? scopeId;
  final String type;
  final String title;
  final String? purpose;
  final String? location;
  final String? timeZone;

  /// Local wall-clock without offset, e.g. `2026-08-22T18:00:00`.
  final String firstStartLocal;
  final int durationMin;
  final String? rrule;
  final bool rsvpRequested;
  final String? visibility;
  final String? trainingPlanId;
  final String? metricBatteryId;

  Map<String, dynamic> toJson() {
    final planId = trainingPlanId;
    final batteryId = metricBatteryId;
    return {
      'scopeKind': scopeKind,
      'scopeId': scopeId,
      'type': type,
      'title': title,
      'purpose': purpose,
      'location': location,
      'timeZone': timeZone,
      'firstStartLocal': firstStartLocal,
      'durationMin': durationMin,
      'rrule': rrule,
      'rsvpRequested': rsvpRequested,
      'visibility': visibility,
      if (planId != null && planId.isNotEmpty) 'trainingPlanId': planId,
      if (batteryId != null && batteryId.isNotEmpty)
        'metricBatteryId': batteryId,
    };
  }
}

class EventSeries {
  const EventSeries({
    required this.id,
    required this.clubId,
    required this.scopeKind,
    required this.scopeId,
    required this.type,
    required this.title,
    required this.timeZone,
    required this.firstStartLocal,
    required this.firstStartUtc,
    required this.durationMin,
    required this.rsvpRequested,
    required this.visibility,
    required this.canceled,
    required this.createdAtUtc,
    this.scopeName,
    this.purpose,
    this.location,
    this.rrule,
    this.trainingPlanId,
    this.metricBatteryId,
    this.metricBatteryName,
  });

  final String id;
  final String clubId;
  final String scopeKind;
  final String scopeId;
  final String? scopeName;
  final String type;
  final String title;
  final String? purpose;
  final String? location;
  final String timeZone;
  final String firstStartLocal;
  final DateTime firstStartUtc;
  final int durationMin;
  final String? rrule;
  final bool rsvpRequested;
  final String visibility;
  final bool canceled;
  final DateTime createdAtUtc;
  final String? trainingPlanId;
  final String? metricBatteryId;
  final String? metricBatteryName;

  factory EventSeries.fromJson(Map<String, dynamic> json) {
    return EventSeries(
      id: json['id']?.toString() ?? '',
      clubId: json['clubId']?.toString() ?? '',
      scopeKind: json['scopeKind'] as String? ?? '',
      scopeId: json['scopeId']?.toString() ?? '',
      scopeName: json['scopeName'] as String?,
      type: json['type'] as String? ?? '',
      title: json['title'] as String? ?? '',
      purpose: json['purpose'] as String?,
      location: json['location'] as String?,
      timeZone: json['timeZone'] as String? ?? '',
      firstStartLocal: json['firstStartLocal'] as String? ?? '',
      firstStartUtc:
          DateTime.tryParse(json['firstStartUtc'] as String? ?? '')?.toUtc() ??
          DateTime.now().toUtc(),
      durationMin: (json['durationMin'] as num?)?.toInt() ?? 0,
      rrule: json['rrule'] as String?,
      rsvpRequested: json['rsvpRequested'] as bool? ?? false,
      visibility: json['visibility'] as String? ?? 'scope',
      canceled: json['canceled'] as bool? ?? false,
      createdAtUtc:
          DateTime.tryParse(json['createdAtUtc'] as String? ?? '')?.toUtc() ??
          DateTime.now().toUtc(),
      trainingPlanId: json['trainingPlanId']?.toString(),
      metricBatteryId: json['metricBatteryId']?.toString(),
      metricBatteryName: json['metricBatteryName'] as String?,
    );
  }
}

/// Formats a local DateTime as wall-clock without offset for `firstStartLocal`.
String formatFirstStartLocal(DateTime local) {
  String two(int n) => n.toString().padLeft(2, '0');
  return '${local.year}-${two(local.month)}-${two(local.day)}'
      'T${two(local.hour)}:${two(local.minute)}:${two(local.second)}';
}

String weekdayToRrule(int weekday) {
  const map = {
    DateTime.monday: 'MO',
    DateTime.tuesday: 'TU',
    DateTime.wednesday: 'WE',
    DateTime.thursday: 'TH',
    DateTime.friday: 'FR',
    DateTime.saturday: 'SA',
    DateTime.sunday: 'SU',
  };
  return map[weekday] ?? 'MO';
}
