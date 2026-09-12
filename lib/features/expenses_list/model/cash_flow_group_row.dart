/// One aggregated row in the cash-flow grouping table. Unlike
/// `ExpenseGroupRow` it keeps both directions so the table can show
/// income / expenses / net side by side.
class CashFlowGroupRow {
  final String groupLabel;
  final String currencyCode;
  final int count;
  final int incomeMinor;
  final int expenseMinor;

  const CashFlowGroupRow({
    required this.groupLabel,
    required this.currencyCode,
    required this.count,
    required this.incomeMinor,
    required this.expenseMinor,
  });

  int get netMinor => incomeMinor - expenseMinor;
}
