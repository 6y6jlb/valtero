import 'package:flutter/material.dart';
import 'package:valtero/features/expenses_list/model/expense_list_query.dart';
import 'package:valtero/shared/l10n/generated/app_localizations.dart';
import 'package:valtero/shared/utils/date_period.dart';
import 'package:valtero/widgets/flag_icon.dart';
import 'package:valtero/widgets/period_picker.dart';

const _filterHeight = 56.0;
const _filterGap = 8.0;
const _filterColumns = 2;

/// Period / currency / tags / payment filter controls.
class ExpensesFilterForm extends StatelessWidget {
  final ExpenseListQuery draft;
  final List<String> currencyOptions;
  final VoidCallback onPickPeriod;
  final ValueChanged<String?> onCurrencyChanged;
  final VoidCallback onPickTags;
  final VoidCallback onPickPayment;
  final VoidCallback onApply;
  final VoidCallback onClear;
  final Map<int, String> tagLabels;
  final Map<int, String> paymentLabels;
  final VoidCallback onClearCurrency;
  final VoidCallback onClearPeriod;
  final VoidCallback onClearTags;
  final VoidCallback onClearPayment;

  const ExpensesFilterForm({
    super.key,
    required this.draft,
    required this.currencyOptions,
    required this.onPickPeriod,
    required this.onCurrencyChanged,
    required this.onPickTags,
    required this.onPickPayment,
    required this.onApply,
    required this.onClear,
    required this.tagLabels,
    required this.paymentLabels,
    required this.onClearCurrency,
    required this.onClearPeriod,
    required this.onClearTags,
    required this.onClearPayment,
  });

  InputDecoration _decoration(ThemeData theme, String label) {
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide(color: theme.colorScheme.outline),
    );
    return InputDecoration(
      labelText: label,
      floatingLabelBehavior: FloatingLabelBehavior.auto,
      border: border,
      enabledBorder: border,
      focusedBorder: border,
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      constraints: const BoxConstraints.tightFor(height: _filterHeight),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    final periodLabel = formatPeriodLabel(
      l10n,
      DatePeriod(from: draft.from, to: draft.to),
    );
    final currencyLabel = draft.currencyCode ?? l10n.all;
    final tagsLabel = draft.tagIds.isEmpty
        ? l10n.all
        : draft.tagIds.map((id) => tagLabels[id] ?? '?').join(', ');
    final paymentLabel = draft.paymentMethodIds.isEmpty
        ? l10n.all
        : draft.paymentMethodIds
            .map((id) => paymentLabels[id] ?? '?')
            .join(', ');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            final cellWidth = (constraints.maxWidth -
                    _filterGap * (_filterColumns - 1)) /
                _filterColumns;

            Widget cell(Widget child) => SizedBox(
                  width: cellWidth,
                  height: _filterHeight,
                  child: child,
                );

            return Wrap(
              spacing: _filterGap,
              runSpacing: _filterGap,
              children: [
                cell(
                  ExpensesFilterOutlineButton(
                    value: periodLabel,
                    icon: Icons.date_range,
                    decoration: _decoration(theme, l10n.periodRange),
                    onTap: onPickPeriod,
                  ),
                ),
                cell(
                  DropdownButtonFormField<String?>(
                    // ignore: deprecated_member_use
                    value: draft.currencyCode,
                    isExpanded: true,
                    isDense: true,
                    iconSize: 20,
                    style: theme.textTheme.bodyMedium,
                    decoration: _decoration(theme, l10n.filterCurrency),
                    selectedItemBuilder: (context) => [
                      Text(l10n.all, overflow: TextOverflow.ellipsis),
                      for (final code in currencyOptions)
                        Text(code, overflow: TextOverflow.ellipsis),
                    ],
                    items: [
                      DropdownMenuItem<String?>(
                        value: null,
                        child: Text(l10n.all),
                      ),
                      for (final code in currencyOptions)
                        DropdownMenuItem<String?>(
                          value: code,
                          child: CurrencyCodeLabel(code, compact: true),
                        ),
                    ],
                    onChanged: onCurrencyChanged,
                  ),
                ),
                cell(
                  ExpensesFilterOutlineButton(
                    value: draft.tagIds.isEmpty
                        ? l10n.all
                        : l10n.tagsSelected(draft.tagIds.length),
                    icon: Icons.label_outline,
                    decoration: _decoration(theme, l10n.selectTags),
                    onTap: onPickTags,
                  ),
                ),
                cell(
                  ExpensesFilterOutlineButton(
                    value: draft.paymentMethodIds.isEmpty
                        ? l10n.all
                        : l10n.paymentSelected(draft.paymentMethodIds.length),
                    icon: Icons.payments_outlined,
                    decoration: _decoration(theme, l10n.filterPayment),
                    onTap: onPickPayment,
                  ),
                ),
              ],
            );
          },
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            FilledButton(
              onPressed: onApply,
              child: Text(l10n.applyFilters),
            ),
            const SizedBox(width: 8),
            OutlinedButton.icon(
              onPressed: onClear,
              icon: Icon(
                Icons.close,
                size: 18,
                color: theme.colorScheme.error,
              ),
              label: Text(l10n.clearFilters),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 4,
          children: [
            InputChip(
              label: Text('${l10n.periodRange}: $periodLabel'),
              onDeleted: onClearPeriod,
            ),
            InputChip(
              label: Text('${l10n.filterCurrency}: $currencyLabel'),
              onDeleted: onClearCurrency,
            ),
            InputChip(
              label: Text('${l10n.selectTags}: $tagsLabel'),
              onDeleted: onClearTags,
            ),
            InputChip(
              label: Text('${l10n.filterPayment}: $paymentLabel'),
              onDeleted: onClearPayment,
            ),
          ],
        ),
      ],
    );
  }
}

/// One-line summary of current draft filters.
String expensesFilterCollapsedSummary(
  AppLocalizations l10n,
  ExpenseListQuery draft,
) {
  final period = formatPeriodLabel(
    l10n,
    DatePeriod(from: draft.from, to: draft.to),
  );
  final currency = draft.currencyCode ?? l10n.all;
  final tags = draft.tagIds.isEmpty
      ? l10n.all
      : l10n.tagsSelected(draft.tagIds.length);
  final payment = draft.paymentMethodIds.isEmpty
      ? l10n.all
      : l10n.paymentSelected(draft.paymentMethodIds.length);
  final country = draft.countryCodes.isEmpty
      ? l10n.all
      : draft.countryCodes.join(', ');
  return '$period · $currency · $tags · $payment · $country';
}

class ExpensesFilterOutlineButton extends StatelessWidget {
  final String value;
  final IconData icon;
  final InputDecoration decoration;
  final VoidCallback onTap;

  const ExpensesFilterOutlineButton({
    super.key,
    required this.value,
    required this.icon,
    required this.decoration,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InputDecorator(
      decoration: decoration,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          height: 24,
          child: Row(
            children: [
              Icon(icon, size: 18, color: theme.colorScheme.onSurface),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  value,
                  style: theme.textTheme.bodyMedium,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
              Icon(
                Icons.arrow_drop_down,
                size: 20,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
