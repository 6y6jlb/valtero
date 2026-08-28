import 'package:flutter/material.dart';
import 'package:valtero/features/expenses_list/model/expense_list_query.dart';
import 'package:valtero/features/expenses_list/ui/expenses_filter_form.dart';
import 'package:valtero/shared/l10n/generated/app_localizations.dart';

export 'package:valtero/features/expenses_list/ui/expenses_filter_form.dart'
    show ExpensesFilterOutlineButton;

class ExpensesFilterCard extends StatefulWidget {
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
  final bool initiallyExpanded;

  const ExpensesFilterCard({
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
    this.initiallyExpanded = true,
  });

  @override
  State<ExpensesFilterCard> createState() => _ExpensesFilterCardState();
}

class _ExpensesFilterCardState extends State<ExpensesFilterCard> {
  late bool _expanded = widget.initiallyExpanded;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Card(
      margin: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => setState(() => _expanded = !_expanded),
              borderRadius: _expanded
                  ? const BorderRadius.vertical(top: Radius.circular(12))
                  : BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 8, 10),
                child: Row(
                  children: [
                    Icon(
                      Icons.filter_list,
                      size: 20,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.filtersTitle,
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          if (!_expanded) ...[
                            const SizedBox(height: 2),
                            Text(
                              expensesFilterCollapsedSummary(l10n, widget.draft),
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ],
                      ),
                    ),
                    IconButton(
                      tooltip: _expanded
                          ? l10n.collapseFilters
                          : l10n.expandFilters,
                      onPressed: () =>
                          setState(() => _expanded = !_expanded),
                      icon: Icon(
                        _expanded
                            ? Icons.expand_less
                            : Icons.expand_more,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (_expanded)
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              child: ExpensesFilterForm(
                draft: widget.draft,
                currencyOptions: widget.currencyOptions,
                onPickPeriod: widget.onPickPeriod,
                onCurrencyChanged: widget.onCurrencyChanged,
                onPickTags: widget.onPickTags,
                onPickPayment: widget.onPickPayment,
                onApply: widget.onApply,
                onClear: widget.onClear,
                tagLabels: widget.tagLabels,
                paymentLabels: widget.paymentLabels,
                onClearCurrency: widget.onClearCurrency,
                onClearPeriod: widget.onClearPeriod,
                onClearTags: widget.onClearTags,
                onClearPayment: widget.onClearPayment,
              ),
            ),
        ],
      ),
    );
  }
}
