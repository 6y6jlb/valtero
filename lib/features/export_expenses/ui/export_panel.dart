import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:valtero/entities/integrations/model/integration_registry.dart';
import 'package:valtero/entities/integrations/telegram/model/telegram_integration.dart';
import 'package:valtero/features/export_expenses/data/expense_exporter.dart';
import 'package:valtero/features/export_expenses/model/export_destination.dart';
import 'package:valtero/features/export_expenses/model/export_readiness.dart';
import 'package:valtero/features/integrations/ui/integration_config_modal.dart';
import 'package:valtero/shared/l10n/generated/app_localizations.dart';
import 'package:valtero/widgets/app_button.dart';
import 'package:valtero/widgets/app_close_icon_button.dart';
import 'package:valtero/widgets/app_sheet_actions_bar.dart';
import 'package:valtero/widgets/app_sheet_header.dart';
import 'package:valtero/widgets/app_sheet_scaffold.dart';
import 'package:valtero/widgets/app_toast.dart';

class ExportPanel extends ConsumerStatefulWidget {
  const ExportPanel({super.key});

  @override
  ConsumerState<ExportPanel> createState() => _ExportPanelState();
}

class _ExportPanelState extends ConsumerState<ExportPanel> {
  ExportFormat _format = ExportFormat.csv;

  Future<void> _run(ExportDestination destination) async {
    final l10n = AppLocalizations.of(context)!;
    if (destination == ExportDestination.share && !isExportShareSupported) {
      await showExportUnsupportedDialog(context, l10n.shareUnsupported);
      return;
    }
    if (destination == ExportDestination.telegram &&
        !ref.read(isIntegrationConfiguredProvider(kTelegramIntegrationId))) {
      showAppToast(context, l10n.telegramNotConnectedHint);
      return;
    }

    try {
      final message = await runExportDestination(
        ref,
        context,
        format: _format,
        destination: destination,
      );
      if (!mounted || message == null) return;
      showAppToast(context, message);
    } catch (_) {
      if (!mounted) return;
      if (destination == ExportDestination.telegram) {
        showAppToast(context, l10n.telegramFailed);
      } else if (destination == ExportDestination.share) {
        await showExportUnsupportedDialog(context, l10n.shareFailed);
      }
    }
  }

  Future<void> _openTelegramSettings() async {
    final integration = ref.read(telegramIntegrationProvider);
    await showIntegrationConfigSheet(context, integration: integration);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final telegramConnected =
        ref.watch(isIntegrationConfiguredProvider(kTelegramIntegrationId));
    final theme = Theme.of(context);

    return AppSheetScaffold(
      header: AppSheetHeader(title: l10n.settingsExport),
      actions: AppSheetActionsBar(
        children: [
          const AppCloseIconButton(),
          AppFilledButton(
            label: l10n.saveFile,
            icon: Icons.check,
            onPressed: () => _run(ExportDestination.save),
          ),
        ],
      ),
      children: [
        SegmentedButton<ExportFormat>(
          segments: [
            ButtonSegment(value: ExportFormat.csv, label: Text(l10n.exportCsv)),
            ButtonSegment(value: ExportFormat.json, label: Text(l10n.exportJson)),
          ],
          selected: {_format},
          onSelectionChanged: (s) => setState(() => _format = s.first),
        ),
        const SizedBox(height: 16),
        if (isExportShareSupported) ...[
          AppOutlinedButton(
            onPressed: () => _run(ExportDestination.share),
            label: l10n.share,
            icon: Icons.share_outlined,
          ),
          const SizedBox(height: 8),
        ],
        AppOutlinedButton(
          onPressed: () => _run(ExportDestination.copy),
          label:
              '${l10n.copyAs} ${_format == ExportFormat.csv ? l10n.exportCsv : l10n.exportJson}',
          icon: Icons.copy_outlined,
        ),
        const SizedBox(height: 24),
        Text(l10n.integrationTelegramTitle, style: theme.textTheme.titleMedium),
        const SizedBox(height: 8),
        if (telegramConnected) ...[
          AppFilledButton.tonal(
            onPressed: () => _run(ExportDestination.telegram),
            label: l10n.sendTelegram,
            icon: Icons.send_outlined,
          ),
        ] else ...[
          Text(
            l10n.telegramNotConnectedHint,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          AppOutlinedButton(
            onPressed: _openTelegramSettings,
            label: l10n.openTelegramIntegration,
            icon: Icons.settings_outlined,
          ),
        ],
      ],
    );
  }
}
