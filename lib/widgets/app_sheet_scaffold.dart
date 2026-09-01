import 'package:flutter/material.dart';
import 'package:valtero/widgets/app_modal_sheet.dart';
import 'package:valtero/widgets/app_sheet_header.dart';

/// Unified modal body: header → scrollable form content → sticky actions.
class AppSheetScaffold extends StatelessWidget {
  final AppSheetHeader? header;
  final List<Widget> children;
  final Widget? actions;
  final EdgeInsetsGeometry? contentPadding;

  const AppSheetScaffold({
    super.key,
    this.header,
    required this.children,
    this.actions,
    this.contentPadding,
  });

  @override
  Widget build(BuildContext context) {
    final scroll = PrimaryScrollController.maybeOf(context);
    // Sticky [actions] already own SafeArea — avoid double bottom inset.
    final padding = contentPadding ??
        (actions != null
            ? const EdgeInsets.fromLTRB(16, 0, 16, 16)
            : appModalScrollPadding(context));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: ListView(
            // Only attach when the modal host provided a primary controller.
            // Avoid stealing Scaffold's primary controller in nested hosts/tests.
            controller: scroll,
            primary: scroll == null ? false : null,
            padding: padding,
            children: [
              if (header != null) ...[
                header!,
                const SizedBox(height: 16),
              ],
              ...children,
            ],
          ),
        ),
        ?actions,
      ],
    );
  }
}
