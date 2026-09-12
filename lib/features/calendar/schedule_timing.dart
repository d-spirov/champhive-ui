import 'package:flutter/material.dart';

DateTime dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

bool isPastCalendarDay(DateTime day, {DateTime? now}) {
  final n = now ?? DateTime.now();
  return dateOnly(day).isBefore(dateOnly(n));
}

bool isPastEventStart(DateTime start, {DateTime? now}) {
  return start.isBefore(now ?? DateTime.now());
}

DateTime eventStartAt(DateTime date, TimeOfDay time) {
  return DateTime(date.year, date.month, date.day, time.hour, time.minute);
}

/// Moves a start that is already in the past up to the next whole hour.
({DateTime date, TimeOfDay time}) snapEventStartToNow({
  required DateTime date,
  required TimeOfDay time,
  DateTime? now,
}) {
  final n = now ?? DateTime.now();
  var day = dateOnly(date);
  final today = dateOnly(n);
  if (day.isBefore(today)) {
    day = today;
  }
  var start = DateTime(day.year, day.month, day.day, time.hour, time.minute);
  if (!start.isBefore(n)) {
    return (date: day, time: time);
  }
  final bumped = DateTime(
    n.year,
    n.month,
    n.day,
    n.hour,
  ).add(const Duration(hours: 1));
  return (
    date: dateOnly(bumped),
    time: TimeOfDay(hour: bumped.hour, minute: 0),
  );
}
