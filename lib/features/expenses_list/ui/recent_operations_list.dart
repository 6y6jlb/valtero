import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:valtero/features/add_expense/ui/add_expense_sheet.dart';
import 'package:valtero/features/expenses_list/model/duplicate_expenses_provider.dart';
import 'package:valtero/features/expenses_list/ui/expense_delete_flow.dart';
import 'package:valtero/features/expenses_list/ui/expense_detail_sheet.dart';
import 'package:valtero/features/expenses_list/ui/recent_expense_tile.dart';
import 'package:valtero/shared/consts/countries.dart';
import 'package:valtero/shared/database/app_database.dart';
import 'package:valtero/shared/l10n/generated/app_localizations.dart';
import 'package:valtero/shared/settings/app_settings_provider.dart';
import 'package:valtero/shared/utils/app_timezone.dart';
import 'package:valtero/shared/utils/date_display.dart';

/// Recent operations list with Today / Yesterday / formatted-date headers.
class RecentOperationsList extends ConsumerWidget {
  final List<Expense> expenses;
  final Map<int, List<int>> expenseTags;
  final Map<int, String> tagLabels;
  final Map<int, String> paymentLabels;

  const RecentOperationsList({
    super.key,
    required this.expenses,
    required this.expenseTags,
    required this.tagLabels,
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
    final dupState = ref.watch(duplicateExpensesProvider);

    final children = <Widget>[];
    String? lastDayKey;

    for (final expense in expenses) {
      final dayKey = relativeDayKey(expense.occurredAt, timeZoneId);
      if (dayKey != lastDayKey) {
        lastDayKey = dayKey;
        final label = formatRelativeDayLabel(
          instant: expense.occurredAt,
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

      final paymentLabel = expense.paymentMethodId == null
          ? null
          : paymentLabels[expense.paymentMethodId!];
      final countryLabel = expense.countryCode == null ||
              expense.countryCode!.isEmpty
          ? null
          : countryDisplayName(
              expense.countryCode!,
              languageCode: lang,
            );
      final tagsLabel = recentExpenseTagsLabel(
        expense.id,
        expenseTags,
        tagLabels,
      );
      children.add(
        RecentExpenseTile(
          expense: expense,
          paymentLabel: paymentLabel,
          countryLabel: countryLabel,
          tagsLabel: tagsLabel,
          showPossibleDuplicate: dupState.isFlagged(expense.id),
          onTap: () => openExpenseDetail(
            context,
            ref,
            expense: expense,
            expenseTags: expenseTags,
            tagLabels: tagLabels,
            paymentLabels: paymentLabels,
          ),
          onEdit: () => showAddExpenseSheet(context, expense: expense),
          onDelete: () => confirmAndDeleteExpense(
            context,
            ref,
            expense.id,
            expense: expense,
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: children,
    );
  }
}
