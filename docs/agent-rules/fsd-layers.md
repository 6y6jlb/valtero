# FSD layer imports

Layers (top → bottom):

`app` → `pages` → `widgets` → `features` → `entities` → `shared`

## Rules

- Import only from the same layer or a lower layer.
- Do not import one feature from another feature — share via `entities/` or `shared/`.
- Feature-only UI stays inside that feature’s `ui/`; put a widget in `lib/widgets/` only when used by multiple features/pages.

## Examples

```dart
// ❌ BAD — feature imports another feature
import 'package:valtero/features/manage_tags/model/tags_provider.dart';
// from features/add_expense/...

// ✅ GOOD — feature uses entity / shared
import 'package:valtero/entities/tag/model/tag.dart';
import 'package:valtero/shared/settings/app_settings_provider.dart';
```

```dart
// ❌ BAD — entity imports a page
import 'package:valtero/pages/dashboard/dashboard_page.dart';

// ✅ GOOD — page composes entities/features
import 'package:valtero/entities/expense/ui/expense_tile.dart';
```
