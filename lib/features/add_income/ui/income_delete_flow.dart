import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:valtero/features/add_income/model/add_income_controller.dart';
import 'package:valtero/shared/database/app_database.dart';
import 'package:valtero/shared/l10n/generated/app_localizations.dart';
import 'package:valtero/shared/settings/app_settings_provider.dart';
import 'package:valtero/shared/utils/app_timezone.dart';
import 'package:valtero/shared/utils/date_display.dart';
import 'package:valtero/shared/utils/money_display.dart';
import 'package:valtero/widgets/app_toast.dart';
import 'package:valtero/widgets/confirm_action_sheet.dart';

/// Returns `true` if the income was deleted.
Future<bool> confirmAndDeleteIncome(
  BuildContext context,
  WidgetRef ref,
  int incomeId, {
  Income? income,
}) async {
  final l10n = AppLocalizations.of(context)!;
  final description = income == null
      ? l10n.confirmDeleteIncomeDescription
      : '${l10n.confirmDeleteIncomeDescription}\n\n'
          '${_incomeDeletePreview(context, ref, income)}';

  final confirmed = await showConfirmActionSheet<bool>(
    context: context,
    initialChildSize: 0.38,
    minChildSize: 0.28,
    maxChildSize: 0.55,
    child: Builder(
      builder: (sheetContext) => ConfirmActionLayout(
        title: l10n.confirmDeleteIncome,
        description: description,
        actions: confirmActionButtons(
          context: sheetContext,
          confirmLabel: l10n.yes,
          destructive: true,
          onConfirm: () => Navigator.pop(sheetContext, true),
          onCancel: () => Navigator.pop(sheetContext, false),
        ),
      ),
    ),
  );
  if (confirmed != true || !context.mounted) return false;

  await ref.read(addIncomeControllerProvider).delete(incomeId);
  if (!context.mounted) return true;

  showAppToast(context, l10n.incomeDeleted);
  return true;
}

String _incomeDeletePreview(
  BuildContext context,
  WidgetRef ref,
  Income income,
) {
  final settings = ref.read(appSettingsProvider).value;
  final localeName = Localizations.localeOf(context).toString();
  final date = formatDateDisplay(
    instant: income.occurredAt,
    timeZoneId: settings?.timeZoneId ?? kSystemTimeZoneId,
    format: dateDisplayFormatFromName(settings?.dateDisplayFormat),
    localeName: localeName,
  );
  final amount = formatMoneyDisplay(
    amountMinor: income.originalAmountMinor,
    currencyCode: income.originalCurrencyCode,
    localeName: localeName,
    format: moneyDisplayFormatFromName(settings?.moneyDisplayFormat),
  );
  final note = income.note?.trim();
  if (note != null && note.isNotEmpty) {
    return '$date · $amount · $note';
  }
  return '$date · $amount';
}
