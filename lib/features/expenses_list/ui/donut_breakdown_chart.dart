import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:valtero/features/expenses_list/model/donut_chart_layout.dart';
import 'package:valtero/features/expenses_list/model/donut_chart_slice.dart';
import 'package:valtero/features/expenses_list/ui/chart_anim.dart';
import 'package:valtero/features/expenses_list/ui/chart_overlay_controls.dart';
import 'package:valtero/features/expenses_list/ui/chart_tooltip_style.dart';
import 'package:valtero/shared/l10n/generated/app_localizations.dart';
import 'package:valtero/widgets/money_text.dart';

/// Shared donut: amounts on segments, legend chips toggle visibility,
/// optional tap on a visible segment.
///
/// When [hiddenKeys] is provided (parent-owned legend), those keys drive
/// visibility. Otherwise the widget keeps its own set when [showLegend] is on.
/// Hidden slices keep a near-zero value so the pie can tween instead of jump.
///
/// Hover / long-press shows a floating tip over the ring (fl_chart has no
/// built-in pie tooltip).
class DonutBreakdownChart extends ConsumerStatefulWidget {
  final List<DonutChartSlice> slices;
  final Set<String>? hiddenKeys;
  final String displayCurrency;
  final ValueChanged<DonutChartSlice>? onSegmentTap;
  final bool showTotal;
  final bool hideCenterTotal;
  final bool hideSegmentAmounts;
  final bool showLegend;
  final double chartHeight;
  final double sectionRadius;
  final String? emptyMessage;
  final Widget? centerOverlay;

  const DonutBreakdownChart({
    super.key,
    required this.slices,
    this.hiddenKeys,
    required this.displayCurrency,
    this.onSegmentTap,
    this.showTotal = true,
    this.hideCenterTotal = false,
    this.hideSegmentAmounts = false,
    this.showLegend = true,
    this.chartHeight = 312,
    this.sectionRadius = kDonutSectionRadius,
    this.emptyMessage,
    this.centerOverlay,
  });

  @override
  ConsumerState<DonutBreakdownChart> createState() =>
      _DonutBreakdownChartState();
}

class _DonutBreakdownChartState extends ConsumerState<DonutBreakdownChart> {
  final Set<String> _localHiddenKeys = {};
  int? _hoveredIndex;

  Set<String> get _hiddenKeys => widget.hiddenKeys ?? _localHiddenKeys;

  @override
  void didUpdateWidget(covariant DonutBreakdownChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.hiddenKeys != null) return;
    final nextKeys = {for (final s in widget.slices) s.key};
    final oldKeys = {for (final s in oldWidget.slices) s.key};
    if (nextKeys.length != oldKeys.length || !nextKeys.containsAll(oldKeys)) {
      _localHiddenKeys.removeWhere((k) => !nextKeys.contains(k));
      _hoveredIndex = null;
    }
  }

  void _toggle(String key) {
    if (widget.hiddenKeys != null) return;
    setState(() {
      if (_localHiddenKeys.contains(key)) {
        _localHiddenKeys.remove(key);
      } else {
        _localHiddenKeys.add(key);
      }
    });
  }

  void _setHover(int? index) {
    if (_hoveredIndex == index) return;
    setState(() => _hoveredIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final all = widget.slices;
    if (all.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: Text(widget.emptyMessage ?? l10n.noMatchingExpenses),
        ),
      );
    }

    final hidden = _hiddenKeys;
    final visible = all
        .where((s) => !hidden.contains(s.key))
        .toList(growable: false);
    final total = visible.fold<int>(0, (sum, s) => sum + s.amountMinor);

    final hiddenFlags = [for (final slice in all) hidden.contains(slice.key)];
    final rawValues = [
      for (var i = 0; i < all.length; i++)
        hiddenFlags[i]
            ? 0.0001
            : (all[i].amountMinor.toDouble().abs() == 0
                  ? 1.0
                  : all[i].amountMinor.toDouble().abs()),
    ];
    final sectionValues = computeDonutSectionValues(
      rawValues,
      hidden: hiddenFlags,
    );

    final hover = _hoveredIndex;
    DonutChartSlice? hoverSlice;
    if (hover != null &&
        hover >= 0 &&
        hover < all.length &&
        !hidden.contains(all[hover].key)) {
      hoverSlice = all[hover];
    }

    return Column(
      children: [
        SizedBox(
          height: widget.chartHeight,
          child: visible.isEmpty
              ? Center(child: Text(l10n.noMatchingExpenses))
              : Padding(
                  padding: kDonutPlotPadding,
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final radii = fitDonutChartRadii(
                        width: constraints.maxWidth,
                        height: constraints.maxHeight,
                        preferredSection: widget.sectionRadius,
                      );
                      final overlay = widget.centerOverlay;
                      return ClipRect(
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            PieChart(
                              PieChartData(
                                sectionsSpace: 2,
                                centerSpaceRadius: radii.centerSpaceRadius,
                                pieTouchData: PieTouchData(
                                  touchCallback: (event, response) {
                                    final index = response
                                        ?.touchedSection
                                        ?.touchedSectionIndex;
                                    if (event is FlPointerExitEvent) {
                                      _setHover(null);
                                    } else if (index != null &&
                                        index >= 0 &&
                                        index < all.length &&
                                        !hidden.contains(all[index].key)) {
                                      _setHover(index);
                                    } else if (event is FlTapUpEvent ||
                                        event is FlLongPressEnd ||
                                        event is FlPanEndEvent) {
                                      // Keep tip until leave / next segment.
                                    } else if (response?.touchedSection ==
                                        null) {
                                      _setHover(null);
                                    }

                                    if (widget.onSegmentTap == null) return;
                                    if (event is! FlTapUpEvent) return;
                                    if (index == null ||
                                        index < 0 ||
                                        index >= all.length) {
                                      return;
                                    }
                                    if (hidden.contains(all[index].key)) {
                                      return;
                                    }
                                    widget.onSegmentTap!(all[index]);
                                  },
                                  mouseCursorResolver: (event, response) {
                                    if (widget.onSegmentTap == null) {
                                      return SystemMouseCursors.basic;
                                    }
                                    final index = response
                                        ?.touchedSection
                                        ?.touchedSectionIndex;
                                    if (index != null &&
                                        index >= 0 &&
                                        index < all.length &&
                                        !hidden.contains(all[index].key)) {
                                      return SystemMouseCursors.click;
                                    }
                                    return SystemMouseCursors.basic;
                                  },
                                ),
                                sections: [
                                  for (var i = 0; i < all.length; i++)
                                    _sectionData(
                                      slice: all[i],
                                      value: sectionValues[i],
                                      isHidden: hidden.contains(all[i].key),
                                      radius: radii.sectionRadius,
                                    ),
                                ],
                              ),
                              duration: kChartAnimDuration,
                              curve: kChartAnimCurve,
                            ),
                            if (overlay != null)
                              IgnorePointer(
                                child: SizedBox(
                                  width:
                                      radii.centerSpaceRadius *
                                      2 *
                                      kDonutCenterTotalWidthFactor,
                                  child: overlay,
                                ),
                              ),
                            if (hoverSlice != null)
                              Positioned(
                                top: 8,
                                left: 8,
                                right: 8,
                                child: IgnorePointer(
                                  child: Align(
                                    alignment: Alignment.topCenter,
                                    child: _DonutHoverTip(
                                      slice: hoverSlice,
                                      displayCurrency: widget.displayCurrency,
                                      hideAmount: widget.hideSegmentAmounts,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
        ),
        if (widget.showLegend && all.isNotEmpty) ...[
          const SizedBox(height: 8),
          Wrap(
            spacing: 10,
            runSpacing: 6,
            alignment: WrapAlignment.center,
            children: [
              for (final slice in all)
                _LegendChip(
                  label: slice.label,
                  color: slice.color,
                  visible: !hidden.contains(slice.key),
                  onTap: () => _toggle(slice.key),
                ),
            ],
          ),
        ],
        if (widget.showTotal &&
            !widget.hideCenterTotal &&
            visible.isNotEmpty) ...[
          const SizedBox(height: 12),
          MoneyText(
            amountMinor: total,
            currencyCode: widget.displayCurrency,
            style: theme.textTheme.titleMedium,
          ),
        ],
      ],
    );
  }

  PieChartSectionData _sectionData({
    required DonutChartSlice slice,
    required double value,
    required bool isHidden,
    required double radius,
  }) {
    return PieChartSectionData(
      value: value,
      title: isHidden
          ? ''
          : (widget.hideSegmentAmounts
                ? slice.label
                : '${slice.label}\n${formatMoneyOf(context, ref, amountMinor: slice.amountMinor, currencyCode: slice.currencyCode ?? widget.displayCurrency)}'),
      color: isHidden ? slice.color.withValues(alpha: 0) : slice.color,
      radius: isHidden ? 0 : radius,
      titleStyle: const TextStyle(
        fontSize: 9,
        color: Colors.white,
        fontWeight: FontWeight.w600,
        height: 1.15,
      ),
    );
  }
}

class _DonutHoverTip extends ConsumerWidget {
  final DonutChartSlice slice;
  final String displayCurrency;
  final bool hideAmount;

  const _DonutHoverTip({
    required this.slice,
    required this.displayCurrency,
    required this.hideAmount,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Material(
      color: chartTooltipBg(context),
      borderRadius: BorderRadius.circular(8),
      elevation: 1,
      shadowColor: Colors.black26,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              slice.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: chartTooltipTitleStyle(context),
            ),
            if (!hideAmount) ...[
              const SizedBox(height: 2),
              Text(
                formatMoneyOf(
                  context,
                  ref,
                  amountMinor: slice.amountMinor,
                  currencyCode: slice.currencyCode ?? displayCurrency,
                ),
                maxLines: 1,
                style: chartTooltipBodyStyle(context, color: slice.color),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _LegendChip extends StatelessWidget {
  final String label;
  final Color color;
  final bool visible;
  final VoidCallback onTap;

  const _LegendChip({
    required this.label,
    required this.color,
    required this.visible,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurfaceVariant;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: visible ? color : theme.colorScheme.outlineVariant,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: theme.textTheme.labelMedium?.copyWith(
                color: visible ? null : muted,
                decoration: visible ? null : TextDecoration.lineThrough,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
