import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:valtero/features/expenses_list/model/chart_time_series.dart';
import 'package:valtero/features/expenses_list/model/donut_chart_slice.dart';
import 'package:valtero/features/expenses_list/model/expense_list_view.dart';
import 'package:valtero/features/expenses_list/ui/breakdown_chart_legend.dart';
import 'package:valtero/features/expenses_list/ui/chart_empty_placeholder.dart';
import 'package:valtero/features/expenses_list/ui/chart_overlay_controls.dart';
import 'package:valtero/features/expenses_list/ui/chart_selection_panel.dart';
import 'package:valtero/features/expenses_list/ui/column_breakdown_chart.dart';
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

/// Donut / column / time-series chart with overlay type + breakdown controls
/// and an overlay total for slice charts only.
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
  ChartSelectionDetail? _selection;

  @override
  void didUpdateWidget(covariant BreakdownChartView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.chartType != widget.chartType) {
      _selection = null;
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
      _selection = null;
    }
  }

  void _setSelection(ChartSelectionDetail? detail) {
    if (identical(_selection, detail)) return;
    if (_selection == null && detail == null) return;
    if (_selection != null &&
        detail != null &&
        _selection!.title == detail.title &&
        _sameLines(_selection!.lines, detail.lines)) {
      return;
    }
    setState(() => _selection = detail);
  }

  static bool _sameLines(
    List<ChartSelectionLine> a,
    List<ChartSelectionLine> b,
  ) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i].label != b[i].label || a[i].amountText != b[i].amountText) {
        return false;
      }
    }
    return true;
  }

  void _toggle(String key) {
    setState(() {
      if (_hiddenKeys.contains(key)) {
        _hiddenKeys.remove(key);
      } else {
        _hiddenKeys.add(key);
      }
      _selection = null;
    });
  }

  Widget _buildChartChild({
    required AppLocalizations l10n,
    required List<DonutChartSlice> allSlices,
    required List<ChartSeriesDef> allSeries,
    required Set<String> hiddenKeys,
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
        );
      case ExpenseChartType.column:
        return ColumnBreakdownChart(
          slices: allSlices,
          hiddenKeys: hiddenKeys,
          displayCurrency: widget.displayCurrency,
          onSegmentTap: widget.onSegmentTap,
          onSelectionChanged: _setSelection,
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
          onSelectionChanged: _setSelection,
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
          onSelectionChanged: _setSelection,
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

    final showFloatingTotal =
        widget.showTotal &&
        !widget.hideCenterTotal &&
        !isTimeSeries &&
        visible.isNotEmpty &&
        (widget.chartType == ExpenseChartType.donut ||
            widget.chartType == ExpenseChartType.column);

    final showSubToggle =
        widget.breakdown == ExpenseChartBreakdown.tagCustom &&
        widget.onShowSubcategoriesChanged != null;

    return Column(
      children: [
        SizedBox(
          height: widget.chartHeight,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // Chart first so overlay actions paint and receive hits on top —
              // tooltips must not block the type / breakdown controls.
              AnimatedSwitcher(
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
                  ),
                ),
              ),
              if (showFloatingTotal &&
                  widget.chartType == ExpenseChartType.column &&
                  _selection == null)
                Positioned(
                  top: 0,
                  left: 0,
                  child: IgnorePointer(
                    child: _ChartTotalBadge(
                      label: l10n.summaryTotal,
                      primaryText: totalPrimaryText,
                      compactText: totalCompactText,
                    ),
                  ),
                ),
              if (showFloatingTotal &&
                  widget.chartType == ExpenseChartType.donut)
                Positioned.fill(
                  child: IgnorePointer(
                    child: Padding(
                      // Match DonutBreakdownChart top inset so the total
                      // stays centered in the ring under the overlay.
                      padding: const EdgeInsets.only(
                        top: kChartOverlayTopInset,
                      ),
                      child: Center(
                        child: _ChartCenterTotal(
                          label: l10n.summaryTotal,
                          primaryText: totalPrimaryText,
                          compactText: totalCompactText,
                        ),
                      ),
                    ),
                  ),
                ),
              // Selection badge: same corner as the column sum badge; absolute
              // so it never resizes the column / legend below.
              if (widget.chartType != ExpenseChartType.donut)
                Positioned(
                  top: 0,
                  left: 0,
                  child: ChartSelectionPanel(detail: _selection),
                ),
              Align(
                alignment: Alignment.topRight,
                child: ChartOverlayControls(
                  chartType: widget.chartType,
                  onChartTypeChanged: widget.onChartTypeChanged,
                  availableChartTypes: widget.availableChartTypes,
                  breakdown: widget.breakdown,
                  onBreakdownChanged: widget.onBreakdownChanged,
                  cashFlowPeriodOnly: widget.cashFlowPeriodOnly,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        if (isTimeSeries)
          BreakdownChartLegend(
            items: [
              if (widget.chartType == ExpenseChartType.line)
                (
                  key: kChartTotalSeriesKey,
                  label: l10n.summaryTotal,
                  color: theme.colorScheme.onSurface,
                  iconKey: null,
                  flagCode: null,
                  flagIsCurrency: false,
                ),
              for (final s in allSeries)
                (
                  key: s.key,
                  label: s.label,
                  color: s.color,
                  iconKey: s.iconKey,
                  flagCode: s.flagCode,
                  flagIsCurrency: s.flagIsCurrency,
                ),
            ],
            hiddenKeys: _hiddenKeys,
            onToggle: _toggle,
            showSubcategories: showSubToggle ? widget.showSubcategories : null,
            onShowSubcategoriesChanged: showSubToggle
                ? widget.onShowSubcategoriesChanged
                : null,
          )
        else
          BreakdownChartLegend(
            items: [
              for (final s in all)
                (
                  key: s.key,
                  label: s.label,
                  color: s.color,
                  iconKey: s.iconKey,
                  flagCode: s.flagCode,
                  flagIsCurrency: s.flagIsCurrency,
                ),
            ],
            hiddenKeys: _hiddenKeys,
            onToggle: _toggle,
            showSubcategories: showSubToggle ? widget.showSubcategories : null,
            onShowSubcategoriesChanged: showSubToggle
                ? widget.onShowSubcategoriesChanged
                : null,
          ),
      ],
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

  static const _maxWidth = kDonutCenterSpaceRadius * 2 * 0.82;

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
    final amountText = _textFitsWidth(primaryText, amountStyle, _maxWidth)
        ? primaryText
        : compactText;
    return SizedBox(
      width: _maxWidth,
      child: FittedBox(
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
      ),
    );
  }
}

class _ChartTotalBadge extends StatelessWidget {
  final String label;
  final String primaryText;
  final String compactText;

  static const _maxWidth = 120.0;

  const _ChartTotalBadge({
    required this.label,
    required this.primaryText,
    required this.compactText,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final amountStyle = theme.textTheme.titleSmall?.copyWith(
      fontWeight: FontWeight.w700,
    );
    final amountText = _textFitsWidth(primaryText, amountStyle, _maxWidth)
        ? primaryText
        : compactText;
    return Material(
      color: theme.colorScheme.surface.withValues(alpha: 0.88),
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: _maxWidth),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
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
          ),
        ),
      ),
    );
  }
}
