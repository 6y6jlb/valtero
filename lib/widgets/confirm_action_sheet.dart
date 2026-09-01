import 'package:flutter/material.dart';
import 'package:valtero/widgets/app_button.dart';
import 'package:valtero/widgets/app_close_icon_button.dart';
import 'package:valtero/widgets/app_modal_sheet.dart';
import 'package:valtero/widgets/app_sheet_actions_bar.dart';
import 'package:valtero/widgets/app_sheet_header.dart';
import 'package:valtero/widgets/app_sheet_scaffold.dart';

/// Centered title + description + optional body + sticky centered actions.
///
/// Use for confirmations and small parameter-change sheets.
class ConfirmActionLayout extends StatelessWidget {
  final String title;
  final String description;
  final Widget? body;
  final List<Widget> actions;

  const ConfirmActionLayout({
    super.key,
    required this.title,
    required this.description,
    this.body,
    required this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return AppSheetScaffold(
      header: AppSheetHeader(
        title: title,
        description: description,
        centered: true,
      ),
      actions: AppSheetActionsBar(children: actions),
      children: [
        ?body,
      ],
    );
  }
}

/// Standard close + primary confirm pair for [ConfirmActionLayout.actions].
///
/// Prefer calling this from a [Builder] inside the sheet so [context] is the
/// modal route (cancel/confirm pop the sheet, not the page underneath).
List<Widget> confirmActionButtons({
  required BuildContext context,
  required String confirmLabel,
  required VoidCallback onConfirm,
  VoidCallback? onCancel,
  bool destructive = false,
}) {
  return [
    AppCloseIconButton(
      onPressed: onCancel ?? () => Navigator.of(context).maybePop(),
    ),
    AppFilledButton(
      label: confirmLabel,
      icon: Icons.check,
      destructive: destructive,
      onPressed: onConfirm,
    ),
  ];
}

Future<T?> showConfirmActionSheet<T>({
  required BuildContext context,
  required Widget child,
  double initialChildSize = 0.42,
  double minChildSize = 0.28,
  double maxChildSize = 0.92,
}) {
  return showAppModalSheet<T>(
    context: context,
    initialChildSize: initialChildSize,
    minChildSize: minChildSize,
    maxChildSize: maxChildSize,
    child: child,
  );
}
