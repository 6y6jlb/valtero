import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:valtero/features/expenses_list/model/chart_breakdown_options.dart';
import 'package:valtero/features/expenses_list/model/chart_time_series.dart';
import 'package:valtero/features/expenses_list/model/cycle_index.dart';
import 'package:valtero/features/expenses_list/model/cycle_transition_direction.dart';
import 'package:valtero/features/expenses_list/model/donut_chart_slice.dart';
import 'package:valtero/features/expenses_list/model/expense_list_view.dart';
import 'package:valtero/features/expenses_list/ui/breakdown_chart_legend.dart';
import 'package:valtero/features/expenses_list/ui/chart_breakdown_row.dart';
import 'package:valtero/features/expenses_list/ui/chart_empty_placeholder.dart';
import 'package:valtero/features/expenses_list/ui/chart_overlay_controls.dart';
import 'package:valtero/features/expenses_list/ui/column_breakdown_chart.dart';
import 'package:valtero/features/expenses_list/ui/directional_slide_switcher.dart';
import 'package:valtero/features/expenses_list/ui/donut_breakdown_chart.dart';
import 'package:valtero/features/expenses_list/ui/line_breakdown_chart.dart';
import 'package:valtero/features/expenses_list/ui/stacked_column_time_chart.dart';
import 'package:valtero/shared/l10n/generated/app_localizations.dart';
import 'package:valtero/widgets/money_text.dart';

const _kDefaultChartTypes = [
  ExpenseChartType.donut,
  ExpenseChartType.column,
  ExpenseChartType.columnByDate,
  ExpenseChartType.line,
];

bool _isTimeSeriesChartType(ExpenseChartType type) {
  return type == ExpenseChartType.columnByDate || type == ExpenseChartType.line;
}

/// Donut / column / time-series chart with type icons above the plot,
/// breakdown icons in a scrollable row above the legend, and a centered
/// total in the donut hole.
class BreakdownChartView extends ConsumerStatefulWidget {
  final List<DonutChartSlice> slices;
  final ChartTimeSeriesAggregation? timeSeries;
  final String displayCurrency;
  final ExpenseChartType chartType;
  final ValueChanged<ExpenseChartType> onChartTypeChanged;
  final List<ExpenseChartType> availableChartTypes;
  final ExpenseChartBreakdown? breakdown;
  final ValueChanged<ExpenseChartBreakdown>? onBreakdownChanged;
  final bool cashFlowPeriodOnly;
  final bool showSubcategories;
  final ValueChanged<bool>? onShowSubcategoriesChanged;
  final ValueChanged<DonutChartSlice>? onSegmentTap;
  final bool showTotal;
  final bool hideCenterTotal;
  final bool hideSegmentAmounts;
  final double chartHeight;
  final String? emptyMessage;
  final IconData emptyIcon;

  const BreakdownChartView({
    super.key,
    required this.slices,
    this.timeSeries,
    required this.displayCurrency,
    required this.chartType,
    required this.onChartTypeChanged,
    this.availableChartTypes = _kDefaultChartTypes,
    this.breakdown,
    this.onBreakdownChanged,
    this.cashFlowPeriodOnly = false,
    this.showSubcategories = false,
    this.onShowSubcategoriesChanged,
    this.onSegmentTap,
    this.showTotal = true,
    this.hideCenterTotal = false,
    this.hideSegmentAmounts = false,
    this.chartHeight = 312,
    this.emptyMessage,
    this.emptyIcon = Icons.pie_chart_outline,
  });

  @override
  ConsumerState<BreakdownChartView> createState() => _BreakdownChartViewState();
}

class _BreakdownChartViewState extends ConsumerState<BreakdownChartView> {
  final Set<String> _hiddenKeys = {};
  bool _breakdownSlideForward = true;

  List<ExpenseChartBreakdown> get _breakdownOrder => widget.cashFlowPeriodOnly
      ? kCashFlowChartBreakdownOrder
      : kExpenseChartBreakdownOrder;

  @override
  void didUpdateWidget(covariant BreakdownChartView oldWidget) {
    super.didUpdateWidget(oldWidget);
    final oldB = oldWidget.breakdown;
    final newB = widget.breakdown;
    if (oldB != null && newB != null && oldB != newB) {
      _breakdownSlideForward =
          cycleTransitionForward(_breakdownOrder, oldB, newB);
    }
    final nextKeys = <String>{
      for (final s in widget.slices) s.key,
      if (widget.timeSeries != null)
        for (final s in widget.timeSeries!.series) s.key,
      if (widget.chartType == ExpenseChartType.line) kChartTotalSeriesKey,
    };
    final oldKeys = <String>{
      for (final s in oldWidget.slices) s.key,
      if (oldWidget.timeSeries != null)
        for (final s in oldWidget.timeSeries!.series) s.key,
      if (oldWidget.chartType == ExpenseChartType.line) kChartTotalSeriesKey,
    };
    if (nextKeys.length != oldKeys.length || !nextKeys.containsAll(oldKeys)) {
      _hiddenKeys.removeWhere((k) => !nextKeys.contains(k));
    }
  }

  void _toggle(String key) {
    setState(() {
      if (_hiddenKeys.contains(key)) {
        _hiddenKeys.remove(key);
      } else {
        _hiddenKeys.add(key);
      }
    });
  }

  Widget _buildChartChild({
    required AppLocalizations l10n,
    required List<DonutChartSlice> allSlices,
    required List<ChartSeriesDef> allSeries,
    required Set<String> hiddenKeys,
    Widget? donutCenterOverlay,
  }) {
    switch (widget.chartType) {
      case ExpenseChartType.donut:
        return DonutBreakdownChart(
          slices: allSlices,
          hiddenKeys: hiddenKeys,
          displayCurrency: widget.displayCurrency,
          onSegmentTap: widget.onSegmentTap,
          showTotal: false,
          hideCenterTotal: true,
          hideSegmentAmounts: widget.hideSegmentAmounts,
          chartHeight: widget.chartHeight,
          showLegend: false,
          emptyMessage: widget.emptyMessage,
          centerOverlay: donutCenterOverlay,
        );
      case ExpenseChartType.column:
        return ColumnBreakdownChart(
          slices: allSlices,
          hiddenKeys: hiddenKeys,
          displayCurrency: widget.displayCurrency,
          onSegmentTap: widget.onSegmentTap,
          hideSegmentAmounts: widget.hideSegmentAmounts,
          chartHeight: widget.chartHeight,
          emptyMessage: widget.emptyMessage,
        );
      case ExpenseChartType.columnByDate:
        final ts = widget.timeSeries;
        if (ts == null) {
          return ChartEmptyPlaceholder(
            message: widget.emptyMessage ?? l10n.noMatchingExpenses,
            icon: widget.emptyIcon,
            height: widget.chartHeight * 0.55,
          );
        }
        return StackedColumnTimeChart(
          series: allSeries,
          points: ts.points,
          hiddenKeys: hiddenKeys,
          displayCurrency: widget.displayCurrency,
          hideAmounts: widget.hideSegmentAmounts,
          chartHeight: widget.chartHeight,
          emptyMessage: widget.emptyMessage,
        );
      case ExpenseChartType.line:
        final ts = widget.timeSeries;
        if (ts == null) {
          return ChartEmptyPlaceholder(
            message: widget.emptyMessage ?? l10n.noMatchingExpenses,
            icon: widget.emptyIcon,
            height: widget.chartHeight * 0.55,
          );
        }
        return LineBreakdownChart(
          series: allSeries,
          points: ts.points,
          hiddenKeys: hiddenKeys,
          displayCurrency: widget.displayCurrency,
          hideAmounts: widget.hideSegmentAmounts,
          chartHeight: widget.chartHeight,
          emptyMessage: widget.emptyMessage,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isTimeSeries = _isTimeSeriesChartType(widget.chartType);
    final all = widget.slices;
    final ts = widget.timeSeries;

    if (!isTimeSeries && all.isEmpty) {
      return ChartEmptyPlaceholder(
        message: widget.emptyMessage ?? l10n.noMatchingExpenses,
        icon: widget.emptyIcon,
        height: widget.chartHeight * 0.55,
      );
    }
    if (isTimeSeries && (ts == null || ts.points.isEmpty)) {
      return ChartEmptyPlaceholder(
        message: widget.emptyMessage ?? l10n.noMatchingExpenses,
        icon: widget.emptyIcon,
        height: widget.chartHeight * 0.55,
      );
    }

    final visible = all
        .where((s) => !_hiddenKeys.contains(s.key))
        .toList(growable: false);
    final allSeries = ts?.series ?? const <ChartSeriesDef>[];

    final total = visible.fold<int>(0, (sum, s) => sum + s.amountMinor);
    final totalPrimaryText = formatMoneyOf(
      context,
      ref,
      amountMinor: total,
      currencyCode: widget.displayCurrency,
      hideFraction: true,
    );
    final totalCompactText = formatMoneyOf(
      context,
      ref,
      amountMinor: total,
      currencyCode: widget.displayCurrency,
      hideFraction: true,
      compact: true,
    );

    final showDonutCenterTotal =
        widget.showTotal &&
        !widget.hideCenterTotal &&
        widget.chartType == ExpenseChartType.donut &&
        visible.isNotEmpty;

    final showSubToggle =
        widget.breakdown == ExpenseChartBreakdown.tagCustom &&
        widget.onShowSubcategoriesChanged != null;

    final showBreakdownRow =
        widget.breakdown != null && widget.onBreakdownChanged != null;

    Widget plot = SizedBox(
      height: widget.chartHeight,
      child: ClipRect(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 280),
          switchInCurve: Curves.easeOutCubic,
          switchOutCurve: Curves.easeInCubic,
          transitionBuilder: (child, animation) {
            final fade = CurvedAnimation(
              parent: animation,
              curve: Curves.easeOut,
            );
            final slide = Tween<Offset>(
              begin: const Offset(0.04, 0),
              end: Offset.zero,
            ).animate(fade);
            return FadeTransition(
              opacity: fade,
              child: SlideTransition(position: slide, child: child),
            );
          },
          child: KeyedSubtree(
            key: ValueKey(widget.chartType),
            child: _buildChartChild(
              l10n: l10n,
              allSlices: all,
              allSeries: allSeries,
              hiddenKeys: _hiddenKeys,
              donutCenterOverlay: showDonutCenterTotal
                  ? _ChartCenterTotal(
                      label: l10n.summaryTotal,
                      primaryText: totalPrimaryText,
                      compactText: totalCompactText,
                    )
                  : null,
            ),
          ),
        ),
      ),
    );

    plot = showBreakdownRow
        ? InteractiveSlidePager(
            pageKey: widget.breakdown!,
            externalForward: _breakdownSlideForward,
            onNext: () => widget.onBreakdownChanged!(
              cycleIndex(_breakdownOrder, widget.breakdown!, forward: true),
            ),
            onPrevious: () => widget.onBreakdownChanged!(
              cycleIndex(_breakdownOrder, widget.breakdown!, forward: false),
            ),
            child: plot,
          )
        : plot;

    String? amountLabel(int amountMinor, {String? currencyCode}) {
      if (widget.hideSegmentAmounts) return null;
      return formatMoneyOf(
        context,
        ref,
        amountMinor: amountMinor,
        currencyCode: currencyCode ?? widget.displayCurrency,
        hideFraction: true,
      );
    }

    int seriesTotal(String key) {
      if (ts == null) return 0;
      if (key == kChartTotalSeriesKey) {
        return ts.points.fold<int>(0, (sum, p) => sum + p.totalMinor);
      }
      return ts.points.fold<int>(
        0,
        (sum, p) => sum + (p.amountBySeriesKey[key] ?? 0),
      );
    }

    final legend = isTimeSeries
        ? BreakdownChartLegend(
            items: [
              if (widget.chartType == ExpenseChartType.line)
                (
                  key: kChartTotalSeriesKey,
                  label: l10n.summaryTotal,
                  color: theme.colorScheme.onSurface,
                  iconKey: null,
                  flagCode: null,
                  flagIsCurrency: false,
                  amountLabel: amountLabel(seriesTotal(kChartTotalSeriesKey)),
                ),
              for (final s in allSeries)
                (
                  key: s.key,
                  label: s.label,
                  color: s.color,
                  iconKey: s.iconKey,
                  flagCode: s.flagCode,
                  flagIsCurrency: s.flagIsCurrency,
                  amountLabel: amountLabel(seriesTotal(s.key)),
                ),
            ],
            hiddenKeys: _hiddenKeys,
            onToggle: _toggle,
            showSubcategories: showSubToggle ? widget.showSubcategories : null,
            onShowSubcategoriesChanged: showSubToggle
                ? widget.onShowSubcategoriesChanged
                : null,
          )
        : BreakdownChartLegend(
            items: [
              for (final s in all)
                (
                  key: s.key,
                  label: s.label,
                  color: s.color,
                  iconKey: s.iconKey,
                  flagCode: s.flagCode,
                  flagIsCurrency: s.flagIsCurrency,
                  amountLabel: amountLabel(
                    s.amountMinor,
                    currencyCode: s.currencyCode,
                  ),
                ),
            ],
            hiddenKeys: _hiddenKeys,
            onToggle: _toggle,
            showSubcategories: showSubToggle ? widget.showSubcategories : null,
            onShowSubcategoriesChanged: showSubToggle
                ? widget.onShowSubcategoriesChanged
                : null,
          );

    return padClearOfEndSystemBar(
      context,
      Column(
        children: [
          ChartOverlayControls(
            chartType: widget.chartType,
            onChartTypeChanged: widget.onChartTypeChanged,
            availableChartTypes: widget.availableChartTypes,
          ),
          const SizedBox(height: 4),
          plot,
          if (showBreakdownRow) ...[
            const SizedBox(height: 4),
            ChartBreakdownRow(
              selected: widget.breakdown!,
              onChanged: widget.onBreakdownChanged!,
              cashFlowPeriodOnly: widget.cashFlowPeriodOnly,
            ),
          ],
          const SizedBox(height: 8),
          legend,
        ],
      ),
    );
  }
}

bool _textFitsWidth(String text, TextStyle? style, double maxWidth) {
  final painter = TextPainter(
    text: TextSpan(text: text, style: style),
    maxLines: 1,
    textDirection: TextDirection.ltr,
  )..layout();
  return painter.width <= maxWidth;
}

class _ChartCenterTotal extends StatelessWidget {
  final String label;
  final String primaryText;
  final String compactText;

  const _ChartCenterTotal({
    required this.label,
    required this.primaryText,
    required this.compactText,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final amountStyle = theme.textTheme.titleMedium?.copyWith(
      fontWeight: FontWeight.w700,
    );
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxWidth = constraints.maxWidth;
        final amountText = _textFitsWidth(primaryText, amountStyle, maxWidth)
            ? primaryText
            : compactText;
        return FittedBox(
          fit: BoxFit.scaleDown,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              Text(amountText, maxLines: 1, style: amountStyle),
            ],
          ),
        );
      },
    );
  }
}
