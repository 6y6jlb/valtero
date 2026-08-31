import 'package:flutter/material.dart';
import 'package:valtero/widgets/app_modal_sheet.dart';

/// One-of-many pick in a bottom sheet (replaces inline dropdowns).
Future<T?> showSingleChoiceSheet<T>({
  required BuildContext context,
  required String title,
  required List<({T value, String label})> options,
  required T selected,
  double initialChildSize = 0.45,
  double minChildSize = 0.3,
  double maxChildSize = 0.85,
}) {
  return showAppModalSheet<T>(
    context: context,
    initialChildSize: initialChildSize,
    minChildSize: minChildSize,
    maxChildSize: maxChildSize,
    child: _SingleChoiceSheetBody<T>(
      title: title,
      options: options,
      selected: selected,
    ),
  );
}

class _SingleChoiceSheetBody<T> extends StatelessWidget {
  final String title;
  final List<({T value, String label})> options;
  final T selected;

  const _SingleChoiceSheetBody({
    required this.title,
    required this.options,
    required this.selected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListView(
      padding: appModalScrollPadding(context),
      children: [
        Text(
          title,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        for (final option in options)
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(option.label),
            trailing: option.value == selected
                ? Icon(Icons.check, color: theme.colorScheme.primary)
                : null,
            onTap: () => Navigator.pop(context, option.value),
          ),
      ],
    );
  }
}
