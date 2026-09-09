import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:valtero/entities/income/model/income_provider.dart';
import 'package:valtero/entities/income/model/income_tags_provider.dart';
import 'package:valtero/entities/payment_method/model/payment_methods_provider.dart';
import 'package:valtero/entities/tag/model/tags_provider.dart';
import 'package:valtero/features/add_income/model/add_income_controller.dart';
import 'package:valtero/features/add_income/ui/income_delete_flow.dart';
import 'package:valtero/features/expenses_list/model/duplicate_income_provider.dart';
import 'package:valtero/shared/consts/countries.dart';
import 'package:valtero/shared/database/app_database.dart';
import 'package:valtero/shared/l10n/generated/app_localizations.dart';
import 'package:valtero/shared/utils/payment_method_label.dart';
import 'package:valtero/shared/utils/tag_label.dart';
import 'package:valtero/widgets/app_button.dart';
import 'package:valtero/widgets/app_close_icon_button.dart';
import 'package:valtero/widgets/app_modal_sheet.dart';
import 'package:valtero/widgets/app_sheet_actions_bar.dart';
import 'package:valtero/widgets/app_sheet_header.dart';
import 'package:valtero/widgets/app_sheet_scaffold.dart';
import 'package:valtero/widgets/expense_duplicate_compare_tile.dart';

/// Mirrors [DuplicateReviewSheet] for [Income] rows (see
/// `duplicateIncomeProvider`).
Future<void> showIncomeDuplicateReviewSheet(BuildContext context) {
  return showAppModalSheet(
    context: context,
    initialChildSize: 0.88,
    minChildSize: 0.5,
    child: const IncomeDuplicateReviewSheet(),
  );
}

class IncomeDuplicateReviewSheet extends ConsumerWidget {
  const IncomeDuplicateReviewSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final dupState = ref.watch(duplicateIncomeProvider);
    final incomes = ref.watch(allIncomeProvider).value ?? const [];
    final byId = {for (final i in incomes) i.id: i};
    final tags = ref.watch(tagsStreamProvider).value ?? const [];
    final payments = ref.watch(paymentMethodsStreamProvider).value ?? const [];
    final incomeTags = ref.watch(incomeTagIdsProvider).value ?? const {};
    final tagLabels = {
      for (final t in tags) t.id: localizedTagLabel(context, t),
    };
    final paymentLabels = {
      for (final m in payments) m.id: localizedPaymentMethodLabel(context, m),
    };
    final lang = Localizations.localeOf(context).languageCode;

    return AppSheetScaffold(
      header: AppSheetHeader(
        title: l10n.duplicateReviewSheetTitle,
        description: l10n.duplicateConflictDialogHint,
      ),
      actions: const AppSheetActionsBar(children: [AppCloseIconButton()]),
      children: [
        if (dupState.groups.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Center(
              child: Text(
                l10n.noMatchingIncome,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          )
        else
          for (var i = 0; i < dupState.groups.length; i++) ...[
            if (i > 0) const SizedBox(height: 20),
            _DuplicateIncomeGroupCard(
              groupIds: dupState.groups[i],
              byId: byId,
              incomeTags: incomeTags,
              tagLabels: tagLabels,
              paymentLabels: paymentLabels,
              languageCode: lang,
            ),
          ],
      ],
    );
  }
}

class _DuplicateIncomeGroupCard extends ConsumerWidget {
  final List<int> groupIds;
  final Map<int, Income> byId;
  final Map<int, List<int>> incomeTags;
  final Map<int, String> tagLabels;
  final Map<int, String> paymentLabels;
  final String languageCode;

  const _DuplicateIncomeGroupCard({
    required this.groupIds,
    required this.byId,
    required this.incomeTags,
    required this.tagLabels,
    required this.paymentLabels,
    required this.languageCode,
  });

  String _tagsLabel(int incomeId) {
    final ids = incomeTags[incomeId] ?? const <int>[];
    if (ids.isEmpty) return '';
    return ids.map((id) => tagLabels[id] ?? '?').join(', ');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final items = groupIds.map((id) => byId[id]).whereType<Income>().toList();
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
                title: l10n.duplicateMatchingIncome,
                occurredAt: items[i].occurredAt,
                amountMinor: items[i].originalAmountMinor,
                currencyCode: items[i].originalCurrencyCode,
                paymentLabel: items[i].paymentMethodId == null
                    ? null
                    : paymentLabels[items[i].paymentMethodId!],
                countryLabel:
                    items[i].countryCode == null ||
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
                    child: AppOutlinedButton(
                      onPressed: () async {
                        await ref
                            .read(addIncomeControllerProvider)
                            .markNotDuplicate([items[i].id]);
                      },
                      icon: Icons.check_circle_outline,
                      label: l10n.duplicateMarkNotDuplicate,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: AppOutlinedButton(
                      destructive: true,
                      onPressed: () {
                        confirmAndDeleteIncome(
                          context,
                          ref,
                          items[i].id,
                          income: items[i],
                        );
                      },
                      icon: Icons.delete_outline,
                      label: l10n.delete,
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
