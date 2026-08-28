import 'package:drift/drift.dart';
import 'package:valtero/entities/payment_method/data/payment_methods_table.dart';
import 'package:valtero/entities/tag/data/tags_table.dart';

class Expenses extends Table {
  IntColumn get id => integer().autoIncrement()();
  DateTimeColumn get occurredAt => dateTime()();
  IntColumn get originalAmountMinor => integer()();
  TextColumn get originalCurrencyCode => text().withLength(min: 3, max: 3)();
  IntColumn get storedAmountMinor => integer()();
  TextColumn get storedCurrencyCode => text().withLength(min: 3, max: 3)();
  RealColumn get rateUsed => real().nullable()();
  DateTimeColumn get rateTimestamp => dateTime().nullable()();
  /// Legacy single-tag column (schema v1). Prefer [ExpenseTags]. Kept for migration.
  IntColumn get tagId => integer().nullable().references(Tags, #id)();
  IntColumn get paymentMethodId =>
      integer().nullable().references(PaymentMethods, #id)();
  TextColumn get note => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
}
