# Platform guide

When you add or change **user-facing product capabilities**, keep the in-app
platform guide **and** the public marketing/legal pages under `site/` in sync.

## Where the guide lives

| Piece | Path |
| --- | --- |
| Sections UI | `lib/features/platform_guide/ui/platform_guide_body.dart` |
| Collapsible block | `lib/features/platform_guide/ui/platform_guide_section.dart` |
| Full page (Settings) | `lib/pages/platform_guide/platform_guide_page.dart` |
| Empty dashboard | `DashboardPage` shows a **sample chart** + “example” banner with a link to `PlatformGuidePage` when `allExpensesProvider` is empty |
| Public site | `site/index.html`, `site/privacy.html`, `site/terms.html` (GitHub Pages) |
| Copy | `lib/shared/l10n/app_en.arb` / `app_ru.arb` / `app_es.arb` / `app_sr.arb` (`guideTitle`, `guideSection*Title`, `guideSection*Body`, `dashboardSampleChartLabel`, `dashboardOpenGuide`, `dashboardRestoreFromBackup`, …) |

## Public site (`site/`)

Plain static HTML served via GitHub Pages (see `.github/workflows/pages.yml`).

| File | Update when |
| --- | --- |
| `site/index.html` | Feature list / product positioning changes (new domains like income, sync, export) |
| `site/privacy.html` | What data is stored, third-party integrations, or processing changes |
| `site/terms.html` | Product description or user-responsibility wording changes |

## Rules

1. **New capability** → add a new `PlatformGuideSection` (or extend an existing body) **and** matching en/ru/es/sr ARB keys. Do not hardcode guide strings in Dart.
2. Sections stay **collapsed by default** (`ExpansionTile` / `PlatformGuideSection`).
3. **Changed UX** for an existing feature → update the corresponding `guideSection*Body` (and title if the name changed).
4. Prefer short, actionable copy (what it does + where to find it). Avoid dumping implementation details.
5. After ARB edits, regenerate l10n (`flutter gen-l10n`) for **all** locales (en/ru/es/sr).
6. **Same capability also user-visible on the public site** → update `site/index.html` (and privacy/terms if storage or legal wording changes). Keep the site concise; do not mirror every in-app tip.

## Checklist before finishing a feature PR

- [ ] Guide section exists or was updated for the new/changed capability
- [ ] en + ru + es + sr strings added/updated
- [ ] Empty dashboard still links to the guide (sample chart banner); Settings → Platform guide still opens the same body
- [ ] `site/index.html` (and privacy/terms if needed) updated when the public feature story changed
