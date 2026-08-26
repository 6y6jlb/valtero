enum ExpenseListSortField { date, amount, currency }

enum ExpenseListGroup { none, currency, date, tag }

/// Filter / sort / group options for the expenses browsing sheet.
class ExpenseListQuery {
  final Set<int> tagIds;
  final String? currencyCode;
  final DateTime? from;
  final DateTime? to;
  final ExpenseListSortField sort;
  final bool ascending;
  final ExpenseListGroup group;

  const ExpenseListQuery({
    this.tagIds = const {},
    this.currencyCode,
    this.from,
    this.to,
    this.sort = ExpenseListSortField.date,
    this.ascending = false,
    this.group = ExpenseListGroup.none,
  });

  ExpenseListQuery copyWith({
    Set<int>? tagIds,
    String? currencyCode,
    bool clearCurrencyCode = false,
    DateTime? from,
    bool clearFrom = false,
    DateTime? to,
    bool clearTo = false,
    ExpenseListSortField? sort,
    bool? ascending,
    ExpenseListGroup? group,
  }) {
    return ExpenseListQuery(
      tagIds: tagIds ?? this.tagIds,
      currencyCode:
          clearCurrencyCode ? null : (currencyCode ?? this.currencyCode),
      from: clearFrom ? null : (from ?? this.from),
      to: clearTo ? null : (to ?? this.to),
      sort: sort ?? this.sort,
      ascending: ascending ?? this.ascending,
      group: group ?? this.group,
    );
  }
}
