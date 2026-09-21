import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:valtero/entities/exchange_rate/model/exchange_rate_provider.dart';
import 'package:valtero/entities/exchange_rate/model/exchange_rate_store.dart';
import 'package:valtero/entities/exchange_rate/model/rate_resolver.dart';
import 'package:valtero/features/expenses_list/model/expense_chart_aggregator.dart';
import 'package:valtero/features/expenses_list/model/expense_list_view.dart';
import 'package:valtero/shared/database/app_database.dart';
import 'package:valtero/shared/settings/app_settings.dart';

class _FakeProvider implements ExchangeRateProvider {
  _FakeProvider(this.rates);

  final Map<String, double> rates;

  @override
  String get id => 'fake';

  @override
  bool get requiresApiKey => false;

  @override
  Future<Map<String, double>> fetchRates({
    required String base,
    required List<String> targets,
    String? apiKey,
  }) async => rates;

  @override
  Future<Map<String, double>> fetchAllRates({
    required String base,
    String? apiKey,
  }) async => rates;

  @override
  Future<bool> validateApiKey(String apiKey) async => true;
}

Expense _expense({
  required int id,
  required String currency,
  required int amountMinor,
  DateTime? occurredAt,
}) {
  final at = occurredAt ?? DateTime(2026, 1, 15);
  return Expense(
    kind: 'expense',
    id: id,
    occurredAt: at,
    originalAmountMinor: amountMinor,
    originalCurrencyCode: currency,
    storedAmountMinor: amountMinor,
    storedCurrencyCode: currency,
    createdAt: at,
    duplicateDismissed: false,
  );
}

void main() {
  late RateResolver resolver;

  setUpAll(() {
    tzdata.initializeTimeZones();
  });

  setUp(() {
    var settings = AppSettings.initial();
    resolver = RateResolver(
      store: InMemoryExchangeRateStore(),
      exchangeRateApi: _FakeProvider({}),
      frankfurter: _FakeProvider({}),
      readSettings: () => settings,
      writeSettings: (s) async => settings = s,
    );
  });

  test('includes expense without rate using native amount', () async {
    final result = await aggregateExpensesForChart(
      expenses: [
        _expense(id: 1, currency: 'USD', amountMinor: 1000),
        _expense(id: 2, currency: 'EUR', amountMinor: 2000),
      ],
      primaryCurrency: 'USD',
      resolver: resolver,
      breakdown: ExpenseChartBreakdown.currency,
      expenseTags: const {},
      tagLabels: const {},
      tagById: const {},
      untaggedLabel: '—',
    );

    expect(result.missingRateCount, 1);
    expect(result.slices.length, 2);
    final eur = result.slices.firstWhere((s) => s.key == 'EUR');
    expect(eur.amountMinor, 2000);
    expect(eur.currencyCode, 'EUR');
  });

  test('missingRateCount is zero when all rates exist', () async {
    await resolver.setManualRate(base: 'EUR', target: 'USD', rate: 1.1);
    final result = await aggregateExpensesForChart(
      expenses: [_expense(id: 1, currency: 'EUR', amountMinor: 1000)],
      primaryCurrency: 'USD',
      resolver: resolver,
      breakdown: ExpenseChartBreakdown.month,
      expenseTags: const {},
      tagLabels: const {},
      tagById: const {},
      untaggedLabel: '—',
    );
    expect(result.missingRateCount, 0);
    expect(result.slices, isNotEmpty);
  });

  test('category slices keep tag iconKey including subcategories', () async {
    final parent = Tag(
      id: 1,
      name: 'Food',
      colorValue: 0xFF00FF00,
      isDefault: false,
      sortOrder: 1,
      kind: 'normal',
      countryCode: null,
      stableKey: null,
      iconKey: 'food',
      parentTagId: null,
    );
    final child = Tag(
      id: 2,
      name: 'Cafe',
      colorValue: 0xFF0000FF,
      isDefault: false,
      sortOrder: 2,
      kind: 'normal',
      countryCode: null,
      stableKey: null,
      iconKey: 'coffee',
      parentTagId: 1,
    );
    final at = DateTime(2026, 1, 15);
    final expense = Expense(
      kind: 'expense',
      id: 10,
      occurredAt: at,
      originalAmountMinor: 500,
      originalCurrencyCode: 'USD',
      storedAmountMinor: 500,
      storedCurrencyCode: 'USD',
      createdAt: at,
      duplicateDismissed: false,
    );
    final result = await aggregateExpensesForChart(
      expenses: [expense],
      primaryCurrency: 'USD',
      resolver: resolver,
      breakdown: ExpenseChartBreakdown.tagCustom,
      expenseTags: {
        10: [2],
      },
      tagLabels: {1: 'Food', 2: 'Cafe'},
      tagById: {1: parent, 2: child},
      untaggedLabel: '—',
      includeSubcategories: true,
    );
    expect(result.slices, hasLength(1));
    expect(result.slices.single.key, 'tag_2');
    expect(result.slices.single.iconKey, 'coffee');
  });

  test(
    'time series date breakdown buckets by selected period not auto',
    () async {
      final result = await aggregateExpensesForTimeSeries(
        expenses: [
          _expense(
            id: 1,
            currency: 'USD',
            amountMinor: 1000,
            occurredAt: DateTime(2026, 1, 10),
          ),
          _expense(
            id: 2,
            currency: 'USD',
            amountMinor: 2000,
            occurredAt: DateTime(2026, 2, 10),
          ),
        ],
        primaryCurrency: 'USD',
        resolver: resolver,
        targetBreakdown: ExpenseChartBreakdown.month,
        expenseTags: const {},
        tagLabels: const {},
        tagById: const {},
        untaggedLabel: '—',
        otherLabel: 'Other',
        periodFrom: DateTime(2026, 1, 1),
        periodTo: DateTime(2026, 2, 28),
      );
      // Auto would pick day for ~59 days; month breakdown must keep months.
      expect(result.points, hasLength(2));
      expect(result.series, isEmpty);
      expect(result.points.map((p) => p.totalMinor).toList(), [1000, 2000]);
      expect(result.points.every((p) => p.amountBySeriesKey.isEmpty), isTrue);
    },
  );

  test(
    'time series category breakdown still emits per-series amounts',
    () async {
      final result = await aggregateExpensesForTimeSeries(
        expenses: [
          _expense(
            id: 1,
            currency: 'USD',
            amountMinor: 1000,
            occurredAt: DateTime(2026, 1, 10),
          ),
          _expense(
            id: 2,
            currency: 'EUR',
            amountMinor: 500,
            occurredAt: DateTime(2026, 1, 11),
          ),
        ],
        primaryCurrency: 'USD',
        resolver: resolver,
        targetBreakdown: ExpenseChartBreakdown.currency,
        expenseTags: const {},
        tagLabels: const {},
        tagById: const {},
        untaggedLabel: '—',
        otherLabel: 'Other',
        periodFrom: DateTime(2026, 1, 1),
        periodTo: DateTime(2026, 1, 31),
      );
      expect(result.series, isNotEmpty);
      expect(result.points.any((p) => p.amountBySeriesKey.isNotEmpty), isTrue);
    },
  );
}
