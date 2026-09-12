import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:valtero/entities/exchange_rate/model/exchange_rate_provider.dart';
import 'package:valtero/entities/exchange_rate/model/exchange_rate_store.dart';
import 'package:valtero/entities/exchange_rate/model/rate_providers.dart';
import 'package:valtero/entities/exchange_rate/model/rate_resolver.dart';
import 'package:valtero/features/add_expense/model/add_expense_controller.dart';
import 'package:valtero/features/add_income/model/add_income_controller.dart';
import 'package:valtero/features/expenses_list/model/bulk_cash_flow_controller.dart';
import 'package:valtero/features/expenses_list/model/cash_flow_selection_key.dart';
import 'package:valtero/features/expenses_list/model/recent_operation.dart';
import 'package:valtero/shared/database/app_database.dart';
import 'package:valtero/shared/database/database_provider.dart';
import 'package:valtero/shared/settings/app_settings.dart';

class _FixedRateProvider implements ExchangeRateProvider {
  @override
  String get id => 'fixed';

  @override
  bool get requiresApiKey => false;

  @override
  Future<Map<String, double>> fetchRates({
    required String base,
    required List<String> targets,
    String? apiKey,
  }) async {
    return {for (final t in targets) t.toUpperCase(): 2.0};
  }

  @override
  Future<Map<String, double>> fetchAllRates({
    required String base,
    String? apiKey,
  }) async {
    return {'EUR': 2.0, 'USD': 2.0};
  }

  @override
  Future<bool> validateApiKey(String apiKey) async => true;
}

void main() {
  late AppDatabase db;
  late ProviderContainer container;
  late AppSettings settings;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    settings = AppSettings.initial();
    final resolver = RateResolver(
      store: InMemoryExchangeRateStore(),
      exchangeRateApi: _FixedRateProvider(),
      frankfurter: _FixedRateProvider(),
      readSettings: () => settings,
      writeSettings: (s) async => settings = s,
    );
    container = ProviderContainer(
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
        rateResolverProvider.overrideWithValue(resolver),
      ],
    );
  });

  tearDown(() async {
    container.dispose();
    await db.close();
  });

  test('partitionCashFlowSelection splits expense and income ids', () {
    final keys = {
      const CashFlowSelectionKey(OperationKind.expense, 1),
      const CashFlowSelectionKey(OperationKind.income, 2),
      const CashFlowSelectionKey(OperationKind.expense, 3),
    };
    final parts = partitionCashFlowSelection(keys);
    expect(parts.expenseIds, [1, 3]);
    expect(parts.incomeIds, [2]);
  });

  test('homogeneousCashFlowKind returns null for mixed selection', () {
    final keys = {
      const CashFlowSelectionKey(OperationKind.expense, 1),
      const CashFlowSelectionKey(OperationKind.income, 2),
    };
    expect(homogeneousCashFlowKind(keys), isNull);
    expect(
      homogeneousCashFlowKind({
        const CashFlowSelectionKey(OperationKind.income, 2),
      }),
      OperationKind.income,
    );
  });

  test('deleteMany removes both expenses and incomes', () async {
    final expenseId = await container.read(addExpenseControllerProvider).save(
          AddExpenseInput(
            originalAmountMinor: 100,
            originalCurrencyCode: 'USD',
            convert: false,
            occurredAt: DateTime(2026, 4, 1),
          ),
        );
    final incomeId = await container.read(addIncomeControllerProvider).save(
          AddIncomeInput(
            originalAmountMinor: 200,
            originalCurrencyCode: 'USD',
            convert: false,
            occurredAt: DateTime(2026, 4, 2),
          ),
        );

    await container.read(bulkCashFlowControllerProvider).deleteMany({
      CashFlowSelectionKey(OperationKind.expense, expenseId),
      CashFlowSelectionKey(OperationKind.income, incomeId),
    });

    expect(await db.getExpenseById(expenseId), isNull);
    expect(await db.getIncomeById(incomeId), isNull);
  });

  test('setCountry updates both kinds', () async {
    final expenseId = await container.read(addExpenseControllerProvider).save(
          AddExpenseInput(
            originalAmountMinor: 100,
            originalCurrencyCode: 'USD',
            convert: false,
            occurredAt: DateTime(2026, 4, 1),
          ),
        );
    final incomeId = await container.read(addIncomeControllerProvider).save(
          AddIncomeInput(
            originalAmountMinor: 200,
            originalCurrencyCode: 'USD',
            convert: false,
            occurredAt: DateTime(2026, 4, 2),
          ),
        );

    final keys = {
      CashFlowSelectionKey(OperationKind.expense, expenseId),
      CashFlowSelectionKey(OperationKind.income, incomeId),
    };
    await container.read(bulkCashFlowControllerProvider).setCountry(keys, 'fr');

    expect((await db.getExpenseById(expenseId))!.countryCode, 'FR');
    expect((await db.getIncomeById(incomeId))!.countryCode, 'FR');
  });

  test('convertToCurrency updates stored amounts for both kinds', () async {
    final expenseId = await container.read(addExpenseControllerProvider).save(
          AddExpenseInput(
            originalAmountMinor: 500,
            originalCurrencyCode: 'USD',
            convert: false,
            occurredAt: DateTime(2026, 4, 1),
          ),
        );
    final incomeId = await container.read(addIncomeControllerProvider).save(
          AddIncomeInput(
            originalAmountMinor: 700,
            originalCurrencyCode: 'USD',
            convert: false,
            occurredAt: DateTime(2026, 4, 2),
          ),
        );

    await container.read(bulkCashFlowControllerProvider).convertToCurrency(
      {
        CashFlowSelectionKey(OperationKind.expense, expenseId),
        CashFlowSelectionKey(OperationKind.income, incomeId),
      },
      'EUR',
    );

    expect((await db.getExpenseById(expenseId))!.storedCurrencyCode, 'EUR');
    expect((await db.getExpenseById(expenseId))!.storedAmountMinor, 1000);
    expect((await db.getIncomeById(incomeId))!.storedCurrencyCode, 'EUR');
    expect((await db.getIncomeById(incomeId))!.storedAmountMinor, 1400);
  });
}
