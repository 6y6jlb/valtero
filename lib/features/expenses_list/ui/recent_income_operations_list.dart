import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:valtero/features/add_income/ui/add_income_sheet.dart';
import 'package:valtero/features/add_income/ui/income_delete_flow.dart';
import 'package:valtero/features/expenses_list/model/duplicate_income_provider.dart';
import 'package:valtero/features/expenses_list/ui/recent_income_tile.dart';
import 'package:valtero/shared/consts/countries.dart';
import 'package:valtero/shared/database/app_database.dart';
import 'package:valtero/shared/l10n/generated/app_localizations.dart';
import 'package:valtero/shared/settings/app_settings_provider.dart';
import 'package:valtero/shared/utils/app_timezone.dart';
import 'package:valtero/shared/utils/date_display.dart';

/// Recent income list with Today / Yesterday / formatted-date headers.
/// Mirrors [RecentOperationsList] for [Income] rows.
class RecentIncomeOperationsList extends ConsumerWidget {
  final List<Income> incomes;
  final Map<int, List<int>> incomeTags;
  final Map<int, String> tagLabels;
  final Map<int, String> paymentLabels;

  const RecentIncomeOperationsList({
    super.key,
    required this.incomes,
    required this.incomeTags,
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
    final dupState = ref.watch(duplicateIncomeProvider);

    final children = <Widget>[];
    String? lastDayKey;

    for (final income in incomes) {
      final dayKey = relativeDayKey(income.occurredAt, timeZoneId);
      if (dayKey != lastDayKey) {
        lastDayKey = dayKey;
        final label = formatRelativeDayLabel(
          instant: income.occurredAt,
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

      final paymentLabel = income.paymentMethodId == null
          ? null
          : paymentLabels[income.paymentMethodId!];
      final countryLabel =
          income.countryCode == null || income.countryCode!.isEmpty
              ? null
              : countryDisplayName(income.countryCode!, languageCode: lang);
      final tagsLabel = recentIncomeTagsLabel(
        income.id,
        incomeTags,
        tagLabels,
      );
      children.add(
        RecentIncomeTile(
          income: income,
          paymentLabel: paymentLabel,
          countryLabel: countryLabel,
          tagsLabel: tagsLabel,
          showPossibleDuplicate: dupState.isFlagged(income.id),
          onTap: () => showAddIncomeSheet(context, income: income),
          onEdit: () => showAddIncomeSheet(context, income: income),
          onDelete: () => confirmAndDeleteIncome(
            context,
            ref,
            income.id,
            income: income,
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
