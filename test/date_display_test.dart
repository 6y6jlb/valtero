import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:valtero/shared/utils/date_display.dart';

void main() {
  setUpAll(() {
    tzdata.initializeTimeZones();
  });

  group('formatDateDisplay', () {
    // 2026-01-15 12:00 UTC
    final instant = DateTime.utc(2026, 1, 15, 12);

    test('isoYmd in UTC', () {
      expect(
        formatDateDisplay(
          instant: instant,
          timeZoneId: 'UTC',
          format: DateDisplayFormat.isoYmd,
          localeName: 'en_US',
        ),
        '2026-01-15',
      );
    });

    test('dmy format', () {
      expect(
        formatDateDisplay(
          instant: instant,
          timeZoneId: 'UTC',
          format: DateDisplayFormat.dmy,
          localeName: 'en_US',
        ),
        '15.01.2026',
      );
    });

    test('mdy format', () {
      expect(
        formatDateDisplay(
          instant: instant,
          timeZoneId: 'UTC',
          format: DateDisplayFormat.mdy,
          localeName: 'en_US',
        ),
        '01/15/2026',
      );
    });

    test('timezone shifts calendar day near midnight UTC', () {
      // 2026-01-15 02:00 UTC → still Jan 14 evening in US/Pacific (UTC-8)
      final nearMidnight = DateTime.utc(2026, 1, 15, 2);
      expect(
        formatDateDisplay(
          instant: nearMidnight,
          timeZoneId: 'America/Los_Angeles',
          format: DateDisplayFormat.isoYmd,
          localeName: 'en_US',
        ),
        '2026-01-14',
      );
      expect(
        formatDateDisplay(
          instant: nearMidnight,
          timeZoneId: 'UTC',
          format: DateDisplayFormat.isoYmd,
          localeName: 'en_US',
        ),
        '2026-01-15',
      );
    });

    test('dateDisplayFormatFromName defaults to isoYmd', () {
      expect(
        dateDisplayFormatFromName(null),
        DateDisplayFormat.isoYmd,
      );
      expect(
        dateDisplayFormatFromName('dmy'),
        DateDisplayFormat.dmy,
      );
    });
  });

  group('formatRelativeDayLabel', () {
    test('today yesterday and older in UTC', () {
      final now = DateTime.now().toUtc();
      final todayNoon = DateTime.utc(now.year, now.month, now.day, 12);
      final yesterdayNoon = todayNoon.subtract(const Duration(days: 1));
      final older = todayNoon.subtract(const Duration(days: 3));

      expect(
        formatRelativeDayLabel(
          instant: todayNoon,
          timeZoneId: 'UTC',
          format: DateDisplayFormat.isoYmd,
          localeName: 'en_US',
          todayLabel: 'Today',
          yesterdayLabel: 'Yesterday',
        ),
        'Today',
      );
      expect(
        formatRelativeDayLabel(
          instant: yesterdayNoon,
          timeZoneId: 'UTC',
          format: DateDisplayFormat.isoYmd,
          localeName: 'en_US',
          todayLabel: 'Today',
          yesterdayLabel: 'Yesterday',
        ),
        'Yesterday',
      );
      expect(
        formatRelativeDayLabel(
          instant: older,
          timeZoneId: 'UTC',
          format: DateDisplayFormat.isoYmd,
          localeName: 'en_US',
          todayLabel: 'Today',
          yesterdayLabel: 'Yesterday',
        ),
        formatDateDisplay(
          instant: older,
          timeZoneId: 'UTC',
          format: DateDisplayFormat.isoYmd,
          localeName: 'en_US',
        ),
      );
    });
  });
}
