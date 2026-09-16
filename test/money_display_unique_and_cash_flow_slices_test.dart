import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:valtero/features/expenses_list/model/cash_flow_aggregator.dart';
import 'package:valtero/shared/utils/money_display.dart';

void main() {
  group('uniqueMoneyDisplayFormats', () {
    test('keeps all five formats for en_US USD when previews differ', () {
      final unique = uniqueMoneyDisplayFormats(
        localeName: 'en_US',
        currencyCode: 'USD',
      );
      expect(unique, contains(MoneyDisplayFormat.localeSymbol));
      expect(unique, contains(MoneyDisplayFormat.localeCode));
      expect(unique, contains(MoneyDisplayFormat.isoBefore));
      expect(unique, contains(MoneyDisplayFormat.plain));
      expect(unique, contains(MoneyDisplayFormat.compactSymbol));
    });

    test('collapses localeSymbol and localeCode when only NBSP differs', () {
      final unique = uniqueMoneyDisplayFormats(
        localeName: 'ru',
        currencyCode: 'RUB',
      );
      final symbol = normalizeMoneyPreview(
        formatMoneyDisplay(
          amountMinor: 123456,
          currencyCode: 'RUB',
          localeName: 'ru',
          format: MoneyDisplayFormat.localeSymbol,
        ),
      );
      final code = normalizeMoneyPreview(
        formatMoneyDisplay(
          amountMinor: 123456,
          currencyCode: 'RUB',
          localeName: 'ru',
          format: MoneyDisplayFormat.localeCode,
        ),
      );
      if (symbol == code) {
        expect(unique, isNot(contains(MoneyDisplayFormat.localeCode)));
        expect(unique, contains(MoneyDisplayFormat.localeSymbol));
      }
      expect(unique, contains(MoneyDisplayFormat.plain));
      expect(unique, contains(MoneyDisplayFormat.compactSymbol));
    });

    test('resolveUniqueMoneyDisplayFormat maps collapsed twin', () {
      final unique = uniqueMoneyDisplayFormats(
        localeName: 'ru',
        currencyCode: 'RUB',
      );
      final resolved = resolveUniqueMoneyDisplayFormat(
        selected: MoneyDisplayFormat.localeCode,
        uniqueFormats: unique,
        localeName: 'ru',
        currencyCode: 'RUB',
      );
      expect(unique.contains(resolved), isTrue);
    });
  });

  group('cashFlowDirectionSlices', () {
    test('builds income and expense slices from buckets', () {
      const buckets = [
        CashFlowBucket(
          key: '2026-01',
          label: '2026-01',
          incomeTotalMinor: 10000,
          expenseTotalMinor: 4000,
        ),
        CashFlowBucket(
          key: '2026-02',
          label: '2026-02',
          incomeTotalMinor: 5000,
          expenseTotalMinor: 2000,
        ),
      ];
      final slices = cashFlowDirectionSlices(
        buckets: buckets,
        incomeLabel: 'Income',
        expenseLabel: 'Expense',
        incomeColor: const Color(0xFF00AA00),
        expenseColor: const Color(0xFFAA0000),
      );
      expect(slices, hasLength(2));
      expect(slices[0].key, 'income');
      expect(slices[0].amountMinor, 15000);
      expect(slices[1].key, 'expense');
      expect(slices[1].amountMinor, 6000);
    });

    test('omits zero sides', () {
      const buckets = [
        CashFlowBucket(
          key: '2026-01',
          label: '2026-01',
          incomeTotalMinor: 1000,
          expenseTotalMinor: 0,
        ),
      ];
      final slices = cashFlowDirectionSlices(
        buckets: buckets,
        incomeLabel: 'Income',
        expenseLabel: 'Expense',
        incomeColor: const Color(0xFF00AA00),
        expenseColor: const Color(0xFFAA0000),
      );
      expect(slices, hasLength(1));
      expect(slices.single.key, 'income');
    });
  });
}
