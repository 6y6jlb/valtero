class ExpenseFilter {
  final int? tagId;
  final String? currencyCode;
  final DateTime? from;
  final DateTime? to;

  const ExpenseFilter({
    this.tagId,
    this.currencyCode,
    this.from,
    this.to,
  });

  static const empty = ExpenseFilter();

  ExpenseFilter copyWith({
    int? tagId,
    bool clearTagId = false,
    String? currencyCode,
    bool clearCurrencyCode = false,
    DateTime? from,
    bool clearFrom = false,
    DateTime? to,
    bool clearTo = false,
  }) {
    return ExpenseFilter(
      tagId: clearTagId ? null : (tagId ?? this.tagId),
      currencyCode:
          clearCurrencyCode ? null : (currencyCode ?? this.currencyCode),
      from: clearFrom ? null : (from ?? this.from),
      to: clearTo ? null : (to ?? this.to),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is ExpenseFilter &&
        other.tagId == tagId &&
        other.currencyCode == currencyCode &&
        other.from == from &&
        other.to == to;
  }

  @override
  int get hashCode => Object.hash(tagId, currencyCode, from, to);
}
