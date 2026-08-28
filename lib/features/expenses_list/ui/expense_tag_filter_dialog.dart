import 'package:flutter/material.dart';
import 'package:valtero/entities/tag/ui/grouped_tag_picker.dart';
import 'package:valtero/shared/database/app_database.dart';
import 'package:valtero/shared/l10n/generated/app_localizations.dart';
import 'package:valtero/widgets/app_modal_sheet.dart';

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
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      children: [
        Text(
          l10n.selectTags,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 12),
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
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton(
              onPressed: () => setState(() => _selected.clear()),
              child: Text(l10n.clearFilters),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(MaterialLocalizations.of(context).cancelButtonLabel),
            ),
            const SizedBox(width: 8),
            FilledButton(
              onPressed: () => Navigator.pop(context, Set<int>.from(_selected)),
              child: Text(MaterialLocalizations.of(context).okButtonLabel),
            ),
          ],
        ),
      ],
    );
  }
}
