import 'package:flutter/material.dart';
import 'package:valtero/features/expenses_list/model/expense_list_query.dart';
import 'package:valtero/features/expenses_list/model/expense_list_view.dart';
import 'package:valtero/features/export_expenses/data/expense_exporter.dart';
import 'package:valtero/features/export_expenses/model/export_destination.dart';
import 'package:valtero/features/export_expenses/model/export_readiness.dart';
import 'package:valtero/features/export_expenses/ui/export_menu.dart';
import 'package:valtero/shared/l10n/generated/app_localizations.dart';
import 'package:valtero/widgets/single_choice_sheet.dart';

class ExpensesListingCard extends StatelessWidget {
  final ExpenseListViewMode view;
  final ExpenseListGroup group;
  final ExpenseListSortField sort;
  final bool ascending;
  final ValueChanged<ExpenseListViewMode> onViewChanged;
  final ValueChanged<ExpenseListGroup> onGroupChanged;
  final void Function(ExpenseListSortField field, bool ascending)
      onSortChanged;
  final Future<void> Function(
    ExportFormat format, {
    required ExportDestination destination,
  }) onExport;
  final bool showTelegram;
  final Widget child;

  const ExpensesListingCard({
    super.key,
    required this.view,
    required this.group,
    required this.sort,
    required this.ascending,
    required this.onViewChanged,
    required this.onGroupChanged,
    required this.onSortChanged,
    required this.onExport,
    this.showTelegram = false,
    required this.child,
  });

  String get _sortKey => '${sort.name}:${ascending ? 'asc' : 'desc'}';

  Future<void> _pickView(BuildContext context, AppLocalizations l10n) async {
    final next = await showSingleChoiceSheet<ExpenseListViewMode>(
      context: context,
      title: l10n.listingView,
      selected: view,
      options: [
        (value: ExpenseListViewMode.list, label: l10n.viewList),
        (value: ExpenseListViewMode.grouping, label: l10n.viewGrouping),
        (value: ExpenseListViewMode.chart, label: l10n.viewChart),
      ],
    );
    if (next != null) onViewChanged(next);
  }

  Future<void> _pickGroup(BuildContext context, AppLocalizations l10n) async {
    final next = await showSingleChoiceSheet<ExpenseListGroup>(
      context: context,
      title: l10n.groupBy,
      selected: group,
      options: [
        (value: ExpenseListGroup.currency, label: l10n.groupCurrency),
        (value: ExpenseListGroup.date, label: l10n.groupDate),
        (value: ExpenseListGroup.country, label: l10n.groupTagCountry),
        (value: ExpenseListGroup.payment, label: l10n.groupPayment),
        (value: ExpenseListGroup.tagCustom, label: l10n.groupTagCustom),
      ],
    );
    if (next != null) onGroupChanged(next);
  }

  Future<void> _pickSort(BuildContext context, AppLocalizations l10n) async {
    final options = <({String value, String label})>[
      for (final field in ExpenseListSortField.values)
        for (final asc in [false, true])
          (
            value: '${field.name}:${asc ? 'asc' : 'desc'}',
            label:
                '${switch (field) {
                  ExpenseListSortField.date => l10n.sortDate,
                  ExpenseListSortField.amount => l10n.sortAmount,
                  ExpenseListSortField.currency => l10n.sortCurrency,
                }} · ${asc ? l10n.ascending : l10n.descending}',
          ),
    ];
    final next = await showSingleChoiceSheet<String>(
      context: context,
      title: l10n.sortBy,
      selected: _sortKey,
      initialChildSize: 0.55,
      options: options,
    );
    if (next == null) return;
    final parts = next.split(':');
    final field =
        ExpenseListSortField.values.firstWhere((e) => e.name == parts[0]);
    onSortChanged(field, parts[1] == 'asc');
  }

  String _viewLabel(AppLocalizations l10n) => switch (view) {
        ExpenseListViewMode.list => l10n.viewList,
        ExpenseListViewMode.grouping => l10n.viewGrouping,
        ExpenseListViewMode.chart => l10n.viewChart,
      };

  String _groupLabel(AppLocalizations l10n) => switch (group) {
        ExpenseListGroup.currency => l10n.groupCurrency,
        ExpenseListGroup.date => l10n.groupDate,
        ExpenseListGroup.country => l10n.groupTagCountry,
        ExpenseListGroup.payment => l10n.groupPayment,
        ExpenseListGroup.tagCustom ||
        ExpenseListGroup.tag =>
          l10n.groupTagCustom,
        ExpenseListGroup.none => l10n.groupCurrency,
      };

  String _sortLabel(AppLocalizations l10n) {
    final fieldLabel = switch (sort) {
      ExpenseListSortField.date => l10n.sortDate,
      ExpenseListSortField.amount => l10n.sortAmount,
      ExpenseListSortField.currency => l10n.sortCurrency,
    };
    return '$fieldLabel · ${ascending ? l10n.ascending : l10n.descending}';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final actionStyle = theme.textTheme.bodySmall?.copyWith(
      fontSize: 12,
      height: 1.2,
    );

    Widget actionLabel(String text) => Text(text, style: actionStyle);

    Widget choiceButton({
      required String prefix,
      required String value,
      required VoidCallback onTap,
    }) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(6),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              actionLabel('$prefix: '),
              Text(
                value,
                style: actionStyle?.copyWith(
                  color: theme.colorScheme.onSurface,
                ),
              ),
              Icon(
                Icons.arrow_drop_down,
                size: 18,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      );
    }

    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
            child: DefaultTextStyle.merge(
              style: actionStyle ?? const TextStyle(fontSize: 12),
              child: IconTheme.merge(
                data: const IconThemeData(size: 16),
                child: Wrap(
                  spacing: 10,
                  runSpacing: 6,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    PopupMenuButton<String>(
                      tooltip: l10n.export,
                      padding: EdgeInsets.zero,
                      onSelected: (key) {
                        final selected = parseExportMenuValue(key);
                        if (selected == null) return;
                        onExport(
                          selected.format,
                          destination: selected.destination,
                        );
                      },
                      itemBuilder: (context) => buildExportMenuItems(
                        l10n,
                        showShare: isExportShareSupported,
                        showTelegram: showTelegram,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 6,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.download_outlined),
                            const SizedBox(width: 4),
                            actionLabel(l10n.export),
                            const Icon(Icons.arrow_drop_down),
                          ],
                        ),
                      ),
                    ),
                    choiceButton(
                      prefix: l10n.listingView,
                      value: _viewLabel(l10n),
                      onTap: () => _pickView(context, l10n),
                    ),
                    if (view == ExpenseListViewMode.grouping)
                      choiceButton(
                        prefix: l10n.groupBy,
                        value: _groupLabel(l10n),
                        onTap: () => _pickGroup(context, l10n),
                      ),
                    choiceButton(
                      prefix: l10n.sortBy,
                      value: _sortLabel(l10n),
                      onTap: () => _pickSort(context, l10n),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const Divider(height: 1),
          child,
        ],
      ),
    );
  }
}
