import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:valtero/entities/integrations/model/integration_registry.dart';
import 'package:valtero/entities/integrations/telegram/model/telegram_integration.dart';
import 'package:valtero/features/export_expenses/data/expense_exporter.dart';
import 'package:valtero/features/export_expenses/model/export_destination.dart';
import 'package:valtero/features/export_expenses/model/export_readiness.dart';
import 'package:valtero/features/export_expenses/ui/export_panel.dart';
import 'package:valtero/features/integrations/ui/integration_config_modal.dart';
import 'package:valtero/shared/l10n/generated/app_localizations.dart';
import 'package:valtero/widgets/app_modal_sheet.dart';
import 'package:valtero/widgets/app_toast.dart';

Future<void> showExportSheet(BuildContext context) {
  return showAppModalSheet(
    context: context,
    child: const ExportPanel(),
  );
}

/// Ensures destination can run: opens Telegram integration sheet or shows alert.
Future<bool> ensureExportDestinationReady(
  BuildContext context,
  WidgetRef ref, {
  required ExportDestination destination,
  bool allowSetupSheet = true,
}) async {
  final l10n = AppLocalizations.of(context)!;
  switch (destination) {
    case ExportDestination.copy:
    case ExportDestination.save:
      return true;
    case ExportDestination.share:
      if (isExportShareSupported) return true;
      await showExportUnsupportedDialog(context, l10n.shareUnsupported);
      return false;
    case ExportDestination.telegram:
      if (ref.read(isIntegrationConfiguredProvider(kTelegramIntegrationId))) {
        return true;
      }
      if (!allowSetupSheet) {
        showAppToast(context, l10n.telegramNotConnectedHint);
        return false;
      }
      await showIntegrationConfigSheet(
        context,
        integration: ref.read(telegramIntegrationProvider),
      );
      if (!context.mounted) return false;
      return ref.read(isIntegrationConfiguredProvider(kTelegramIntegrationId));
  }
}

Future<void> performExport(
  BuildContext context,
  WidgetRef ref, {
  required ExportFormat format,
  required ExportDestination destination,
  Future<String?> Function()? run,
  bool allowSetupSheet = true,
}) async {
  final ready = await ensureExportDestinationReady(
    context,
    ref,
    destination: destination,
    allowSetupSheet: allowSetupSheet,
  );
  if (!ready || !context.mounted) return;

  final l10n = AppLocalizations.of(context)!;
  try {
    final String? message;
    if (run != null) {
      message = await run();
    } else {
      if (!context.mounted) return;
      message = await runExportDestination(
        ref,
        context,
        format: format,
        destination: destination,
      );
    }
    if (!context.mounted || message == null) return;
    showAppToast(context, message);
  } on StateError catch (e) {
    if (!context.mounted) return;
    if (e.message == 'telegram_not_configured') {
      if (allowSetupSheet) {
        await showIntegrationConfigSheet(
          context,
          integration: ref.read(telegramIntegrationProvider),
        );
      } else {
        showAppToast(context, l10n.telegramNotConnectedHint);
      }
      return;
    }
    if (destination == ExportDestination.telegram) {
      showAppToast(context, l10n.telegramFailed);
    } else if (destination == ExportDestination.share) {
      await showExportUnsupportedDialog(context, l10n.shareUnsupported);
    }
  } catch (_) {
    if (!context.mounted) return;
    if (destination == ExportDestination.telegram) {
      showAppToast(context, l10n.telegramFailed);
    } else if (destination == ExportDestination.share) {
      await showExportUnsupportedDialog(context, l10n.shareFailed);
    }
  }
}
