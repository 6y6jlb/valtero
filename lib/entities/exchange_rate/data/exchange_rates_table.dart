import 'package:drift/drift.dart';

/// Cache and manual overrides. [source] is exchangerate_api | frankfurter | manual.
class ExchangeRates extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get baseCurrencyCode => text().withLength(min: 3, max: 3)();
  TextColumn get targetCurrencyCode => text().withLength(min: 3, max: 3)();
  TextColumn get source => text()();
  RealColumn get rate => real()();
  DateTimeColumn get fetchedAt => dateTime()();

  @override
  List<Set<Column>> get uniqueKeys => [
        {baseCurrencyCode, targetCurrencyCode, source},
      ];
}
