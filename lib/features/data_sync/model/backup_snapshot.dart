import 'package:valtero/features/data_sync/model/backup_format.dart';
import 'package:valtero/shared/database/app_database.dart';
import 'package:valtero/shared/database/schema_version.dart';
import 'package:valtero/shared/settings/app_settings.dart';

/// Builds an inner [BackupEnvelope] from the live database + settings.
class BackupSnapshotBuilder {
  Future<BackupEnvelope> build({
    required AppDatabase db,
    required AppSettings settings,
    String? appVersion,
    DateTime? exportedAt,
  }) async {
    final tags = await db.watchTagsList();
    final methods = await db.getAllPaymentMethods();
    final expenses = await db.getAllExpenses();
    final tagIdsByExpense =
        await db.getTagIdsByExpenseIds(expenses.map((e) => e.id).toList());
    final manualRates = await db.getManualExchangeRates();

    final tagById = {for (final t in tags) t.id: t};
    final methodById = {for (final m in methods) m.id: m};

    final backupTags = tags
        .map(
          (t) => BackupTagData(
            stableKey: t.stableKey,
            name: t.name,
            kind: t.kind,
            colorValue: t.colorValue,
            isDefault: t.isDefault,
            sortOrder: t.sortOrder,
            countryCode: t.countryCode,
          ),
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
          ),
        )
        .toList();

    final backupExpenses = <BackupExpenseData>[];
    final backupExpenseTags = <BackupExpenseTagData>[];

    for (final expense in expenses) {
      final clientId = 'e${expense.id}';
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
        ),
      );

      for (final tagId in tagIdsByExpense[expense.id] ?? const <int>[]) {
        final tag = tagById[tagId];
        if (tag == null) continue;
        backupExpenseTags.add(
          BackupExpenseTagData(
            expenseClientId: clientId,
            tagStableKey: tag.stableKey,
            tagName: tag.name,
            tagKind: tag.kind,
          ),
        );
      }
    }

    final overrides = manualRates
        .map(
          (r) => BackupExchangeRateOverrideData(
            baseCurrencyCode: r.baseCurrencyCode,
            targetCurrencyCode: r.targetCurrencyCode,
            rate: r.rate,
            fetchedAt: r.fetchedAt,
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
        exchangeRateOverrides: overrides,
        settings: settingsData,
      ),
    );
  }
}
