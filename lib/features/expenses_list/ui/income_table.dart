import 'package:flutter/material.dart';
import 'package:valtero/features/add_income/ui/add_income_sheet.dart';
import 'package:valtero/features/add_income/ui/income_delete_flow.dart';
import 'package:valtero/features/expenses_list/ui/possible_duplicate_badge.dart';
import 'package:valtero/shared/consts/countries.dart';
import 'package:valtero/shared/database/app_database.dart';
import 'package:valtero/shared/l10n/generated/app_localizations.dart';
import 'package:valtero/widgets/date_text.dart';
import 'package:valtero/widgets/flag_icon.dart';
import 'package:valtero/widgets/money_text.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const double _kColGap = 16;
const double _kDateW = 110;
const double _kAmountW = 120;
const double _kOriginalAmountW = 120;
const double _kPaymentW = 100;
const double _kCountryW = 110;
const double _kEditW = 40;
const double _kDeleteW = 40;

const double _kTableMinWidth = 16 * 2 +
    _kDateW +
    _kColGap +
    _kAmountW +
    _kColGap +
    _kOriginalAmountW +
    _kColGap +
    _kPaymentW +
    _kColGap +
    _kCountryW +
    _kColGap +
    140 +
    _kColGap +
    _kEditW +
    _kColGap +
    _kDeleteW;

/// Income list table (no multi-select — parity without bulk actions).
class IncomeTable extends StatelessWidget {
  final List<Income> items;
  final Map<int, List<int>> incomeTags;
  final Map<int, String> tagLabels;
  final Map<int, String> paymentLabels;
  final String untaggedLabel;
  final String? displayCurrency;
  final int? Function(Income income) convertedMinor;
  final Set<int> possibleDuplicateIds;

  const IncomeTable({
    super.key,
    required this.items,
    required this.incomeTags,
    required this.tagLabels,
    this.paymentLabels = const {},
    required this.untaggedLabel,
    required this.displayCurrency,
    required this.convertedMinor,
    this.possibleDuplicateIds = const {},
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final headerStyle = theme.textTheme.labelMedium?.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth > _kTableMinWidth
            ? constraints.maxWidth
            : _kTableMinWidth;
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SizedBox(
            width: width,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Row(
                    children: [
                      SizedBox(
                        width: _kDateW,
                        child: Text(l10n.columnDate, style: headerStyle),
                      ),
                      const SizedBox(width: _kColGap),
                      SizedBox(
                        width: _kAmountW,
                        child: Text(l10n.columnAmount, style: headerStyle),
                      ),
                      const SizedBox(width: _kColGap),
                      SizedBox(
                        width: _kOriginalAmountW,
                        child: Text(
                          l10n.columnOriginalAmount,
                          style: headerStyle,
                        ),
                      ),
                      const SizedBox(width: _kColGap),
                      SizedBox(
                        width: _kPaymentW,
                        child: Text(l10n.paymentMethod, style: headerStyle),
                      ),
                      const SizedBox(width: _kColGap),
                      SizedBox(
                        width: _kCountryW,
                        child: Text(l10n.country, style: headerStyle),
                      ),
                      const SizedBox(width: _kColGap),
                      Expanded(
                        child: Text(l10n.columnTags, style: headerStyle),
                      ),
                      const SizedBox(width: _kColGap),
                      const SizedBox(width: _kEditW),
                      const SizedBox(width: _kColGap),
                      const SizedBox(width: _kDeleteW),
                    ],
                  ),
                ),
                const Divider(height: 1),
                for (final income in items)
                  _IncomeTableRow(
                    income: income,
                    tagLabel: _tagLabel(income.id),
                    paymentLabel: income.paymentMethodId == null
                        ? l10n.paymentMethodNone
                        : (paymentLabels[income.paymentMethodId!] ??
                            l10n.paymentMethodNone),
                    displayCurrency: displayCurrency,
                    convertedAmountMinor: convertedMinor(income),
                    showPossibleDuplicate:
                        possibleDuplicateIds.contains(income.id),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _tagLabel(int incomeId) {
    final ids = incomeTags[incomeId] ?? const <int>[];
    if (ids.isEmpty) return untaggedLabel;
    return ids.map((id) => tagLabels[id] ?? '?').join(', ');
  }
}

class _IncomeTableRow extends ConsumerWidget {
  final Income income;
  final String tagLabel;
  final String paymentLabel;
  final String? displayCurrency;
  final int? convertedAmountMinor;
  final bool showPossibleDuplicate;

  const _IncomeTableRow({
    required this.income,
    required this.tagLabel,
    required this.paymentLabel,
    required this.displayCurrency,
    required this.convertedAmountMinor,
    this.showPossibleDuplicate = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final lang = Localizations.localeOf(context).languageCode;
    final showConverted =
        displayCurrency != null && convertedAmountMinor != null;
    final countryCode = income.countryCode;
    final countryLabel = countryCode == null || countryCode.isEmpty
        ? l10n.tagKindUnspecifiedCountry
        : countryDisplayName(countryCode, languageCode: lang);

    final content = Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          SizedBox(
            width: _kDateW,
            child: DateText(
              instant: income.occurredAt,
              style: theme.textTheme.bodyMedium,
            ),
          ),
          const SizedBox(width: _kColGap),
          SizedBox(
            width: _kAmountW,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: MoneyText(
                          amountMinor: showConverted
                              ? convertedAmountMinor!
                              : income.storedAmountMinor,
                          currencyCode: showConverted
                              ? displayCurrency!
                              : income.storedCurrencyCode,
                          style: theme.textTheme.titleSmall,
                        ),
                      ),
                      if (showPossibleDuplicate) ...[
                        const SizedBox(width: 4),
                        const PossibleDuplicateBadge(size: 16),
                      ],
                    ],
                  ),
                  if (showConverted &&
                      income.storedCurrencyCode.toUpperCase() !=
                          displayCurrency!.toUpperCase())
                    MoneyText(
                      amountMinor: income.storedAmountMinor,
                      currencyCode: income.storedCurrencyCode,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(width: _kColGap),
          SizedBox(
            width: _kOriginalAmountW,
            child: Align(
              alignment: Alignment.centerLeft,
              child: MoneyText(
                amountMinor: income.originalAmountMinor,
                currencyCode: income.originalCurrencyCode,
                style: theme.textTheme.titleSmall,
              ),
            ),
          ),
          const SizedBox(width: _kColGap),
          SizedBox(
            width: _kPaymentW,
            child: Text(
              paymentLabel,
              style: theme.textTheme.bodySmall,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: _kColGap),
          SizedBox(
            width: _kCountryW,
            child: Row(
              children: [
                if (countryCode != null && countryCode.isNotEmpty) ...[
                  FlagIcon.country(countryCode, size: 16),
                  const SizedBox(width: 4),
                ],
                Expanded(
                  child: Text(
                    countryLabel,
                    style: theme.textTheme.bodySmall,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: _kColGap),
          Expanded(
            child: Text(
              tagLabel,
              style: theme.textTheme.bodySmall,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: _kColGap),
          SizedBox(
            width: _kEditW,
            child: IconButton(
              icon: const Icon(Icons.edit_outlined, size: 20),
              tooltip: l10n.editIncome,
              onPressed: () => showAddIncomeSheet(context, income: income),
              visualDensity: VisualDensity.compact,
            ),
          ),
          const SizedBox(width: _kColGap),
          SizedBox(
            width: _kDeleteW,
            child: IconButton(
              icon: const Icon(Icons.delete_outline, size: 20),
              tooltip: l10n.delete,
              onPressed: () => confirmAndDeleteIncome(
                context,
                ref,
                income.id,
                income: income,
              ),
              visualDensity: VisualDensity.compact,
            ),
          ),
        ],
      ),
    );

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: InkWell(
            onTap: () => showAddIncomeSheet(context, income: income),
            child: content,
          ),
        ),
        const Divider(height: 1),
      ],
    );
  }
}
