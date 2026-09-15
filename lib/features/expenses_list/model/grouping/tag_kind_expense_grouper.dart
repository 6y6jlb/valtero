import 'package:valtero/entities/tag/model/tag_kind.dart';
import 'package:valtero/features/expenses_list/model/grouping/expense_grouper.dart';
import 'package:valtero/features/expenses_list/model/grouping/expense_grouping_context.dart';
import 'package:valtero/shared/database/app_database.dart';

final class TagKindExpenseGrouper extends ExpenseGrouperBase {
  final TagKind kind;

  const TagKindExpenseGrouper(this.kind);

  @override
  Iterable<String> labelsFor(
    Expense expense,
    ExpenseGroupingContext context,
  ) {
    final ids = context.expenseTags[expense.id] ?? const <int>[];
    final matching = <int>[
      for (final id in ids)
        if (context.tagById[id] != null &&
            tagKindOf(context.tagById[id]!) == kind &&
            context.tagById[id]!.parentTagId == null)
          id,
    ];

    if (matching.isEmpty) {
      // Roll up subtag-only attachments to their parent label.
      for (final id in ids) {
        final tag = context.tagById[id];
        if (tag == null || tag.parentTagId == null) continue;
        if (tagKindOf(tag) != kind) continue;
        final parent = context.tagById[tag.parentTagId!];
        if (parent != null &&
            parent.parentTagId == null &&
            tagKindOf(parent) == kind) {
          matching.add(parent.id);
        }
      }
    }

    if (matching.isEmpty) {
      return [context.unspecifiedLabelFor(kind)];
    }

    matching.sort(
      (a, b) => (context.tagById[a]?.sortOrder ?? 0)
          .compareTo(context.tagById[b]?.sortOrder ?? 0),
    );
    return [context.tagLabels[matching.first] ?? '?'];
  }
}
