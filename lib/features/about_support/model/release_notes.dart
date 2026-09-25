/// Short English release notes shown in Settings (not the developer changelog).
///
/// Newest version first. Collapse consecutive patches that describe the same
/// user-facing theme into one entry under the latest of those versions.
class AppReleaseNotes {
  final String version;
  final List<String> lines;

  const AppReleaseNotes({
    required this.version,
    required this.lines,
  });
}

/// User-facing history. Keep brief; no agent rules, tests, or tooling.
const kAppReleaseNotes = <AppReleaseNotes>[
  AppReleaseNotes(
    version: '1.1.19',
    lines: [
      'Chart dates space out so they do not overlap; a single year still shows a point on the line.',
      'Show, Create, and bulk actions match the selected tab colors.',
    ],
  ),
  AppReleaseNotes(
    version: '1.1.18',
    lines: [
      'Chart date labels stay fully visible on columns and lines.',
      'Settings → What\'s new lists short highlights from recent updates.',
    ],
  ),
  AppReleaseNotes(
    version: '1.1.17',
    lines: [
      'Swipe on the chart to change breakdown; swipe outside to switch Cash flow / Expenses / Income — pages slide with your finger and keep scroll position.',
      'Chart targets sit above the legend; legends show amounts under each label.',
      'Show, Create, and bulk actions use frosted button plates.',
    ],
  ),
  AppReleaseNotes(
    version: '1.1.14',
    lines: [
      'Chart type icons stay on one row on phones; landscape charts clear the system bar.',
    ],
  ),
  AppReleaseNotes(
    version: '1.1.13',
    lines: [
      'Income charts update when you change an amount or currency.',
    ],
  ),
  AppReleaseNotes(
    version: '1.1.10',
    lines: [
      'Amount calculator when editing an expense or income.',
      'Edits and deletes sync across devices with last-write-wins and soft-delete.',
    ],
  ),
  AppReleaseNotes(
    version: '1.1.9',
    lines: [
      'Line and stacked-by-date charts for expenses and income; cash-flow line chart.',
      'Categories vs subcategories on category charts and lists.',
      'Clearer Google Drive sync progress and result toasts.',
    ],
  ),
  AppReleaseNotes(
    version: '1.1.8',
    lines: [
      'Larger icon set for tags and payment methods; payment icons in backup and sync.',
      'Debug logs: Share and Send to developer with attachment.',
    ],
  ),
  AppReleaseNotes(
    version: '1.1.7',
    lines: [
      'Cash-flow donut chart (default) plus grouped bars.',
      'Contact developer Send, Settings gear on main screens, improved debug log actions.',
    ],
  ),
  AppReleaseNotes(
    version: '1.1.6',
    lines: [
      'Currency symbols in money display; clearer recent-row icons; subcategory links in backup.',
    ],
  ),
  AppReleaseNotes(
    version: '1.1.5',
    lines: [
      'Longer sync messages no longer clip; schema-update alerts use a scrollable dialog.',
    ],
  ),
  AppReleaseNotes(
    version: '1.1.4',
    lines: [
      'One-level subcategories for expense and income tags, with seeds and filters/export support.',
    ],
  ),
  AppReleaseNotes(
    version: '1.1.3',
    lines: [
      'Cash-flow list matches expenses/income (filters, summary, charts, export).',
      'Bulk actions on income and cash-flow lists.',
    ],
  ),
  AppReleaseNotes(
    version: '1.1.2',
    lines: [
      'Cash flow as the default Home tab; Show cash flow from the Show menu.',
      'Last-used category remembered on new expense or income.',
    ],
  ),
  AppReleaseNotes(
    version: '1.1.0',
    lines: [
      'Single + menu for Add expense / Add income; Show menu for expenses and income lists.',
    ],
  ),
  AppReleaseNotes(
    version: '1.0.0',
    lines: [
      'First public release.',
    ],
  ),
];
