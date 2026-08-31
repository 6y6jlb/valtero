# Changelog

All notable user-facing changes to Valtero are documented here.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html)
via the repo-root [`VERSION`](VERSION) file (`x.y.z+build`).

## [Unreleased]

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
