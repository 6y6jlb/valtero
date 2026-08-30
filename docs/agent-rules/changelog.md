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
4. Include `VERSION`, `pubspec.yaml`, and `CHANGELOG.md` in that commit

| Situation | What to bump |
| --- | --- |
| Normal commit (feature, fix, docs-for-product, refactor that ships) | **patch** (`z`) + changelog |
| User says to bump **minor** / «минор» / minor version | **minor** (`y`) + changelog |
| User says to bump **major** / «мажор» / major version | **major** (`x`) + changelog |
| User says only bump **build** / Android `versionCode` | **build** (`+n`) — changelog optional |
| Empty / no-op commit | Do not create; no bump |

Vague “ship it” / “commit” **without** naming minor/major → **patch**.

## Changelog entry (required with every semver bump of x/y/z)

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

2. Summarize **user-facing** behavior when possible (Settings paths, sync, export,
   l10n). For pure agent-rule / tooling commits, a short **Changed** note is enough.
3. Do not invent future dates; use the commit / bump day.
4. Keep `## [Unreleased]` at the top for notes not yet tied to a version.

## Build-only bumps

`bump build` / `make version-build` (Android `versionCode` only) does **not**
require a changelog entry. Do not use build-only bumps as a substitute for the
default patch-on-commit rule.

## Agent checklist (before finishing a commit)

- [ ] `VERSION` bumped (**patch** by default; minor/major only if the user asked)
- [ ] `pubspec.yaml` synced from `VERSION`
- [ ] `CHANGELOG.md` has a `## [x.y.z]` section matching the new version
- [ ] Commit message matches the bump intent (`fix` / `add` / `Ship vX.Y` as usual)
