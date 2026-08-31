import 'package:flutter/material.dart';
import 'package:valtero/features/expenses_list/model/expense_list_view.dart';
import 'package:valtero/shared/l10n/generated/app_localizations.dart';

/// Compact chart breakdown toggles.
///
/// When all icons fit on one line they stay in a single row; otherwise they
/// wrap into two rows split as evenly as possible (e.g. 4 + 4).
class ChartBreakdownIcons extends StatelessWidget {
  final ExpenseChartBreakdown selected;
  final ValueChanged<ExpenseChartBreakdown> onChanged;

  const ChartBreakdownIcons({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  static const _iconExtent = 48.0;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final muted = theme.colorScheme.onSurfaceVariant;

    Widget iconBtn({
      required ExpenseChartBreakdown value,
      required IconData icon,
      required String tooltip,
    }) {
      final isSelected = selected == value;
      return IconButton(
        tooltip: tooltip,
        visualDensity: VisualDensity.compact,
        onPressed: () => onChanged(value),
        icon: Icon(icon, color: isSelected ? primary : muted),
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
        final fitsOneRow = !constraints.maxWidth.isFinite ||
            constraints.maxWidth >= _iconExtent * n;
        if (fitsOneRow) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: icons,
          );
        }
        final topCount = (n + 1) ~/ 2;
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: icons.sublist(0, topCount),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: icons.sublist(topCount),
            ),
          ],
        );
      },
    );
  }
}
