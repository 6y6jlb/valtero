import 'package:flutter/material.dart';
import 'package:valtero/shared/consts/countries.dart';
import 'package:valtero/shared/database/app_database.dart';
import 'package:valtero/shared/l10n/generated/app_localizations.dart';
import 'package:valtero/widgets/expense_duplicate_compare_tile.dart';

enum DuplicateConflictAction {
  saveAsUnique,
  deleteMatchAndSave,
  cancel,
}

class DuplicateConflictDialogResult {
  final DuplicateConflictAction action;
  final List<int> matchIdsToDelete;

  const DuplicateConflictDialogResult({
    required this.action,
    this.matchIdsToDelete = const [],
  });
}

Future<DuplicateConflictDialogResult?> showDuplicateConflictDialog({
  required BuildContext context,
  required DateTime draftOccurredAt,
  required int draftAmountMinor,
  required String draftCurrencyCode,
  required String? draftPaymentLabel,
  required String? draftCountryCode,
  required String? draftTagsLabel,
  required String? draftNote,
  required List<Expense> matches,
  required Map<int, String> paymentLabels,
  required String Function(int expenseId) tagsLabelFor,
}) {
  return showDialog<DuplicateConflictDialogResult>(
    context: context,
    builder: (context) => DuplicateConflictDialog(
      draftOccurredAt: draftOccurredAt,
      draftAmountMinor: draftAmountMinor,
      draftCurrencyCode: draftCurrencyCode,
      draftPaymentLabel: draftPaymentLabel,
      draftCountryCode: draftCountryCode,
      draftTagsLabel: draftTagsLabel,
      draftNote: draftNote,
      matches: matches,
      paymentLabels: paymentLabels,
      tagsLabelFor: tagsLabelFor,
    ),
  );
}

class DuplicateConflictDialog extends StatelessWidget {
  final DateTime draftOccurredAt;
  final int draftAmountMinor;
  final String draftCurrencyCode;
  final String? draftPaymentLabel;
  final String? draftCountryCode;
  final String? draftTagsLabel;
  final String? draftNote;
  final List<Expense> matches;
  final Map<int, String> paymentLabels;
  final String Function(int expenseId) tagsLabelFor;

  const DuplicateConflictDialog({
    super.key,
    required this.draftOccurredAt,
    required this.draftAmountMinor,
    required this.draftCurrencyCode,
    required this.draftPaymentLabel,
    required this.draftCountryCode,
    required this.draftTagsLabel,
    required this.draftNote,
    required this.matches,
    required this.paymentLabels,
    required this.tagsLabelFor,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final lang = Localizations.localeOf(context).languageCode;
    final match = matches.first;

    String? countryLabel(String? code) => code == null || code.isEmpty
        ? null
        : countryDisplayName(code, languageCode: lang);

    return AlertDialog(
      title: Text(l10n.duplicateConflictDialogTitle),
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
              title: l10n.duplicateYourExpense,
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
              title: l10n.duplicateMatchingExpense,
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
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(
            const DuplicateConflictDialogResult(
              action: DuplicateConflictAction.cancel,
            ),
          ),
          child: Text(l10n.dismiss),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(
            DuplicateConflictDialogResult(
              action: DuplicateConflictAction.deleteMatchAndSave,
              matchIdsToDelete: matches.map((e) => e.id).toList(),
            ),
          ),
          child: Text(l10n.duplicateDeleteMatchAndSave),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(
            const DuplicateConflictDialogResult(
              action: DuplicateConflictAction.saveAsUnique,
            ),
          ),
          child: Text(l10n.duplicateSaveAsUnique),
        ),
      ],
    );
  }
}
