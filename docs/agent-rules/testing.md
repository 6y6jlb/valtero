# Testing

Guidelines for unit and feature tests in Valtero.

## Stack

- **`flutter_test` only** for now — no mockito / mocktail / golden packages unless explicitly approved ([dependencies.md](dependencies.md)).
- Prefer **hand-written fakes** (see `test/rate_resolver_test.dart`) over codegen mocks.
- In-memory Drift (`NativeDatabase.memory()` / `AppDatabase(NativeDatabase.memory())`) is fine for DAO / controller feature tests.

## What to cover

| Layer | Prefer | Examples |
| --- | --- | --- |
| Pure utils / model | Unit tests | `Money`, `formatMoneyDisplay`, `filterExpenses`, chart drill-down, groupers |
| Controllers with DB/rates | Feature-ish unit tests with fakes / memory DB | `AddExpenseController.save` / `update` |
| Widgets / full UI | Skip unless the bug is UI-only; keep thin | — |

## Rules

1. Put tests under `test/`, mirror domain names (`money_display_test.dart`, `expense_list_filtering_test.dart`).
2. One logical behavior per `test(...)`; name with the expected outcome.
3. Do **not** hit the network in unit/feature tests — fake `RateResolver` / Dio.
4. Money stays in **integer minor units** in fixtures.
5. When adding a pure helper or changing filter/money/rate logic in the same PR, add or extend a test.
6. Schema / migration: add fixture upgrade tests for breaking `migrate_to_vN` changes. Never wipe user DB on upgrade.
7. When a Drift / generated model gains a **required** field (e.g. new non-null column), update **all** hand-built `Expense(...)` / table-row fixtures across `test/` — not only the new feature’s tests.

## After finishing a plan / feature

Before declaring the work done (and before asking the user to commit):

1. Run the **full** suite: `flutter test` (not only the new/related files).
2. Fix every failure — including compile errors in unrelated fixtures broken by schema/API changes.
3. Re-run `flutter test` until green.

Targeted runs (`flutter test test/foo_test.dart`) are fine while iterating; the exit gate is the full suite.

## Running

```bash
flutter test
# or a single file while iterating:
flutter test test/money_display_test.dart
```

If `flutter test` / `flutter gen-l10n` cannot run in the agent environment (permissions, read-only SDK cache, root), do **not** copy Flutter into the repo — see [tooling-environment.md](tooling-environment.md). Report the blocker and ask the user to run the suite.
