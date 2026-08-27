import 'package:flutter/material.dart';
import 'package:valtero/shared/utils/date_period.dart';

/// One month grid used by [showPeriodPicker] for custom range selection.
class PeriodMonthCalendar extends StatelessWidget {
  final DateTime month;
  final DateTime? rangeStart;
  final DateTime? rangeEnd;
  final ValueChanged<DateTime> onDaySelected;
  final VoidCallback onPrevMonth;
  final VoidCallback onNextMonth;

  const PeriodMonthCalendar({
    super.key,
    required this.month,
    required this.rangeStart,
    required this.rangeEnd,
    required this.onDaySelected,
    required this.onPrevMonth,
    required this.onNextMonth,
  });

  static DateTime monthStart(DateTime d) => DateTime(d.year, d.month, 1);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final material = MaterialLocalizations.of(context);
    final first = monthStart(month);
    final daysInMonth = DateTime(first.year, first.month + 1, 0).day;
    final firstWeekday = first.weekday % 7; // Sunday = 0
    final today = dateOnly(DateTime.now());
    final start = rangeStart == null ? null : dateOnly(rangeStart!);
    final end = rangeEnd == null ? null : dateOnly(rangeEnd!);
    final rangeLo = start == null
        ? null
        : (end == null || !end.isBefore(start) ? start : end);
    final rangeHi = end == null
        ? start
        : (start == null || !end.isBefore(start) ? end : start);

    final weekdayLabels = material.narrowWeekdays;

    final cells = <DateTime?>[];
    for (var i = 0; i < firstWeekday; i++) {
      final day = first.subtract(Duration(days: firstWeekday - i));
      cells.add(day);
    }
    for (var d = 1; d <= daysInMonth; d++) {
      cells.add(DateTime(first.year, first.month, d));
    }
    while (cells.length % 7 != 0) {
      final last = cells.last!;
      cells.add(last.add(const Duration(days: 1)));
    }

    final monthTitle = material.formatMonthYear(first).toLowerCase();

    return SizedBox(
      width: 280,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              IconButton(
                visualDensity: VisualDensity.compact,
                onPressed: onPrevMonth,
                icon: const Icon(Icons.chevron_left),
              ),
              Expanded(
                child: Text(
                  monthTitle,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              IconButton(
                visualDensity: VisualDensity.compact,
                onPressed: onNextMonth,
                icon: const Icon(Icons.chevron_right),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              for (final label in weekdayLabels)
                Expanded(
                  child: Text(
                    label.toLowerCase(),
                    textAlign: TextAlign.center,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 4),
          for (var row = 0; row < cells.length ~/ 7; row++)
            Row(
              children: [
                for (var col = 0; col < 7; col++)
                  Expanded(
                    child: _DayCell(
                      day: cells[row * 7 + col]!,
                      inMonth: cells[row * 7 + col]!.month == first.month,
                      isToday: sameDay(cells[row * 7 + col], today),
                      isSelected: _isEndpoint(
                        cells[row * 7 + col]!,
                        rangeLo,
                        rangeHi,
                      ),
                      inRange: _inRange(
                        cells[row * 7 + col]!,
                        rangeLo,
                        rangeHi,
                      ),
                      onTap: () => onDaySelected(cells[row * 7 + col]!),
                    ),
                  ),
              ],
            ),
        ],
      ),
    );
  }

  bool _isEndpoint(DateTime day, DateTime? lo, DateTime? hi) {
    return sameDay(day, lo) || sameDay(day, hi);
  }

  bool _inRange(DateTime day, DateTime? lo, DateTime? hi) {
    if (lo == null || hi == null) return false;
    final d = dateOnly(day);
    return !d.isBefore(lo) && !d.isAfter(hi);
  }
}

class _DayCell extends StatelessWidget {
  final DateTime day;
  final bool inMonth;
  final bool isToday;
  final bool isSelected;
  final bool inRange;
  final VoidCallback onTap;

  const _DayCell({
    required this.day,
    required this.inMonth,
    required this.isToday,
    required this.isSelected,
    required this.inRange,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    Color? bg;
    if (isSelected) {
      bg = scheme.primary;
    } else if (inRange) {
      bg = scheme.primary.withValues(alpha: 0.18);
    }

    final textColor = isSelected
        ? scheme.onPrimary
        : inMonth
            ? scheme.onSurface
            : scheme.onSurfaceVariant.withValues(alpha: 0.55);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Material(
        color: bg ?? Colors.transparent,
        borderRadius: BorderRadius.circular(isSelected ? 20 : 4),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(isSelected ? 20 : 4),
          child: SizedBox(
            height: 36,
            child: Center(
              child: Text(
                '${day.day}',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: textColor,
                  fontWeight: isToday || isSelected
                      ? FontWeight.w700
                      : FontWeight.w400,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
