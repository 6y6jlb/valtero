import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:valtero/shared/utils/app_timezone.dart';

void main() {
  setUpAll(() {
    tzdata.initializeTimeZones();
  });

  test('calendarWeekKey is Monday of the week in the zone', () {
    // Thursday 2026-01-15 → Monday 2026-01-12
    final key = calendarWeekKey(
      DateTime.utc(2026, 1, 15, 12),
      'UTC',
    );
    expect(key, '2026-01-12');
  });

  test('calendarDayKey formats YYYY-MM-DD', () {
    expect(
      calendarDayKey(DateTime.utc(2026, 3, 5, 8), 'UTC'),
      '2026-03-05',
    );
  });
}
