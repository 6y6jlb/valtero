import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:valtero/shared/database/app_database.dart';
import 'package:valtero/shared/l10n/generated/app_localizations.dart';
import 'package:valtero/shared/settings/app_settings_provider.dart';
import 'package:valtero/shared/utils/app_timezone.dart';
import 'package:valtero/shared/utils/date_display.dart';
import 'package:valtero/shared/utils/money_display.dart';

/// Builds a centered multi-line list of expenses for bulk confirm descriptions.
String buildExpenseBulkListDescription(
  BuildContext context,
  WidgetRef ref, {
  required List<Expense> expenses,
  int previewLimit = 8,
}) {
  final l10n = AppLocalizations.of(context)!;
  final settings = ref.read(appSettingsProvider).value;
  final moneyFormat = moneyDisplayFormatFromName(settings?.moneyDisplayFormat);
  final dateFormat = dateDisplayFormatFromName(settings?.dateDisplayFormat);
  final tzId = settings?.timeZoneId ?? kSystemTimeZoneId;
  final localeName = Localizations.localeOf(context).toString();

  final preview = expenses.take(previewLimit).map((e) {
    final date = formatDateDisplay(
      instant: e.occurredAt,
      timeZoneId: tzId,
      format: dateFormat,
      localeName: localeName,
    );
    final amount = formatMoneyDisplay(
      amountMinor: e.storedAmountMinor,
      currencyCode: e.storedCurrencyCode,
      localeName: localeName,
      format: moneyFormat,
    );
    final note = e.note?.trim();
    if (note != null && note.isNotEmpty) {
      return '$date · $amount · $note';
    }
    return '$date · $amount';
  }).toList();

  final remaining = expenses.length - preview.length;
  if (remaining > 0) {
    preview.add(l10n.bulkAndMore(remaining));
  }
  return preview.join('\n');
}
