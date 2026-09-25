# Changelog

All notable user-facing changes to Valtero are documented here.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html)
via the repo-root [`VERSION`](VERSION) file (`x.y.z+build`).

## [Unreleased]

## [1.1.19] - 2026-09-25

### Fixed

- Time-series chart date labels thin out by plot width so neighboring dates no
  longer overlap or look like they spilled onto the next slide; a single-point
  year line shows a visible marker.

### Changed

- Bottom Show / Create / bulk actions use solid `primaryContainer` plates
  (same as the selected direction tab), without frosted blur.

## [1.1.18] - 2026-09-24

### Fixed

- Column and line chart date labels stay inside the plot (edge titles no longer
  clip off the sides after the interactive chart slide).

### Added

- Settings → What's new: short English release notes for app updates (before
  Thanks).

## [1.1.17] - 2026-09-24

### Changed

- Tab and chart-breakdown switches follow the finger: the current page and the
  next slide in parallel; release past ~30% width (or a short trackpad burst)
  commits, otherwise the page springs back. Vertical scroll offset stays put.
- Chart legend chips show the series amount under the label (hidden when rates
  are missing).
- Breakdown / period targets sit above the legend on every chart type and
  screen width, not above the plot.
- Bottom Show / Create / bulk actions use individual frosted plates (Telegram-
  like neutrals; real blur depends on the platform).

## [1.1.16] - 2026-09-24

### Changed

- Switching Cash flow / Expenses / Income (and chart breakdown) uses a parallel
  horizontal slide; the previous page exits while the next enters.
- Vertical scroll position is kept across those switches instead of jumping to
  the top. Chart aggregation no longer blanks the plot with a spinner when a
  previous chart for the same tab is already on screen.

## [1.1.15] - 2026-09-24

### Changed

- Chart chrome is more compact on phones: type icons stay top-right; country /
  tag / period targets move to one scrollable row above the legend. Hover and
  touch details show as in-plot tooltips instead of a left summary badge.
- Horizontal swipe on the chart cycles breakdown; outside the chart it cycles
  Cash flow / Expenses / Income.

## [1.1.14] - 2026-09-22

### Fixed

- Chart type actions (donut, columns, line) stay on one row on a phone. Country, date, tag, and other target actions still wrap at four per row.
- In landscape, the chart shifts clear of the system navigation bar so those actions are not covered.

## [1.1.13] - 2026-09-22

### Fixed

- Income charts refresh when an amount or currency changes.

## [1.1.12] - 2026-09-22

### Fixed

- Chart subcategory switch no longer clips vertically in the legend.
- On narrow screens, chart overlay actions wrap at most 4 icons per row so the
  sum / selection badge no longer overlaps them; long titles ellipsize while
  the amount stays full.
- Chart-type actions are visually separated from breakdown / period icons (rule
  under types); selected chart-type icons use a circular wash with a slightly
  bluer tint.
- Dashboard direction tab switch shows a chart-slot loader instead of flashing
  an empty chart stub while aggregation finishes. Tapping a multi-line chart
  selection badge opens a detail sheet; single-line totals stay overlay-only.

## [1.1.11] - 2026-09-21

### Fixed

- Dashboard / list donut chart: type and breakdown icons sit **above** the plot
  and the legend stays **below** it, so neither overlaps the ring. The donut
  keeps its previous size.

## [1.1.10] - 2026-09-21

### Added

- Amount calculator when editing an expense or income (add / subtract / multiply /
  divide / percent of); Apply writes the result into the amount field before Save.
- Operation sync identity and soft-delete (schema **v11**): stable `syncId`,
  `updatedAt`, and `deletedAt` tombstones so edits and deletes propagate across
  devices.

### Changed

- Encrypted backup and Google Drive Sync merge expenses/income with
  **last-write-wins** on `updatedAt` (match by `syncId`, else a unique
  day+amount+currency fingerprint). Deletes travel as tombstones in the sync
  snapshot; lists, charts, and CSV/JSON export stay live-only. Ambiguous
  soft-duplicates (2+ local live matches) still use skip / import-as-unique.

## [1.1.9] - 2026-09-21

### Added

- Line and stacked-by-date column charts for expenses/income (fourth chart shape
  alongside donut and classic columns); cash flow gains a line chart (income /
  expense / net).
- Categories vs Subcategories toggle on category charts and list grouping
  (persisted per direction).
- Google Drive sync: persistent “Syncing…” toast with spinner, then a success
  toast with added expense/income counts (and skipped duplicates when any).

### Changed

- Cash-flow recent rows and the cash-flow list table show category tags like
  expenses/income.
- Chart-type and breakdown toggle icons keep a fixed size so switching views no
  longer janks the layout on mobile.
- Chart hover details float over the plot (sum-badge corner) instead of pushing
  layout; plot content sits below overlay actions; hidden donut slices no longer
  leave a blank arc.

## [1.1.8] - 2026-09-16

### Added

- Much larger curated icon catalog for tags, subcategories, and payment methods
  (~90 icons); seeded subtags get default icons.
- Payment methods store an optional `iconKey` (schema **v10**); picker enabled in
  Settings → Payment methods; icons round-trip in encrypted backup/sync.
- Debug & logs: separate **Share** (system share sheet) and **Send to developer**
  (email with `.log` attached — Android Intent + FileProvider, Linux `xdg-email`,
  macOS Mail when possible).

### Changed

- Soft toast after Send to developer: mail chooser opened (not “sent”).
- `cash` vs `salary` icons no longer share the same glyph.

### Fixed

- Android email attach grants URI read permission to chooser targets so the log
  file opens in mail apps.
- Import backfills payment `iconKey` only when the local row has none.

## [1.1.7] - 2026-09-16

### Added

- Cash-flow **donut** chart (income vs expense totals) as the default shape, with
  toggle to temporal grouped bars; choice persisted as `cashFlowChartType`.
- Contact developer: **Send** opens mailto; Copy stays in the sheet actions.
- Integrations sheet: **Suggest an integration** opens Contact developer; Close
  footer on integration config sheets.
- Settings gear on Dashboard, Expenses/Income list, and Platform guide (not on
  Settings itself).
- Debug & logs sticky actions (copy email / copy logs / clear / send); Linux
  send uses `xdg-email --attach` with path+mailto fallback; refresh overlay on
  the log viewer.

### Changed

- Expandable FAB open state uses a rotating `+` (45°) instead of swapping to ×;
  Show FAB collapses the label, then morphs the list icon into the rotated +.
- Appearance money-format dropdown shows only visually unique previews (NBSP /
  twin formats collapsed).
- Per-currency summary headers use `ISO · count` (no flag/symbol); income has
  its own help copy; Russian expense wording clarified.
- Rates list places the target currency flag before the amount (same pattern as
  the base flag).
- Tag icon key `other` uses a full outlined category icon instead of `more_horiz`.
- Direct `url_launcher` dependency for mailto / Linux email fallback.

## [1.1.6] - 2026-09-15

### Changed

- Money amounts show currency glyphs (`₽`, `$`, `€`, …) instead of bare ISO
  codes in `localeCode` / `localeSymbol` / `isoBefore` / `compactSymbol`
  (and in per-currency summary headers / currency chart labels). `plain`
  still uses ISO for machine-stable export.
- Dashboard recent rows lead with tag icon → currency flag → payment icon
  (country stays in the subtitle).
- Encrypted backup / Drive sync expenseTag and incomeTag links include
  optional parent fields so subcategories round-trip unambiguously.

## [1.1.5] - 2026-09-15

### Fixed

- Sync toast no longer clips long multi-line messages (e.g. cloud schema newer
  than this app); duration scales with message length.
- Pull-to-refresh and Sync now show a scrollable dialog for the newer-schema
  gate, consistent with Backup & sync / Integrations.

## [1.1.4] - 2026-09-15

### Added

- Optional one-level subcategories under expense and income category tags,
  with default seeds per category (incl. dacha, home repairs, transit,
  dentistry, and more), nested management in Settings → Tags, and last-used
  subcategory remembered on create (same as categories).
- Add/edit operation sheet shows the selected category (and subcategory)
  as colored chips instead of a “N selected” count.

### Changed

- Lists, recent rows, detail, filters, and CSV/JSON export show category
  and subcategory together (e.g. “Health · Doctor”). Charts by category
  still roll up to the parent only (no subcategory breakdown).
- Encrypted backup / Drive sync includes optional `parentStableKey` (and
  name+kind fallback for custom parents) for subcategory hierarchy
  (schema v9).

### Fixed

- Add subcategory from the operation sheet when the category has no children yet.
- Seeded subcategory no longer re-attached after the user promotes it to top-level.
- Charts/grouping roll up subtag-only operations to the parent category.
- Recent/detail/duplicate labels and bulk tag change respect category · subcategory.
- Voice expense match of a subcategory also selects its parent category.

## [1.1.3] - 2026-09-12

### Added

- Cash flow list parity with expenses/income: filters, per-currency summary
  (income / expense / net), list / grouping / chart views, merged CSV/JSON
  export, and persisted display preferences.
- Multi-select bulk actions on income and cash-flow lists (delete, change
  tags, country, currency) — same set as expenses; cash-flow tag change is
  disabled when the selection mixes expenses and income.

### Fixed

- Amount field autofocuses when opening add/edit expense or income sheets
  (keyboard opens immediately on mobile).
- Direction-tab switch no longer flashes a progress stripe between the
  filter bar and the chart (layout no longer jumps).

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

## [1.0.0] - 2026-09-09

### Added

- First public release version (`1.0.0`).
