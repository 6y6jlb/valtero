# AGENTS.md — Valtero

Guidelines for humans and coding agents working on this multi-currency expense tracker.

## Platform priorities

- **Primary**: Linux Ubuntu (test changes here first)
- **Supported**: Android, Windows desktop
- No tray / window_manager / foreground-service packages — this is not a continuously running timer app

## Architecture (light FSD)

Layers form a one-way dependency chain (top → bottom only; no sideways imports between slices of the same layer):

```
app → pages → widgets → features → entities → shared
```

| Layer | Role |
| --- | --- |
| `lib/app/` | Bootstrap, `MaterialApp`, routes, theme, `AppInitializer` |
| `lib/pages/` | One folder per screen; thin composition only |
| `lib/widgets/` | Cross-feature UI only (keep small) |
| `lib/features/` | User-facing use cases (`model/` + `ui/`, optional `data/`) |
| `lib/entities/` | Domain model + Drift tables/DAOs / rate providers / optional integrations registry |
| `lib/shared/` | DB core, Hive settings, Dio, consts, l10n, utils, file logging |

**Import rule**: a file may only import from its own layer (siblings) or from a layer further down. Never import upward or sideways across features.

Details: [docs/agent-rules/fsd-layers.md](docs/agent-rules/fsd-layers.md)

## State & storage

- **Riverpod** for state (`AsyncNotifier` for Hive/Drift-backed state)
- **Drift (SQLite)** for expenses, income, tags, exchange-rate cache/overrides (`sqlite3` ≥3.x bundles native SQLite via build hooks on Linux/Android/Windows)
- **Schema version** SSOT: `kAppSchemaVersion`. Production baseline **v8** (`Operations` + `OperationTags` with `kind` expense|income); fresh installs use `onCreate`. Bumps above baseline: stepwise `migrate_to_vN` only; DBs older than baseline are refused — **never wipe** user DB on upgrade — see [drift-conventions.md](docs/agent-rules/drift-conventions.md). Same int goes into strict exchange envelopes as `schemaVersion`.
- **Hive CE** for `AppSettings` only (reporting currencies, API key, detection cache, theme/locale/timezone, integration credentials, debug logging flag)

Details: [docs/agent-rules/riverpod-conventions.md](docs/agent-rules/riverpod-conventions.md), [docs/agent-rules/drift-conventions.md](docs/agent-rules/drift-conventions.md)

## Money & currency

- Amounts are always **integer minor units** (never `double` for money)
- UI amounts via `MoneyText` / `formatMoneyDisplay` (`intl` + Settings → Appearance → money display: `localeSymbol` | `localeCode` | `isoBefore` | `plain` | `compactSymbol`); export keeps `Money.formatMinor`
- Rate resolution order: keyed ExchangeRate-API → Frankfurter → manual override → `null`
- On expense **or income** entry: save as-is **or** convert into a reporting currency; always keep original amount/currency

Details: [docs/agent-rules/money-and-currency.md](docs/agent-rules/money-and-currency.md)

## Localization

- No hardcoded user-facing strings; use `AppLocalizations` (en / ru / es / sr)
- ARB files live in `lib/shared/l10n/`

Details: [docs/agent-rules/l10n-strings.md](docs/agent-rules/l10n-strings.md)

## Key domain flows

1. **Add / edit expense** (same bottom sheet) → amount + currency → as-is or convert-to reporting currency (show live rate) → **payment method** → **country** (ISO on the expense, not a tag) → **category tags** (`Tags.kind = normal`, optional one-level **subcategory** via `parentTagId`) → note/date → before persist, soft-check for **possible duplicates** (same calendar day + original amount + currency); conflict dialog offers save-as-unique / delete-match-and-save / cancel. Editing resets `duplicateDismissed` when the fingerprint changes. When editing, the amount field has a **calculator** icon (add / subtract / multiply / divide / percent of) that writes the result back into the field before Save. Tap a row in lists/dashboard recent to edit.
2. **Add / edit income** → same money/payment/country/note/date fields as expenses; category tags use `Tags.kind = income` (salary, sale, gift, … — separate from expense categories) with optional subcategory; soft-duplicate check mirrors expenses. Tags may show curated **icons** via `Tags.iconKey` (shared catalog with payment methods). Edit mode also has the amount **calculator** icon.
3. **Dashboard** → 3-way direction tab above filters (**Expenses** / **Income** / **Cash flow**) → donut / column / **columns-by-date** / **line** chart (expenses or income; category charts can show parent categories or subcategories) or cash-flow **donut** (income vs expense totals, default) / **grouped bars** / **line** by period → recent operations + link to full list; AppBar: Google Drive sync / rates / settings (tags & export live under Settings); convert stored amounts to display currency via `RateResolver` in Dart. Possible-duplicate alert badges on recent rows when soft matches exist. Cash flow chart buckets income vs expenses by day/week/month/year only (bars/line); donut aggregates those totals.
4. **Rates** → on launch if last refresh >24h, refresh in background; Settings → Currency sheet can force refresh / set manual rates / view all rates; **Frankfurter** (free ECB, no key) is always available under Settings → Integrations and is the default source; ExchangeRate-API key (optional override) is also under Integrations. Explicit network fetches share a **1h cooldown** (`lastRateRefreshAt`); cached rates + that timestamp travel in encrypted backup / Google Drive sync (newer `fetchedAt` wins per pair/source; cooldown uses the later timestamp).
5. **Tag suggestions** → detect country/currency (ip-api.com, locale fallback) → suggest **category** tags (Tags sheet, filtered by kind). Detected country primes the expense/income country field on create.
6. **Export** → CSV/JSON for expenses and for income (includes `countryCode` + payment) → save / share / copy; **Telegram** destination appears only when the Telegram integration is connected; **encrypted backup/sync** (Settings → Backup & sync, `.valterobackup`) embeds `formatVersion` + `schemaVersion` (`kAppSchemaVersion`) for merge import across devices; includes expenses/**income** (with `syncId` / `updatedAt` / soft-delete tombstones) /tags/payments/**all exchange rates** + non-secret settings (incl. `lastRateRefreshAt`); API keys / Telegram / Google Drive credentials are excluded. On import, operations merge by **last-write-wins** on `updatedAt` (match `syncId`, else unique day+amount+currency fingerprint); ambiguous soft-duplicates (2+ local matches) still open a resolution sheet (skip / import as unique).
7. **Integrations** → Settings → Integrations lists optional/built-in services (`entities/integrations/`: Telegram, **Frankfurter**, ExchangeRate-API, **Google Drive Sync**). Each opens a config modal (Test connection; credential forms save on success / Disconnect where applicable). Frankfurter needs no credentials and stays “connected”. Capability-gated UI (export menu Telegram items, rate source label) reads `isIntegrationConfiguredProvider` / `configuredExportIntegrationsProvider`
8. **Google Drive Sync** → optional E2EE sync: OAuth (`flutter_web_auth_2` + PKCE) → encrypted snapshot (same `BackupCrypto` / `.valterobackup` envelope) in Drive `appDataFolder`; lazy pull on launch + debounced push after local expense, **income**, **or exchange-rate** changes; operations merge **last-write-wins** by `updatedAt` (`syncId` + soft-delete tombstones so deletes propagate); **pull-to-refresh (swipe down)** on Dashboard / Expenses also triggers sync when no modal is open. Sync passphrase stored only on-device (never sent to Google). Cross-account share creates a regular Drive file + `permissions.create` (needs `drive.file` scope; Google OAuth verification for >100 users); owner can share with **multiple** collaborator emails and revoke via chip delete (`permissions.delete`). Personal vs shared file keep **separate** last-synced timestamps so an owner sync does not skip pulling the shared file. **Join shared sync** on a second Google account uses restricted `drive` scope so the app can discover `sharedWithMe` files (Picker-less). With Settings → Debug & logs enabled, sync logs fetch/decrypt/pull-decision/import/push summaries to the file log. Client ids live in gitignored `local.oauth.env` (`GOOGLE_OAUTH_CLIENT_ID_DESKTOP` + **`GOOGLE_OAUTH_CLIENT_SECRET_DESKTOP`** / `_ANDROID`); Make/release inject `--dart-define`. Desktop loopback redirect: `http://127.0.0.1:43823/oauth2redirect` — Google’s token endpoint typically still requires the Desktop **client secret** even with PKCE. Android uses reverse-client-id redirect — the Android OAuth client must have **Custom URI scheme** enabled (Advanced settings), or Google returns `invalid_request`. Version gate: remote `schemaVersion` **older or equal** merges forward; **newer** remote schema blocks pull+push and shows an update-required alert.
9. **Debug & logs** → Settings → Debug & logs: toggle verbose debug breadcrumbs; **errors/warnings always written** to a redacted file log (`shared/logging/`); sticky sheet actions: copy email / copy logs / clear / **Share** (system share sheet with `.log`) / **Send to developer** (email to the developer with attachment: Android Intent, Linux `xdg-email --attach`, macOS Mail when possible; mailto+path fallback otherwise); refresh icon overlays the log viewer (top-right). Secrets never logged (`LogRedactor`). Settings also has **Thanks** (optional ETH / Bitcoin tip addresses) and **Contact developer** (same email, copyable + mailto Send)
10. **Possible duplicates** → Expenses/income lists show an alert banner + per-row badges when 2+ non-dismissed rows share day/amount/currency; review sheet lets the user delete a row or mark “not a duplicate” (`duplicateDismissed`)
11. **Voice expense input (Android only)** → mic on the add-expense sheet opens a capture sheet (`speech_to_text`); transcript is heuristically parsed into amount / optional currency / tag / payment, shown for review, then **Create** prefills those form fields or **Cancel** leaves the form empty. Recognition language follows the device speech locales (not limited to app UI locales). **No audio file and no transcript are persisted** (in-memory for the capture session only; the expense **note** is not auto-filled from speech). Recognition **errors** may be written to the app file log without the spoken text. Hidden on Linux/Windows.

## Navigation

- Home: **Dashboard** (AppBar title `navDashboard` — Home / Главная; no bottom nav). Direction tab above filters: **Cash flow** (default on first launch) / Expenses / Income — last selected tab is persisted in Hive (`dashboardDirection`) and restored on next launch. If there are **no expenses and no income yet** (and direction is cash flow), Dashboard shows a **sample cash-flow chart** (donut income vs expense by default, or bars) labeled as an example, with a link to the **platform guide**; expenses-only sample still appears on the Expenses tab when there are no expenses. After the first operation, real chart data appears. The guide is also opened from Settings → Platform guide.
- **Expenses / Income list**: full page via Show FAB / list link (back arrow); same direction tab + filters (Cash flow first); alert banner for possible duplicates when present; per-currency summary card with convert/info icons; empty placeholder; add/edit stays a sheet (theme-colored `+` expands to text actions **Add expense** / **Add income**; Dashboard **Show** expands to **Show cash flow** / **Show expenses** / **Show income** — sticky bottom on Dashboard, list page, and Platform guide — **not** on Settings)
- Settings via gear in the AppBar on Dashboard, list, and Platform guide (not on Settings itself) → full page with back arrow
- Sheets (full window width; **default** for modals — see [modal-sheets.md](docs/agent-rules/modal-sheets.md)): add/edit expense, **add/edit income**, **create/edit tag**, tags list, export, currency, appearance, rates list, filters, **integrations**, **debug logs**, **duplicate review**, **voice expense capture** (Android)
- Dashboard: direction tab → filter summary bar above the chart → full-screen sheet; one donut / column / **columns-by-date** / **line** chart (type icons overlay top-right; choice persisted) for expenses/income, or cash-flow **donut** (income vs expense, default) / **grouped bars** / **line** (persisted as `cashFlowChartType`); shared [BreakdownChartView](lib/features/expenses_list/ui/breakdown_chart_view.dart) / [DonutBreakdownChart](lib/features/expenses_list/ui/donut_breakdown_chart.dart) / [CashFlowChartView](lib/features/expenses_list/ui/cash_flow_chart_view.dart) with [ChartOverlayControls](lib/features/expenses_list/ui/chart_overlay_controls.dart): amounts on segments, legend chips (tag/payment icons or flags when available) toggle visibility; for expenses/income, tap segment → list with filter; cash-flow donut has no segment drill-down); breakdown/period icons sit **under** the type toggle in the same overlay via [ChartBreakdownIcons](lib/features/expenses_list/ui/chart_breakdown_icons.dart) (cash flow: temporal only; period persisted as `cashFlowChartDatePeriod`); when breakdown is category, a compact Subcategories switch leads the legend (off by default = parent categories only); recent operations (leading icon: **subcategory tag → tag → currency flag → payment**; country stays in the subtitle) + “Show expenses”; FABs
- Expenses/income list columns: date, amount (optional possible-duplicate badge), payment, country, tags; chart view uses the same donut; tap a segment applies that filter and switches to list
- AppBar titles are section names (`navDashboard` = Home / Главная on Dashboard, `navExpenses` on Expenses, `settings` on Settings); timezone still applies to expense/income dates/filters (Settings → Appearance). Dashboard and Expenses AppBars include a Google Drive sync icon (primary when connected, muted when not) that opens the sync quick sheet; Dashboard / Expenses list / Platform guide also show the settings gear ([SettingsAppBarButton](lib/pages/settings/settings_app_bar_button.dart))
- Desktop default window size: **853×720** (≈⅔ of the previous 1280 width)
- Public marketing/legal pages under [`site/`](site/) — keep in sync with user-facing capabilities per [platform-guide.md](docs/agent-rules/platform-guide.md)

## App version

- **SSOT**: repo-root `VERSION` (`semver+build`, e.g. `1.0.0+1`)
- **Changelog + bump**: every commit bumps **patch** and updates [`CHANGELOG.md`](CHANGELOG.md), unless the user explicitly asks for **minor** or **major** — see [docs/agent-rules/changelog.md](docs/agent-rules/changelog.md). Build-only (`+n`) bumps are optional and do not replace patch-on-commit.
- **Tooling**: `scripts/app_version.sh` / `.ps1` — `sync` writes `pubspec.yaml`; `flutter-args` emits `--build-name` / `--build-number` / `--dart-define=APP_VERSION=…`; `bump major|minor|patch` changes semver only, `bump build` increments `+N` (Android `versionCode`)
- **Make**: `version-major` / `version-minor` / `version-patch` / `version-build`, or `version VERSION=x.y.z+n`; also `codegen` for Drift (`build_runner`) after clone / schema changes
- **Make / release**: `run-*`, `build-*`, `release-*` sync + pass those flags so Linux / Windows / Android binaries and the in-app label match. Google Drive Sync client ids come from gitignored `local.oauth.env` (see `local.oauth.env.example`); `make android-sha1` prints the debug SHA-1 for the Android OAuth client.
- **UI**: `appVersionLabelProvider` reads compile-time `APP_VERSION` (shown in Settings when set via Make/release)

## Code style

- Comments only for non-obvious logic
- Names explain intent: `getRateForPair()` not `get()`, `changeStoredCurrency()` not `set()`
- PascalCase classes, camelCase members, `_` prefix for private
- **Do not** put the product name (`Valtero`) in file or class names — use role names (`AppPageScaffold`, not `ValteroPageScaffold`)
- UI component files: **≤ 500 lines** (one screen/sheet/widget per file); split private sub-widgets into sibling `ui/` files and pure logic into `model/`
- **DRY**: the same pattern in **more than 2 places** → extract a shared helper/widget (see [dry.md](docs/agent-rules/dry.md)); e.g. `AppFilledButton` instead of re-wiring busy spinners

Details: [docs/agent-rules/naming.md](docs/agent-rules/naming.md), [docs/agent-rules/ui-component-size.md](docs/agent-rules/ui-component-size.md), [docs/agent-rules/dry.md](docs/agent-rules/dry.md)

## New dependencies

Do **not** add a package to `pubspec.yaml` without an **explicit user approve**.

Before proposing one: check need (existing code enough?), overlap with current deps/features, why this package is better, and that it is still maintained / actively developed. Present that to the user and wait for approve of the **specific package** before `pub add` / editing `pubspec.yaml`.

Details: [docs/agent-rules/dependencies.md](docs/agent-rules/dependencies.md)

## When making changes

1. Read existing code in the relevant FSD slice first
2. Keep imports within the layer rules
3. Prefer extending an entity/feature over adding cross-cutting spaghetti
4. Test on Linux Ubuntu
5. If core flow or architecture changes, update this `AGENTS.md`
6. If platform run/build/release flow changes, update `README.md` and the **App version** section here
7. **If editing an agent rule**: update `docs/agent-rules/<topic>.md` first (source of truth). If a local `.cursor/rules/<topic>.mdc` mirror exists, update its body in the same pass. Never edit only the `.mdc`.
8. **After finishing a plan / feature**: run full `flutter test` (not only new files), fix every failure including unrelated fixtures broken by schema changes, then re-run until green — see [testing.md](docs/agent-rules/testing.md). If Flutter/Dart tooling is blocked by the environment, report that and ask the user — **never** copy the Flutter/Dart SDK (or other toolchains) into the repo to work around it — see [tooling-environment.md](docs/agent-rules/tooling-environment.md)
9. **On every commit**: bump **patch** in `VERSION` (unless the user explicitly asked for minor/major), sync `pubspec.yaml`, and update [`CHANGELOG.md`](CHANGELOG.md) — see [changelog.md](docs/agent-rules/changelog.md)

## Topic rules (tool-agnostic)

| File | Why it exists |
| --- | --- |
| [docs/agent-rules/fsd-layers.md](docs/agent-rules/fsd-layers.md) | Layer import direction with ✅/❌ examples |
| [docs/agent-rules/money-and-currency.md](docs/agent-rules/money-and-currency.md) | Minor units + rate resolution order |
| [docs/agent-rules/drift-conventions.md](docs/agent-rules/drift-conventions.md) | Tables/DAOs, `kAppSchemaVersion`, migrate_to_vN, exchange envelope versions |
| [docs/agent-rules/riverpod-conventions.md](docs/agent-rules/riverpod-conventions.md) | Provider placement and `AsyncNotifier` pattern |
| [docs/agent-rules/l10n-strings.md](docs/agent-rules/l10n-strings.md) | No hardcoded UI strings; en/ru/es/sr ARB |
| [docs/agent-rules/naming.md](docs/agent-rules/naming.md) | No product name in file/class identifiers; intent-based names |
| [docs/agent-rules/dry.md](docs/agent-rules/dry.md) | Same pattern in **>2** places → extract shared helper/widget |
| [docs/agent-rules/ui-component-size.md](docs/agent-rules/ui-component-size.md) | ≤ 500 lines per UI component; when/how to split |
| [docs/agent-rules/modal-sheets.md](docs/agent-rules/modal-sheets.md) | Default modals = bottom sheets (`showAppModalSheet`); dialogs only when stated |
| [docs/agent-rules/dependencies.md](docs/agent-rules/dependencies.md) | New packages: need / overlap / health + explicit user approve |
| [docs/agent-rules/tooling-environment.md](docs/agent-rules/tooling-environment.md) | **Never** copy Flutter/Dart/SDKs into the repo; report env failures instead |
| [docs/agent-rules/platform-guide.md](docs/agent-rules/platform-guide.md) | Keep in-app platform guide in sync with new capabilities |
| [docs/agent-rules/testing.md](docs/agent-rules/testing.md) | Unit/feature tests; **full `flutter test` after finishing a plan** |
| [docs/agent-rules/changelog.md](docs/agent-rules/changelog.md) | Keep a Changelog; **patch + changelog on every commit**; minor/major only when the user asks |

## Tool-specific rule files (gitignored)

Cursor (and similar tools) may need vendor-specific wrappers (e.g. `.cursor/rules/*.mdc` with `globs` / `alwaysApply`). Those paths are **gitignored**.

To generate Cursor mirrors once locally:

1. For each file in `docs/agent-rules/`, create `.cursor/rules/<same-name>.mdc`
2. Wrap the markdown body with YAML frontmatter:

| Topic | Frontmatter hint |
| --- | --- |
| `fsd-layers` | `alwaysApply: true` |
| `money-and-currency` | `globs: lib/entities/expense/**,lib/entities/exchange_rate/**,lib/features/add_expense/**` |
| `drift-conventions` | `globs: lib/**/data/**,lib/shared/database/**` |
| `riverpod-conventions` | `globs: lib/**/model/**,lib/shared/settings/**` |
| `l10n-strings` | `globs: lib/**/*.dart,lib/shared/l10n/**` |
| `naming` | `alwaysApply: true` |
| `dry` | `alwaysApply: true` |
| `ui-component-size` | `globs: lib/**/ui/**,lib/pages/**,lib/widgets/**` |
| `modal-sheets` | `globs: lib/**/ui/**,lib/pages/**,lib/widgets/**` |
| `dependencies` | `alwaysApply: true` |
| `tooling-environment` | `alwaysApply: true` |
| `platform-guide` | `globs: lib/features/platform_guide/**,lib/pages/platform_guide/**` |
| `testing` | `globs: test/**` |
| `changelog` | `globs: CHANGELOG.md,VERSION,scripts/app_version.*` |

Ask an agent: “Mirror `docs/agent-rules/*.md` into `.cursor/rules/*.mdc` with the frontmatter from AGENTS.md.”
