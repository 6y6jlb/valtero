import 'package:drift/drift.dart';

class Tags extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  IntColumn get colorValue => integer().nullable()();
  BoolColumn get isDefault => boolean().withDefault(const Constant(false))();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
  /// `normal` (category). Legacy `country` / `trip` kinds are unused.
  TextColumn get kind => text().withDefault(const Constant('normal'))();
  TextColumn get countryCode => text().nullable()();
  /// Stable id for localized defaults/suggestions, e.g. `groceries`.
  TextColumn get stableKey => text().nullable()();
}
