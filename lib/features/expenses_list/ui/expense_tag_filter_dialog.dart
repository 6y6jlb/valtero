import 'package:flutter/material.dart';
import 'package:valtero/entities/tag/ui/tag_chip.dart';
import 'package:valtero/shared/database/app_database.dart';
import 'package:valtero/shared/l10n/generated/app_localizations.dart';

Future<Set<int>?> showExpenseTagFilterDialog(
  BuildContext context, {
  required List<Tag> tags,
  required Set<int> initialSelection,
}) {
  final l10n = AppLocalizations.of(context)!;
  final selected = {...initialSelection};
  return showDialog<Set<int>>(
    context: context,
    builder: (ctx) {
      return StatefulBuilder(
        builder: (ctx, setLocal) {
          return AlertDialog(
            title: Text(l10n.selectTags),
            content: SizedBox(
              width: 360,
              child: SingleChildScrollView(
                child: Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: [
                    for (final tag in tags)
                      TagChip(
                        tag: tag,
                        selected: selected.contains(tag.id),
                        onTap: () {
                          setLocal(() {
                            if (selected.contains(tag.id)) {
                              selected.remove(tag.id);
                            } else {
                              selected.add(tag.id);
                            }
                          });
                        },
                      ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => setLocal(() => selected.clear()),
                child: Text(l10n.clearFilters),
              ),
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: Text(MaterialLocalizations.of(ctx).cancelButtonLabel),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(ctx, Set<int>.from(selected)),
                child: Text(l10n.applyFilters),
              ),
            ],
          );
        },
      );
    },
  );
}
