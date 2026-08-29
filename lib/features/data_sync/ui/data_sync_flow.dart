import 'package:flutter/material.dart';
import 'package:valtero/features/data_sync/ui/data_sync_panel.dart';
import 'package:valtero/widgets/app_modal_sheet.dart';

/// Opens the backup/sync sheet (Export + Import tabs).
Future<void> showDataSyncSheet(
  BuildContext context, {
  DataSyncTab initialTab = DataSyncTab.export,
}) {
  return showAppModalSheet(
    context: context,
    initialChildSize: 0.8,
    minChildSize: 0.45,
    child: DataSyncPanel(initialTab: initialTab),
  );
}

/// Import-only entry (e.g. empty dashboard restore).
Future<void> showDataSyncImportFlow(BuildContext context) {
  return showDataSyncSheet(context, initialTab: DataSyncTab.import);
}
