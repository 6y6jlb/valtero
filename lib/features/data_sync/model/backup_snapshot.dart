import 'package:valtero/features/data_sync/model/backup_format.dart';
import 'package:valtero/shared/database/app_database.dart';
import 'package:valtero/shared/database/schema_version.dart';
import 'package:valtero/shared/settings/app_settings.dart';

/// Builds an inner [BackupEnvelope] from the live database + settings.
///
/// Includes soft-deleted operations (tombstones) so deletes propagate on sync.
class BackupSnapshotBuilder {
  Future<BackupEnvelope> build({
    required AppDatabase db,
    required AppSettings settings,
    String? appVersion,
    DateTime? exportedAt,
  }) async {
    final tags = await db.watchTagsList();
    final methods = await db.getAllPaymentMethods();
    final expenses = await db.getAllExpenses(includeDeleted: true);
    final tagIdsByExpense =
        await db.getTagIdsByExpenseIds(expenses.map((e) => e.id).toList());
    final incomes = await db.getAllIncome(includeDeleted: true);
    final tagIdsByIncome =
        await db.getTagIdsByIncomeIds(incomes.map((e) => e.id).toList());
    final allRates = await db.getAllExchangeRates();

    final tagById = {for (final t in tags) t.id: t};
    final methodById = {for (final m in methods) m.id: m};

    final backupTags = tags
        .map(
          (t) {
            final parent = t.parentTagId == null ? null : tagById[t.parentTagId!];
            return BackupTagData(
              stableKey: t.stableKey,
              name: t.name,
              kind: t.kind,
              colorValue: t.colorValue,
              isDefault: t.isDefault,
              sortOrder: t.sortOrder,
              countryCode: t.countryCode,
              iconKey: t.iconKey,
              parentStableKey: parent?.stableKey,
              parentName: parent?.stableKey == null ? parent?.name : null,
              parentKind: parent?.stableKey == null ? parent?.kind : null,
            );
          },
        )
        .toList();

    final backupMethods = methods
        .map(
          (m) => BackupPaymentMethodData(
            stableKey: m.stableKey,
            name: m.name,
            colorValue: m.colorValue,
            isDefault: m.isDefault,
            sortOrder: m.sortOrder,
            iconKey: m.iconKey,
          ),
        )
        .toList();

    final backupExpenses = <BackupExpenseData>[];
    final backupExpenseTags = <BackupExpenseTagData>[];

    for (final expense in expenses) {
      final clientId = expense.syncId;
      final payment = expense.paymentMethodId == null
          ? null
          : methodById[expense.paymentMethodId!];
      backupExpenses.add(
        BackupExpenseData(
          clientId: clientId,
          occurredAt: expense.occurredAt,
          originalAmountMinor: expense.originalAmountMinor,
          originalCurrencyCode: expense.originalCurrencyCode,
          storedAmountMinor: expense.storedAmountMinor,
          storedCurrencyCode: expense.storedCurrencyCode,
          rateUsed: expense.rateUsed,
          rateTimestamp: expense.rateTimestamp,
          paymentStableKey: payment?.stableKey,
          paymentName: payment?.name,
          countryCode: expense.countryCode,
          note: expense.note,
          createdAt: expense.createdAt,
          updatedAt: expense.updatedAt,
          deletedAt: expense.deletedAt,
          duplicateDismissed: expense.duplicateDismissed,
        ),
      );

      for (final tagId in tagIdsByExpense[expense.id] ?? const <int>[]) {
        final tag = tagById[tagId];
        if (tag == null) continue;
        final parent =
            tag.parentTagId == null ? null : tagById[tag.parentTagId!];
        backupExpenseTags.add(
          BackupExpenseTagData(
            expenseClientId: clientId,
            tagStableKey: tag.stableKey,
            tagName: tag.name,
            tagKind: tag.kind,
            parentStableKey: parent?.stableKey,
            parentName: parent?.stableKey == null ? parent?.name : null,
            parentKind: parent?.stableKey == null ? parent?.kind : null,
          ),
        );
      }
    }

    final backupIncomes = <BackupIncomeData>[];
    final backupIncomeTags = <BackupIncomeTagData>[];

    for (final income in incomes) {
      final clientId = income.syncId;
      final payment = income.paymentMethodId == null
          ? null
          : methodById[income.paymentMethodId!];
      backupIncomes.add(
        BackupIncomeData(
          clientId: clientId,
          occurredAt: income.occurredAt,
          originalAmountMinor: income.originalAmountMinor,
          originalCurrencyCode: income.originalCurrencyCode,
          storedAmountMinor: income.storedAmountMinor,
          storedCurrencyCode: income.storedCurrencyCode,
          rateUsed: income.rateUsed,
          rateTimestamp: income.rateTimestamp,
          paymentStableKey: payment?.stableKey,
          paymentName: payment?.name,
          countryCode: income.countryCode,
          note: income.note,
          createdAt: income.createdAt,
          updatedAt: income.updatedAt,
          deletedAt: income.deletedAt,
          duplicateDismissed: income.duplicateDismissed,
        ),
      );

      for (final tagId in tagIdsByIncome[income.id] ?? const <int>[]) {
        final tag = tagById[tagId];
        if (tag == null) continue;
        final parent =
            tag.parentTagId == null ? null : tagById[tag.parentTagId!];
        backupIncomeTags.add(
          BackupIncomeTagData(
            incomeClientId: clientId,
            tagStableKey: tag.stableKey,
            tagName: tag.name,
            tagKind: tag.kind,
            parentStableKey: parent?.stableKey,
            parentName: parent?.stableKey == null ? parent?.name : null,
            parentKind: parent?.stableKey == null ? parent?.kind : null,
          ),
        );
      }
    }

    final overrides = allRates
        .map(
          (r) => BackupExchangeRateOverrideData(
            baseCurrencyCode: r.baseCurrencyCode,
            targetCurrencyCode: r.targetCurrencyCode,
            rate: r.rate,
            fetchedAt: r.fetchedAt,
            source: r.source,
          ),
        )
        .toList();

    final settingsData = BackupSettingsData(
      reportingCurrencies: List<String>.from(settings.reportingCurrencies),
      primaryCurrency: settings.primaryCurrency,
      customCurrencyCodes: List<String>.from(settings.customCurrencyCodes),
      themeMode: settings.themeMode,
      locale: settings.locale,
      moneyDisplayFormat: settings.moneyDisplayFormat,
      dateDisplayFormat: settings.dateDisplayFormat,
      timeZoneId: settings.timeZoneId,
      dismissedTagSuggestions:
          List<String>.from(settings.dismissedTagSuggestions),
      googleDriveSharedWithEmails:
          List<String>.from(settings.googleDriveSharedWithEmails),
      googleDriveSharedFileId: settings.googleDriveSharedFileId,
      lastRateRefreshAt: settings.lastRateRefreshAt,
    );

    return BackupEnvelope(
      formatVersion: kBackupFormatVersion,
      schemaVersion: kAppSchemaVersion,
      exportedAt: exportedAt ?? DateTime.now().toUtc(),
      appVersion: appVersion,
      data: BackupPayloadData(
        tags: backupTags,
        paymentMethods: backupMethods,
        expenses: backupExpenses,
        expenseTags: backupExpenseTags,
        incomes: backupIncomes,
        incomeTags: backupIncomeTags,
        exchangeRateOverrides: overrides,
        settings: settingsData,
      ),
    );
  }
}
