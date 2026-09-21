import 'package:drift/drift.dart';
import 'package:valtero/entities/payment_method/data/payment_methods_table.dart';
import 'package:valtero/shared/utils/sync_id.dart';

@TableIndex(name: 'operations_kind_occurred_at', columns: {#kind, #occurredAt})
@TableIndex(name: 'operations_sync_id', columns: {#syncId}, unique: true)
class Operations extends Table {
  IntColumn get id => integer().autoIncrement()();
  /// Cross-device identity for sync / backup merge (UUID v4).
  TextColumn get syncId => text().clientDefault(newSyncId)();
  /// `'expense'` or `'income'`.
  TextColumn get kind => text()();
  DateTimeColumn get occurredAt => dateTime()();
  IntColumn get originalAmountMinor => integer()();
  TextColumn get originalCurrencyCode => text().withLength(min: 3, max: 3)();
  IntColumn get storedAmountMinor => integer()();
  TextColumn get storedCurrencyCode => text().withLength(min: 3, max: 3)();
  RealColumn get rateUsed => real().nullable()();
  DateTimeColumn get rateTimestamp => dateTime().nullable()();
  IntColumn get paymentMethodId =>
      integer().nullable().references(PaymentMethods, #id)();
  /// ISO 3166-1 alpha-2 country code (e.g. `RU`), not a tag.
  TextColumn get countryCode => text().nullable()();
  TextColumn get note => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  /// Last local create/edit/delete clock — used for last-write-wins sync.
  DateTimeColumn get updatedAt =>
      dateTime().clientDefault(() => DateTime.now())();
  /// Soft-delete tombstone; live rows have `null`.
  DateTimeColumn get deletedAt => dateTime().nullable()();
  /// User confirmed this row is not a duplicate of others sharing
  /// the same day + original amount + currency fingerprint.
  BoolColumn get duplicateDismissed =>
      boolean().withDefault(const Constant(false))();
}
