import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:team_hive/features/calendar/schedule_timing.dart';

void main() {
  final now = DateTime(2026, 9, 12, 21, 30);

  test('past calendar days are rejected', () {
    expect(isPastCalendarDay(DateTime(2026, 9, 11), now: now), isTrue);
    expect(isPastCalendarDay(DateTime(2026, 9, 12), now: now), isFalse);
    expect(isPastCalendarDay(DateTime(2026, 9, 13), now: now), isFalse);
  });

  test('past clock times on today are rejected', () {
    expect(isPastEventStart(DateTime(2026, 9, 12, 18, 0), now: now), isTrue);
    expect(isPastEventStart(DateTime(2026, 9, 12, 22, 0), now: now), isFalse);
  });

  test('snap moves a past start to the next hour', () {
    final snapped = snapEventStartToNow(
      date: DateTime(2026, 9, 11),
      time: const TimeOfDay(hour: 18, minute: 0),
      now: now,
    );
    expect(snapped.date, DateTime(2026, 9, 12));
    expect(snapped.time, const TimeOfDay(hour: 22, minute: 0));
  });
}
