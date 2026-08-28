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
| `lib/entities/` | Domain model + Drift tables/DAOs / rate providers |
| `lib/shared/` | DB core, Hive settings, Dio, consts, l10n, utils |

**Import rule**: a file may only import from its own layer (siblings) or from a layer further down. Never import upward or sideways across features.

Details: [docs/agent-rules/fsd-layers.md](docs/agent-rules/fsd-layers.md)

## State & storage

- **Riverpod** for state (`AsyncNotifier` for Hive/Drift-backed state)
- **Drift (SQLite)** for expenses, tags, exchange-rate cache/overrides (`sqlite3` ≥3.x bundles native SQLite via build hooks on Linux/Android/Windows)
- **Schema version** SSOT: `kAppSchemaVersion` + `migrations/migrate_to_vN.dart` on upgrade; same int goes into strict exchange envelopes as `schemaVersion`
- **Hive CE** for `AppSettings` only (reporting currencies, API key, detection cache, theme/locale/timezone)

Details: [docs/agent-rules/riverpod-conventions.md](docs/agent-rules/riverpod-conventions.md), [docs/agent-rules/drift-conventions.md](docs/agent-rules/drift-conventions.md)

## Money & currency

- Amounts are always **integer minor units** (never `double` for money)
- UI amounts via `MoneyText` / `formatMoneyDisplay` (`intl` + Settings → Appearance → money display); export keeps `Money.formatMinor`
- Rate resolution order: keyed ExchangeRate-API → Frankfurter → manual override → `null`
- On expense entry: save as-is **or** convert into a reporting currency; always keep original amount/currency

Details: [docs/agent-rules/money-and-currency.md](docs/agent-rules/money-and-currency.md)

## Localization

- No hardcoded user-facing strings; use `AppLocalizations` (en/ru)
- ARB files live in `lib/shared/l10n/`

Details: [docs/agent-rules/l10n-strings.md](docs/agent-rules/l10n-strings.md)

## Key domain flows

1. **Add expense** (bottom sheet from Dashboard) → amount + currency → as-is or convert-to reporting currency (show live rate) → **payment method** (cash/card/crypto/… or custom; optional default in Settings) → **tags by kind** (country, trip, category; one tag per kind, kinds optional) → persist original + stored amounts
2. **Dashboard** → charts/summary + recent expenses list; entry points for add / tags / export sheets; convert stored amounts to display currency via `RateResolver` in Dart
3. **Rates** → on launch if last refresh >24h, refresh in background; Settings → Currency sheet can force refresh / bind API key / set manual rates / view all rates
4. **Tag suggestions** → detect country/currency (ip-api.com, locale fallback) → suggest tags by country + trip tags by foreign currency (Tags sheet)
5. **Export** → CSV/JSON (human) → save / share / Telegram; future strict/encrypted interchange must embed `formatVersion` + `schemaVersion` (`kAppSchemaVersion`) for import adapters

## Navigation

- Home: **Dashboard** (no bottom nav). If there are **no expenses yet**, Dashboard shows a **sample chart** labeled as an example, with a link to the **platform guide**; after the first expense, real chart data appears. The guide is also opened from Settings → Platform guide.
- **Expenses**: full page via FAB “Show expenses” (back arrow); add expense stays a sheet (`+` FAB sticky bottom on Dashboard, Expenses, and Platform guide — **not** on Settings)
- Settings via gear in the AppBar → full page with back arrow
- Sheets (full window width): add expense, tags, export, currency, appearance, rates list, dashboard filters
- Dashboard: one donut (shared [DonutBreakdownChart](lib/features/expenses_list/ui/donut_breakdown_chart.dart): amounts on segments, legend chips toggle visibility; tap segment → Expenses with filter); breakdown by country / payment method / trip / category / month / currency via shared [ChartBreakdownIcons](lib/features/expenses_list/ui/chart_breakdown_icons.dart); filter summary bar → full-screen sheet; FABs “Show expenses” + add
- Expenses chart view uses the same donut widget; tap a segment applies that filter and switches to list
- AppBar shows live date/time in the selected timezone (default: auto-detected system zone)
- Desktop default window size: **853×720** (≈⅔ of the previous 1280 width)

## App version

- **SSOT**: repo-root `VERSION` (`semver+build`, e.g. `1.0.0+1`)
- **Tooling**: `scripts/app_version.sh` / `.ps1` — `sync` writes `pubspec.yaml`; `flutter-args` emits `--build-name` / `--build-number` / `--dart-define=APP_VERSION=…`; `bump major|minor|patch` changes semver only, `bump build` increments `+N` (Android `versionCode`)
- **Make**: `version-major` / `version-minor` / `version-patch` / `version-build`, or `version VERSION=x.y.z+n`; also `codegen` for Drift (`build_runner`) after clone / schema changes
- **Make / release**: `run-*`, `build-*`, `release-*` sync + pass those flags so Linux / Windows / Android binaries and the in-app label match
- **UI**: `appVersionLabelProvider` reads compile-time `APP_VERSION` (shown in Settings when set via Make/release)

## Code style

- Comments only for non-obvious logic
- Names explain intent: `getRateForPair()` not `get()`, `changeStoredCurrency()` not `set()`
- PascalCase classes, camelCase members, `_` prefix for private
- **Do not** put the product name (`Valtero`) in file or class names — use role names (`AppPageScaffold`, not `ValteroPageScaffold`)
- UI component files: **≤ 500 lines** (one screen/sheet/widget per file); split private sub-widgets into sibling `ui/` files and pure logic into `model/`

Details: [docs/agent-rules/naming.md](docs/agent-rules/naming.md), [docs/agent-rules/ui-component-size.md](docs/agent-rules/ui-component-size.md)

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

## Topic rules (tool-agnostic)

| File | Why it exists |
| --- | --- |
| [docs/agent-rules/fsd-layers.md](docs/agent-rules/fsd-layers.md) | Layer import direction with ✅/❌ examples |
| [docs/agent-rules/money-and-currency.md](docs/agent-rules/money-and-currency.md) | Minor units + rate resolution order |
| [docs/agent-rules/drift-conventions.md](docs/agent-rules/drift-conventions.md) | Tables/DAOs, `kAppSchemaVersion`, migrate_to_vN, exchange envelope versions |
| [docs/agent-rules/riverpod-conventions.md](docs/agent-rules/riverpod-conventions.md) | Provider placement and `AsyncNotifier` pattern |
| [docs/agent-rules/l10n-strings.md](docs/agent-rules/l10n-strings.md) | No hardcoded UI strings; en/ru ARB |
| [docs/agent-rules/naming.md](docs/agent-rules/naming.md) | No product name in file/class identifiers; intent-based names |
| [docs/agent-rules/ui-component-size.md](docs/agent-rules/ui-component-size.md) | ≤ 500 lines per UI component; when/how to split |
| [docs/agent-rules/dependencies.md](docs/agent-rules/dependencies.md) | New packages: need / overlap / health + explicit user approve |
| [docs/agent-rules/platform-guide.md](docs/agent-rules/platform-guide.md) | Keep in-app platform guide in sync with new capabilities |

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
| `ui-component-size` | `globs: lib/**/ui/**,lib/pages/**,lib/widgets/**` |
| `dependencies` | `alwaysApply: true` |
| `platform-guide` | `globs: lib/features/platform_guide/**,lib/pages/platform_guide/**` |

Ask an agent: “Mirror `docs/agent-rules/*.md` into `.cursor/rules/*.mdc` with the frontmatter from AGENTS.md.”
