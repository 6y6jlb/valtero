import 'package:flutter/material.dart';
import 'package:valtero/shared/l10n/generated/app_localizations.dart';
import 'package:valtero/shared/utils/date_period.dart';
import 'package:valtero/widgets/period_month_calendar.dart';

/// Opens a period picker with presets and dual-month custom range selection.
/// Returns `null` if cancelled.
Future<DatePeriod?> showPeriodPicker(
  BuildContext context, {
  DatePeriod initial = DatePeriod.all,
}) {
  return showDialog<DatePeriod>(
    context: context,
    builder: (context) => PeriodPickerDialog(initial: initial.normalized()),
  );
}

String formatPeriodDay(DateTime d) =>
    '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

String localizedPeriodPreset(AppLocalizations l10n, PeriodPreset preset) {
  return switch (preset) {
    PeriodPreset.all => l10n.periodAll,
    PeriodPreset.today => l10n.periodToday,
    PeriodPreset.yesterday => l10n.periodYesterday,
    PeriodPreset.last7Days => l10n.periodLast7Days,
    PeriodPreset.last30Days => l10n.periodLast30Days,
    PeriodPreset.thisMonth => l10n.periodThisMonth,
    PeriodPreset.lastMonth => l10n.periodLastMonth,
    PeriodPreset.thisQuarter => l10n.periodThisQuarter,
    PeriodPreset.thisYear => l10n.periodThisYear,
    PeriodPreset.previousYear => l10n.periodPreviousYear,
    PeriodPreset.last12Months => l10n.periodLast12Months,
    PeriodPreset.custom => l10n.periodCustom,
  };
}

String formatPeriodLabel(
  AppLocalizations l10n,
  DatePeriod period, {
  DateTime? now,
}) {
  final p = period.normalized();
  final preset = matchPeriodPreset(p, now);
  if (preset != null && preset != PeriodPreset.custom) {
    return localizedPeriodPreset(l10n, preset);
  }
  if (p.from != null && p.to != null) {
    return l10n.periodFromTo(formatPeriodDay(p.from!), formatPeriodDay(p.to!));
  }
  if (p.from != null) {
    return '${l10n.periodFrom}: ${formatPeriodDay(p.from!)}';
  }
  if (p.to != null) {
    return '${l10n.periodTo}: ${formatPeriodDay(p.to!)}';
  }
  return l10n.periodAll;
}

const _sidebarPresets = <PeriodPreset>[
  PeriodPreset.today,
  PeriodPreset.yesterday,
  PeriodPreset.last7Days,
  PeriodPreset.last30Days,
  PeriodPreset.thisMonth,
  PeriodPreset.lastMonth,
  PeriodPreset.thisQuarter,
  PeriodPreset.thisYear,
  PeriodPreset.previousYear,
  PeriodPreset.last12Months,
  PeriodPreset.all,
];

class PeriodPickerDialog extends StatefulWidget {
  final DatePeriod initial;

  const PeriodPickerDialog({super.key, required this.initial});

  @override
  State<PeriodPickerDialog> createState() => _PeriodPickerDialogState();
}

class _PeriodPickerDialogState extends State<PeriodPickerDialog> {
  late PeriodPreset _preset;
  late DateTime? _from;
  late DateTime? _to;
  late DateTime _leftMonth;
  bool _awaitingEnd = false;

  @override
  void initState() {
    super.initState();
    _from = widget.initial.from;
    _to = widget.initial.to;
    _preset = matchPeriodPreset(widget.initial) ?? PeriodPreset.custom;
    _leftMonth = PeriodMonthCalendar.monthStart(
      _from ?? _to ?? DateTime.now(),
    );
  }

  DateTime get _rightMonth =>
      DateTime(_leftMonth.year, _leftMonth.month + 1, 1);

  void _shiftMonths(int delta) {
    setState(() {
      _leftMonth = DateTime(_leftMonth.year, _leftMonth.month + delta, 1);
    });
  }

  void _selectPreset(PeriodPreset preset) {
    final period = periodForPreset(preset);
    setState(() {
      _preset = preset;
      _from = period.from;
      _to = period.to;
      _awaitingEnd = false;
      if (_from != null) {
        _leftMonth = PeriodMonthCalendar.monthStart(_from!);
      }
    });
  }

  void _onDaySelected(DateTime day) {
    final selected = dateOnly(day);
    setState(() {
      _preset = PeriodPreset.custom;
      if (!_awaitingEnd || _from == null) {
        _from = selected;
        _to = selected;
        _awaitingEnd = true;
      } else {
        if (selected.isBefore(_from!)) {
          _to = _from;
          _from = selected;
        } else {
          _to = selected;
        }
        _awaitingEnd = false;
      }
    });
  }

  DatePeriod get _result {
    if (_preset != PeriodPreset.custom) {
      return periodForPreset(_preset);
    }
    return DatePeriod(from: _from, to: _to).normalized();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final wide = MediaQuery.sizeOf(context).width >= 720;

    final calendars = Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PeriodMonthCalendar(
          month: _leftMonth,
          rangeStart: _from,
          rangeEnd: _to,
          onDaySelected: _onDaySelected,
          onPrevMonth: () => _shiftMonths(-1),
          onNextMonth: () => _shiftMonths(1),
        ),
        const SizedBox(width: 12),
        PeriodMonthCalendar(
          month: _rightMonth,
          rangeStart: _from,
          rangeEnd: _to,
          onDaySelected: _onDaySelected,
          onPrevMonth: () => _shiftMonths(-1),
          onNextMonth: () => _shiftMonths(1),
        ),
      ],
    );

    final presets = SizedBox(
      width: wide ? 168 : double.infinity,
      child: ListView(
        shrinkWrap: true,
        children: [
          for (final preset in _sidebarPresets)
            _PresetTile(
              label: localizedPeriodPreset(l10n, preset),
              selected: _preset == preset,
              onTap: () => _selectPreset(preset),
            ),
        ],
      ),
    );

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: wide ? 780 : 360,
          maxHeight: MediaQuery.sizeOf(context).height * 0.9,
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 4, 8, 8),
                child: Text(
                  l10n.periodRange,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Flexible(
                child: wide
                    ? Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          presets,
                          VerticalDivider(
                            width: 24,
                            color: theme.colorScheme.outlineVariant,
                          ),
                          Flexible(
                            child: SingleChildScrollView(
                              child: calendars,
                            ),
                          ),
                        ],
                      )
                    : SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            SizedBox(height: 220, child: presets),
                            const Divider(),
                            calendars,
                          ],
                        ),
                      ),
              ),
              const SizedBox(height: 8),
              if (_preset == PeriodPreset.custom &&
                  (_from != null || _to != null))
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Text(
                    formatPeriodLabel(
                      l10n,
                      DatePeriod(from: _from, to: _to),
                    ),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              Padding(
                padding: const EdgeInsets.fromLTRB(4, 8, 4, 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(l10n.cancel),
                    ),
                    const SizedBox(width: 8),
                    FilledButton(
                      onPressed: () => Navigator.pop(context, _result),
                      child: Text(l10n.applyFilters),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PresetTile extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _PresetTile({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: selected
          ? theme.colorScheme.primary.withValues(alpha: 0.12)
          : Colors.transparent,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
              color: selected
                  ? theme.colorScheme.primary
                  : theme.colorScheme.onSurface,
            ),
          ),
        ),
      ),
    );
  }
}
