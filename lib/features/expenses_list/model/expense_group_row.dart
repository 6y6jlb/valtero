/// One aggregated row in the expenses grouping table.
class ExpenseGroupRow {
  final String groupLabel;
  final int count;
  final int amountMinor;
  final String currencyCode;

  const ExpenseGroupRow({
    required this.groupLabel,
    required this.count,
    required this.amountMinor,
    required this.currencyCode,
  });
}
