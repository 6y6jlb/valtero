import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:valtero/entities/exchange_rate/model/exchange_rate_provider.dart';
import 'package:valtero/entities/exchange_rate/model/exchange_rate_store.dart';
import 'package:valtero/entities/exchange_rate/model/rate_providers.dart';
import 'package:valtero/entities/exchange_rate/model/rate_resolver.dart';
import 'package:valtero/features/add_income/model/add_income_controller.dart';
import 'package:valtero/features/expenses_list/model/bulk_income_controller.dart';
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

  Future<int> _saveUsd(int minor) {
    return container.read(addIncomeControllerProvider).save(
          AddIncomeInput(
            originalAmountMinor: minor,
            originalCurrencyCode: 'USD',
            convert: false,
            occurredAt: DateTime(2026, 4, 1),
          ),
        );
  }

  test('setCountry updates all selected incomes', () async {
    final a = await _saveUsd(100);
    final b = await _saveUsd(200);
    await container.read(bulkIncomeControllerProvider).setCountry([a, b], 'de');

    expect((await db.getIncomeById(a))!.countryCode, 'DE');
    expect((await db.getIncomeById(b))!.countryCode, 'DE');
  });

  test('setTags replaces tags on all selected incomes', () async {
    final tagA = await db.insertTag(
      TagsCompanion.insert(name: 'a', kind: const Value('income')),
    );
    final tagB = await db.insertTag(
      TagsCompanion.insert(name: 'b', kind: const Value('income')),
    );
    final id = await container.read(addIncomeControllerProvider).save(
          AddIncomeInput(
            originalAmountMinor: 100,
            originalCurrencyCode: 'USD',
            convert: false,
            tagIds: [tagA],
            occurredAt: DateTime(2026, 4, 1),
          ),
        );

    await container.read(bulkIncomeControllerProvider).setTags([id], [tagB]);
    expect(await db.getTagIdsForIncome(id), [tagB]);
  });

  test('deleteMany removes incomes and their tags', () async {
    final tagId = await db.insertTag(
      TagsCompanion.insert(name: 'x', kind: const Value('income')),
    );
    final id = await container.read(addIncomeControllerProvider).save(
          AddIncomeInput(
            originalAmountMinor: 100,
            originalCurrencyCode: 'USD',
            convert: false,
            tagIds: [tagId],
            occurredAt: DateTime(2026, 4, 1),
          ),
        );

    await container.read(bulkIncomeControllerProvider).deleteMany([id]);
    expect(await db.getIncomeById(id), isNull);
    expect(await db.getTagIdsForIncome(id), isEmpty);
  });

  test('convertToCurrency updates stored amount from original', () async {
    final id = await _saveUsd(1000);
    await container
        .read(bulkIncomeControllerProvider)
        .convertToCurrency([id], 'EUR');

    final row = await db.getIncomeById(id);
    expect(row!.originalCurrencyCode, 'USD');
    expect(row.originalAmountMinor, 1000);
    expect(row.storedCurrencyCode, 'EUR');
    expect(row.storedAmountMinor, 2000);
    expect(row.rateUsed, 2.0);
  });
}
