import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:valtero/shared/consts/palette.dart';
import 'package:valtero/shared/consts/payment_methods.dart';
import 'package:valtero/shared/database/app_database.dart';
import 'package:valtero/shared/database/database_provider.dart';
import 'package:valtero/shared/settings/app_settings_provider.dart';

class ManagePaymentMethodsController {
  final Ref ref;

  ManagePaymentMethodsController(this.ref);

  AppDatabase get _db => ref.read(appDatabaseProvider);

  Future<void> seedDefaults() async {
    for (final key in paymentMethodSeedKeys) {
      await _db.ensurePaymentMethodByStableKey(
        stableKey: key,
        fallbackName: key,
        isDefault: true,
        colorValue: defaultTagColorValues[key],
      );
    }
    await _ensureDefaultPaymentMethod();
  }

  /// Prefer card as the app default until the user picks something else.
  Future<void> _ensureDefaultPaymentMethod() async {
    final settings = ref.read(appSettingsProvider).value;
    if (settings == null || settings.defaultPaymentMethodId != null) return;
    final card = await _db.findPaymentMethodByStableKey(
      kDefaultPaymentMethodStableKey,
    );
    if (card == null) return;
    await ref
        .read(appSettingsProvider.notifier)
        .setDefaultPaymentMethodId(card.id);
  }

  Future<int> addCustom({
    required String name,
    int? colorValue,
  }) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return -1;
    final all = await _db.getAllPaymentMethods();
    final nextOrder = all.isEmpty
        ? 0
        : all.map((p) => p.sortOrder).reduce((a, b) => a > b ? a : b) + 1;
    return _db.insertPaymentMethod(
      PaymentMethodsCompanion.insert(
        name: trimmed,
        colorValue: Value(colorValue),
        isDefault: const Value(false),
        sortOrder: Value(nextOrder),
      ),
    );
  }

  Future<void> rename(PaymentMethod method, String name) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return;
    await (_db.update(_db.paymentMethods)
          ..where((p) => p.id.equals(method.id)))
        .write(
      PaymentMethodsCompanion(
        name: Value(trimmed),
        stableKey: const Value(null),
      ),
    );
  }

  Future<void> setColor(PaymentMethod method, int? colorValue) async {
    await (_db.update(_db.paymentMethods)
          ..where((p) => p.id.equals(method.id)))
        .write(
      PaymentMethodsCompanion(colorValue: Value(colorValue)),
    );
  }

  Future<void> delete(int id) async {
    final methods = await _db.getAllPaymentMethods();
    final target = methods.where((m) => m.id == id).firstOrNull;
    if (target == null || target.isDefault) return;

    await _db.deletePaymentMethodById(id);
    final settings = ref.read(appSettingsProvider).value;
    if (settings?.defaultPaymentMethodId == id) {
      await ref
          .read(appSettingsProvider.notifier)
          .setDefaultPaymentMethodId(null);
    }
  }
}

final managePaymentMethodsControllerProvider =
    Provider<ManagePaymentMethodsController>((ref) {
  return ManagePaymentMethodsController(ref);
});
