# Changelog

All notable user-facing changes to Valtero are documented here.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html)
via the repo-root [`VERSION`](VERSION) file (`x.y.z+build`).

## [Unreleased]

## [1.1.2] - 2026-09-11

### Added

- Show FAB includes **Show cash flow**; cash-flow sample chart (income + expenses)
  when the dashboard is empty.

### Changed

- Direction tabs order: Cash flow (default on first launch) → Expenses → Income;
  last selected tab is persisted across app restarts.
- New expense / income forms preselect the last category tag used for that
  operation type (user can change before saving).
- Sample chart copy mentions expenses or income.
- Expandable `+` / Show FABs keep a stable widget tree (trigger animation
  controller survives open/close); sub-actions stay mounted and animate with
  height-factor + opacity; each FAB is anchored with a fixed `Positioned(right: …)`
  so neighbors never shift; open trigger still uses two-phase × (appear, then
  180° spin).

### Fixed

- Expandable FAB open/close animation no longer vanishes (trigger was remounted
  on every toggle; dismiss barrier stays mounted so Stack indices stay stable).
- Expandable FAB open, sub-action, and close respond on the first tap
  (dismiss barrier behind the cluster; invisible × no longer steals hits).
- Opening one FAB submenu no longer shoves the other FAB sideways.
- Show FAB no longer clips/overlaps the `+` button when closed or open.

## [1.1.1] - 2026-09-10

### Changed

- Expandable FABs: `AddOperationFab` uses page callbacks (no widgets→features
  import); opening one menu closes the other; tap outside dismisses.

## [1.1.0] - 2026-09-10

### Changed

- Single theme-colored `+` FAB expands to text actions for Add expense / Add income
  (replaces separate red/green FABs); menu actions use a slightly lighter fill than
  the primary FAB.
- Dashboard **Show** FAB expands to Show expenses / Show income (replaces the
  direction-specific list FAB); sibling FABs stay bottom-aligned when a menu opens.
- Create/edit tag (and payment method) use the standard bottom sheet instead of a
  centered dialog.
- Agent rule: default modals are bottom sheets (`docs/agent-rules/modal-sheets.md`).

## [1.0.0] - 2026-09-09

### Changed

- First public release version (`1.0.0`).
- Drift production baseline is **schema v8** (`operations` / `operation_tags`);
  pre-v8 stepwise migrations removed. Existing v8 databases and backups keep
  working; older local DBs are refused without wiping data.

## [1.6.4] - 2026-09-09

### Changed

- Tags sheet: country detect and suggestions stay above expense/income category tabs.

## [1.6.3] - 2026-09-09

### Changed

- Add expense / income FABs use red vs green button backgrounds (white `+`).

## [1.6.2] - 2026-09-09

### Changed

- Expenses and incomes share one SQLite `operations` table (`kind`), schema **v8**
  (upgrade copies existing rows; backup JSON still uses separate expense/income arrays).
- Tags sheet: expense vs income categories as bookmark tabs (like Dashboard).
- Settings: Thanks near the bottom with accent heart icon; app version sticky footer.
- Add expense / income FABs both use `+`, with red vs green icon color.

## [1.6.1] - 2026-09-09

### Added

- Income list parity with expenses: list / grouping / chart views, sort, summary
  with convert-to display currency, filtered export, and persisted display prefs.
- Compact chart empty placeholder (icon + short line) on Dashboard and charts.
- Distinct add-expense (`↗`) and add-income (`↙`) FAB icons.
- From Cash flow: separate Show expenses / Show income icon FABs opening the
  full list screens.

### Changed

- Direction selector uses folder-style bookmark tabs instead of a segmented
  control.
- Dashboard empty charts distinguish “none yet” vs “nothing matches filters”.

### Fixed

- Bookmark tabs no longer throw `borderRadius` / non-uniform border errors
  (active tab label was blank).

## [1.6.0] - 2026-09-09

### Added

- **Income tracking**: separate income entries with the same money fields as
  expenses (amount/currency, convert-to reporting currency, payment method,
  country, note, date), soft-duplicate checks, and income-only category tags
  (salary, sale, gift, refund, investment, …).
- **Cash flow** dashboard tab: grouped bars comparing income vs expenses by
  day/week/month/year, plus a merged recent-operations feed.
- **Direction tabs** on the Dashboard (Expenses / Income / Cash flow) above the
  filter bar; FAB opens add-expense or add-income based on the active tab.
- **Tag icons**: curated icon keys on tags (`Tags.iconKey`) with picker in the
  Tags sheet; seeded categories get default icons on upgrade.
- Export CSV/JSON for income alongside expenses; encrypted backup / Google Drive
  sync include income rows (schema **v7**).
- In-app platform guide sections for Income and Cash flow; public `site/` pages
  updated for expense + income positioning.

### Changed

- Schema version **v7**: `Incomes` / `IncomeTags` tables and `Tags.iconKey`.
- Soft-duplicate fingerprint core moved to shared `operation_fingerprint` for
  reuse by expenses and income.

### Fixed

- Google Drive Sync: owner shared-file sync no longer fails silently with HTTP
  404 after personal sync succeeds. Missing `drive.file` on the refresh token
  (common after personal-only re-sign-in) now triggers a scoped re-auth / clear
  error, and debug logs include token scopes, pull reasons, Dio status bodies,
  and local expense/income counts.
- Debug log file now starts each session (and each share/copy) with a header:
  product code, app version, schema, platform, locale, UTC timestamp,
  installId / sessionId, and Google account email when connected.

## [1.5.5] - 2026-09-09

### Added

- Pull-to-refresh (swipe down) on Dashboard and Expenses triggers Google Drive
  sync when configured and no modal/sheet is open.
- Shared sync: revoke a collaborator from the email chip (Drive permission
  delete + local list cleanup). Multiple collaborators were already supported.
- Donut chart: tiny slices get a minimum visual sweep so on-segment labels stay
  readable.
- With Debug & logs enabled, Google Drive Sync writes fetch / decrypt / pull /
  import / push summaries to the app log file.

### Fixed

- Google Drive Sync: owners no longer skip pulling the **shared** sync file after
  syncing their personal appData snapshot (separate last-synced timestamps per
  target). Cross-account changes with the same passphrase now merge correctly.

## [1.5.4] - 2026-09-09

### Changed

- Dashboard: filter summary bar sits **above** the chart (same order idea as the
  expenses list).
- Dashboard AppBar title is the section name (**Home** / **Главная** / …)
  instead of the live date/time clock.

## [1.5.3] - 2026-09-09

### Added

- Dashboard/Expenses breakdown charts show the **total** as an overlay: centered
  in the donut hole, or as a small badge on the opposite corner from the chart-type
  toggle for the column chart. Column chart bars are now labeled with their amount
  below the category label (in addition to the existing touch tooltip). The donut
  is ~20% larger by default (self-limited to the available width, no scrolling).
  Totals never show cents; if the full amount still doesn't fit its overlay it
  shortens to a compact form (`$20,000` → `$20K`) instead of overflowing.
- Google Drive Sync: the AppBar sync icon turns into a warning state (and the
  Backup & sync card / integration settings show **"Sync is paused — you're
  signed out"**) as soon as stored credentials go stale — even before the user
  attempts a manual sync — so they don't assume everything is up to date when
  it isn't. Opening the sync sheet or settings while in that state now
  proactively offers the sign-in alert instead of waiting for the next failed
  sync attempt.

### Fixed

- Google Drive Sync: when a stale/expired token requires signing in again
  (`invalid_grant` / missing refresh token / invalid-token test result), the
  sync now/test-connection/config-form flows show an alert offering an
  immediate **Sign in with Google** action (reusing the stored passphrase)
  instead of only reporting the error with no way to act on it.

## [1.5.2] - 2026-09-01

### Changed

- Unified modal sheets and dialogs around a shared layout: title (optional
  trailing action) → description → form → sticky centered actions
  (`AppSheetScaffold`, `AppSheetHeader`, `AppSheetActionsBar`).
- Action buttons use a consistent trailing-icon pattern (text then icon): close
  (label + grey X), OK (success), Save/Create (check). Sticky footers use a
  tinted action strip above the keyboard and system bottom inset; filter sheets
  (main Filters, currency, tags, payment) share the same Clear / Close / OK|Apply
  pattern.

### Added

- Shared sheet chrome widgets and l10n keys `ok` / `create`.
- Settings: **Thanks** (ETH + Bitcoin tip addresses) and **Contact developer** (email);
  Debug & logs shows where to send shared logs.

## [1.5.1] - 2026-09-01

### Added

- Expenses list and dashboard recent rows show the **original amount** (table
  column; dimmed second line on the dashboard only when it differs from stored).
- Row tap opens an **expense detail** sheet (Edit / Close / Delete); edit and
  delete icons remain on the row. Expenses table gains an edit icon before delete.

### Changed

- Split oversized expenses sheet orchestrator into focused UI helpers (display
  rates, listing views, filter flow, title bar, duplicates banner).
- Agent rule: never copy Flutter/Dart SDKs into the repo to work around tooling
  failures (`docs/agent-rules/tooling-environment.md`).

## [1.5.0] - 2026-08-31

### Added

- **Android:** voice expense dictation — microphone on the add-expense sheet
  opens a capture sheet with a speak pattern hint (amount → currency →
  category → payment). Speech is parsed on-device (`speech_to_text`), reviewed,
  then applied to form fields (or cancelled). Recognition language follows
  device locales. Audio and transcript are not stored; only recognition errors
  may appear in app logs (without spoken text). Unavailable on Linux/Windows.

### Fixed

- Save on the add/edit expense sheet stays disabled until a valid amount is
  entered.

## [1.4.10] - 2026-08-31

### Added

- Encrypted backup / Google Drive sync now includes **all** cached exchange
  rates (not only manual overrides) plus `lastRateRefreshAt`, so devices share
  rates and the **1h** network-fetch cooldown (newer `fetchedAt` wins; cooldown
  uses the later timestamp).

### Fixed

- Android: long modal sheets (e.g. rates list) can scroll again — removed the
  locked `DraggableScrollableSheet` wrapper that swallowed touch drags.

### Changed

- Google Drive debounced push also runs after exchange-rate DB changes.

## [1.4.9] - 2026-08-31

### Added

- Chart breakdown by **day** and **week** (alongside month/year); choice is
  persisted with other list display prefs.
- Filter currency and expenses listing view / group / sort open in bottom sheets
  (same pattern as tags and payment filters).

### Changed

- Chart type icons live in one block (country, payment, tags, day, week, month,
  year, currency); when they do not fit on one line they wrap into two balanced
  rows (e.g. 4 + 4).

## [1.4.8] - 2026-08-31

### Added

- Dashboard and expenses chart: **column** view alongside donut; type toggle
  overlays the chart (top-right) without growing the block; choice persisted.
- AppBar Google Drive sync icon on Dashboard and Expenses (primary when
  connected, muted when not); opens a quick sync sheet with the same Sync now /
  setup actions as Backup & sync.
- Shared `AppFilledButton` / tonal / outlined / text with stable-size busy
  spinner (no button resize while loading).
- Agent rule: DRY — same pattern in more than two places must be extracted
  ([docs/agent-rules/dry.md](docs/agent-rules/dry.md)).

### Changed

- Dashboard page split into thin orchestrator + `DashboardBody` + sample-slice
  helper (FSD-friendly, ≤500-line UI files).
- ExpansionTile sections (add expense meta, platform guide) no longer show
  expanded divider borders.
- Tags and export removed from Dashboard AppBar (remain under Settings).
- Integration / Backup & sync / Google Drive action buttons use app busy
  buttons; AppBar sync icon shows a spinner while syncing.

### Fixed

- Backup & sync: Google Drive actions respect panel busy state; local
  export/import disabled while Drive sync is running (and the reverse).

## [1.4.7] - 2026-08-31

### Added

- Backup & sync: Google Drive card with link to Integrations, **Sync now**, and a
  success checkmark showing last sync time (tap for relative time).
- Shared `ActionSuccessStatusIcon` and relative-time labels (en / ru / es / sr).
- ExchangeRate-API integration: **Enable** switch (active only after a successful
  connection test, same pattern as Telegram).
- Backup envelope metadata syncs Google Drive collaborator emails and shared file
  id across devices on pull-merge.
- Validation string `amountRequired` for empty/invalid expense amounts.

### Changed

- Modal sheets: keyboard-aware height from full screen; bottom scroll padding
  includes system safe area (fixes collaborator block under Android nav).
- Sync success feedback moved from bottom banner to icon beside action buttons
  (Google Drive integration + Backup & sync).
- Integration forms: success toasts near actions; errors under buttons; Telegram
  enable requires verified credentials, not just filled fields.

### Fixed

- Add-expense modal no longer double-applies keyboard inset on the action bar.
- Backup & sync **Sync now** shows specific error messages (passphrase, re-auth,
  newer schema, etc.) instead of generic connection failed.
- Manual rate add no longer shows misleading “Save” toast.

## [1.4.6] - 2026-08-30

### Added

- Google Drive Sync help sheet explaining same-account vs cross-account flows;
  “Join a sync someone shared with you” for a second Google account (restricted
  `drive` scope to discover shared files); pull-merge-push on the shared file
  for both owner and joiner.
- Currency settings: fetch-all-rates from the active service into the local
  Drift cache; per-pair refresh icon on View rates; fetch-from-service on the
  manual rate sheet. Network fetches share a **1-hour cooldown** (via
  `lastRateRefreshAt`) so ExchangeRate-API free quota stays usable.
- Unknown currency/country flags use a muted help icon with tooltip instead of
  the package’s white question-mark square.

### Changed

- Google Drive Sync passphrase Generate/Copy moved into the field suffix (same
  pattern as Backup & sync via shared `PassphraseTextField`); regenerating after
  connect asks for confirmation.
- Google Drive Sync help icon sits at the end of the integration description
  instead of on its own row.
- Modal sheets pad for the on-screen keyboard so focused fields stay visible.

### Fixed

- Shared-file sync no longer blind-overwrites the collaborator’s changes; both
  sides pull-merge before push.

## [1.4.5] - 2026-08-30

### Fixed

- Desktop Google Drive sign-in: send Desktop OAuth **client secret** on token
  exchange (Google still requires it with PKCE); clearer error when the secret
  is missing; loopback redirect uses `http://127.0.0.1:43823/oauth2redirect`.
- Opening Settings → Integrations no longer hits Riverpod
  `setState() during build` when the logger depended on settings via `watch`.
- Android release builds declare `INTERNET` so VPNs can list the app for
  split-tunneling and network features work outside debug/profile.

### Changed

- Document Linux WebKitGTK 4.1 / libsoup 3.0 **dev** packages for
  `make run-linux`, and `GOOGLE_OAUTH_CLIENT_SECRET_DESKTOP` in
  `local.oauth.env.example` / Make dart-defines.

## [1.4.4] - 2026-08-30

### Added

- Frankfurter listed under Settings → Integrations (built-in ECB rates, Test
  connection, no credentials); Currency sheet links to it when it is the active
  source.
- Shared `SecretTextField` with a lock prefix to show/hide secrets for Telegram
  bot token, ExchangeRate-API key, Google Drive passphrase, and Backup & sync
  passphrases.

### Fixed

- ExchangeRate-API test no longer reports DNS/network failures as an invalid
  key; clarify that keys must come from exchangerate-api.com (not
  exchangeratesapi.io / APILayer).
- Google Drive sign-in maps network token exchange failures and access denied
  to clearer messages.

## [1.4.3] - 2026-08-30

### Fixed

- Redact Google OAuth client ids, reverse-client schemes, and token shapes from
  the shareable debug log; stop logging raw Android redirect URIs on sign-in.
- Telegram connection test maps DNS / network failures to a clear UI message
  and logs host/type without embedding the bot URL.

### Changed

- Telegram and ExchangeRate-API integrations: remove Save; successful Test
  connection persists credentials (and refreshes rates for ExchangeRate-API).

## [1.4.2] - 2026-08-30

### Fixed

- Integration failures (Telegram test, Google Drive sign-in/sync) are written to
  the debug log file instead of being swallowed as UI-only status codes.
- Android Google Drive OAuth: document and surface the required **Custom URI
  scheme** Advanced setting (Google’s default blocks reverse-client-id redirects).

### Changed

- Integration config actions are disabled until required fields are filled,
  credentials are verified (Save), or the integration is already connected
  (Disconnect); Google Drive Sign-in / Share / Copy follow the same rules.

## [1.4.1] - 2026-08-30

### Changed

- Versioning policy: every commit bumps **patch** and updates `CHANGELOG.md`;
  **minor** / **major** only when explicitly requested (see `docs/agent-rules/changelog.md`).

## [1.4.0] - 2026-08-30

### Added

- **Google Drive Sync** integration (Settings → Integrations): encrypted automatic
  sync between devices via Drive `appDataFolder` (personal) and optional
  cross-account share via a Drive file (`drive.file` scope). Uses the same
  Argon2id → AES-GCM envelope as Backup & sync; Google only stores ciphertext.
- Version gate for cloud sync: older remote `schemaVersion` merges forward;
  newer remote schema blocks sync and shows an update-required alert so a newer
  cloud snapshot is never overwritten.
- Root `CHANGELOG.md` and agent rule requiring a changelog entry on every
  **minor** or **major** `VERSION` bump.

## [1.3.0] - 2026-08-30

### Added

- Soft-duplicate detection and review for expenses (same calendar day + amount +
  currency), including import conflict resolution on encrypted backup merge.
- Integrations registry (Telegram export destination, ExchangeRate-API) under
  Settings → Integrations.
- Encrypted backup / merge-import (`.valterobackup`) under Settings → Backup & sync.
