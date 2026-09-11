/// Which side of cash flow the dashboard / list currently shows.
///
/// [cashFlow] is first so tab order defaults to it.
enum TransactionDirection { cashFlow, expenses, income }

extension TransactionDirectionPersistence on TransactionDirection {
  String get settingsValue => name;

  static TransactionDirection fromSettings(String? raw) {
    return switch (raw) {
      'expenses' => TransactionDirection.expenses,
      'income' => TransactionDirection.income,
      _ => TransactionDirection.cashFlow,
    };
  }
}
