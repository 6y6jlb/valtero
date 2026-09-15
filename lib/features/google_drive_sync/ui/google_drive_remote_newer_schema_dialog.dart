import 'package:flutter/material.dart';
import 'package:valtero/shared/l10n/generated/app_localizations.dart';
import 'package:valtero/widgets/app_ok_button.dart';

/// Blocking alert when cloud sync data requires a newer app (schema gate).
Future<void> showGoogleDriveRemoteNewerSchemaDialog(
  BuildContext context, {
  required String message,
}) {
  final l10n = AppLocalizations.of(context)!;
  return showDialog<void>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(l10n.googleDriveRemoteNewerSchemaTitle),
      content: SingleChildScrollView(child: Text(message)),
      actions: [const AppOkButton()],
    ),
  );
}
