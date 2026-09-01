import 'package:flutter/material.dart';

/// Sticky centered action bar for modal sheets (safe area + keyboard-friendly).
///
/// Full-width strip with top corner radius, tinted above the sheet body.
class AppSheetActionsBar extends StatelessWidget {
  final List<Widget> children;

  const AppSheetActionsBar({
    super.key,
    required this.children,
  });

  static const _topRadius = 16.0;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Material(
      color: scheme.surfaceContainerHigh,
      elevation: 0,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(_topRadius),
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
          child: SizedBox(
            width: double.infinity,
            child: Wrap(
              alignment: WrapAlignment.center,
              spacing: 12,
              runSpacing: 8,
              children: children,
            ),
          ),
        ),
      ),
    );
  }
}
