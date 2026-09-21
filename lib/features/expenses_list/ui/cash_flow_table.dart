import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:valtero/features/expenses_list/model/cash_flow_selection_key.dart';
import 'package:valtero/features/expenses_list/model/recent_operation.dart';
import 'package:valtero/features/expenses_list/ui/possible_duplicate_badge.dart';
import 'package:valtero/features/expenses_list/ui/signed_money_text.dart';
import 'package:valtero/shared/consts/countries.dart';
import 'package:valtero/shared/l10n/generated/app_localizations.dart';
import 'package:valtero/shared/utils/tag_label.dart';
import 'package:valtero/widgets/date_text.dart';
import 'package:valtero/widgets/flag_icon.dart';
import 'package:valtero/widgets/money_text.dart';

const double _kColGap = 16;
const double _kSelectW = 40;
const double _kDateW = 110;
const double _kTypeW = 90;
const double _kAmountW = 140;
const double _kOriginalAmountW = 120;
const double _kPaymentW = 100;
const double _kCountryW = 110;
const double _kTagsW = 140;
const double _kEditW = 40;
const double _kDeleteW = 40;

const double _kTableMinWidth = 16 * 2 +
    _kSelectW +
    _kColGap +
    _kDateW +
    _kColGap +
    _kTypeW +
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

/// Merged cash-flow list table. Amount is signed and tinted per direction;
/// a type column names the direction; tags come from the matching kind map.
class CashFlowTable extends StatelessWidget {
  final List<RecentOperation> items;
  final Map<int, String> paymentLabels;
  final Map<int, List<int>> expenseTags;
  final Map<int, List<int>> incomeTags;
  final Map<int, String> tagLabels;
  final Map<int, int?> tagParentIds;
  final String untaggedLabel;
  final String? displayCurrency;
  final int? Function(RecentOperation operation) convertedMinor;
  final ValueChanged<CashFlowSelectionKey> onDelete;
  final ValueChanged<RecentOperation>? onOpen;
  final ValueChanged<RecentOperation>? onEdit;
  final Set<CashFlowSelectionKey> selectedKeys;
  final ValueChanged<CashFlowSelectionKey> onToggleSelected;
  final VoidCallback? onToggleSelectAll;
  final bool allSelectableSelected;

  const CashFlowTable({
    super.key,
    required this.items,
    this.paymentLabels = const {},
    this.expenseTags = const {},
    this.incomeTags = const {},
    this.tagLabels = const {},
    this.tagParentIds = const {},
    this.untaggedLabel = '',
    required this.displayCurrency,
    required this.convertedMinor,
    required this.onDelete,
    this.onOpen,
    this.onEdit,
    this.selectedKeys = const {},
    required this.onToggleSelected,
    this.onToggleSelectAll,
    this.allSelectableSelected = false,
  });

  bool get _hasSelection => selectedKeys.isNotEmpty;

  String _tagLabel(RecentOperation op) {
    final ids = op.kind == OperationKind.income
        ? (incomeTags[op.id] ?? const <int>[])
        : (expenseTags[op.id] ?? const <int>[]);
    if (ids.isEmpty) return untaggedLabel;
    final combined =
        formatTagLabelsCombined(ids, tagLabels, tagParentIds);
    return combined.isEmpty ? untaggedLabel : combined;
  }

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
                        width: _kTypeW,
                        child: Text(l10n.columnType, style: headerStyle),
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
                for (final op in items)
                  CashFlowTableRow(
                    operation: op,
                    paymentLabel: op.paymentMethodId == null
                        ? l10n.paymentMethodNone
                        : (paymentLabels[op.paymentMethodId!] ??
                            l10n.paymentMethodNone),
                    tagsLabel: _tagLabel(op),
                    displayCurrency: displayCurrency,
                    convertedAmountMinor: convertedMinor(op),
                    selected: selectedKeys.contains(
                      CashFlowSelectionKey.fromOperation(op),
                    ),
                    selectionActive: _hasSelection,
                    onToggleSelected: () => onToggleSelected(
                      CashFlowSelectionKey.fromOperation(op),
                    ),
                    onDelete: () => onDelete(
                      CashFlowSelectionKey.fromOperation(op),
                    ),
                    onOpen: onOpen == null ? null : () => onOpen!(op),
                    onEdit: onEdit == null ? null : () => onEdit!(op),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class CashFlowTableRow extends ConsumerWidget {
  final RecentOperation operation;
  final String paymentLabel;
  final String tagsLabel;
  final String? displayCurrency;
  final int? convertedAmountMinor;
  final bool selected;
  final bool selectionActive;
  final VoidCallback onToggleSelected;
  final VoidCallback onDelete;
  final VoidCallback? onOpen;
  final VoidCallback? onEdit;

  const CashFlowTableRow({
    super.key,
    required this.operation,
    required this.paymentLabel,
    required this.tagsLabel,
    required this.displayCurrency,
    required this.convertedAmountMinor,
    required this.selected,
    required this.selectionActive,
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
    final isIncome = operation.kind == OperationKind.income;
    final sign = isIncome ? 1 : -1;
    final showConverted =
        displayCurrency != null && convertedAmountMinor != null;
    final countryCode = operation.countryCode;
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
              instant: operation.occurredAt,
              style: theme.textTheme.bodyMedium,
            ),
          ),
          const SizedBox(width: _kColGap),
          SizedBox(
            width: _kTypeW,
            child: Row(
              children: [
                Icon(
                  isIncome
                      ? Icons.south_west_outlined
                      : Icons.north_east_outlined,
                  size: 16,
                  color: isIncome
                      ? theme.colorScheme.tertiary
                      : theme.colorScheme.error,
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    isIncome
                        ? l10n.operationTypeIncome
                        : l10n.operationTypeExpense,
                    style: theme.textTheme.bodySmall,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
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
                        child: SignedMoneyText(
                          signedAmountMinor: sign *
                              (showConverted
                                  ? convertedAmountMinor!
                                  : operation.amountMinor),
                          currencyCode: showConverted
                              ? displayCurrency!
                              : operation.currencyCode,
                          style: theme.textTheme.titleSmall,
                        ),
                      ),
                      if (operation.possibleDuplicate) ...[
                        const SizedBox(width: 4),
                        const PossibleDuplicateBadge(size: 16),
                      ],
                    ],
                  ),
                  if (showConverted &&
                      operation.currencyCode.toUpperCase() !=
                          displayCurrency!.toUpperCase())
                    MoneyText(
                      amountMinor: operation.amountMinor,
                      currencyCode: operation.currencyCode,
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
                amountMinor: operation.originalAmountMinor,
                currencyCode: operation.originalCurrencyCode,
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
              tagsLabel,
              style: theme.textTheme.bodySmall,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: _kColGap),
          SizedBox(
            width: _kEditW,
            child: IconButton(
              icon: const Icon(Icons.edit_outlined, size: 20),
              tooltip: isIncome ? l10n.editIncome : l10n.editExpense,
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
