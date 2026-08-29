import 'package:valtero/shared/utils/app_timezone.dart';

/// Inclusive calendar-day period for filters (wall-clock days in app timezone).
class DatePeriod {
  final DateTime? from;
  final DateTime? to;

  const DatePeriod({this.from, this.to});

  static const all = DatePeriod();

  bool get isAll => from == null && to == null;

  DatePeriod normalized() {
    final a = from == null ? null : dateOnly(from!);
    final b = to == null ? null : dateOnly(to!);
    if (a != null && b != null && a.isAfter(b)) {
      return DatePeriod(from: b, to: a);
    }
    return DatePeriod(from: a, to: b);
  }
}

/// Calendar date with time stripped (year/month/day fields only).
DateTime dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

bool sameDay(DateTime? a, DateTime? b) {
  if (a == null && b == null) return true;
  if (a == null || b == null) return false;
  return a.year == b.year && a.month == b.month && a.day == b.day;
}

enum PeriodPreset {
  all,
  today,
  yesterday,
  last7Days,
  last30Days,
  thisMonth,
  lastMonth,
  thisQuarter,
  thisYear,
  previousYear,
  last12Months,
  custom,
}

/// [now] should be wall-clock "today" in the app timezone when provided.
/// Prefer [periodForPresetInTimeZone] from UI code.
DatePeriod periodForPreset(PeriodPreset preset, [DateTime? now]) {
  final n = now ?? DateTime.now();
  final today = dateOnly(n);
  switch (preset) {
    case PeriodPreset.all:
      return DatePeriod.all;
    case PeriodPreset.today:
      return DatePeriod(from: today, to: today);
    case PeriodPreset.yesterday:
      final y = today.subtract(const Duration(days: 1));
      return DatePeriod(from: y, to: y);
    case PeriodPreset.last7Days:
      return DatePeriod(
        from: today.subtract(const Duration(days: 6)),
        to: today,
      );
    case PeriodPreset.last30Days:
      return DatePeriod(
        from: today.subtract(const Duration(days: 29)),
        to: today,
      );
    case PeriodPreset.thisMonth:
      return DatePeriod(
        from: DateTime(today.year, today.month, 1),
        to: today,
      );
    case PeriodPreset.lastMonth:
      final firstThis = DateTime(today.year, today.month, 1);
      final lastPrev = firstThis.subtract(const Duration(days: 1));
      final firstPrev = DateTime(lastPrev.year, lastPrev.month, 1);
      return DatePeriod(from: firstPrev, to: lastPrev);
    case PeriodPreset.thisQuarter:
      final qStartMonth = ((today.month - 1) ~/ 3) * 3 + 1;
      return DatePeriod(
        from: DateTime(today.year, qStartMonth, 1),
        to: today,
      );
    case PeriodPreset.thisYear:
      return DatePeriod(
        from: DateTime(today.year, 1, 1),
        to: today,
      );
    case PeriodPreset.previousYear:
      final y = today.year - 1;
      return DatePeriod(
        from: DateTime(y, 1, 1),
        to: DateTime(y, 12, 31),
      );
    case PeriodPreset.last12Months:
      return DatePeriod(
        from: dateOnly(DateTime(today.year, today.month - 11, today.day)),
        to: today,
      );
    case PeriodPreset.custom:
      return DatePeriod.all;
  }
}

DatePeriod periodForPresetInTimeZone(PeriodPreset preset, String timeZoneId) {
  final now = nowInTimeZone(timeZoneId);
  return periodForPreset(preset, DateTime(now.year, now.month, now.day));
}

PeriodPreset? matchPeriodPreset(DatePeriod period, [DateTime? now]) {
  final p = period.normalized();
  if (p.isAll) return PeriodPreset.all;
  for (final preset in PeriodPreset.values) {
    if (preset == PeriodPreset.custom) continue;
    final candidate = periodForPreset(preset, now);
    if (sameDay(candidate.from, p.from) && sameDay(candidate.to, p.to)) {
      return preset;
    }
  }
  return PeriodPreset.custom;
}
