import 'package:flutter/material.dart';
import 'package:valtero/widgets/app_modal_sheet.dart';

Future<void> showFeatureHelpSheet(
  BuildContext context, {
  required String title,
  required String body,
}) {
  return showAppModalSheet<void>(
    context: context,
    initialChildSize: 0.45,
    minChildSize: 0.3,
    maxChildSize: 0.75,
    child: ListView(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 12),
        Text(
          body,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                height: 1.45,
              ),
        ),
        const SizedBox(height: 16),
        Align(
          alignment: Alignment.centerRight,
          child: FilledButton(
            onPressed: () => Navigator.pop(context),
            child: Text(MaterialLocalizations.of(context).okButtonLabel),
          ),
        ),
      ],
    ),
  );
}
