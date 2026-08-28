# Naming

## Do not use the product / project name in identifiers

Avoid **Valtero** (and other product branding) in **file names**, **class names**, **typedefs**, **constants**, and similar code identifiers.

Prefer role-based names that describe what the thing does:

```dart
// ❌ BAD
class ValteroPageScaffold { … }
const kValteroFabBottomPadding = 96;
// file: valtero_page_scaffold.dart

// ✅ GOOD
class AppPageScaffold { … }
const kFabBottomPadding = 96;
// file: app_page_scaffold.dart
```

Same for features: `platform_guide`, `AppModalSheet`, `addExpenseFab` — not `valteroGuide`, `ValteroSheet`, etc.

**OK to use the product name in:**

- User-facing copy (l10n / ARB), e.g. app title, guide headlines
- Package / import path `package:valtero/…` (pub package name)
- Docs that refer to the product itself (`AGENTS.md`, README)

## Other naming (reminder)

- Names explain intent: `getRateForPair()` not `get()`, `changeStoredCurrency()` not `set()`
- PascalCase classes, camelCase members, `_` prefix for private
- UI files: `snake_case.dart` named after the primary public widget
