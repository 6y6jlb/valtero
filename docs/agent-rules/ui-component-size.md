# UI component size

Keep UI files small enough to scan in one pass. A **component** is a Dart file whose main job is one screen, sheet, or reusable widget (public widget + private helpers in the same file).

## Limit

- **Target: ≤ 500 lines** per component file (excluding generated code: `*.g.dart`, l10n).
- **Hard stop: ~600 lines** — split before adding more UI or logic to that file.
- Count imports, types, and private `_Widget` classes in the same file toward the limit.

## When to split

Split when a file grows or already exceeds the limit:

1. **Private sub-widgets** (`_FilterCard`, `_ExpenseRow`, …) → sibling files in the same feature `ui/` folder (subfolder OK).
2. **Pure logic** (filter/sort/aggregate, no `BuildContext`) → feature `model/` or `shared/utils/`.
3. **Orchestrator** (state + composition) stays thin: wire providers, callbacks, and child widgets — ideally ≤ 300 lines.

Do **not** move feature-only widgets to `lib/widgets/` unless another feature or page also uses them.

## Naming & layout

Prefer flat or shallow folders under `lib/features/<feature>/ui/`:

```
ui/
  expenses_sheet.dart          # public entry / barrel if needed
  expenses_sheet_body.dart     # orchestrator
  expenses_filter_card.dart
  expenses_listing_card.dart
  expense_table.dart
  grouped_expense_table.dart
  expense_chart.dart
```

- One primary public widget per file; name the file after that widget (`snake_case.dart`).
- Shared private helpers used by one widget only can stay in the same file if the total stays under the limit.
- Extract shared constants (`pageSizeOptions`, column flex values) next to the widget that uses them, or to `model/` if used across files.

## Examples

```dart
// ❌ BAD — 1700+ lines: sheet + filters + tables + chart + row in one file
// lib/features/expenses_list/ui/expenses_sheet.dart

// ✅ GOOD — orchestrator composes extracted widgets
class ExpensesSheetBody extends ConsumerStatefulWidget { ... }
// build() delegates to ExpensesFilterCard, ExpensesListingCard, ExpenseTable, ...
```

```dart
// ❌ BAD — filter/sort functions inside a 800-line State class
List<Expense> _applyFilter(...) { ... }

// ✅ GOOD — pure helpers in model/
// lib/features/expenses_list/model/expense_list_filtering.dart
List<Expense> filterExpenses({ required List<Expense> all, ... }) { ... }
```

## Agent checklist

Before finishing a UI change:

1. Run `wc -l` on touched component files.
2. If over 500 lines, split in the same PR or explicitly note follow-up decomposition in the PR description.
3. After split, the public import path for pages should stay stable (re-export from the original entry file if the page imported it).
