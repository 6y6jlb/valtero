# Localization strings

- Do not hardcode user-facing strings in widgets
- Add keys to `lib/shared/l10n/app_en.arb` and `app_ru.arb`
- Access via `AppLocalizations.of(context)!`
- Default/suggested tags and country names use **stable keys** / country codes and are localized at display time (`localizedTagLabel`, `countryDisplayName`)
- App language: Settings → Appearance → Language (`system` | `en` | `ru`). System falls back to **English** if the OS language is unsupported.

```dart
// ❌ BAD
Text('Add expense');
Text(tag.name); // for default/country tags

// ✅ GOOD
Text(AppLocalizations.of(context)!.addExpense);
Text(localizedTagLabel(context, tag));
```

Supported locales: `en`, `ru`.
