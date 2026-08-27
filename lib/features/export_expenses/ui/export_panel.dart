import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:valtero/features/export_expenses/data/expense_exporter.dart';
import 'package:valtero/features/export_expenses/model/export_controller.dart';
import 'package:valtero/features/export_expenses/model/export_destination.dart';
import 'package:valtero/shared/l10n/generated/app_localizations.dart';
import 'package:valtero/shared/settings/app_settings_provider.dart';
import 'package:valtero/widgets/app_modal_sheet.dart';
import 'package:valtero/widgets/app_toast.dart';

Future<void> showExportSheet(BuildContext context) {
  return showAppModalSheet(
    context: context,
    child: const ExportPanel(),
  );
}

Future<String?> runExportDestination(
  WidgetRef ref,
  BuildContext context, {
  required ExportFormat format,
  required ExportDestination destination,
}) async {
  final controller = ref.read(exportControllerProvider);
  final l10n = AppLocalizations.of(context)!;
  switch (destination) {
    case ExportDestination.save:
      final path = await controller.saveFile(format);
      return path == null ? null : l10n.exportDone;
    case ExportDestination.share:
      await controller.share(format);
      return l10n.exportDone;
    case ExportDestination.copy:
      await controller.copy(format);
      return l10n.copiedToClipboard;
    case ExportDestination.telegram:
      await controller.sendTelegram(format);
      return l10n.telegramSent;
  }
}

class ExportPanel extends ConsumerStatefulWidget {
  const ExportPanel({super.key});

  @override
  ConsumerState<ExportPanel> createState() => _ExportPanelState();
}

class _ExportPanelState extends ConsumerState<ExportPanel> {
  ExportFormat _format = ExportFormat.csv;
  final _tokenController = TextEditingController();
  final _chatController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final s = ref.read(appSettingsProvider).value;
      if (s != null) {
        _tokenController.text = s.telegramBotToken;
        _chatController.text = s.telegramChatId;
      }
    });
  }

  @override
  void dispose() {
    _tokenController.dispose();
    _chatController.dispose();
    super.dispose();
  }

  Future<void> _run(ExportDestination destination) async {
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
        showAppToast(context, AppLocalizations.of(context)!.telegramFailed);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final settings = ref.watch(appSettingsProvider).value;
    final scrollController = PrimaryScrollController.maybeOf(context);

    return ListView(
      controller: scrollController,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      children: [
        Text(l10n.settingsExport, style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 16),
        SegmentedButton<ExportFormat>(
          segments: [
            ButtonSegment(value: ExportFormat.csv, label: Text(l10n.exportCsv)),
            ButtonSegment(value: ExportFormat.json, label: Text(l10n.exportJson)),
          ],
          selected: {_format},
          onSelectionChanged: (s) => setState(() => _format = s.first),
        ),
        const SizedBox(height: 16),
        FilledButton(
          onPressed: () => _run(ExportDestination.save),
          child: Text(l10n.saveFile),
        ),
        const SizedBox(height: 8),
        OutlinedButton(
          onPressed: () => _run(ExportDestination.share),
          child: Text(l10n.share),
        ),
        const SizedBox(height: 8),
        OutlinedButton(
          onPressed: () => _run(ExportDestination.copy),
          child: Text('${l10n.copyAs} ${_format == ExportFormat.csv ? l10n.exportCsv : l10n.exportJson}'),
        ),
        const SizedBox(height: 24),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(l10n.telegramEnabled),
          value: settings?.telegramEnabled ?? false,
          onChanged: (v) {
            ref.read(appSettingsProvider.notifier).setTelegram(enabled: v);
          },
        ),
        TextField(
          controller: _tokenController,
          decoration: InputDecoration(labelText: l10n.telegramBotToken),
          obscureText: true,
          onChanged: (v) {
            ref.read(appSettingsProvider.notifier).setTelegram(botToken: v);
          },
        ),
        TextField(
          controller: _chatController,
          decoration: InputDecoration(labelText: l10n.telegramChatId),
          onChanged: (v) {
            ref.read(appSettingsProvider.notifier).setTelegram(chatId: v);
          },
        ),
        const SizedBox(height: 8),
        FilledButton.tonal(
          onPressed: () => _run(ExportDestination.telegram),
          child: Text(l10n.sendTelegram),
        ),
      ],
    );
  }
}
