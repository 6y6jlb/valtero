# Localization strings

- Do not hardcode user-facing strings in widgets
- Add keys to `lib/shared/l10n/app_en.arb` and `app_ru.arb`
- Access via `AppLocalizations.of(context)!` (or a thin helper)

```dart
// ❌ BAD
Text('Add expense');

// ✅ GOOD
Text(AppLocalizations.of(context)!.addExpense);
```

Supported locales: `en`, `ru`.
