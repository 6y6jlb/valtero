import 'package:flutter/material.dart';
import 'package:valtero/widgets/app_modal_sheet.dart';
import 'package:valtero/widgets/app_ok_button.dart';
import 'package:valtero/widgets/app_sheet_actions_bar.dart';
import 'package:valtero/widgets/app_sheet_header.dart';
import 'package:valtero/widgets/app_sheet_scaffold.dart';

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
    child: AppSheetScaffold(
      header: AppSheetHeader(
        title: title,
        description: body,
      ),
      actions: const AppSheetActionsBar(
        children: [AppOkButton()],
      ),
      children: const [],
    ),
  );
}
