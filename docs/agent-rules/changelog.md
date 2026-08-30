# Changelog

Whenever the app version’s **minor** or **major** segment changes, update
[`CHANGELOG.md`](../../CHANGELOG.md) in the same change set (or immediately
before the version bump commit).

## When an entry is required

| Change to `VERSION` (`x.y.z+n`) | CHANGELOG entry |
| --- | --- |
| **major** (`x` increases) | **Required** |
| **minor** (`y` increases) | **Required** |
| **patch** (`z` increases) | Optional (add if the fix is user-facing and worth calling out) |
| **build** only (`+n`) | Not required |

Triggers include `scripts/app_version.sh bump major|minor`, Make targets
`version-major` / `version-minor`, and `make version VERSION=x.y.z+n` when `x` or
`y` changes relative to the previous `VERSION`.

## How to write the entry

1. Open root [`CHANGELOG.md`](../../CHANGELOG.md) (Keep a Changelog style).
2. Move relevant items from `## [Unreleased]` into a new section:

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

3. Summarize **user-facing** behavior (Settings paths, sync, export, l10n), not
   every internal refactor. Link to docs or issue keys only when helpful.
4. Keep `## [Unreleased]` at the top for work not yet released under a bump.

## Agent checklist

- [ ] If this PR/commit bumps minor or major in `VERSION`, `CHANGELOG.md` has a
      matching `## [x.y.z]` section (or Unreleased items were moved into it).
- [ ] Do not invent dates in the future; use the release / bump day.
- [ ] Do not skip the changelog because “docs only” if the bump is minor/major —
      at least note the capability change that justified the bump.
