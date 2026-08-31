# DRY — extract after the third copy

## Rule

If the **same pattern** appears in **more than 2 places** (i.e. a third copy), extract it into a shared helper, widget, or model API in the same change (or immediately after), instead of pasting again.

Threshold:

| Copies | Action |
| --- | --- |
| 1–2 | Inline is OK |
| **≥ 3** | **Extract** (shared widget / function / small type) |

“Same pattern” means the same structure and intent, not merely similar-looking lines. Renaming locals or swapping one string does not make it a different pattern.

## Where to put the extract

Follow FSD and existing conventions:

- Cross-feature UI chrome → `lib/widgets/` (e.g. `AppFilledButton`, `AppPageScaffold`)
- Feature-only UI → that feature’s `ui/`
- Pure logic → feature `model/` or `shared/utils/`
- Do **not** invent a new package without [dependencies.md](dependencies.md) approve

Prefer **role names** ([naming.md](naming.md)): `AppFilledButton`, not product-branded wrappers.

## Examples

```dart
// ❌ BAD — third (and fourth…) call site still hand-wires busy + label
FilledButton(
  onPressed: busy ? () {} : onPressed,
  child: Stack(/* spinner over invisible Text */),
);

// ✅ GOOD — extracted once used from 3+ places
AppFilledButton(
  label: l10n.googleDriveSyncNow,
  busy: syncing,
  onPressed: canSync ? _sync : null,
);
```

```dart
// ❌ BAD — copy-pasted message-key switch in two sheets + a panel (3+)
String _message(l10n, key) => switch (key) { … };

// ✅ GOOD
googleDriveSyncResultMessage(l10n, result);
```

## When not to extract

- One-off UI that only looks similar (different state, different side effects)
- Premature abstraction before the second real use
- Forcing unrelated call sites into one mega-widget with many flags — prefer a small shared piece (label/spinner) composed differently if needed

## Agent checklist

1. Before finishing a change, scan for a pattern you just introduced or touched that already exists elsewhere.
2. If this is the **third** occurrence, extract in this pass (or note a blocker if FSD placement is unclear).
3. After extract, replace all copies — leave no mixed old/new call style for the same pattern.
