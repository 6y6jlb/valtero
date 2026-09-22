import 'package:flutter/material.dart';
import 'package:valtero/features/expenses_list/model/chart_overlay_layout.dart';
import 'package:valtero/features/expenses_list/model/expense_list_view.dart';
import 'package:valtero/features/expenses_list/ui/chart_toggle_icon.dart';
import 'package:valtero/shared/l10n/generated/app_localizations.dart';

/// Compact chart breakdown toggles.
///
/// When [compact] is true, buttons use the same 36px footprint as
/// [ChartToggleIcon]. Otherwise they stay at 48px for standalone rows.
///
/// When [maxIconsPerRow] is set (e.g. 4 on narrow screens), icons wrap into
/// rows of that length. Otherwise they stay in one row when width allows,
/// or split evenly into two rows.
class ChartBreakdownIcons extends StatelessWidget {
  final ExpenseChartBreakdown selected;
  final ValueChanged<ExpenseChartBreakdown> onChanged;
  final bool compact;
  final int? maxIconsPerRow;

  const ChartBreakdownIcons({
    super.key,
    required this.selected,
    required this.onChanged,
    this.compact = false,
    this.maxIconsPerRow,
  });

  double get _iconExtent => compact ? ChartToggleIcon.extent : 48.0;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final muted = theme.colorScheme.onSurfaceVariant;
    final extent = _iconExtent;

    Widget iconBtn({
      required ExpenseChartBreakdown value,
      required IconData icon,
      required String tooltip,
    }) {
      final isSelected = selected == value;
      return IconButton(
        tooltip: tooltip,
        visualDensity: VisualDensity.compact,
        constraints: BoxConstraints(
          minWidth: extent,
          minHeight: extent,
        ),
        padding: EdgeInsets.zero,
        onPressed: () => onChanged(value),
        icon: Icon(
          icon,
          size: compact ? ChartToggleIcon.iconSize : null,
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
      iconBtn(
        value: ExpenseChartBreakdown.country,
        icon: Icons.public,
        tooltip: l10n.chartByTagCountry,
      ),
      iconBtn(
        value: ExpenseChartBreakdown.payment,
        icon: Icons.payments_outlined,
        tooltip: l10n.chartByPayment,
      ),
      iconBtn(
        value: ExpenseChartBreakdown.tagCustom,
        icon: Icons.label_outline,
        tooltip: l10n.chartByTagCustom,
      ),
      iconBtn(
        value: ExpenseChartBreakdown.day,
        icon: Icons.today_outlined,
        tooltip: l10n.chartByDay,
      ),
      iconBtn(
        value: ExpenseChartBreakdown.week,
        icon: Icons.date_range_outlined,
        tooltip: l10n.chartByWeek,
      ),
      iconBtn(
        value: ExpenseChartBreakdown.month,
        icon: Icons.calendar_month,
        tooltip: l10n.chartByMonth,
      ),
      iconBtn(
        value: ExpenseChartBreakdown.year,
        icon: Icons.calendar_today,
        tooltip: l10n.chartByYear,
      ),
      iconBtn(
        value: ExpenseChartBreakdown.currency,
        icon: Icons.currency_exchange,
        tooltip: l10n.chartByCurrency,
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final n = icons.length;
        final forced = maxIconsPerRow;
        final List<int> rowLengths;
        if (forced != null && forced > 0 && forced < n) {
          rowLengths = chunkChartOverlayIconRows(n, forced);
        } else if (constraints.maxWidth.isFinite &&
            constraints.maxWidth < extent * n) {
          final topCount = (n + 1) ~/ 2;
          rowLengths = [topCount, n - topCount];
        } else {
          rowLengths = [n];
        }

        if (rowLengths.length == 1) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: icons,
          );
        }

        final rows = <Widget>[];
        var offset = 0;
        for (var i = 0; i < rowLengths.length; i++) {
          final len = rowLengths[i];
          if (i > 0) {
            rows.add(const SizedBox(height: kChartOverlayIconRowGap));
          }
          rows.add(
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: icons.sublist(offset, offset + len),
            ),
          );
          offset += len;
        }
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: rows,
        );
      },
    );
  }
}
