# Platform guide

When you add or change **user-facing product capabilities**, keep the in-app platform guide in sync.

## Where the guide lives

| Piece | Path |
| --- | --- |
| Sections UI | `lib/features/platform_guide/ui/platform_guide_body.dart` |
| Collapsible block | `lib/features/platform_guide/ui/platform_guide_section.dart` |
| Full page (Settings) | `lib/pages/platform_guide/platform_guide_page.dart` |
| Empty dashboard | `DashboardPage` shows a **sample chart** + “example” banner with a link to `PlatformGuidePage` when `allExpensesProvider` is empty |
| Copy | `lib/shared/l10n/app_en.arb` / `app_ru.arb` (`guideTitle`, `guideSection*Title`, `guideSection*Body`, `dashboardSampleChartLabel`, `dashboardOpenGuide`, …) |

## Rules

1. **New capability** → add a new `PlatformGuideSection` (or extend an existing body) **and** matching en/ru ARB keys. Do not hardcode guide strings in Dart.
2. Sections stay **collapsed by default** (`ExpansionTile` / `PlatformGuideSection`).
3. **Changed UX** for an existing feature → update the corresponding `guideSection*Body` (and title if the name changed).
4. Prefer short, actionable copy (what it does + where to find it). Avoid dumping implementation details.
5. After ARB edits, regenerate l10n (`flutter gen-l10n`) for **all** locales (en/ru/es/sr).

## Checklist before finishing a feature PR

- [ ] Guide section exists or was updated for the new/changed capability
- [ ] en + ru + es + sr strings added/updated
- [ ] Empty dashboard still links to the guide (sample chart banner); Settings → Platform guide still opens the same body
