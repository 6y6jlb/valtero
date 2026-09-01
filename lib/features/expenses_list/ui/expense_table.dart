import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:valtero/features/expenses_list/ui/possible_duplicate_badge.dart';
import 'package:valtero/shared/consts/countries.dart';
import 'package:valtero/shared/database/app_database.dart';
import 'package:valtero/shared/l10n/generated/app_localizations.dart';
import 'package:valtero/widgets/date_text.dart';
import 'package:valtero/widgets/flag_icon.dart';
import 'package:valtero/widgets/money_text.dart';

const double _kColGap = 16;
const double _kSelectW = 40;
const double _kDateW = 110;
const double _kAmountW = 120;
const double _kOriginalAmountW = 120;
const double _kPaymentW = 100;
const double _kCountryW = 110;
const double _kTagsW = 140;
const double _kEditW = 40;
const double _kDeleteW = 40;

/// Minimum content width so columns don't compress on narrow screens.
const double _kTableMinWidth =
    16 * 2 + // horizontal padding
    _kSelectW +
    _kColGap +
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
    _kTagsW +
    _kColGap +
    _kEditW +
    _kColGap +
    _kDeleteW;

class ExpenseTable extends StatelessWidget {
  final List<Expense> items;
  final Map<int, List<int>> expenseTags;
  final Map<int, String> tagLabels;
  final Map<int, String> paymentLabels;
  final String untaggedLabel;
  final String? displayCurrency;
  final int? Function(Expense expense) convertedMinor;
  final ValueChanged<int> onDelete;
  final ValueChanged<Expense>? onOpen;
  final ValueChanged<Expense>? onEdit;
  final Set<int> selectedIds;
  final ValueChanged<int> onToggleSelected;
  final VoidCallback? onToggleSelectAll;
  final bool allSelectableSelected;
  final Set<int> possibleDuplicateIds;

  const ExpenseTable({
    super.key,
    required this.items,
    required this.expenseTags,
    required this.tagLabels,
    this.paymentLabels = const {},
    required this.untaggedLabel,
    required this.displayCurrency,
    required this.convertedMinor,
    required this.onDelete,
    this.onOpen,
    this.onEdit,
    this.selectedIds = const {},
    required this.onToggleSelected,
    this.onToggleSelectAll,
    this.allSelectableSelected = false,
    this.possibleDuplicateIds = const {},
  });

  bool get _hasSelection => selectedIds.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final headerStyle = theme.textTheme.labelMedium?.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
    );
    final someSelected =
        _hasSelection && !allSelectableSelected && items.isNotEmpty;

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
                        width: _kSelectW,
                        child: Checkbox(
                          tristate: true,
                          value: allSelectableSelected
                              ? true
                              : (someSelected ? null : false),
                          onChanged: onToggleSelectAll == null
                              ? null
                              : (_) => onToggleSelectAll!(),
                          visualDensity: VisualDensity.compact,
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                        ),
                      ),
                      const SizedBox(width: _kColGap),
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
                for (final expense in items)
                  ExpenseTableRow(
                    expense: expense,
                    tagLabel: _tagLabel(expense.id),
                    paymentLabel: expense.paymentMethodId == null
                        ? l10n.paymentMethodNone
                        : (paymentLabels[expense.paymentMethodId!] ??
                            l10n.paymentMethodNone),
                    displayCurrency: displayCurrency,
                    convertedAmountMinor: convertedMinor(expense),
                    selected: selectedIds.contains(expense.id),
                    selectionActive: _hasSelection,
                    showPossibleDuplicate:
                        possibleDuplicateIds.contains(expense.id),
                    onToggleSelected: () => onToggleSelected(expense.id),
                    onDelete: () => onDelete(expense.id),
                    onOpen: onOpen == null ? null : () => onOpen!(expense),
                    onEdit: onEdit == null ? null : () => onEdit!(expense),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _tagLabel(int expenseId) {
    final ids = expenseTags[expenseId] ?? const <int>[];
    if (ids.isEmpty) return untaggedLabel;
    return ids.map((id) => tagLabels[id] ?? '?').join(', ');
  }
}

class ExpenseTableRow extends ConsumerWidget {
  final Expense expense;
  final String tagLabel;
  final String paymentLabel;
  final String? displayCurrency;
  final int? convertedAmountMinor;
  final bool selected;
  final bool selectionActive;
  final bool showPossibleDuplicate;
  final VoidCallback onToggleSelected;
  final VoidCallback onDelete;
  final VoidCallback? onOpen;
  final VoidCallback? onEdit;

  const ExpenseTableRow({
    super.key,
    required this.expense,
    required this.tagLabel,
    required this.paymentLabel,
    required this.displayCurrency,
    required this.convertedAmountMinor,
    required this.selected,
    required this.selectionActive,
    this.showPossibleDuplicate = false,
    required this.onToggleSelected,
    required this.onDelete,
    this.onOpen,
    this.onEdit,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final lang = Localizations.localeOf(context).languageCode;
    final showConverted =
        displayCurrency != null && convertedAmountMinor != null;
    final countryCode = expense.countryCode;
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
              instant: expense.occurredAt,
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
                              : expense.storedAmountMinor,
                          currencyCode: showConverted
                              ? displayCurrency!
                              : expense.storedCurrencyCode,
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
                      expense.storedCurrencyCode.toUpperCase() !=
                          displayCurrency!.toUpperCase())
                    MoneyText(
                      amountMinor: expense.storedAmountMinor,
                      currencyCode: expense.storedCurrencyCode,
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
                amountMinor: expense.originalAmountMinor,
                currencyCode: expense.originalCurrencyCode,
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
              tooltip: l10n.editExpense,
              onPressed: selectionActive || onEdit == null ? null : onEdit,
              visualDensity: VisualDensity.compact,
            ),
          ),
          const SizedBox(width: _kColGap),
          SizedBox(
            width: _kDeleteW,
            child: IconButton(
              icon: const Icon(Icons.delete_outline, size: 20),
              tooltip: l10n.delete,
              onPressed: selectionActive ? null : onDelete,
              visualDensity: VisualDensity.compact,
            ),
          ),
        ],
      ),
    );

    VoidCallback? rowTap;
    if (selectionActive) {
      rowTap = onToggleSelected;
    } else if (onOpen != null) {
      rowTap = onOpen;
    } else if (onEdit != null) {
      rowTap = onEdit;
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              SizedBox(
                width: _kSelectW,
                child: Checkbox(
                  value: selected,
                  onChanged: (_) => onToggleSelected(),
                  visualDensity: VisualDensity.compact,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
              const SizedBox(width: _kColGap),
              Expanded(
                child: rowTap == null
                    ? content
                    : InkWell(onTap: rowTap, child: content),
              ),
            ],
          ),
        ),
        const Divider(height: 1),
      ],
    );
  }
}
