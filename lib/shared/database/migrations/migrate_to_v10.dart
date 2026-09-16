import 'package:drift/drift.dart';
import 'package:valtero/shared/database/app_database.dart';

/// v10: optional [PaymentMethods.iconKey] (same curated catalog as tags).
Future<void> migrateToV10(Migrator m, AppDatabase db) async {
  await m.addColumn(db.paymentMethods, db.paymentMethods.iconKey);
}
