import 'package:flutter/material.dart';
import 'package:valtero/features/expenses_list/model/expense_list_view.dart';
import 'package:valtero/shared/l10n/generated/app_localizations.dart';

/// Compact date-breakdown toggles for the cash-flow chart (day/week/month/year
/// only — no tag/payment/country/currency breakdowns apply to cash flow).
class CashFlowBreakdownIcons extends StatelessWidget {
  final ExpenseChartBreakdown selected;
  final ValueChanged<ExpenseChartBreakdown> onChanged;

  const CashFlowBreakdownIcons({
    super.key,
    required this.selected,
    required this.onChanged,
  });

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

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
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
      ],
    );
  }
}
