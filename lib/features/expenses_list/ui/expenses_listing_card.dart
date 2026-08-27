import 'package:flutter/material.dart';
import 'package:valtero/features/expenses_list/model/expense_list_query.dart';
import 'package:valtero/features/expenses_list/model/expense_list_view.dart';
import 'package:valtero/features/export_expenses/data/expense_exporter.dart';
import 'package:valtero/shared/l10n/generated/app_localizations.dart';

const expensesPageSizeOptions = [10, 25, 50, 100];

class ExpensesListingCard extends StatelessWidget {
  final int totalCount;
  final int pageSize;
  final int page;
  final int pageCount;
  final ExpenseListViewMode view;
  final ExpenseListGroup group;
  final ExpenseChartBreakdown chartBreakdown;
  final String? displayCurrency;
  final String? exportMessage;
  final VoidCallback onDisplayIn;
  final ValueChanged<int> onPageSizeChanged;
  final ValueChanged<int> onPageChanged;
  final ValueChanged<ExpenseListViewMode> onViewChanged;
  final ValueChanged<ExpenseListGroup> onGroupChanged;
  final ValueChanged<ExpenseChartBreakdown> onChartBreakdownChanged;
  final Future<void> Function(ExportFormat format, {required bool share})
      onExport;
  final Widget child;

  const ExpensesListingCard({
    super.key,
    required this.totalCount,
    required this.pageSize,
    required this.page,
    required this.pageCount,
    required this.view,
    required this.group,
    required this.chartBreakdown,
    required this.displayCurrency,
    required this.exportMessage,
    required this.onDisplayIn,
    required this.onPageSizeChanged,
    required this.onPageChanged,
    required this.onViewChanged,
    required this.onGroupChanged,
    required this.onChartBreakdownChanged,
    required this.onExport,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 8),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              alignment: WrapAlignment.spaceBetween,
              children: [
                Text(
                  l10n.totalRecords(totalCount),
                  style: theme.textTheme.titleSmall,
                ),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    OutlinedButton.icon(
                      onPressed: onDisplayIn,
                      icon: const Icon(Icons.currency_exchange, size: 18),
                      label: Text(
                        displayCurrency == null
                            ? l10n.displayIn
                            : '${l10n.displayIn}: $displayCurrency',
                      ),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('${l10n.perPage}: '),
                        DropdownButton<int>(
                          value: pageSize,
                          underline: const SizedBox.shrink(),
                          items: [
                            for (final n in expensesPageSizeOptions)
                              DropdownMenuItem(value: n, child: Text('$n')),
                          ],
                          onChanged: (v) {
                            if (v != null) onPageSizeChanged(v);
                          },
                        ),
                      ],
                    ),
                    PopupMenuButton<String>(
                      tooltip: l10n.export,
                      onSelected: (key) {
                        switch (key) {
                          case 'csv_save':
                            onExport(ExportFormat.csv, share: false);
                          case 'csv_share':
                            onExport(ExportFormat.csv, share: true);
                          case 'json_save':
                            onExport(ExportFormat.json, share: false);
                          case 'json_share':
                            onExport(ExportFormat.json, share: true);
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
                          value: 'json_save',
                          child: Text(
                            '${l10n.exportJson} · ${l10n.saveFile}',
                          ),
                        ),
                        PopupMenuItem(
                          value: 'json_share',
                          child: Text('${l10n.exportJson} · ${l10n.share}'),
                        ),
                      ],
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 8,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.download_outlined, size: 18),
                            const SizedBox(width: 6),
                            Text(l10n.export),
                            const Icon(Icons.arrow_drop_down, size: 18),
                          ],
                        ),
                      ),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('${l10n.listingView}: '),
                        DropdownButton<ExpenseListViewMode>(
                          value: view,
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
                  ],
                ),
              ],
            ),
          ),
          if (view == ExpenseListViewMode.grouping ||
              view == ExpenseListViewMode.chart ||
              (view == ExpenseListViewMode.list && pageCount > 1))
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
              child: Wrap(
                spacing: 8,
                runSpacing: 4,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  if (view == ExpenseListViewMode.grouping)
                    DropdownButton<ExpenseListGroup>(
                      value: group,
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
                          child: Text('${l10n.groupBy}: ${l10n.groupDate}'),
                        ),
                        DropdownMenuItem(
                          value: ExpenseListGroup.tag,
                          child: Text('${l10n.groupBy}: ${l10n.groupTag}'),
                        ),
                      ],
                      onChanged: (v) {
                        if (v != null) onGroupChanged(v);
                      },
                    ),
                  if (view == ExpenseListViewMode.chart)
                    DropdownButton<ExpenseChartBreakdown>(
                      value: chartBreakdown,
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
                  if (view == ExpenseListViewMode.list && pageCount > 1)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          onPressed: page > 0
                              ? () => onPageChanged(page - 1)
                              : null,
                          icon: const Icon(Icons.chevron_left),
                        ),
                        Text('${page + 1} / $pageCount'),
                        IconButton(
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
          if (exportMessage != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
              child: Text(exportMessage!),
            ),
          const Divider(height: 1),
          child,
        ],
      ),
    );
  }
}
