# Changelog and version bumps

Every **git commit** that lands project work must bump the app version and update
[`CHANGELOG.md`](../../CHANGELOG.md) in the **same** commit (or immediately before
it in the same change set).

SSOT for the version string: repo-root [`VERSION`](../../VERSION)
(`x.y.z+build`). Sync into `pubspec.yaml` with `./scripts/app_version.sh sync`
(or `make sync-version`) after bumping.

## Default: patch on every commit

Unless the user **explicitly** asks to bump **minor** or **major**, agents must:

1. Run `./scripts/app_version.sh bump patch` (or `make version-patch`)
2. Run `./scripts/app_version.sh sync`
3. Add / extend a `CHANGELOG.md` section for the new `x.y.z`
4. Update in-app release notes when the change is **user-visible** (see below)
5. Include `VERSION`, `pubspec.yaml`, `CHANGELOG.md`, and release-notes sources
   in that commit

| Situation | What to bump |
| --- | --- |
| Normal commit (feature, fix, docs-for-product, refactor that ships) | **patch** (`z`) + changelog |
| User says to bump **minor** / «минор» / minor version | **minor** (`y`) + changelog |
| User says to bump **major** / «мажор» / major version | **major** (`x`) + changelog |
| User says only bump **build** / Android `versionCode` | **build** (`+n`) — changelog optional |
| Empty / no-op commit | Do not create; no bump |

Vague “ship it” / “commit” **without** naming minor/major → **patch**.

## Developer changelog (`CHANGELOG.md`)

Keep a Changelog style at repo root [`CHANGELOG.md`](../../CHANGELOG.md).

1. Prefer moving bullets from `## [Unreleased]` into a dated section, or write the
   section directly for this bump:

   ```markdown
   ## [x.y.z] - YYYY-MM-DD

   ### Added
   - …

   ### Changed
   - …

   ### Fixed
   - …

   ### Removed
   - …
   ```

2. Summarize **product** behavior when possible (Settings paths, sync, export,
   l10n). Pure agent-rule / tooling / test-suite policy notes belong here in a
   short **Changed** line when useful for developers — they must **not** go into
   the in-app release notes.
3. Do not invent future dates; use the commit / bump day.
4. Keep `## [Unreleased]` at the top for notes not yet tied to a version.

## In-app release notes (Settings → What's new)

Source: [`lib/features/about_support/model/release_notes.dart`](../../lib/features/about_support/model/release_notes.dart)
(`kAppReleaseNotes`). Shown in Settings before Thanks. Sheet chrome strings are
localized (en/ru/es/sr); **note body text is English only** for now.

On every **semver** bump (`x.y.z`, not build-only):

1. If the commit changes something a user can see or do in the app, add or
   extend a short English bullet under that version (newest versions first).
2. Keep lines brief and plain — no `Added`/`Changed` headings, no file paths,
   no agent/tooling/test-policy wording.
3. Consecutive patches that describe the **same** theme (e.g. chart swipe
   polish across 1.1.15–1.1.17) may be **collapsed** into one entry under the
   latest of those versions instead of repeating.
4. Commits that only touch agent rules, CI, or developer docs: update
   `CHANGELOG.md` if needed, **skip** in-app notes.

## Build-only bumps

`bump build` / `make version-build` (Android `versionCode` only) does **not**
require a changelog entry or release-notes update. Do not use build-only bumps
as a substitute for the default patch-on-commit rule.

## Agent checklist (before finishing a commit)

- [ ] `VERSION` bumped (**patch** by default; minor/major only if the user asked)
- [ ] `pubspec.yaml` synced from `VERSION`
- [ ] `CHANGELOG.md` has a `## [x.y.z]` section matching the new version
- [ ] User-visible work → `kAppReleaseNotes` updated (English, short); otherwise skip
- [ ] Commit message matches the bump intent (`fix` / `add` / `Ship vX.Y` as usual)
