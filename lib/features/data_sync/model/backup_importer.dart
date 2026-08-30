import 'package:drift/drift.dart';
import 'package:valtero/features/data_sync/model/backup_format.dart';
import 'package:valtero/shared/database/app_database.dart';
import 'package:valtero/shared/settings/app_settings.dart';

class ImportReport {
  final int expensesAdded;
  final int tagsAdded;
  final int paymentsAdded;
  final int expensesSkippedDuplicate;
  final bool settingsApplied;

  const ImportReport({
    required this.expensesAdded,
    required this.tagsAdded,
    required this.paymentsAdded,
    this.expensesSkippedDuplicate = 0,
    this.settingsApplied = false,
  });
}

/// Merges a validated [BackupEnvelope] into the local database (+ optional settings).
class BackupImporter {
  Future<ImportReport> importEnvelope({
    required AppDatabase db,
    required BackupEnvelope envelope,
    required AppSettings currentSettings,
    required Future<void> Function(AppSettings updated) saveSettings,
    bool applySettings = false,
    Set<String> skipClientIds = const {},
    Set<String> forceUniqueClientIds = const {},
  }) async {
    envelope.validateForImport();

    final data = envelope.data;
    var tagsAdded = 0;
    var paymentsAdded = 0;
    var expensesAdded = 0;
    var expensesSkippedDuplicate = 0;

    final existingTags = await db.watchTagsList();
    final existingMethods = await db.getAllPaymentMethods();

    final tagIdByStableKey = <String, int>{};
    final tagIdByNameKind = <String, int>{};
    for (final t in existingTags) {
      final key = t.stableKey;
      if (key != null && key.isNotEmpty) {
        tagIdByStableKey[key] = t.id;
      }
      tagIdByNameKind[_nameKindKey(t.name, t.kind)] = t.id;
    }

    final paymentIdByStableKey = <String, int>{};
    final paymentIdByName = <String, int>{};
    for (final m in existingMethods) {
      final key = m.stableKey;
      if (key != null && key.isNotEmpty) {
        paymentIdByStableKey[key] = m.id;
      }
      paymentIdByName[m.name] = m.id;
    }

    for (final tag in data.tags) {
      final resolved = await _resolveOrCreateTag(
        db: db,
        tag: tag,
        tagIdByStableKey: tagIdByStableKey,
        tagIdByNameKind: tagIdByNameKind,
      );
      if (resolved.created) tagsAdded++;
    }

    for (final method in data.paymentMethods) {
      final resolved = await _resolveOrCreatePayment(
        db: db,
        method: method,
        paymentIdByStableKey: paymentIdByStableKey,
        paymentIdByName: paymentIdByName,
      );
      if (resolved.created) paymentsAdded++;
    }

    final localExpenseIdByClientId = <String, int>{};

    for (final expense in data.expenses) {
      if (skipClientIds.contains(expense.clientId)) {
        expensesSkippedDuplicate++;
        continue;
      }

      final paymentId = _lookupPaymentId(
        stableKey: expense.paymentStableKey,
        name: expense.paymentName,
        paymentIdByStableKey: paymentIdByStableKey,
        paymentIdByName: paymentIdByName,
      );

      final markUnique = forceUniqueClientIds.contains(expense.clientId);
      final newId = await db.insertExpense(
        ExpensesCompanion.insert(
          occurredAt: expense.occurredAt,
          originalAmountMinor: expense.originalAmountMinor,
          originalCurrencyCode: expense.originalCurrencyCode,
          storedAmountMinor: expense.storedAmountMinor,
          storedCurrencyCode: expense.storedCurrencyCode,
          rateUsed: Value(expense.rateUsed),
          rateTimestamp: Value(expense.rateTimestamp),
          paymentMethodId: Value(paymentId),
          countryCode: Value(expense.countryCode),
          note: Value(expense.note),
          createdAt: expense.createdAt,
          duplicateDismissed: Value(
            markUnique || expense.duplicateDismissed,
          ),
        ),
      );
      localExpenseIdByClientId[expense.clientId] = newId;
      expensesAdded++;
    }

    final tagsByNewExpense = <int, List<int>>{};
    for (final link in data.expenseTags) {
      final expenseId = localExpenseIdByClientId[link.expenseClientId];
      if (expenseId == null) continue;
      final tagId = _lookupTagId(
        stableKey: link.tagStableKey,
        name: link.tagName,
        kind: link.tagKind ?? 'normal',
        tagIdByStableKey: tagIdByStableKey,
        tagIdByNameKind: tagIdByNameKind,
      );
      if (tagId == null) continue;
      tagsByNewExpense.putIfAbsent(expenseId, () => []).add(tagId);
    }
    for (final entry in tagsByNewExpense.entries) {
      await db.setExpenseTags(entry.key, entry.value);
    }

    for (final rate in data.exchangeRateOverrides) {
      if (rate.baseCurrencyCode.isEmpty || rate.targetCurrencyCode.isEmpty) {
        continue;
      }
      await db.upsertRate(
        base: rate.baseCurrencyCode,
        target: rate.targetCurrencyCode,
        source: 'manual',
        rate: rate.rate,
        fetchedAt: rate.fetchedAt,
      );
    }

    var settingsApplied = false;
    if (applySettings) {
      final s = data.settings;
      final updated = currentSettings.copyWith(
        reportingCurrencies: s.reportingCurrencies,
        primaryCurrency: s.primaryCurrency,
        customCurrencyCodes: s.customCurrencyCodes,
        themeMode: s.themeMode,
        locale: s.locale,
        moneyDisplayFormat: s.moneyDisplayFormat,
        dateDisplayFormat: s.dateDisplayFormat,
        timeZoneId: s.timeZoneId,
        dismissedTagSuggestions: s.dismissedTagSuggestions,
      );
      await saveSettings(updated);
      settingsApplied = true;
    }

    return ImportReport(
      expensesAdded: expensesAdded,
      tagsAdded: tagsAdded,
      paymentsAdded: paymentsAdded,
      expensesSkippedDuplicate: expensesSkippedDuplicate,
      settingsApplied: settingsApplied,
    );
  }

  Future<_ResolvedId> _resolveOrCreateTag({
    required AppDatabase db,
    required BackupTagData tag,
    required Map<String, int> tagIdByStableKey,
    required Map<String, int> tagIdByNameKind,
  }) async {
    final stable = tag.stableKey?.trim();
    if (stable != null && stable.isNotEmpty) {
      final existing = tagIdByStableKey[stable];
      if (existing != null) {
        return _ResolvedId(existing, created: false);
      }
    }

    final nameKind = _nameKindKey(tag.name, tag.kind);
    final byName = tagIdByNameKind[nameKind];
    if (byName != null) {
      if (stable != null && stable.isNotEmpty) {
        tagIdByStableKey[stable] = byName;
      }
      return _ResolvedId(byName, created: false);
    }

    if (stable != null && stable.isNotEmpty) {
      final id = await db.ensureTagByStableKey(
        stableKey: stable,
        fallbackName: tag.name,
        isDefault: tag.isDefault,
        kind: tag.kind,
        colorValue: tag.colorValue,
      );
      tagIdByStableKey[stable] = id;
      tagIdByNameKind[nameKind] = id;
      return _ResolvedId(id, created: true);
    }

    final id = await db.insertTag(
      TagsCompanion.insert(
        name: tag.name,
        kind: Value(tag.kind),
        colorValue: Value(tag.colorValue),
        countryCode: Value(tag.countryCode),
        isDefault: Value(tag.isDefault),
        sortOrder: Value(tag.sortOrder),
      ),
    );
    tagIdByNameKind[nameKind] = id;
    return _ResolvedId(id, created: true);
  }

  Future<_ResolvedId> _resolveOrCreatePayment({
    required AppDatabase db,
    required BackupPaymentMethodData method,
    required Map<String, int> paymentIdByStableKey,
    required Map<String, int> paymentIdByName,
  }) async {
    final stable = method.stableKey?.trim();
    if (stable != null && stable.isNotEmpty) {
      final existing = paymentIdByStableKey[stable];
      if (existing != null) {
        return _ResolvedId(existing, created: false);
      }
    }

    final byName = paymentIdByName[method.name];
    if (byName != null) {
      if (stable != null && stable.isNotEmpty) {
        paymentIdByStableKey[stable] = byName;
      }
      return _ResolvedId(byName, created: false);
    }

    if (stable != null && stable.isNotEmpty) {
      final id = await db.ensurePaymentMethodByStableKey(
        stableKey: stable,
        fallbackName: method.name,
        isDefault: method.isDefault,
        colorValue: method.colorValue,
      );
      paymentIdByStableKey[stable] = id;
      paymentIdByName[method.name] = id;
      return _ResolvedId(id, created: true);
    }

    final id = await db.insertPaymentMethod(
      PaymentMethodsCompanion.insert(
        name: method.name,
        colorValue: Value(method.colorValue),
        isDefault: Value(method.isDefault),
        sortOrder: Value(method.sortOrder),
      ),
    );
    paymentIdByName[method.name] = id;
    return _ResolvedId(id, created: true);
  }

  int? _lookupTagId({
    required String? stableKey,
    required String? name,
    required String kind,
    required Map<String, int> tagIdByStableKey,
    required Map<String, int> tagIdByNameKind,
  }) {
    final stable = stableKey?.trim();
    if (stable != null && stable.isNotEmpty) {
      final id = tagIdByStableKey[stable];
      if (id != null) return id;
    }
    if (name == null || name.isEmpty) return null;
    return tagIdByNameKind[_nameKindKey(name, kind)];
  }

  int? _lookupPaymentId({
    required String? stableKey,
    required String? name,
    required Map<String, int> paymentIdByStableKey,
    required Map<String, int> paymentIdByName,
  }) {
    final stable = stableKey?.trim();
    if (stable != null && stable.isNotEmpty) {
      final id = paymentIdByStableKey[stable];
      if (id != null) return id;
    }
    if (name == null || name.isEmpty) return null;
    return paymentIdByName[name];
  }

  String _nameKindKey(String name, String kind) =>
      '${name.toLowerCase()}|$kind';
}

class _ResolvedId {
  final int id;
  final bool created;
  const _ResolvedId(this.id, {required this.created});
}
