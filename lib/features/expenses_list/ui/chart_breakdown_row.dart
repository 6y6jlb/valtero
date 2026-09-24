import 'package:flutter/material.dart';
import 'package:valtero/features/expenses_list/model/chart_breakdown_options.dart';
import 'package:valtero/features/expenses_list/model/expense_list_view.dart';
import 'package:valtero/features/expenses_list/ui/chart_toggle_icon.dart';
import 'package:valtero/shared/l10n/generated/app_localizations.dart';

/// Single horizontally scrollable row of chart breakdown / period icons.
///
/// When the selected icon is off-screen, it is scrolled into view after layout.
class ChartBreakdownRow extends StatefulWidget {
  final ExpenseChartBreakdown selected;
  final ValueChanged<ExpenseChartBreakdown> onChanged;
  final bool cashFlowPeriodOnly;

  const ChartBreakdownRow({
    super.key,
    required this.selected,
    required this.onChanged,
    this.cashFlowPeriodOnly = false,
  });

  @override
  State<ChartBreakdownRow> createState() => _ChartBreakdownRowState();
}

class _ChartBreakdownRowState extends State<ChartBreakdownRow> {
  final ScrollController _controller = ScrollController();
  final Map<ExpenseChartBreakdown, GlobalKey> _keys = {};

  List<ExpenseChartBreakdown> get _order => widget.cashFlowPeriodOnly
      ? kCashFlowChartBreakdownOrder
      : kExpenseChartBreakdownOrder;

  GlobalKey _keyFor(ExpenseChartBreakdown value) =>
      _keys.putIfAbsent(value, GlobalKey.new);

  @override
  void didUpdateWidget(covariant ChartBreakdownRow oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selected != widget.selected ||
        oldWidget.cashFlowPeriodOnly != widget.cashFlowPeriodOnly) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _ensureSelectedVisible();
      });
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _ensureSelectedVisible();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _ensureSelectedVisible() {
    final ctx = _keyFor(widget.selected).currentContext;
    if (ctx == null) return;
    Scrollable.ensureVisible(
      ctx,
      alignment: 0.5,
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final muted = theme.colorScheme.onSurfaceVariant;
    const extent = ChartToggleIcon.extent;

    Widget iconBtn({
      required ExpenseChartBreakdown value,
      required IconData icon,
      required String tooltip,
    }) {
      final isSelected = widget.selected == value;
      return IconButton(
        key: _keyFor(value),
        tooltip: tooltip,
        visualDensity: VisualDensity.compact,
        constraints: const BoxConstraints(minWidth: extent, minHeight: extent),
        padding: EdgeInsets.zero,
        onPressed: () => widget.onChanged(value),
        icon: Icon(
          icon,
          size: ChartToggleIcon.iconSize,
          color: isSelected ? primary : muted,
        ),
        style: IconButton.styleFrom(
          backgroundColor: isSelected
              ? primary.withValues(alpha: 0.12)
              : Colors.transparent,
        ),
      );
    }

    final icons = <Widget>[
      for (final value in _order)
        switch (value) {
          ExpenseChartBreakdown.country => iconBtn(
              value: value,
              icon: Icons.public,
              tooltip: l10n.chartByTagCountry,
            ),
          ExpenseChartBreakdown.payment => iconBtn(
              value: value,
              icon: Icons.payments_outlined,
              tooltip: l10n.chartByPayment,
            ),
          ExpenseChartBreakdown.tagCustom => iconBtn(
              value: value,
              icon: Icons.label_outline,
              tooltip: l10n.chartByTagCustom,
            ),
          ExpenseChartBreakdown.day => iconBtn(
              value: value,
              icon: Icons.today_outlined,
              tooltip: l10n.chartByDay,
            ),
          ExpenseChartBreakdown.week => iconBtn(
              value: value,
              icon: Icons.date_range_outlined,
              tooltip: l10n.chartByWeek,
            ),
          ExpenseChartBreakdown.month => iconBtn(
              value: value,
              icon: Icons.calendar_month,
              tooltip: l10n.chartByMonth,
            ),
          ExpenseChartBreakdown.year => iconBtn(
              value: value,
              icon: Icons.calendar_today,
              tooltip: l10n.chartByYear,
            ),
          ExpenseChartBreakdown.currency => iconBtn(
              value: value,
              icon: Icons.currency_exchange,
              tooltip: l10n.chartByCurrency,
            ),
        },
    ];

    return Align(
      alignment: Alignment.center,
      child: SingleChildScrollView(
        controller: _controller,
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: icons,
        ),
      ),
    );
  }
}
