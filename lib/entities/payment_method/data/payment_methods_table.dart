import 'package:drift/drift.dart';

/// How an expense was paid (cash, card, crypto, …) — not a tag.
class PaymentMethods extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  IntColumn get colorValue => integer().nullable()();
  BoolColumn get isDefault => boolean().withDefault(const Constant(false))();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();

  /// Stable id for seeded methods, e.g. `cash`, `card`, `crypto`.
  TextColumn get stableKey => text().nullable()();
}
