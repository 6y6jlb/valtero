import 'package:drift/drift.dart';
import 'package:valtero/features/data_sync/model/backup_format.dart';
import 'package:valtero/shared/database/app_database.dart';
import 'package:valtero/shared/finance/operation_fingerprint.dart';
import 'package:valtero/shared/settings/app_settings.dart';
import 'package:valtero/shared/utils/sync_id.dart';

class ImportReport {
  final int expensesAdded;
  final int tagsAdded;
  final int paymentsAdded;
  final int expensesSkippedDuplicate;
  final int incomesAdded;
  final int incomesSkippedDuplicate;
  final int expensesUpdated;
  final int incomesUpdated;
  final int expensesTombstoned;
  final int incomesTombstoned;
  final bool settingsApplied;

  const ImportReport({
    required this.expensesAdded,
    required this.tagsAdded,
    required this.paymentsAdded,
    this.expensesSkippedDuplicate = 0,
    this.incomesAdded = 0,
    this.incomesSkippedDuplicate = 0,
    this.expensesUpdated = 0,
    this.incomesUpdated = 0,
    this.expensesTombstoned = 0,
    this.incomesTombstoned = 0,
    this.settingsApplied = false,
  });
}

enum _MergeAction { added, updated, keptLocal }

class _MergeResult {
  final int localId;
  final _MergeAction action;
  final bool becameTombstone;
  final bool applyRemoteTags;

  const _MergeResult({
    required this.localId,
    required this.action,
    this.becameTombstone = false,
    required this.applyRemoteTags,
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
    var incomesAdded = 0;
    var incomesSkippedDuplicate = 0;
    var expensesUpdated = 0;
    var incomesUpdated = 0;
    var expensesTombstoned = 0;
    var incomesTombstoned = 0;

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

    // Second pass: wire parentTagId once all tags exist (parent may follow child).
    for (final tag in data.tags) {
      int? parentId;
      final parentKey = tag.parentStableKey?.trim();
      if (parentKey != null && parentKey.isNotEmpty) {
        parentId = tagIdByStableKey[parentKey];
      }
      if (parentId == null &&
          tag.parentName != null &&
          tag.parentName!.trim().isNotEmpty) {
        parentId = tagIdByNameKind[_nameKindKey(
          tag.parentName!,
          tag.parentKind ?? tag.kind,
        )];
      }
      if (parentId == null) continue;
      final childStable = tag.stableKey?.trim();
      int? childId;
      if (childStable != null && childStable.isNotEmpty) {
        childId = tagIdByStableKey[childStable];
      }
      childId ??= tagIdByNameKind[_nameKindKey(tag.name, tag.kind)];
      if (childId == null) continue;
      final resolvedChildId = childId;
      final existing = await (db.select(db.tags)
            ..where((t) => t.id.equals(resolvedChildId)))
          .getSingleOrNull();
      if (existing == null) continue;
      if (existing.parentTagId == parentId) continue;
      await (db.update(db.tags)..where((t) => t.id.equals(resolvedChildId)))
          .write(
        TagsCompanion(parentTagId: Value(parentId)),
      );
    }

    // Refresh maps after parent wiring so link lookup can disambiguate
    // same-name children under different parents.
    final tagsAfterParents = await db.watchTagsList();
    final tagParentById = <int, int?>{
      for (final t in tagsAfterParents) t.id: t.parentTagId,
    };
    final tagIdByNameKindParent = <String, int>{};
    for (final t in tagsAfterParents) {
      final key = t.stableKey;
      if (key != null && key.isNotEmpty) {
        tagIdByStableKey[key] = t.id;
      }
      tagIdByNameKind[_nameKindKey(t.name, t.kind)] = t.id;
      if (t.parentTagId != null) {
        tagIdByNameKindParent[
            '${_nameKindKey(t.name, t.kind)}|${t.parentTagId}'] = t.id;
      }
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
    final expenseAcceptRemoteTags = <int>{};
    final localExpenses = await db.getAllExpenses(includeDeleted: true);
    final expenseBySyncId = <String, Operation>{
      for (final e in localExpenses) e.syncId: e,
    };
    final expensesByFingerprint = <OperationFingerprint, List<Operation>>{};
    for (final e in localExpenses) {
      final key = fingerprintOf(
        occurredAt: e.occurredAt,
        originalAmountMinor: e.originalAmountMinor,
        originalCurrencyCode: e.originalCurrencyCode,
      );
      expensesByFingerprint.putIfAbsent(key, () => []).add(e);
    }

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
      final result = await _mergeIncomingOperation(
        db: db,
        kind: 'expense',
        clientId: expense.clientId,
        occurredAt: expense.occurredAt,
        originalAmountMinor: expense.originalAmountMinor,
        originalCurrencyCode: expense.originalCurrencyCode,
        storedAmountMinor: expense.storedAmountMinor,
        storedCurrencyCode: expense.storedCurrencyCode,
        rateUsed: expense.rateUsed,
        rateTimestamp: expense.rateTimestamp,
        paymentId: paymentId,
        countryCode: expense.countryCode,
        note: expense.note,
        createdAt: expense.createdAt,
        updatedAt: expense.updatedAt,
        deletedAt: expense.deletedAt,
        duplicateDismissed: markUnique || expense.duplicateDismissed,
        bySyncId: expenseBySyncId,
        byFingerprint: expensesByFingerprint,
        forceInsert: markUnique,
      );
      localExpenseIdByClientId[expense.clientId] = result.localId;
      if (result.applyRemoteTags) {
        expenseAcceptRemoteTags.add(result.localId);
      }
      switch (result.action) {
        case _MergeAction.added:
          expensesAdded++;
        case _MergeAction.updated:
          expensesUpdated++;
          if (result.becameTombstone) expensesTombstoned++;
        case _MergeAction.keptLocal:
          break;
      }
    }

    final tagsByExpense = <int, List<int>>{};
    for (final link in data.expenseTags) {
      final expenseId = localExpenseIdByClientId[link.expenseClientId];
      if (expenseId == null || !expenseAcceptRemoteTags.contains(expenseId)) {
        continue;
      }
      final tagId = _lookupTagId(
        stableKey: link.tagStableKey,
        name: link.tagName,
        kind: link.tagKind ?? 'normal',
        parentStableKey: link.parentStableKey,
        parentName: link.parentName,
        parentKind: link.parentKind,
        tagIdByStableKey: tagIdByStableKey,
        tagIdByNameKind: tagIdByNameKind,
        tagIdByNameKindParent: tagIdByNameKindParent,
        tagParentById: tagParentById,
      );
      if (tagId == null) continue;
      tagsByExpense.putIfAbsent(expenseId, () => []).add(tagId);
    }
    for (final entry in tagsByExpense.entries) {
      await db.setExpenseTags(entry.key, entry.value);
    }

    final localIncomeIdByClientId = <String, int>{};
    final incomeAcceptRemoteTags = <int>{};
    final localIncomes = await db.getAllIncome(includeDeleted: true);
    final incomeBySyncId = <String, Operation>{
      for (final e in localIncomes) e.syncId: e,
    };
    final incomesByFingerprint = <OperationFingerprint, List<Operation>>{};
    for (final e in localIncomes) {
      final key = fingerprintOf(
        occurredAt: e.occurredAt,
        originalAmountMinor: e.originalAmountMinor,
        originalCurrencyCode: e.originalCurrencyCode,
      );
      incomesByFingerprint.putIfAbsent(key, () => []).add(e);
    }

    for (final income in data.incomes) {
      if (skipClientIds.contains(income.clientId)) {
        incomesSkippedDuplicate++;
        continue;
      }

      final paymentId = _lookupPaymentId(
        stableKey: income.paymentStableKey,
        name: income.paymentName,
        paymentIdByStableKey: paymentIdByStableKey,
        paymentIdByName: paymentIdByName,
      );

      final markUnique = forceUniqueClientIds.contains(income.clientId);
      final result = await _mergeIncomingOperation(
        db: db,
        kind: 'income',
        clientId: income.clientId,
        occurredAt: income.occurredAt,
        originalAmountMinor: income.originalAmountMinor,
        originalCurrencyCode: income.originalCurrencyCode,
        storedAmountMinor: income.storedAmountMinor,
        storedCurrencyCode: income.storedCurrencyCode,
        rateUsed: income.rateUsed,
        rateTimestamp: income.rateTimestamp,
        paymentId: paymentId,
        countryCode: income.countryCode,
        note: income.note,
        createdAt: income.createdAt,
        updatedAt: income.updatedAt,
        deletedAt: income.deletedAt,
        duplicateDismissed: markUnique || income.duplicateDismissed,
        bySyncId: incomeBySyncId,
        byFingerprint: incomesByFingerprint,
        forceInsert: markUnique,
      );
      localIncomeIdByClientId[income.clientId] = result.localId;
      if (result.applyRemoteTags) {
        incomeAcceptRemoteTags.add(result.localId);
      }
      switch (result.action) {
        case _MergeAction.added:
          incomesAdded++;
        case _MergeAction.updated:
          incomesUpdated++;
          if (result.becameTombstone) incomesTombstoned++;
        case _MergeAction.keptLocal:
          break;
      }
    }

    final tagsByIncome = <int, List<int>>{};
    for (final link in data.incomeTags) {
      final incomeId = localIncomeIdByClientId[link.incomeClientId];
      if (incomeId == null || !incomeAcceptRemoteTags.contains(incomeId)) {
        continue;
      }
      final tagId = _lookupTagId(
        stableKey: link.tagStableKey,
        name: link.tagName,
        kind: link.tagKind ?? 'normal',
        parentStableKey: link.parentStableKey,
        parentName: link.parentName,
        parentKind: link.parentKind,
        tagIdByStableKey: tagIdByStableKey,
        tagIdByNameKind: tagIdByNameKind,
        tagIdByNameKindParent: tagIdByNameKindParent,
        tagParentById: tagParentById,
      );
      if (tagId == null) continue;
      tagsByIncome.putIfAbsent(incomeId, () => []).add(tagId);
    }
    for (final entry in tagsByIncome.entries) {
      await db.setIncomeTags(entry.key, entry.value);
    }

    for (final rate in data.exchangeRateOverrides) {
      if (rate.baseCurrencyCode.isEmpty || rate.targetCurrencyCode.isEmpty) {
        continue;
      }
      final source =
          rate.source.trim().isEmpty ? 'manual' : rate.source.trim();
      await db.upsertRateIfNewer(
        base: rate.baseCurrencyCode,
        target: rate.targetCurrencyCode,
        source: source,
        rate: rate.rate,
        fetchedAt: rate.fetchedAt,
      );
    }

    // Shared network-fetch cooldown: always take the later timestamp, even
    // when the rest of settings are not applied (Drive sync path).
    final remoteRefresh = data.settings.lastRateRefreshAt;
    final localRefresh = currentSettings.lastRateRefreshAt;
    final mergedRefresh = _laterDateTime(localRefresh, remoteRefresh);

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
        lastRateRefreshAt: mergedRefresh,
        clearLastRateRefreshAt: mergedRefresh == null,
      );
      await saveSettings(updated);
      settingsApplied = true;
    } else if (mergedRefresh != null &&
        (localRefresh == null || mergedRefresh.isAfter(localRefresh))) {
      await saveSettings(
        currentSettings.copyWith(lastRateRefreshAt: mergedRefresh),
      );
    }

    return ImportReport(
      expensesAdded: expensesAdded,
      tagsAdded: tagsAdded,
      paymentsAdded: paymentsAdded,
      expensesSkippedDuplicate: expensesSkippedDuplicate,
      incomesAdded: incomesAdded,
      incomesSkippedDuplicate: incomesSkippedDuplicate,
      expensesUpdated: expensesUpdated,
      incomesUpdated: incomesUpdated,
      expensesTombstoned: expensesTombstoned,
      incomesTombstoned: incomesTombstoned,
      settingsApplied: settingsApplied,
    );
  }

  /// Last-write-wins merge for one incoming expense or income row.
  Future<_MergeResult> _mergeIncomingOperation({
    required AppDatabase db,
    required String kind,
    required String clientId,
    required DateTime occurredAt,
    required int originalAmountMinor,
    required String originalCurrencyCode,
    required int storedAmountMinor,
    required String storedCurrencyCode,
    required double? rateUsed,
    required DateTime? rateTimestamp,
    required int? paymentId,
    required String? countryCode,
    required String? note,
    required DateTime createdAt,
    required DateTime updatedAt,
    required DateTime? deletedAt,
    required bool duplicateDismissed,
    required Map<String, Operation> bySyncId,
    required Map<OperationFingerprint, List<Operation>> byFingerprint,
    required bool forceInsert,
  }) async {
    Operation? match;
    if (!forceInsert && clientId.isNotEmpty) {
      match = bySyncId[clientId];
    }
    final fp = fingerprintOf(
      occurredAt: occurredAt,
      originalAmountMinor: originalAmountMinor,
      originalCurrencyCode: originalCurrencyCode,
    );
    if (match == null && !forceInsert) {
      final candidates = byFingerprint[fp] ?? const <Operation>[];
      if (candidates.length == 1) {
        match = candidates.first;
      } else if (candidates.length > 1) {
        // Align with conflict UI (live-only): a single live row among
        // tombstones is still a unique LWW converge, not an insert.
        final live = [
          for (final o in candidates)
            if (o.deletedAt == null) o,
        ];
        if (live.length == 1) {
          match = live.first;
        }
      }
    }

    if (match != null) {
      // Remote wins only when strictly newer.
      if (!updatedAt.isAfter(match.updatedAt)) {
        return _MergeResult(
          localId: match.id,
          action: _MergeAction.keptLocal,
          applyRemoteTags: false,
        );
      }

      final winningSyncId =
          _isUuidLike(clientId) ? clientId : match.syncId;
      final wasLive = match.deletedAt == null;
      final nowTombstone = deletedAt != null;

      await db.updateOperationRow(
        match.copyWith(
          syncId: winningSyncId,
          kind: kind,
          occurredAt: occurredAt,
          originalAmountMinor: originalAmountMinor,
          originalCurrencyCode: originalCurrencyCode,
          storedAmountMinor: storedAmountMinor,
          storedCurrencyCode: storedCurrencyCode,
          rateUsed: Value(rateUsed),
          rateTimestamp: Value(rateTimestamp),
          paymentMethodId: Value(paymentId),
          countryCode: Value(countryCode),
          note: Value(note),
          createdAt: createdAt,
          updatedAt: updatedAt,
          deletedAt: Value(deletedAt),
          duplicateDismissed: duplicateDismissed,
        ),
      );

      // Refresh indexes for subsequent rows in this import.
      bySyncId.remove(match.syncId);
      final refreshed = match.copyWith(
        syncId: winningSyncId,
        kind: kind,
        occurredAt: occurredAt,
        originalAmountMinor: originalAmountMinor,
        originalCurrencyCode: originalCurrencyCode,
        storedAmountMinor: storedAmountMinor,
        storedCurrencyCode: storedCurrencyCode,
        rateUsed: Value(rateUsed),
        rateTimestamp: Value(rateTimestamp),
        paymentMethodId: Value(paymentId),
        countryCode: Value(countryCode),
        note: Value(note),
        createdAt: createdAt,
        updatedAt: updatedAt,
        deletedAt: Value(deletedAt),
        duplicateDismissed: duplicateDismissed,
      );
      bySyncId[winningSyncId] = refreshed;
      final oldFp = fingerprintOf(
        occurredAt: match.occurredAt,
        originalAmountMinor: match.originalAmountMinor,
        originalCurrencyCode: match.originalCurrencyCode,
      );
      byFingerprint[oldFp]?.removeWhere((o) => o.id == match!.id);
      byFingerprint.putIfAbsent(fp, () => []).removeWhere((o) => o.id == match!.id);
      byFingerprint.putIfAbsent(fp, () => []).add(refreshed);

      return _MergeResult(
        localId: match.id,
        action: _MergeAction.updated,
        becameTombstone: wasLive && nowTombstone,
        applyRemoteTags: true,
      );
    }

    final syncId = _isUuidLike(clientId) ? clientId : newSyncId();
    final companion = OperationsCompanion.insert(
      syncId: Value(syncId),
      kind: kind,
      occurredAt: occurredAt,
      originalAmountMinor: originalAmountMinor,
      originalCurrencyCode: originalCurrencyCode,
      storedAmountMinor: storedAmountMinor,
      storedCurrencyCode: storedCurrencyCode,
      rateUsed: Value(rateUsed),
      rateTimestamp: Value(rateTimestamp),
      paymentMethodId: Value(paymentId),
      countryCode: Value(countryCode),
      note: Value(note),
      createdAt: createdAt,
      updatedAt: Value(updatedAt),
      deletedAt: Value(deletedAt),
      duplicateDismissed: Value(duplicateDismissed),
    );
    final newId = kind == 'income'
        ? await db.insertIncome(companion)
        : await db.insertExpense(companion);

    final inserted = Operation(
      id: newId,
      syncId: syncId,
      kind: kind,
      occurredAt: occurredAt,
      originalAmountMinor: originalAmountMinor,
      originalCurrencyCode: originalCurrencyCode,
      storedAmountMinor: storedAmountMinor,
      storedCurrencyCode: storedCurrencyCode,
      rateUsed: rateUsed,
      rateTimestamp: rateTimestamp,
      paymentMethodId: paymentId,
      countryCode: countryCode,
      note: note,
      createdAt: createdAt,
      updatedAt: updatedAt,
      deletedAt: deletedAt,
      duplicateDismissed: duplicateDismissed,
    );
    bySyncId[syncId] = inserted;
    byFingerprint.putIfAbsent(fp, () => []).add(inserted);

    return _MergeResult(
      localId: newId,
      action: _MergeAction.added,
      applyRemoteTags: true,
    );
  }

  static bool _isUuidLike(String value) {
    return RegExp(
      r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$',
    ).hasMatch(value);
  }

  static DateTime? _laterDateTime(DateTime? a, DateTime? b) {
    if (a == null) return b;
    if (b == null) return a;
    return a.isAfter(b) ? a : b;
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
        iconKey: tag.iconKey,
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
        iconKey: Value(tag.iconKey),
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
        await _maybeBackfillPaymentIcon(db, existing, method.iconKey);
        return _ResolvedId(existing, created: false);
      }
    }

    final byName = paymentIdByName[method.name];
    if (byName != null) {
      if (stable != null && stable.isNotEmpty) {
        paymentIdByStableKey[stable] = byName;
      }
      await _maybeBackfillPaymentIcon(db, byName, method.iconKey);
      return _ResolvedId(byName, created: false);
    }

    if (stable != null && stable.isNotEmpty) {
      final id = await db.ensurePaymentMethodByStableKey(
        stableKey: stable,
        fallbackName: method.name,
        isDefault: method.isDefault,
        colorValue: method.colorValue,
        iconKey: method.iconKey,
      );
      paymentIdByStableKey[stable] = id;
      paymentIdByName[method.name] = id;
      return _ResolvedId(id, created: true);
    }

    final id = await db.insertPaymentMethod(
      PaymentMethodsCompanion.insert(
        name: method.name,
        colorValue: Value(method.colorValue),
        iconKey: Value(method.iconKey),
        isDefault: Value(method.isDefault),
        sortOrder: Value(method.sortOrder),
      ),
    );
    paymentIdByName[method.name] = id;
    return _ResolvedId(id, created: true);
  }

  /// Fills [iconKey] only when the local row has none (never overwrites).
  Future<void> _maybeBackfillPaymentIcon(
    AppDatabase db,
    int paymentId,
    String? iconKey,
  ) async {
    if (iconKey == null || iconKey.isEmpty) return;
    final existing = await (db.select(db.paymentMethods)
          ..where((p) => p.id.equals(paymentId)))
        .getSingleOrNull();
    if (existing == null || existing.iconKey != null) return;
    await (db.update(db.paymentMethods)..where((p) => p.id.equals(paymentId)))
        .write(
      PaymentMethodsCompanion(iconKey: Value(iconKey)),
    );
  }

  int? _lookupTagId({
    required String? stableKey,
    required String? name,
    required String kind,
    String? parentStableKey,
    String? parentName,
    String? parentKind,
    required Map<String, int> tagIdByStableKey,
    required Map<String, int> tagIdByNameKind,
    required Map<String, int> tagIdByNameKindParent,
    required Map<int, int?> tagParentById,
  }) {
    final stable = stableKey?.trim();
    if (stable != null && stable.isNotEmpty) {
      final id = tagIdByStableKey[stable];
      if (id != null) return id;
    }

    int? parentId;
    final parentKey = parentStableKey?.trim();
    if (parentKey != null && parentKey.isNotEmpty) {
      parentId = tagIdByStableKey[parentKey];
    }
    if (parentId == null &&
        parentName != null &&
        parentName.trim().isNotEmpty) {
      parentId = tagIdByNameKind[_nameKindKey(
        parentName,
        parentKind ?? kind,
      )];
    }

    if (name == null || name.isEmpty) return null;
    final nameKind = _nameKindKey(name, kind);
    if (parentId != null) {
      final underParent = tagIdByNameKindParent['$nameKind|$parentId'];
      if (underParent != null) return underParent;
    }

    final byName = tagIdByNameKind[nameKind];
    if (byName == null) return null;
    if (parentId != null && tagParentById[byName] != parentId) {
      return null;
    }
    return byName;
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
