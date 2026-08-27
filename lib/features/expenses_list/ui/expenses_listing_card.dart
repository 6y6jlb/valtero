import 'package:flutter/material.dart';
import 'package:valtero/features/expenses_list/model/expense_list_export.dart';
import 'package:valtero/features/expenses_list/model/expense_list_query.dart';
import 'package:valtero/features/expenses_list/model/expense_list_view.dart';
import 'package:valtero/features/export_expenses/data/expense_exporter.dart';
import 'package:valtero/shared/l10n/generated/app_localizations.dart';

const expensesPageSizeOptions = [10, 25, 50, 100];

class ExpensesListingCard extends StatelessWidget {
  final int pageSize;
  final int page;
  final int pageCount;
  final ExpenseListViewMode view;
  final ExpenseListGroup group;
  final ExpenseChartBreakdown chartBreakdown;
  final ExpenseListSortField sort;
  final bool ascending;
  final String? displayCurrency;
  final VoidCallback onDisplayIn;
  final ValueChanged<int> onPageSizeChanged;
  final ValueChanged<int> onPageChanged;
  final ValueChanged<ExpenseListViewMode> onViewChanged;
  final ValueChanged<ExpenseListGroup> onGroupChanged;
  final ValueChanged<ExpenseChartBreakdown> onChartBreakdownChanged;
  final void Function(ExpenseListSortField field, bool ascending)
      onSortChanged;
  final Future<void> Function(
    ExportFormat format, {
    required ExpenseExportAction action,
  }) onExport;
  final Widget child;

  const ExpensesListingCard({
    super.key,
    required this.pageSize,
    required this.page,
    required this.pageCount,
    required this.view,
    required this.group,
    required this.chartBreakdown,
    required this.sort,
    required this.ascending,
    required this.displayCurrency,
    required this.onDisplayIn,
    required this.onPageSizeChanged,
    required this.onPageChanged,
    required this.onViewChanged,
    required this.onGroupChanged,
    required this.onChartBreakdownChanged,
    required this.onSortChanged,
    required this.onExport,
    required this.child,
  });

  String get _sortKey => '${sort.name}:${ascending ? 'asc' : 'desc'}';

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final actionStyle = theme.textTheme.bodySmall?.copyWith(
      fontSize: 12,
      height: 1.2,
    );

    Widget actionLabel(String text) => Text(text, style: actionStyle);

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
                    TextButton.icon(
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        visualDensity: VisualDensity.compact,
                        textStyle: actionStyle,
                      ),
                      onPressed: onDisplayIn,
                      icon: const Icon(Icons.currency_exchange),
                      label: Text(
                        displayCurrency == null
                            ? l10n.displayIn
                            : '${l10n.displayIn}: $displayCurrency',
                      ),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        actionLabel('${l10n.perPage}: '),
                        DropdownButton<int>(
                          value: pageSize,
                          isDense: true,
                          style: actionStyle?.copyWith(
                            color: theme.colorScheme.onSurface,
                          ),
                          underline: const SizedBox.shrink(),
                          items: [
                            for (final n in expensesPageSizeOptions)
                              DropdownMenuItem(
                                value: n,
                                child: Text('$n'),
                              ),
                          ],
                          onChanged: (v) {
                            if (v != null) onPageSizeChanged(v);
                          },
                        ),
                      ],
                    ),
                    PopupMenuButton<String>(
                      tooltip: l10n.export,
                      padding: EdgeInsets.zero,
                      onSelected: (key) {
                        switch (key) {
                          case 'csv_save':
                            onExport(
                              ExportFormat.csv,
                              action: ExpenseExportAction.save,
                            );
                          case 'csv_share':
                            onExport(
                              ExportFormat.csv,
                              action: ExpenseExportAction.share,
                            );
                          case 'csv_copy':
                            onExport(
                              ExportFormat.csv,
                              action: ExpenseExportAction.copy,
                            );
                          case 'json_save':
                            onExport(
                              ExportFormat.json,
                              action: ExpenseExportAction.save,
                            );
                          case 'json_share':
                            onExport(
                              ExportFormat.json,
                              action: ExpenseExportAction.share,
                            );
                          case 'json_copy':
                            onExport(
                              ExportFormat.json,
                              action: ExpenseExportAction.copy,
                            );
                        }
                      },
                      itemBuilder: (context) => [
                        PopupMenuItem(
                          value: 'csv_save',
                          child: Text(
                            '${l10n.exportCsv} · ${l10n.saveFile}',
                          ),
                        ),
                        PopupMenuItem(
                          value: 'csv_share',
                          child: Text('${l10n.exportCsv} · ${l10n.share}'),
                        ),
                        PopupMenuItem(
                          value: 'csv_copy',
                          child: Text(
                            '${l10n.copyAs} ${l10n.exportCsv}',
                          ),
                        ),
                        PopupMenuItem(
                          value: 'json_save',
                          child: Text(
                            '${l10n.exportJson} · ${l10n.saveFile}',
                          ),
                        ),
                        PopupMenuItem(
                          value: 'json_share',
                          child: Text('${l10n.exportJson} · ${l10n.share}'),
                        ),
                        PopupMenuItem(
                          value: 'json_copy',
                          child: Text(
                            '${l10n.copyAs} ${l10n.exportJson}',
                          ),
                        ),
                      ],
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
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        actionLabel('${l10n.listingView}: '),
                        DropdownButton<ExpenseListViewMode>(
                          value: view,
                          isDense: true,
                          style: actionStyle?.copyWith(
                            color: theme.colorScheme.onSurface,
                          ),
                          underline: const SizedBox.shrink(),
                          items: [
                            DropdownMenuItem(
                              value: ExpenseListViewMode.list,
                              child: Text(l10n.viewList),
                            ),
                            DropdownMenuItem(
                              value: ExpenseListViewMode.grouping,
                              child: Text(l10n.viewGrouping),
                            ),
                            DropdownMenuItem(
                              value: ExpenseListViewMode.chart,
                              child: Text(l10n.viewChart),
                            ),
                          ],
                          onChanged: (v) {
                            if (v != null) onViewChanged(v);
                          },
                        ),
                      ],
                    ),
                    if (view == ExpenseListViewMode.grouping)
                      DropdownButton<ExpenseListGroup>(
                        value: group,
                        isDense: true,
                        style: actionStyle?.copyWith(
                          color: theme.colorScheme.onSurface,
                        ),
                        underline: const SizedBox.shrink(),
                        items: [
                          DropdownMenuItem(
                            value: ExpenseListGroup.currency,
                            child: Text(
                              '${l10n.groupBy}: ${l10n.groupCurrency}',
                            ),
                          ),
                          DropdownMenuItem(
                            value: ExpenseListGroup.date,
                            child: Text(
                              '${l10n.groupBy}: ${l10n.groupDate}',
                            ),
                          ),
                          DropdownMenuItem(
                            value: ExpenseListGroup.tag,
                            child: Text(
                              '${l10n.groupBy}: ${l10n.groupTag}',
                            ),
                          ),
                        ],
                        onChanged: (v) {
                          if (v != null) onGroupChanged(v);
                        },
                      ),
                    if (view == ExpenseListViewMode.chart)
                      DropdownButton<ExpenseChartBreakdown>(
                        value: chartBreakdown,
                        isDense: true,
                        style: actionStyle?.copyWith(
                          color: theme.colorScheme.onSurface,
                        ),
                        underline: const SizedBox.shrink(),
                        items: [
                          DropdownMenuItem(
                            value: ExpenseChartBreakdown.currency,
                            child: Text(
                              '${l10n.chartBy}: ${l10n.chartByCurrency}',
                            ),
                          ),
                          DropdownMenuItem(
                            value: ExpenseChartBreakdown.tags,
                            child: Text(
                              '${l10n.chartBy}: ${l10n.chartByTags}',
                            ),
                          ),
                          DropdownMenuItem(
                            value: ExpenseChartBreakdown.month,
                            child: Text(
                              '${l10n.chartBy}: ${l10n.chartByMonth}',
                            ),
                          ),
                          DropdownMenuItem(
                            value: ExpenseChartBreakdown.year,
                            child: Text(
                              '${l10n.chartBy}: ${l10n.chartByYear}',
                            ),
                          ),
                        ],
                        onChanged: (v) {
                          if (v != null) onChartBreakdownChanged(v);
                        },
                      ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        actionLabel('${l10n.sortBy}: '),
                        DropdownButton<String>(
                          value: _sortKey,
                          isDense: true,
                          style: actionStyle?.copyWith(
                            color: theme.colorScheme.onSurface,
                          ),
                          underline: const SizedBox.shrink(),
                          items: [
                            for (final field in ExpenseListSortField.values)
                              for (final asc in [false, true])
                                DropdownMenuItem(
                                  value:
                                      '${field.name}:${asc ? 'asc' : 'desc'}',
                                  child: Text(
                                    '${switch (field) {
                                      ExpenseListSortField.date =>
                                        l10n.sortDate,
                                      ExpenseListSortField.amount =>
                                        l10n.sortAmount,
                                      ExpenseListSortField.currency =>
                                        l10n.sortCurrency,
                                    }} · ${asc ? l10n.ascending : l10n.descending}',
                                  ),
                                ),
                          ],
                          onChanged: (v) {
                            if (v == null) return;
                            final parts = v.split(':');
                            final field = ExpenseListSortField.values
                                .firstWhere((e) => e.name == parts[0]);
                            onSortChanged(field, parts[1] == 'asc');
                          },
                        ),
                      ],
                    ),
                    if (view == ExpenseListViewMode.list && pageCount > 1)
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            visualDensity: VisualDensity.compact,
                            onPressed: page > 0
                                ? () => onPageChanged(page - 1)
                                : null,
                            icon: const Icon(Icons.chevron_left),
                          ),
                          actionLabel('${page + 1} / $pageCount'),
                          IconButton(
                            visualDensity: VisualDensity.compact,
                            onPressed: page < pageCount - 1
                                ? () => onPageChanged(page + 1)
                                : null,
                            icon: const Icon(Icons.chevron_right),
                          ),
                        ],
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
