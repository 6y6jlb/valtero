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
6. Schema / migration: until production data, MVP may use a destructive baseline — no stepwise migration tests required. When `migrate_to_vN` returns, add fixture upgrade tests for breaking changes.

## Running

```bash
flutter test
# or a single file:
flutter test test/money_display_test.dart
```
