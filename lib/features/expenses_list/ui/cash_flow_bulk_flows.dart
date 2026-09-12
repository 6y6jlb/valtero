import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:valtero/entities/tag/model/tag_kind.dart';
import 'package:valtero/entities/tag/model/tags_provider.dart';
import 'package:valtero/entities/tag/ui/grouped_tag_picker.dart';
import 'package:valtero/features/add_expense/ui/country_picker_dialog.dart';
import 'package:valtero/features/expenses_list/model/bulk_cash_flow_controller.dart';
import 'package:valtero/features/expenses_list/model/cash_flow_bulk_list_description.dart';
import 'package:valtero/features/expenses_list/model/cash_flow_selection_key.dart';
import 'package:valtero/features/expenses_list/model/recent_operation.dart';
import 'package:valtero/shared/database/app_database.dart';
import 'package:valtero/shared/l10n/generated/app_localizations.dart';
import 'package:valtero/widgets/app_toast.dart';
import 'package:valtero/widgets/confirm_action_sheet.dart';
import 'package:valtero/widgets/currency_picker.dart';

List<RecentOperation> _selectedOperations(
  List<RecentOperation> all,
  Set<CashFlowSelectionKey> selectedKeys,
) {
  return all
      .where(
        (op) => selectedKeys.contains(CashFlowSelectionKey.fromOperation(op)),
      )
      .toList();
}

Future<bool> runBulkDeleteCashFlow(
  BuildContext context,
  WidgetRef ref, {
  required List<RecentOperation> allOperations,
  required Set<CashFlowSelectionKey> selectedKeys,
}) async {
  final l10n = AppLocalizations.of(context)!;
  final selected = _selectedOperations(allOperations, selectedKeys);
  if (selected.isEmpty) return false;

  final list = buildCashFlowBulkListDescription(
    context,
    ref,
    operations: selected,
  );
  final confirmed = await showConfirmActionSheet<bool>(
    context: context,
    initialChildSize: selected.length > 4 ? 0.55 : 0.4,
    child: Builder(
      builder: (sheetContext) => ConfirmActionLayout(
        title: l10n.bulkDeleteTitleCashFlow,
        description: l10n.bulkDeleteDescriptionCashFlow(list),
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

  await ref.read(bulkCashFlowControllerProvider).deleteMany(selectedKeys);
  if (!context.mounted) return true;
  showAppToast(context, l10n.bulkCashFlowDeleted(selected.length));
  return true;
}

Future<bool> runBulkChangeCashFlowTags(
  BuildContext context,
  WidgetRef ref, {
  required List<RecentOperation> allOperations,
  required Set<CashFlowSelectionKey> selectedKeys,
}) async {
  final l10n = AppLocalizations.of(context)!;
  final kind = homogeneousCashFlowKind(selectedKeys);
  if (kind == null) {
    showAppToast(context, l10n.bulkChangeTagsMixedKinds);
    return false;
  }

  final selected = _selectedOperations(allOperations, selectedKeys);
  if (selected.isEmpty) return false;

  final tagKind = kind == OperationKind.income ? TagKind.income : TagKind.custom;
  final allTags = ref.read(tagsStreamProvider).value ?? const <Tag>[];
  final tags = [for (final t in allTags) if (tagKindOf(t) == tagKind) t];
  final tagById = {for (final t in tags) t.id: t};
  final list = buildCashFlowBulkListDescription(
    context,
    ref,
    operations: selected,
  );

  final result = await showConfirmActionSheet<Set<int>>(
    context: context,
    initialChildSize: 0.75,
    minChildSize: 0.45,
    child: _BulkCashFlowTagsSheet(
      description: l10n.bulkChangeTagsDescription(list),
      tags: tags,
      tagById: tagById,
      tagKind: tagKind,
    ),
  );
  if (result == null || !context.mounted) return false;

  final controller = ref.read(bulkCashFlowControllerProvider);
  if (kind == OperationKind.income) {
    await controller.setIncomeTags(selectedKeys, result.toList());
  } else {
    await controller.setExpenseTags(selectedKeys, result.toList());
  }
  if (!context.mounted) return true;
  showAppToast(context, l10n.bulkCashFlowUpdated(selected.length));
  return true;
}

Future<bool> runBulkChangeCashFlowCountry(
  BuildContext context,
  WidgetRef ref, {
  required List<RecentOperation> allOperations,
  required Set<CashFlowSelectionKey> selectedKeys,
}) async {
  final l10n = AppLocalizations.of(context)!;
  final selected = _selectedOperations(allOperations, selectedKeys);
  if (selected.isEmpty) return false;

  final country = await showCountryPicker(context);
  if (country == null || !context.mounted) return false;

  final list = buildCashFlowBulkListDescription(
    context,
    ref,
    operations: selected,
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

  await ref
      .read(bulkCashFlowControllerProvider)
      .setCountry(selectedKeys, country);
  if (!context.mounted) return true;
  showAppToast(context, l10n.bulkCashFlowUpdated(selected.length));
  return true;
}

Future<bool> runBulkChangeCashFlowCurrency(
  BuildContext context,
  WidgetRef ref, {
  required List<RecentOperation> allOperations,
  required Set<CashFlowSelectionKey> selectedKeys,
}) async {
  final l10n = AppLocalizations.of(context)!;
  final selected = _selectedOperations(allOperations, selectedKeys);
  if (selected.isEmpty) return false;

  final currency = await showCurrencyPicker(context);
  if (currency == null || !context.mounted) return false;

  final list = buildCashFlowBulkListDescription(
    context,
    ref,
    operations: selected,
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
    await ref.read(bulkCashFlowControllerProvider).convertToCurrency(
          selectedKeys,
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
  showAppToast(context, l10n.bulkCashFlowUpdated(selected.length));
  return true;
}

class _BulkCashFlowTagsSheet extends StatefulWidget {
  final String description;
  final List<Tag> tags;
  final Map<int, Tag> tagById;
  final TagKind tagKind;

  const _BulkCashFlowTagsSheet({
    required this.description,
    required this.tags,
    required this.tagById,
    required this.tagKind,
  });

  @override
  State<_BulkCashFlowTagsSheet> createState() => _BulkCashFlowTagsSheetState();
}

class _BulkCashFlowTagsSheetState extends State<_BulkCashFlowTagsSheet> {
  final Set<int> _selected = {};

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return ConfirmActionLayout(
      title: l10n.bulkChangeTagsTitle,
      description: widget.description,
      body: GroupedTagPicker(
        tags: widget.tags,
        kinds: [widget.tagKind],
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
