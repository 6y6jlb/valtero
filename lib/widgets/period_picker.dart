import 'package:flutter/material.dart';
import 'package:valtero/shared/l10n/generated/app_localizations.dart';
import 'package:valtero/shared/utils/date_period.dart';

/// Opens a period picker with presets and a combined from–to custom range.
/// Returns `null` if cancelled.
Future<DatePeriod?> showPeriodPicker(
  BuildContext context, {
  DatePeriod initial = DatePeriod.all,
}) {
  return showDialog<DatePeriod>(
    context: context,
    builder: (context) => _PeriodPickerDialog(initial: initial.normalized()),
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

class _PeriodPickerDialog extends StatefulWidget {
  final DatePeriod initial;

  const _PeriodPickerDialog({required this.initial});

  @override
  State<_PeriodPickerDialog> createState() => _PeriodPickerDialogState();
}

class _PeriodPickerDialogState extends State<_PeriodPickerDialog> {
  late PeriodPreset _preset;
  late DateTime? _from;
  late DateTime? _to;

  @override
  void initState() {
    super.initState();
    _from = widget.initial.from;
    _to = widget.initial.to;
    _preset = matchPeriodPreset(widget.initial) ?? PeriodPreset.custom;
  }

  void _selectPreset(PeriodPreset preset) {
    if (preset == PeriodPreset.custom) {
      setState(() => _preset = PeriodPreset.custom);
      return;
    }
    final period = periodForPreset(preset);
    setState(() {
      _preset = preset;
      _from = period.from;
      _to = period.to;
    });
  }

  Future<void> _pickCustomRange() async {
    final now = DateTime.now();
    final initialStart = _from ?? _to ?? now;
    final initialEnd = _to ?? _from ?? now;
    final start = initialStart.isBefore(initialEnd) ? initialStart : initialEnd;
    final end = initialStart.isBefore(initialEnd) ? initialEnd : initialStart;

    final range = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      initialDateRange: DateTimeRange(start: start, end: end),
      helpText: AppLocalizations.of(context)!.periodCustom,
      saveText: AppLocalizations.of(context)!.applyFilters,
    );
    if (range == null || !mounted) return;
    setState(() {
      _preset = PeriodPreset.custom;
      _from = dateOnly(range.start);
      _to = dateOnly(range.end);
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final presets = PeriodPreset.values
        .where((p) => p != PeriodPreset.custom)
        .toList();

    return AlertDialog(
      title: Text(l10n.periodRange),
      content: SizedBox(
        width: 420,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 320),
              child: ListView(
                shrinkWrap: true,
                children: [
                  for (final preset in presets)
                    RadioListTile<PeriodPreset>(
                      dense: true,
                      value: preset,
                      // ignore: deprecated_member_use
                      groupValue: _preset,
                      title: Text(localizedPeriodPreset(l10n, preset)),
                      // ignore: deprecated_member_use
                      onChanged: (v) {
                        if (v != null) _selectPreset(v);
                      },
                    ),
                  RadioListTile<PeriodPreset>(
                    dense: true,
                    value: PeriodPreset.custom,
                    // ignore: deprecated_member_use
                    groupValue: _preset,
                    title: Text(l10n.periodCustom),
                    subtitle: _preset == PeriodPreset.custom &&
                            (_from != null || _to != null)
                        ? Text(
                            formatPeriodLabel(
                              l10n,
                              DatePeriod(from: _from, to: _to),
                            ),
                          )
                        : Text(l10n.periodCustomHint),
                    // ignore: deprecated_member_use
                    onChanged: (v) {
                      if (v != null) _selectPreset(v);
                    },
                  ),
                ],
              ),
            ),
            if (_preset == PeriodPreset.custom) ...[
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: _pickCustomRange,
                icon: const Icon(Icons.date_range),
                label: Text(
                  _from == null && _to == null
                      ? l10n.periodPickRange
                      : l10n.periodFromTo(
                          formatPeriodDay(_from ?? _to!),
                          formatPeriodDay(_to ?? _from!),
                        ),
                ),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.cancel),
        ),
        FilledButton(
          onPressed: () {
            if (_preset == PeriodPreset.custom &&
                _from == null &&
                _to == null) {
              return;
            }
            final period = _preset == PeriodPreset.custom
                ? DatePeriod(from: _from, to: _to).normalized()
                : periodForPreset(_preset);
            Navigator.pop(context, period);
          },
          child: Text(l10n.applyFilters),
        ),
      ],
    );
  }
}
