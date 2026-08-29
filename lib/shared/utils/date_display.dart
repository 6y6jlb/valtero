import 'package:intl/intl.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:valtero/shared/utils/app_timezone.dart';

/// How calendar dates are shown in the UI.
enum DateDisplayFormat {
  /// Locale-aware medium date (`Jan 15, 2026` / `15 янв. 2026 г.`).
  localeMedium,

  /// ISO `YYYY-MM-DD`.
  isoYmd,

  /// `DD.MM.YYYY`.
  dmy,

  /// `MM/DD/YYYY`.
  mdy,
}

DateDisplayFormat dateDisplayFormatFromName(String? name) {
  return DateDisplayFormat.values.firstWhere(
    (f) => f.name == name,
    orElse: () => DateDisplayFormat.isoYmd,
  );
}

String _pad2(int n) => n.toString().padLeft(2, '0');

/// Formats an absolute [instant] as a calendar date in [timeZoneId].
String formatDateDisplay({
  required DateTime instant,
  required String timeZoneId,
  required DateDisplayFormat format,
  required String localeName,
}) {
  final zoned = zonedFromInstant(instant, timeZoneId);
  return formatZonedDateDisplay(
    zoned: zoned,
    format: format,
    localeName: localeName,
  );
}

String formatZonedDateDisplay({
  required tz.TZDateTime zoned,
  required DateDisplayFormat format,
  required String localeName,
}) {
  switch (format) {
    case DateDisplayFormat.localeMedium:
      return DateFormat.yMMMd(localeName).format(zoned);
    case DateDisplayFormat.isoYmd:
      return '${zoned.year}-${_pad2(zoned.month)}-${_pad2(zoned.day)}';
    case DateDisplayFormat.dmy:
      return '${_pad2(zoned.day)}.${_pad2(zoned.month)}.${zoned.year}';
    case DateDisplayFormat.mdy:
      return '${_pad2(zoned.month)}/${_pad2(zoned.day)}/${zoned.year}';
  }
}

/// Calendar day key in [timeZoneId] for grouping (`YYYY-MM-DD`).
String relativeDayKey(DateTime instant, String timeZoneId) =>
    calendarDayKey(instant, timeZoneId);

/// Label for a day group: today / yesterday / formatted date.
String formatRelativeDayLabel({
  required DateTime instant,
  required String timeZoneId,
  required DateDisplayFormat format,
  required String localeName,
  required String todayLabel,
  required String yesterdayLabel,
}) {
  final day = zonedFromInstant(instant, timeZoneId);
  final now = nowInTimeZone(timeZoneId);
  final today = tz.TZDateTime(day.location, now.year, now.month, now.day);
  final yesterday = today.subtract(const Duration(days: 1));
  final dayOnly = tz.TZDateTime(day.location, day.year, day.month, day.day);

  if (dayOnly == today) return todayLabel;
  if (dayOnly == yesterday) return yesterdayLabel;
  return formatZonedDateDisplay(
    zoned: day,
    format: format,
    localeName: localeName,
  );
}
