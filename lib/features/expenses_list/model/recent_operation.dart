import 'package:valtero/shared/database/app_database.dart';

/// Which entity a merged cash-flow recent-operations row represents.
enum OperationKind { expense, income }

/// Minimal merged view of an [Expense] or [Income] row for the cash-flow
/// direction's recent operations list. Keeps a reference to the source row
/// so edit/delete actions can reuse the existing expense/income flows.
class RecentOperation {
  final OperationKind kind;
  final int id;
  final DateTime occurredAt;
  final int amountMinor;
  final String currencyCode;
  final bool possibleDuplicate;
  final Expense? expense;
  final Income? income;

  const RecentOperation._({
    required this.kind,
    required this.id,
    required this.occurredAt,
    required this.amountMinor,
    required this.currencyCode,
    this.possibleDuplicate = false,
    this.expense,
    this.income,
  });

  /// Underlying row; `Expense` and `Income` are the same Drift type.
  Operation get row => (expense ?? income)!;

  int? get paymentMethodId =>
      expense?.paymentMethodId ?? income?.paymentMethodId;

  String? get countryCode => expense?.countryCode ?? income?.countryCode;

  int get originalAmountMinor => row.originalAmountMinor;

  String get originalCurrencyCode => row.originalCurrencyCode;

  double? get rateUsed => row.rateUsed;

  String? get note => row.note;

  /// Signed amount for cash-flow math: income positive, expenses negative.
  int get signedAmountMinor =>
      kind == OperationKind.income ? amountMinor : -amountMinor;

  factory RecentOperation.fromExpense(
    Expense expense, {
    bool possibleDuplicate = false,
  }) =>
      RecentOperation._(
        kind: OperationKind.expense,
        id: expense.id,
        occurredAt: expense.occurredAt,
        amountMinor: expense.storedAmountMinor,
        currencyCode: expense.storedCurrencyCode,
        possibleDuplicate: possibleDuplicate,
        expense: expense,
      );

  factory RecentOperation.fromIncome(
    Income income, {
    bool possibleDuplicate = false,
  }) =>
      RecentOperation._(
        kind: OperationKind.income,
        id: income.id,
        occurredAt: income.occurredAt,
        amountMinor: income.storedAmountMinor,
        currencyCode: income.storedCurrencyCode,
        possibleDuplicate: possibleDuplicate,
        income: income,
      );
}

/// Merges expenses + incomes into a single date-sorted (desc) list, used by
/// the cash-flow direction's recent operations section.
List<RecentOperation> mergeRecentOperations({
  required List<Expense> expenses,
  required List<Income> incomes,
  Set<int> possibleDuplicateExpenseIds = const {},
  Set<int> possibleDuplicateIncomeIds = const {},
}) {
  final merged = [
    for (final e in expenses)
      RecentOperation.fromExpense(
        e,
        possibleDuplicate: possibleDuplicateExpenseIds.contains(e.id),
      ),
    for (final i in incomes)
      RecentOperation.fromIncome(
        i,
        possibleDuplicate: possibleDuplicateIncomeIds.contains(i.id),
      ),
  ]..sort((a, b) => b.occurredAt.compareTo(a.occurredAt));
  return merged;
}
