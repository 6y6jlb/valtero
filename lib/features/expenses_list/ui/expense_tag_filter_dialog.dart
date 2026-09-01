import 'package:flutter/material.dart';
import 'package:valtero/entities/tag/ui/grouped_tag_picker.dart';
import 'package:valtero/shared/database/app_database.dart';
import 'package:valtero/shared/l10n/generated/app_localizations.dart';
import 'package:valtero/widgets/app_button.dart';
import 'package:valtero/widgets/app_close_icon_button.dart';
import 'package:valtero/widgets/app_modal_sheet.dart';
import 'package:valtero/widgets/app_sheet_actions_bar.dart';
import 'package:valtero/widgets/app_sheet_header.dart';
import 'package:valtero/widgets/app_sheet_scaffold.dart';

Future<Set<int>?> showExpenseTagFilterDialog(
  BuildContext context, {
  required List<Tag> tags,
  required Set<int> initialSelection,
}) {
  return showAppModalSheet<Set<int>>(
    context: context,
    initialChildSize: 0.7,
    minChildSize: 0.4,
    maxChildSize: 0.95,
    child: _ExpenseTagFilterSheet(
      tags: tags,
      initialSelection: initialSelection,
    ),
  );
}

class _ExpenseTagFilterSheet extends StatefulWidget {
  final List<Tag> tags;
  final Set<int> initialSelection;

  const _ExpenseTagFilterSheet({
    required this.tags,
    required this.initialSelection,
  });

  @override
  State<_ExpenseTagFilterSheet> createState() => _ExpenseTagFilterSheetState();
}

class _ExpenseTagFilterSheetState extends State<_ExpenseTagFilterSheet> {
  late Set<int> _selected;

  @override
  void initState() {
    super.initState();
    _selected = {...widget.initialSelection};
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return AppSheetScaffold(
      header: AppSheetHeader(title: l10n.selectTags),
      contentPadding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      actions: AppSheetActionsBar(
        children: [
          AppTextButton(
            onPressed: () => setState(() => _selected.clear()),
            label: l10n.clearFilters,
          ),
          AppCloseIconButton(onPressed: () => Navigator.pop(context)),
          AppFilledButton(
            onPressed: () => Navigator.pop(context, Set<int>.from(_selected)),
            icon: Icons.check,
            label: l10n.ok,
          ),
        ],
      ),
      children: [
        GroupedTagPicker(
          tags: widget.tags,
          selectedIds: _selected,
          onTagTap: (tag) {
            setState(() {
              if (_selected.contains(tag.id)) {
                _selected.remove(tag.id);
              } else {
                _selected.add(tag.id);
              }
            });
          },
        ),
      ],
    );
  }
}
