import 'package:flutter/material.dart';
import 'package:valtero/features/expenses_list/model/expense_list_view.dart';
import 'package:valtero/features/expenses_list/ui/chart_toggle_icon.dart';
import 'package:valtero/shared/l10n/generated/app_localizations.dart';

/// Tight padding for bar/line plots that sit **below** [ChartOverlayControls]
/// instead of under them.
const kChartPlotPadding = EdgeInsets.fromLTRB(4, 8, 12, 4);

/// Padding around the donut ring. Overlay actions and the legend live outside
/// the plot, so this is only a little air around the pie (not a chrome inset).
const kDonutPlotPadding = EdgeInsets.all(8);

/// Chart-type icons laid out above the plot (top-right).
class ChartOverlayControls extends StatelessWidget {
  final ExpenseChartType chartType;
  final ValueChanged<ExpenseChartType> onChartTypeChanged;
  final List<ExpenseChartType> availableChartTypes;

  const ChartOverlayControls({
    super.key,
    required this.chartType,
    required this.onChartTypeChanged,
    required this.availableChartTypes,
  });

  List<Widget> _chartToggleIcons(AppLocalizations l10n) {
    final icons = <Widget>[];
    for (final type in availableChartTypes) {
      switch (type) {
        case ExpenseChartType.donut:
          icons.add(
            ChartToggleIcon(
              tooltip: l10n.chartTypeDonut,
              selected: chartType == ExpenseChartType.donut,
              icon: Icons.pie_chart_outline,
              onPressed: () => onChartTypeChanged(ExpenseChartType.donut),
            ),
          );
        case ExpenseChartType.column:
          icons.add(
            ChartToggleIcon(
              tooltip: l10n.chartTypeColumn,
              selected: chartType == ExpenseChartType.column,
              icon: Icons.bar_chart,
              onPressed: () => onChartTypeChanged(ExpenseChartType.column),
            ),
          );
        case ExpenseChartType.columnByDate:
          icons.add(
            ChartToggleIcon(
              tooltip: l10n.chartTypeColumnByDate,
              selected: chartType == ExpenseChartType.columnByDate,
              icon: Icons.stacked_bar_chart,
              onPressed: () =>
                  onChartTypeChanged(ExpenseChartType.columnByDate),
            ),
          );
        case ExpenseChartType.line:
          icons.add(
            ChartToggleIcon(
              tooltip: l10n.chartTypeLine,
              selected: chartType == ExpenseChartType.line,
              icon: Icons.show_chart,
              onPressed: () => onChartTypeChanged(ExpenseChartType.line),
            ),
          );
      }
    }
    return icons;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final toggleIcons = _chartToggleIcons(l10n);
    final surface = theme.colorScheme.surface.withValues(alpha: 0.88);

    return Align(
      alignment: Alignment.centerRight,
      child: Material(
        color: surface,
        elevation: 0,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2),
          child: Row(mainAxisSize: MainAxisSize.min, children: toggleIcons),
        ),
      ),
    );
  }
}

/// Insets [child] on the trailing side by the system bar (navigation / gesture
/// bar sits there after a landscape rotation) so chart actions stay visible.
Widget padClearOfEndSystemBar(BuildContext context, Widget child) {
  final safe = MediaQuery.paddingOf(context);
  final rtl = Directionality.of(context) == TextDirection.rtl;
  final end = rtl ? safe.left : safe.right;
  if (end <= 0) return child;
  return Padding(
    padding: EdgeInsetsDirectional.only(end: end),
    child: child,
  );
}
