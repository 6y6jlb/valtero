import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:valtero/features/expenses_list/model/recent_operation.dart';
import 'package:valtero/shared/l10n/generated/app_localizations.dart';
import 'package:valtero/shared/settings/app_settings_provider.dart';
import 'package:valtero/shared/utils/app_timezone.dart';
import 'package:valtero/shared/utils/date_display.dart';
import 'package:valtero/shared/utils/money_display.dart';

/// Builds a multi-line list of cash-flow operations for bulk confirm descriptions.
String buildCashFlowBulkListDescription(
  BuildContext context,
  WidgetRef ref, {
  required List<RecentOperation> operations,
  int previewLimit = 8,
}) {
  final l10n = AppLocalizations.of(context)!;
  final settings = ref.read(appSettingsProvider).value;
  final moneyFormat = moneyDisplayFormatFromName(settings?.moneyDisplayFormat);
  final dateFormat = dateDisplayFormatFromName(settings?.dateDisplayFormat);
  final tzId = settings?.timeZoneId ?? kSystemTimeZoneId;
  final localeName = Localizations.localeOf(context).toString();

  final preview = operations.take(previewLimit).map((op) {
    final date = formatDateDisplay(
      instant: op.occurredAt,
      timeZoneId: tzId,
      format: dateFormat,
      localeName: localeName,
    );
    final typeLabel = op.kind == OperationKind.income
        ? l10n.operationTypeIncome
        : l10n.operationTypeExpense;
    final signedMinor = op.signedAmountMinor;
    final signPrefix = signedMinor >= 0 ? '+' : '−';
    final amount = formatMoneyDisplay(
      amountMinor: signedMinor.abs(),
      currencyCode: op.currencyCode,
      localeName: localeName,
      format: moneyFormat,
    );
    final note = op.note?.trim();
    final line = '$date · $typeLabel · $signPrefix$amount';
    if (note != null && note.isNotEmpty) {
      return '$line · $note';
    }
    return line;
  }).toList();

  final remaining = operations.length - preview.length;
  if (remaining > 0) {
    preview.add(l10n.bulkAndMore(remaining));
  }
  return preview.join('\n');
}
