import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:valtero/features/add_expense/ui/add_expense_sheet.dart';
import 'package:valtero/features/add_income/ui/add_income_sheet.dart';
import 'package:valtero/features/add_income/ui/income_delete_flow.dart';
import 'package:valtero/features/expenses_list/model/duplicate_expenses_provider.dart';
import 'package:valtero/features/expenses_list/model/duplicate_income_provider.dart';
import 'package:valtero/features/expenses_list/model/recent_operation.dart';
import 'package:valtero/features/expenses_list/ui/expense_delete_flow.dart';
import 'package:valtero/features/expenses_list/ui/possible_duplicate_badge.dart';
import 'package:valtero/shared/consts/countries.dart';
import 'package:valtero/shared/l10n/generated/app_localizations.dart';
import 'package:valtero/shared/settings/app_settings_provider.dart';
import 'package:valtero/shared/utils/app_timezone.dart';
import 'package:valtero/shared/utils/date_display.dart';
import 'package:valtero/widgets/flag_icon.dart';
import 'package:valtero/widgets/money_text.dart';

/// Recent operations list for the cash-flow direction: merges expenses and
/// incomes (see [RecentOperation]) into one date-grouped list, tinting
/// income vs. expense amounts so the direction reads at a glance. Mirrors
/// [RecentOperationsList] / [RecentIncomeOperationsList] but works off the
/// merged shape and opens the matching add/edit sheet per row.
class RecentCashFlowOperationsList extends ConsumerWidget {
  final List<RecentOperation> operations;
  final Map<int, String> paymentLabels;

  const RecentCashFlowOperationsList({
    super.key,
    required this.operations,
    required this.paymentLabels,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final lang = Localizations.localeOf(context).languageCode;
    final localeName = Localizations.localeOf(context).toString();
    final settings = ref.watch(appSettingsProvider).value;
    final timeZoneId = settings?.timeZoneId ?? kSystemTimeZoneId;
    final dateFormat = dateDisplayFormatFromName(settings?.dateDisplayFormat);
    final expenseDup = ref.watch(duplicateExpensesProvider);
    final incomeDup = ref.watch(duplicateIncomeProvider);

    final children = <Widget>[];
    String? lastDayKey;

    for (final op in operations) {
      final dayKey = relativeDayKey(op.occurredAt, timeZoneId);
      if (dayKey != lastDayKey) {
        lastDayKey = dayKey;
        final label = formatRelativeDayLabel(
          instant: op.occurredAt,
          timeZoneId: timeZoneId,
          format: dateFormat,
          localeName: localeName,
          todayLabel: l10n.periodToday,
          yesterdayLabel: l10n.periodYesterday,
        );
        children.add(
          Padding(
            padding: EdgeInsets.only(
              top: children.isEmpty ? 0 : 12,
              bottom: 4,
            ),
            child: Text(
              label,
              style: theme.textTheme.labelLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        );
      }

      children.add(
        _buildTile(context, ref, l10n, theme, lang, op, expenseDup, incomeDup),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: children,
    );
  }

  Widget _buildTile(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
    ThemeData theme,
    String lang,
    RecentOperation op,
    DuplicateExpensesState expenseDup,
    DuplicateIncomeState incomeDup,
  ) {
    final isIncome = op.kind == OperationKind.income;
    final countryCode =
        isIncome ? op.income!.countryCode : op.expense!.countryCode;
    final paymentMethodId =
        isIncome ? op.income!.paymentMethodId : op.expense!.paymentMethodId;
    final paymentLabel =
        paymentMethodId == null ? null : paymentLabels[paymentMethodId];
    final countryLabel = countryCode == null || countryCode.isEmpty
        ? null
        : countryDisplayName(countryCode, languageCode: lang);
    final showDup = isIncome
        ? incomeDup.isFlagged(op.id)
        : expenseDup.isFlagged(op.id);
    final amountColor =
        isIncome ? theme.colorScheme.tertiary : theme.colorScheme.error;
    final parts = <String>[
      if (paymentLabel != null && paymentLabel.isNotEmpty) paymentLabel,
      if (countryLabel != null && countryLabel.isNotEmpty) countryLabel,
    ];

    void openEdit() => isIncome
        ? showAddIncomeSheet(context, income: op.income)
        : showAddExpenseSheet(context, expense: op.expense);

    return ListTile(
      contentPadding: EdgeInsets.zero,
      onTap: openEdit,
      leading: countryCode == null || countryCode.isEmpty
          ? null
          : FlagIcon.country(countryCode, size: 28),
      title: Row(
        children: [
          Flexible(
            child: MoneyText(
              amountMinor: op.amountMinor,
              currencyCode: op.currencyCode,
              style: theme.textTheme.titleSmall?.copyWith(
                color: amountColor,
              ),
            ),
          ),
          if (showDup) ...[
            const SizedBox(width: 6),
            const PossibleDuplicateBadge(size: 16),
          ],
        ],
      ),
      subtitle: parts.isEmpty
          ? null
          : Text(
              parts.join(' · '),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.edit_outlined, size: 20),
            tooltip: isIncome ? l10n.editIncome : l10n.editExpense,
            visualDensity: VisualDensity.compact,
            onPressed: openEdit,
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, size: 20),
            tooltip: l10n.delete,
            visualDensity: VisualDensity.compact,
            onPressed: () => isIncome
                ? confirmAndDeleteIncome(context, ref, op.id, income: op.income)
                : confirmAndDeleteExpense(
                    context,
                    ref,
                    op.id,
                    expense: op.expense,
                  ),
          ),
        ],
      ),
    );
  }
}
