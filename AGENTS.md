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
- **Drift (SQLite)** for expenses, tags, exchange-rate cache/overrides (`sqlite3_flutter_libs` bundles native SQLite on Linux/Android/Windows while on Drift/`sqlite3` 2.x)
- **Hive** for `AppSettings` only (reporting currencies, API key, detection cache, theme/locale/timezone)

Details: [docs/agent-rules/riverpod-conventions.md](docs/agent-rules/riverpod-conventions.md), [docs/agent-rules/drift-conventions.md](docs/agent-rules/drift-conventions.md)

## Money & currency

- Amounts are always **integer minor units** (never `double` for money)
- Rate resolution order: keyed ExchangeRate-API → Frankfurter → manual override → `null`
- On expense entry: save as-is **or** convert into a reporting currency; always keep original amount/currency

Details: [docs/agent-rules/money-and-currency.md](docs/agent-rules/money-and-currency.md)

## Localization

- No hardcoded user-facing strings; use `AppLocalizations` (en/ru)
- ARB files live in `lib/shared/l10n/`

Details: [docs/agent-rules/l10n-strings.md](docs/agent-rules/l10n-strings.md)

## Key domain flows

1. **Add expense** (bottom sheet from Dashboard) → amount + currency → as-is or convert-to reporting currency (show live rate) → **multiple tags** (incl. auto country tag + “Select country” + payment **resource** tags: cash/card/crypto/…) → persist original + stored amounts
2. **Dashboard** → charts/summary + recent expenses list; entry points for add / tags / export sheets; convert stored amounts to display currency via `RateResolver` in Dart
3. **Rates** → on launch if last refresh >24h, refresh in background; Settings → Currency sheet can force refresh / bind API key / set manual rates / view all rates
4. **Tag suggestions** → detect country/currency (ip-api.com, locale fallback) → suggest tags by country + trip tags by foreign currency (Tags sheet)
5. **Export** → CSV/JSON → save file / OS share / Telegram `sendDocument` (sheet from Dashboard or Settings)

## Navigation

- Single home screen: **Dashboard** (no bottom nav)
- Settings via gear in the AppBar → full page with back arrow
- Sheets (full window width): add expense, tags, export, currency, appearance, rates list, **expenses list**
- Dashboard: one donut (by tags / months / currency), tag exclude filters, date period, FAB “Show expenses”
- AppBar shows live date/time in the selected timezone (default: auto-detected system zone)
- Desktop default window size: **853×720** (≈⅔ of the previous 1280 width)

## Code style

- Comments only for non-obvious logic
- Names explain intent: `getRateForPair()` not `get()`, `changeStoredCurrency()` not `set()`
- PascalCase classes, camelCase members, `_` prefix for private

## When making changes

1. Read existing code in the relevant FSD slice first
2. Keep imports within the layer rules
3. Prefer extending an entity/feature over adding cross-cutting spaghetti
4. Test on Linux Ubuntu
5. If core flow or architecture changes, update this `AGENTS.md`
6. **If editing an agent rule**: update `docs/agent-rules/<topic>.md` first (source of truth). If a local `.cursor/rules/<topic>.mdc` mirror exists, update its body in the same pass. Never edit only the `.mdc`.

## Topic rules (tool-agnostic)

| File | Why it exists |
| --- | --- |
| [docs/agent-rules/fsd-layers.md](docs/agent-rules/fsd-layers.md) | Layer import direction with ✅/❌ examples |
| [docs/agent-rules/money-and-currency.md](docs/agent-rules/money-and-currency.md) | Minor units + rate resolution order |
| [docs/agent-rules/drift-conventions.md](docs/agent-rules/drift-conventions.md) | Where tables/DAOs live + migration checklist |
| [docs/agent-rules/riverpod-conventions.md](docs/agent-rules/riverpod-conventions.md) | Provider placement and `AsyncNotifier` pattern |
| [docs/agent-rules/l10n-strings.md](docs/agent-rules/l10n-strings.md) | No hardcoded UI strings; en/ru ARB |

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

Ask an agent: “Mirror `docs/agent-rules/*.md` into `.cursor/rules/*.mdc` with the frontmatter from AGENTS.md.”
