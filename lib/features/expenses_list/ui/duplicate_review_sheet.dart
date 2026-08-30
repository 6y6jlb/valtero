import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:valtero/entities/expense/model/expense_tags_provider.dart';
import 'package:valtero/entities/expense/model/expenses_provider.dart';
import 'package:valtero/entities/payment_method/model/payment_methods_provider.dart';
import 'package:valtero/entities/tag/model/tags_provider.dart';
import 'package:valtero/features/expenses_list/model/bulk_expense_controller.dart';
import 'package:valtero/features/expenses_list/model/duplicate_expenses_provider.dart';
import 'package:valtero/features/expenses_list/ui/expense_delete_flow.dart';
import 'package:valtero/shared/consts/countries.dart';
import 'package:valtero/shared/database/app_database.dart';
import 'package:valtero/shared/l10n/generated/app_localizations.dart';
import 'package:valtero/shared/utils/payment_method_label.dart';
import 'package:valtero/shared/utils/tag_label.dart';
import 'package:valtero/widgets/app_modal_sheet.dart';
import 'package:valtero/widgets/expense_duplicate_compare_tile.dart';

Future<void> showDuplicateReviewSheet(BuildContext context) {
  return showAppModalSheet(
    context: context,
    initialChildSize: 0.88,
    minChildSize: 0.5,
    child: const DuplicateReviewSheet(),
  );
}

class DuplicateReviewSheet extends ConsumerWidget {
  const DuplicateReviewSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final scrollController = PrimaryScrollController.maybeOf(context);
    final dupState = ref.watch(duplicateExpensesProvider);
    final expenses = ref.watch(allExpensesProvider).value ?? const [];
    final byId = {for (final e in expenses) e.id: e};
    final tags = ref.watch(tagsStreamProvider).value ?? const [];
    final payments = ref.watch(paymentMethodsStreamProvider).value ?? const [];
    final expenseTags = ref.watch(expenseTagIdsProvider).value ?? const {};
    final tagLabels = {
      for (final t in tags) t.id: localizedTagLabel(context, t),
    };
    final paymentLabels = {
      for (final m in payments) m.id: localizedPaymentMethodLabel(context, m),
    };
    final lang = Localizations.localeOf(context).languageCode;

    return ListView(
      controller: scrollController,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
      children: [
        Text(
          l10n.duplicateReviewSheetTitle,
          style: theme.textTheme.titleLarge,
        ),
        const SizedBox(height: 8),
        Text(
          l10n.duplicateConflictDialogHint,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 16),
        if (dupState.groups.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Center(
              child: Text(
                l10n.noMatchingExpenses,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          )
        else
          for (var i = 0; i < dupState.groups.length; i++) ...[
            if (i > 0) const SizedBox(height: 20),
            _DuplicateGroupCard(
              groupIds: dupState.groups[i],
              byId: byId,
              expenseTags: expenseTags,
              tagLabels: tagLabels,
              paymentLabels: paymentLabels,
              languageCode: lang,
            ),
          ],
      ],
    );
  }
}

class _DuplicateGroupCard extends ConsumerWidget {
  final List<int> groupIds;
  final Map<int, Expense> byId;
  final Map<int, List<int>> expenseTags;
  final Map<int, String> tagLabels;
  final Map<int, String> paymentLabels;
  final String languageCode;

  const _DuplicateGroupCard({
    required this.groupIds,
    required this.byId,
    required this.expenseTags,
    required this.tagLabels,
    required this.paymentLabels,
    required this.languageCode,
  });

  String _tagsLabel(int expenseId) {
    final ids = expenseTags[expenseId] ?? const <int>[];
    if (ids.isEmpty) return '';
    return ids.map((id) => tagLabels[id] ?? '?').join(', ');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final items = groupIds.map((id) => byId[id]).whereType<Expense>().toList();
    if (items.length < 2) return const SizedBox.shrink();

    return Card(
      margin: EdgeInsets.zero,
      color: theme.colorScheme.errorContainer.withValues(alpha: 0.25),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (var i = 0; i < items.length; i++) ...[
              if (i > 0) const SizedBox(height: 10),
              ExpenseDuplicateCompareTile(
                title: l10n.duplicateMatchingExpense,
                occurredAt: items[i].occurredAt,
                amountMinor: items[i].originalAmountMinor,
                currencyCode: items[i].originalCurrencyCode,
                paymentLabel: items[i].paymentMethodId == null
                    ? null
                    : paymentLabels[items[i].paymentMethodId!],
                countryLabel: items[i].countryCode == null ||
                        items[i].countryCode!.isEmpty
                    ? null
                    : countryDisplayName(
                        items[i].countryCode!,
                        languageCode: languageCode,
                      ),
                tagsLabel: _tagsLabel(items[i].id),
                note: items[i].note,
                borderColor: theme.colorScheme.error.withValues(alpha: 0.4),
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        await ref
                            .read(bulkExpenseControllerProvider)
                            .markNotDuplicate([items[i].id]);
                      },
                      icon: const Icon(Icons.check_circle_outline, size: 18),
                      label: Text(l10n.duplicateMarkNotDuplicate),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: theme.colorScheme.error,
                      ),
                      onPressed: () {
                        confirmAndDeleteExpense(
                          context,
                          ref,
                          items[i].id,
                          expense: items[i],
                        );
                      },
                      icon: const Icon(Icons.delete_outline, size: 18),
                      label: Text(l10n.delete),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
