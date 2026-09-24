import 'package:flutter_test/flutter_test.dart';
import 'package:valtero/features/expenses_list/model/chart_breakdown_options.dart';
import 'package:valtero/features/expenses_list/model/cycle_index.dart';
import 'package:valtero/features/expenses_list/model/expense_list_view.dart';
import 'package:valtero/features/expenses_list/model/transaction_direction.dart';

void main() {
  group('cycleIndex', () {
    test('steps forward and wraps', () {
      expect(cycleIndex([1, 2, 3], 1, forward: true), 2);
      expect(cycleIndex([1, 2, 3], 3, forward: true), 1);
    });

    test('steps backward and wraps', () {
      expect(cycleIndex([1, 2, 3], 1, forward: false), 3);
      expect(cycleIndex([1, 2, 3], 2, forward: false), 1);
    });

    test('missing current returns first', () {
      expect(cycleIndex(['a', 'b'], 'z', forward: true), 'a');
    });

    test('empty list returns current', () {
      expect(cycleIndex<int>([], 7, forward: true), 7);
    });
  });

  group('consumeHorizontalCycleDelta', () {
    test('accumulates below threshold without steps', () {
      final r = consumeHorizontalCycleDelta(accum: 0, dx: -20);
      expect(r.steps, 0);
      expect(r.accum, -20);
    });

    test('negative dx past threshold fires forward steps', () {
      final r = consumeHorizontalCycleDelta(accum: 0, dx: -56);
      expect(r.steps, 1);
      expect(r.forward, isTrue);
      expect(r.accum, 0);
    });

    test('positive dx past threshold fires previous steps', () {
      final r = consumeHorizontalCycleDelta(accum: 0, dx: 112);
      expect(r.steps, 2);
      expect(r.forward, isFalse);
      expect(r.accum, 0);
    });

    test('keeps remainder after steps', () {
      final r = consumeHorizontalCycleDelta(accum: -10, dx: -60);
      expect(r.steps, 1);
      expect(r.forward, isTrue);
      expect(r.accum, -14);
    });
  });

  group('chart breakdown order cycle', () {
    test('expense order wraps currency to country', () {
      expect(
        cycleIndex(
          kExpenseChartBreakdownOrder,
          ExpenseChartBreakdown.currency,
          forward: true,
        ),
        ExpenseChartBreakdown.country,
      );
    });

    test('cash-flow order wraps year to day', () {
      expect(
        cycleIndex(
          kCashFlowChartBreakdownOrder,
          ExpenseChartBreakdown.year,
          forward: true,
        ),
        ExpenseChartBreakdown.day,
      );
    });
  });

  group('direction tab cycle', () {
    test('cashFlow → expenses → income → cashFlow', () {
      expect(
        cycleIndex(
          TransactionDirection.values,
          TransactionDirection.cashFlow,
          forward: true,
        ),
        TransactionDirection.expenses,
      );
      expect(
        cycleIndex(
          TransactionDirection.values,
          TransactionDirection.expenses,
          forward: true,
        ),
        TransactionDirection.income,
      );
      expect(
        cycleIndex(
          TransactionDirection.values,
          TransactionDirection.income,
          forward: true,
        ),
        TransactionDirection.cashFlow,
      );
    });
  });
}
