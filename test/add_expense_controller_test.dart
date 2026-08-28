import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:valtero/entities/exchange_rate/model/rate_providers.dart';
import 'package:valtero/entities/exchange_rate/model/rate_resolver.dart';
import 'package:valtero/entities/exchange_rate/model/exchange_rate_provider.dart';
import 'package:valtero/entities/exchange_rate/model/exchange_rate_store.dart';
import 'package:valtero/features/add_expense/model/add_expense_controller.dart';
import 'package:valtero/shared/database/app_database.dart';
import 'package:valtero/shared/database/database_provider.dart';
import 'package:valtero/shared/settings/app_settings.dart';

class _NoopProvider implements ExchangeRateProvider {
  @override
  String get id => 'noop';

  @override
  bool get requiresApiKey => false;

  @override
  Future<Map<String, double>> fetchRates({
    required String base,
    required List<String> targets,
    String? apiKey,
  }) async =>
      {};

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
      exchangeRateApi: _NoopProvider(),
      frankfurter: _NoopProvider(),
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

  test('save persists countryCode and tags', () async {
    final tagId = await db.insertTag(TagsCompanion.insert(name: 'food'));
    final controller = container.read(addExpenseControllerProvider);
    final id = await controller.save(
      AddExpenseInput(
        originalAmountMinor: 2500,
        originalCurrencyCode: 'usd',
        convert: false,
        tagIds: [tagId],
        countryCode: 'at',
        note: 'coffee',
        occurredAt: DateTime(2026, 3, 1),
      ),
    );

    final row = await db.getExpenseById(id);
    expect(row, isNotNull);
    expect(row!.countryCode, 'AT');
    expect(row.originalAmountMinor, 2500);
    expect(row.originalCurrencyCode, 'USD');
    expect(row.note, 'coffee');
    expect(await db.getTagIdsForExpense(id), [tagId]);
  });

  test('update changes amount and country', () async {
    final controller = container.read(addExpenseControllerProvider);
    final id = await controller.save(
      AddExpenseInput(
        originalAmountMinor: 1000,
        originalCurrencyCode: 'EUR',
        convert: false,
        countryCode: 'DE',
        occurredAt: DateTime(2026, 3, 1),
      ),
    );

    await controller.update(
      id,
      AddExpenseInput(
        originalAmountMinor: 2000,
        originalCurrencyCode: 'EUR',
        convert: false,
        countryCode: 'ES',
        occurredAt: DateTime(2026, 3, 2),
      ),
    );

    final row = await db.getExpenseById(id);
    expect(row!.originalAmountMinor, 2000);
    expect(row.countryCode, 'ES');
    expect(row.occurredAt.day, 2);
  });
}
