/// Tag maps and sort hints passed into expense groupers.
class ExpenseGroupingContext {
  final Map<int, List<int>> expenseTags;
  final Map<int, String> tagLabels;
  final String untaggedLabel;
  final bool ascending;

  const ExpenseGroupingContext({
    required this.expenseTags,
    required this.tagLabels,
    required this.untaggedLabel,
    this.ascending = false,
  });
}
