import 'package:valtero/entities/tag/model/tag_hierarchy.dart';
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
    final matching = resolveCategoryTargets(
      tagIds: ids,
      kind: kind,
      tagById: context.tagById,
      includeSubcategories: context.includeSubcategories,
    );

    if (matching.isEmpty) {
      return [context.unspecifiedLabelFor(kind)];
    }

    matching.sort(
      (a, b) => (context.tagById[a]?.sortOrder ?? 0)
          .compareTo(context.tagById[b]?.sortOrder ?? 0),
    );
    final tagId = matching.first;
    if (context.includeSubcategories &&
        context.tagById[tagId]?.parentTagId != null) {
      return [
        categoryTargetLabel(
          tagId: tagId,
          tagById: context.tagById,
          tagLabels: context.tagLabels,
          fallback: context.unspecifiedLabelFor(kind),
        ),
      ];
    }
    return [context.tagLabels[tagId] ?? '?'];
  }
}
