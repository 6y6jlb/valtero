# Changelog

All notable user-facing changes to Valtero are documented here.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html)
via the repo-root [`VERSION`](VERSION) file (`x.y.z+build`).

## [Unreleased]

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
