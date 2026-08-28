import 'package:flutter/material.dart';
import 'package:valtero/shared/l10n/generated/app_localizations.dart';
import 'package:valtero/shared/utils/date_period.dart';
import 'package:valtero/widgets/app_modal_sheet.dart';
import 'package:valtero/widgets/period_month_calendar.dart';

/// Opens a period picker with presets and dual-month custom range selection.
/// Returns `null` if cancelled.
Future<DatePeriod?> showPeriodPicker(
  BuildContext context, {
  DatePeriod initial = DatePeriod.all,
}) {
  return showAppModalSheet<DatePeriod>(
    context: context,
    initialChildSize: 0.85,
    minChildSize: 0.5,
    maxChildSize: 0.95,
    child: PeriodPickerSheet(initial: initial.normalized()),
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

class PeriodPickerSheet extends StatefulWidget {
  final DatePeriod initial;

  const PeriodPickerSheet({super.key, required this.initial});

  @override
  State<PeriodPickerSheet> createState() => _PeriodPickerSheetState();
}

class _PeriodPickerSheetState extends State<PeriodPickerSheet> {
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
    Navigator.pop(context, period);
  }

  void _onDaySelected(DateTime day) {
    final selected = dateOnly(day);
    if (!_awaitingEnd || _from == null) {
      setState(() {
        _preset = PeriodPreset.custom;
        _from = selected;
        _to = selected;
        _awaitingEnd = true;
      });
      return;
    }

    DateTime from = _from!;
    DateTime to = selected;
    if (selected.isBefore(from)) {
      to = from;
      from = selected;
    }
    Navigator.pop(
      context,
      DatePeriod(from: from, to: to).normalized(),
    );
  }

  Widget _calendar(DateTime month) {
    return PeriodMonthCalendar(
      month: month,
      rangeStart: _from,
      rangeEnd: _to,
      onDaySelected: _onDaySelected,
      onPrevMonth: () => _shiftMonths(-1),
      onNextMonth: () => _shiftMonths(1),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final screen = MediaQuery.sizeOf(context);
    // Sidebar + two months needs ~720+; otherwise stack for mobile.
    final sideBySide = screen.width >= 720;
    final dualMonths = screen.width >= 520;

    final presets = ListView(
      shrinkWrap: true,
      children: [
        for (final preset in _sidebarPresets)
          _PresetTile(
            label: localizedPeriodPreset(l10n, preset),
            selected: _preset == preset,
            onTap: () => _selectPreset(preset),
          ),
      ],
    );

    final calendars = dualMonths
        ? Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _calendar(_leftMonth)),
              const SizedBox(width: 8),
              Expanded(child: _calendar(_rightMonth)),
            ],
          )
        : Column(
            children: [
              _calendar(_leftMonth),
              const SizedBox(height: 12),
              _calendar(_rightMonth),
            ],
          );

    final body = sideBySide
        ? Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 160,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 420),
                  child: presets,
                ),
              ),
              VerticalDivider(
                width: 16,
                color: theme.colorScheme.outlineVariant,
              ),
              Expanded(
                child: SingleChildScrollView(child: calendars),
              ),
            ],
          )
        : SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 200),
                  child: presets,
                ),
                Divider(color: theme.colorScheme.outlineVariant),
                calendars,
              ],
            ),
          );

    return ListView(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 24),
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(4, 4, 4, 8),
          child: Text(
            l10n.periodRange,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        SizedBox(
          height: sideBySide ? 420 : 520,
          child: body,
        ),
        const SizedBox(height: 8),
        if (_from != null || _to != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
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
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
        ),
      ],
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
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
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
