# Riverpod conventions

## Placement

- Providers that belong to a feature live in that feature’s `model/`
- Entity-scoped streams/CRUD providers live in the entity’s `model/` (or next to the DAO usage)
- Cross-cutting settings live in `lib/shared/settings/`

## Pattern

- Prefer `AsyncNotifier` / `AsyncNotifierProvider` for Hive- or Drift-backed state
- Dispose IO clients / subscriptions in `ref.onDispose`
- On Riverpod 3+, `StateProvider` / `StateNotifierProvider` / `ChangeNotifierProvider` live in `package:flutter_riverpod/legacy.dart` — prefer Notifier APIs for new code

```dart
// ❌ BAD — global mutable singleton for settings
class SettingsStore {
  static AppSettings? current;
}

// ✅ GOOD
final appSettingsProvider =
    AsyncNotifierProvider<AppSettingsNotifier, AppSettings>(
  AppSettingsNotifier.new,
);
```
