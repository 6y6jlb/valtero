import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:valtero/entities/tag/model/tag_kind.dart';
import 'package:valtero/entities/tag/model/tags_provider.dart';
import 'package:valtero/entities/tag/ui/grouped_tag_picker.dart';
import 'package:valtero/features/add_expense/ui/country_picker_dialog.dart';
import 'package:valtero/features/expenses_list/model/bulk_expense_controller.dart';
import 'package:valtero/features/expenses_list/model/expense_bulk_list_description.dart';
import 'package:valtero/shared/database/app_database.dart';
import 'package:valtero/shared/l10n/generated/app_localizations.dart';
import 'package:valtero/widgets/app_toast.dart';
import 'package:valtero/widgets/confirm_action_sheet.dart';
import 'package:valtero/widgets/currency_picker.dart';

List<Expense> _selectedExpenses(
  List<Expense> all,
  Set<int> selectedIds,
) {
  return all.where((e) => selectedIds.contains(e.id)).toList();
}

Future<bool> runBulkDeleteExpenses(
  BuildContext context,
  WidgetRef ref, {
  required List<Expense> allExpenses,
  required Set<int> selectedIds,
}) async {
  final l10n = AppLocalizations.of(context)!;
  final selected = _selectedExpenses(allExpenses, selectedIds);
  if (selected.isEmpty) return false;

  final list = buildExpenseBulkListDescription(
    context,
    ref,
    expenses: selected,
  );
  final confirmed = await showConfirmActionSheet<bool>(
    context: context,
    initialChildSize: selected.length > 4 ? 0.55 : 0.4,
    child: Builder(
      builder: (sheetContext) => ConfirmActionLayout(
        title: l10n.bulkDeleteTitle,
        description: l10n.bulkDeleteDescription(list),
        actions: confirmActionButtons(
          context: sheetContext,
          confirmLabel: l10n.delete,
          destructive: true,
          onConfirm: () => Navigator.pop(sheetContext, true),
        ),
      ),
    ),
  );
  if (confirmed != true || !context.mounted) return false;

  await ref.read(bulkExpenseControllerProvider).deleteMany(
        selected.map((e) => e.id).toList(),
      );
  if (!context.mounted) return true;
  showAppToast(context, l10n.bulkExpensesDeleted(selected.length));
  return true;
}

Future<bool> runBulkChangeTags(
  BuildContext context,
  WidgetRef ref, {
  required List<Expense> allExpenses,
  required Set<int> selectedIds,
}) async {
  final l10n = AppLocalizations.of(context)!;
  final selected = _selectedExpenses(allExpenses, selectedIds);
  if (selected.isEmpty) return false;

  final tags = ref.read(tagsStreamProvider).value ?? const <Tag>[];
  final tagById = {for (final t in tags) t.id: t};
  final list = buildExpenseBulkListDescription(
    context,
    ref,
    expenses: selected,
  );

  final result = await showConfirmActionSheet<Set<int>>(
    context: context,
    initialChildSize: 0.75,
    minChildSize: 0.45,
    child: _BulkTagsSheet(
      description: l10n.bulkChangeTagsDescription(list),
      tags: tags,
      tagById: tagById,
    ),
  );
  if (result == null || !context.mounted) return false;

  await ref.read(bulkExpenseControllerProvider).setTags(
        selected.map((e) => e.id).toList(),
        result.toList(),
      );
  if (!context.mounted) return true;
  showAppToast(context, l10n.bulkExpensesUpdated(selected.length));
  return true;
}

Future<bool> runBulkChangeCountry(
  BuildContext context,
  WidgetRef ref, {
  required List<Expense> allExpenses,
  required Set<int> selectedIds,
}) async {
  final l10n = AppLocalizations.of(context)!;
  final selected = _selectedExpenses(allExpenses, selectedIds);
  if (selected.isEmpty) return false;

  final country = await showCountryPicker(context);
  if (country == null || !context.mounted) return false;

  final list = buildExpenseBulkListDescription(
    context,
    ref,
    expenses: selected,
  );
  final confirmed = await showConfirmActionSheet<bool>(
    context: context,
    initialChildSize: selected.length > 4 ? 0.55 : 0.4,
    child: Builder(
      builder: (sheetContext) => ConfirmActionLayout(
        title: l10n.bulkChangeCountryTitle,
        description: l10n.bulkChangeCountryDescription(list),
        actions: confirmActionButtons(
          context: sheetContext,
          confirmLabel: l10n.bulkChangeCountry,
          onConfirm: () => Navigator.pop(sheetContext, true),
        ),
      ),
    ),
  );
  if (confirmed != true || !context.mounted) return false;

  await ref.read(bulkExpenseControllerProvider).setCountry(
        selected.map((e) => e.id).toList(),
        country,
      );
  if (!context.mounted) return true;
  showAppToast(context, l10n.bulkExpensesUpdated(selected.length));
  return true;
}

Future<bool> runBulkChangeCurrency(
  BuildContext context,
  WidgetRef ref, {
  required List<Expense> allExpenses,
  required Set<int> selectedIds,
}) async {
  final l10n = AppLocalizations.of(context)!;
  final selected = _selectedExpenses(allExpenses, selectedIds);
  if (selected.isEmpty) return false;

  final currency = await showCurrencyPicker(context);
  if (currency == null || !context.mounted) return false;

  final list = buildExpenseBulkListDescription(
    context,
    ref,
    expenses: selected,
  );
  final confirmed = await showConfirmActionSheet<bool>(
    context: context,
    initialChildSize: selected.length > 4 ? 0.55 : 0.4,
    child: Builder(
      builder: (sheetContext) => ConfirmActionLayout(
        title: l10n.bulkChangeCurrencyTitle,
        description: l10n.bulkChangeCurrencyDescription(currency, list),
        actions: confirmActionButtons(
          context: sheetContext,
          confirmLabel: l10n.bulkChangeCurrency,
          onConfirm: () => Navigator.pop(sheetContext, true),
        ),
      ),
    ),
  );
  if (confirmed != true || !context.mounted) return false;

  try {
    await ref.read(bulkExpenseControllerProvider).convertToCurrency(
          selected.map((e) => e.id).toList(),
          currency,
        );
  } on StateError catch (e) {
    if (!context.mounted) return false;
    if (e.message == 'rate_unavailable') {
      showAppToast(context, l10n.bulkCurrencyRateUnavailable);
      return false;
    }
    rethrow;
  }
  if (!context.mounted) return true;
  showAppToast(context, l10n.bulkExpensesUpdated(selected.length));
  return true;
}

class _BulkTagsSheet extends StatefulWidget {
  final String description;
  final List<Tag> tags;
  final Map<int, Tag> tagById;

  const _BulkTagsSheet({
    required this.description,
    required this.tags,
    required this.tagById,
  });

  @override
  State<_BulkTagsSheet> createState() => _BulkTagsSheetState();
}

class _BulkTagsSheetState extends State<_BulkTagsSheet> {
  final Set<int> _selected = {};

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return ConfirmActionLayout(
      title: l10n.bulkChangeTagsTitle,
      description: widget.description,
      body: GroupedTagPicker(
        tags: widget.tags,
        selectedIds: _selected,
        singleSelectPerKind: true,
        onTagTap: (tag) {
          setState(() {
            toggleTagSelection(
              selected: _selected,
              tag: tag,
              tagById: widget.tagById,
              singleSelectPerKind: true,
            );
          });
        },
      ),
      actions: confirmActionButtons(
        context: context,
        confirmLabel: l10n.bulkChangeTags,
        onConfirm: () => Navigator.pop(context, Set<int>.from(_selected)),
      ),
    );
  }
}
