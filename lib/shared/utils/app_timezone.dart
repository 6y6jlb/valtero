import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

/// Sentinel: follow the device timezone (re-detected at runtime).
const kSystemTimeZoneId = 'system';

/// Common IANA zones for the currencies / countries we care about.
const List<String> selectableTimeZones = [
  kSystemTimeZoneId,
  'UTC',
  'Europe/Moscow',
  'Europe/Minsk',
  'Europe/Kyiv',
  'Europe/Warsaw',
  'Europe/Berlin',
  'Europe/Paris',
  'Europe/London',
  'Europe/Istanbul',
  'Asia/Almaty',
  'Asia/Tashkent',
  'Asia/Tbilisi',
  'Asia/Yerevan',
  'Asia/Baku',
  'Asia/Dubai',
  'Asia/Shanghai',
  'Asia/Tokyo',
  'Asia/Seoul',
  'Asia/Kolkata',
  'Asia/Bangkok',
  'Asia/Ho_Chi_Minh',
  'Asia/Jakarta',
  'Asia/Singapore',
  'America/New_York',
  'America/Chicago',
  'America/Denver',
  'America/Los_Angeles',
  'America/Toronto',
  'America/Sao_Paulo',
  'America/Mexico_City',
  'America/Argentina/Buenos_Aires',
  'Australia/Sydney',
  'Pacific/Auckland',
];

String? _detectedLocalIana;

Future<void> initTimeZones() async {
  tzdata.initializeTimeZones();
  try {
    final info = await FlutterTimezone.getLocalTimezone();
    _detectedLocalIana = info.identifier;
    // Prefer device zone as tz.local when known.
    try {
      tz.setLocalLocation(tz.getLocation(info.identifier));
    } catch (_) {
      // Keep package default local.
    }
  } catch (_) {
    _detectedLocalIana = null;
  }
}

String get detectedLocalTimeZoneId =>
    _detectedLocalIana ?? DateTime.now().timeZoneName;

tz.Location resolveTimeZoneLocation(String timeZoneId) {
  if (timeZoneId == kSystemTimeZoneId) {
    final detected = _detectedLocalIana;
    if (detected != null) {
      try {
        return tz.getLocation(detected);
      } catch (_) {}
    }
    return tz.local;
  }
  try {
    return tz.getLocation(timeZoneId);
  } catch (_) {
    return tz.local;
  }
}

tz.TZDateTime nowInTimeZone(String timeZoneId) {
  return tz.TZDateTime.now(resolveTimeZoneLocation(timeZoneId));
}

/// Convert an absolute [instant] into the selected app timezone.
tz.TZDateTime zonedFromInstant(DateTime instant, String timeZoneId) {
  return tz.TZDateTime.from(instant, resolveTimeZoneLocation(timeZoneId));
}

/// Build an absolute instant from wall-clock fields in [timeZoneId].
tz.TZDateTime wallClockInTimeZone(
  String timeZoneId, {
  required int year,
  required int month,
  required int day,
  int hour = 0,
  int minute = 0,
  int second = 0,
  int millisecond = 0,
}) {
  return tz.TZDateTime(
    resolveTimeZoneLocation(timeZoneId),
    year,
    month,
    day,
    hour,
    minute,
    second,
    millisecond,
  );
}

DateTime dayStartInTimeZone(DateTime calendarDay, String timeZoneId) {
  return wallClockInTimeZone(
    timeZoneId,
    year: calendarDay.year,
    month: calendarDay.month,
    day: calendarDay.day,
  );
}

DateTime dayEndInTimeZone(DateTime calendarDay, String timeZoneId) {
  return wallClockInTimeZone(
    timeZoneId,
    year: calendarDay.year,
    month: calendarDay.month,
    day: calendarDay.day,
    hour: 23,
    minute: 59,
    second: 59,
    millisecond: 999,
  );
}

/// Calendar day key `YYYY-MM-DD` in [timeZoneId].
String calendarDayKey(DateTime instant, String timeZoneId) {
  final z = zonedFromInstant(instant, timeZoneId);
  final m = z.month.toString().padLeft(2, '0');
  final d = z.day.toString().padLeft(2, '0');
  return '${z.year}-$m-$d';
}

/// Calendar month key `YYYY-MM` in [timeZoneId].
String calendarMonthKey(DateTime instant, String timeZoneId) {
  final z = zonedFromInstant(instant, timeZoneId);
  return '${z.year}-${z.month.toString().padLeft(2, '0')}';
}

/// Calendar year key in [timeZoneId].
String calendarYearKey(DateTime instant, String timeZoneId) {
  return '${zonedFromInstant(instant, timeZoneId).year}';
}

String timeZoneLabel(String timeZoneId) {
  if (timeZoneId == kSystemTimeZoneId) {
    return detectedLocalTimeZoneId;
  }
  return timeZoneId;
}
