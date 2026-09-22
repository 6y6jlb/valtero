import 'package:flutter/material.dart';
import 'package:valtero/features/expenses_list/ui/chart_selection_panel.dart';
import 'package:valtero/widgets/app_modal_sheet.dart';
import 'package:valtero/widgets/app_sheet_header.dart';
import 'package:valtero/widgets/app_sheet_scaffold.dart';

/// Bottom sheet with the full chart selection / total block info.
Future<void> showChartSelectionSheet(
  BuildContext context,
  ChartSelectionDetail detail,
) {
  return showAppModalSheet<void>(
    context: context,
    initialChildSize: 0.45,
    minChildSize: 0.3,
    maxChildSize: 0.85,
    child: ChartSelectionSheet(detail: detail),
  );
}

class ChartSelectionSheet extends StatelessWidget {
  final ChartSelectionDetail detail;

  const ChartSelectionSheet({super.key, required this.detail});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AppSheetScaffold(
      header: AppSheetHeader(title: detail.title),
      children: [
        for (final line in detail.lines) ...[
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (line.color != null) ...[
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: line.color,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                ],
                Expanded(
                  child: Text(
                    line.amountText == null || line.amountText!.isEmpty
                        ? line.label
                        : '${line.label}: ${line.amountText}',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: line.color ?? theme.colorScheme.onSurface,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
