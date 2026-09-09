import 'package:flutter/material.dart';
import 'package:valtero/features/add_expense/ui/duplicate_conflict_dialog.dart';
import 'package:valtero/shared/consts/countries.dart';
import 'package:valtero/shared/database/app_database.dart';
import 'package:valtero/shared/l10n/generated/app_localizations.dart';
import 'package:valtero/widgets/app_button.dart';
import 'package:valtero/widgets/app_close_icon_button.dart';
import 'package:valtero/widgets/expense_duplicate_compare_tile.dart';

Future<DuplicateConflictDialogResult?> showIncomeDuplicateConflictDialog({
  required BuildContext context,
  required DateTime draftOccurredAt,
  required int draftAmountMinor,
  required String draftCurrencyCode,
  required String? draftPaymentLabel,
  required String? draftCountryCode,
  required String? draftTagsLabel,
  required String? draftNote,
  required List<Income> matches,
  required Map<int, String> paymentLabels,
  required String Function(int incomeId) tagsLabelFor,
}) {
  return showDialog<DuplicateConflictDialogResult>(
    context: context,
    builder: (context) {
      final l10n = AppLocalizations.of(context)!;
      final theme = Theme.of(context);
      final lang = Localizations.localeOf(context).languageCode;
      final match = matches.first;

      String? countryLabel(String? code) => code == null || code.isEmpty
          ? null
          : countryDisplayName(code, languageCode: lang);

      return AlertDialog(
        title: Text(l10n.duplicateConflictIncomeTitle),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                l10n.duplicateConflictDialogHint,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 12),
              ExpenseDuplicateCompareTile(
                title: l10n.duplicateYourIncome,
                occurredAt: draftOccurredAt,
                amountMinor: draftAmountMinor,
                currencyCode: draftCurrencyCode,
                paymentLabel: draftPaymentLabel,
                countryLabel: countryLabel(draftCountryCode),
                tagsLabel: draftTagsLabel,
                note: draftNote,
                borderColor: theme.colorScheme.primary.withValues(alpha: 0.35),
              ),
              const SizedBox(height: 8),
              ExpenseDuplicateCompareTile(
                title: l10n.duplicateMatchingIncome,
                occurredAt: match.occurredAt,
                amountMinor: match.originalAmountMinor,
                currencyCode: match.originalCurrencyCode,
                paymentLabel: match.paymentMethodId == null
                    ? null
                    : paymentLabels[match.paymentMethodId!],
                countryLabel: countryLabel(match.countryCode),
                tagsLabel: tagsLabelFor(match.id),
                note: match.note,
                borderColor: theme.colorScheme.error.withValues(alpha: 0.35),
              ),
              if (matches.length > 1) ...[
                const SizedBox(height: 6),
                Text(
                  '+${matches.length - 1}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ],
          ),
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          AppCloseIconButton(
            onPressed: () => Navigator.of(context).pop(
              const DuplicateConflictDialogResult(
                action: DuplicateConflictAction.cancel,
              ),
            ),
            label: l10n.dismiss,
          ),
          AppOutlinedButton(
            onPressed: () => Navigator.of(context).pop(
              DuplicateConflictDialogResult(
                action: DuplicateConflictAction.deleteMatchAndSave,
                matchIdsToDelete: matches.map((e) => e.id).toList(),
              ),
            ),
            destructive: true,
            icon: Icons.delete_outline,
            label: l10n.duplicateDeleteMatchAndSave,
          ),
          AppFilledButton(
            onPressed: () => Navigator.of(context).pop(
              const DuplicateConflictDialogResult(
                action: DuplicateConflictAction.saveAsUnique,
              ),
            ),
            icon: Icons.check,
            label: l10n.duplicateSaveAsUnique,
          ),
        ],
      );
    },
  );
}
