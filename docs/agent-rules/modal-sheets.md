# Modal sheets

**Default modal UI** is a bottom sheet that slides up from the bottom of the
screen (`showAppModalSheet` / `showModalBottomSheet` with drag handle), not a
centered `AlertDialog` / `showDialog`.

## Default

- New forms, pickers, settings panels, create/edit flows, and multi-step UI →
  **`showAppModalSheet`** + **`AppSheetScaffold`** / **`AppSheetHeader`** /
  **`AppSheetActionsBar`** (see existing sheets under `lib/features/**/ui/` and
  `lib/widgets/`).
- Full window width on desktop (already handled by `showAppModalSheet`).
- Prefer nested bottom sheets over stacking a dialog on top of a sheet.

```dart
// ❌ BAD — form / create-edit as centered dialog
return showDialog(
  context: context,
  builder: (_) => AlertDialog(title: Text(title), content: form),
);

// ✅ GOOD
return showAppModalSheet(
  context: context,
  child: AppSheetScaffold(
    header: AppSheetHeader(title: title),
    actions: AppSheetActionsBar(children: [...]),
    children: [...],
  ),
);
```

## Exceptions (only when explicitly required)

Use `showDialog` / `AlertDialog` only when the task **states** that a dialog is
wanted, or for a short confirm / blocking alert that already follows an
established dialog pattern in the same flow (e.g. soft-duplicate conflict
choices, one-line errors). Prefer converting leftover form dialogs to sheets
when you touch them.

Do **not** invent a new centered dialog for create/edit of tags, payments,
filters, or similar — use the sheet pattern.
