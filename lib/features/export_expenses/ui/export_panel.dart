import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:valtero/features/export_expenses/data/expense_exporter.dart';
import 'package:valtero/features/export_expenses/model/export_destination.dart';
import 'package:valtero/features/export_expenses/model/export_readiness.dart';
import 'package:valtero/shared/l10n/generated/app_localizations.dart';
import 'package:valtero/shared/settings/app_settings_provider.dart';
import 'package:valtero/widgets/app_toast.dart';

class ExportPanel extends ConsumerStatefulWidget {
  final bool highlightTelegram;

  const ExportPanel({super.key, this.highlightTelegram = false});

  @override
  ConsumerState<ExportPanel> createState() => _ExportPanelState();
}

class _ExportPanelState extends ConsumerState<ExportPanel> {
  ExportFormat _format = ExportFormat.csv;
  final _tokenController = TextEditingController();
  final _chatController = TextEditingController();
  final _telegramKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final s = ref.read(appSettingsProvider).value;
      if (s != null) {
        _tokenController.text = s.telegramBotToken;
        _chatController.text = s.telegramChatId;
      }
      if (widget.highlightTelegram) {
        final ctx = _telegramKey.currentContext;
        if (ctx != null) {
          Scrollable.ensureVisible(
            ctx,
            duration: const Duration(milliseconds: 250),
            alignment: 0.1,
          );
        }
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
    final l10n = AppLocalizations.of(context)!;
    if (destination == ExportDestination.share && !isExportShareSupported) {
      await showExportUnsupportedDialog(context, l10n.shareUnsupported);
      return;
    }
    if (destination == ExportDestination.telegram &&
        !isTelegramExportConfigured(ref.read(appSettingsProvider).value)) {
      showAppToast(context, l10n.telegramSetupNeeded);
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

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final settings = ref.watch(appSettingsProvider).value;
    final scrollController = PrimaryScrollController.maybeOf(context);
    final theme = Theme.of(context);

    return ListView(
      controller: scrollController,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      children: [
        Text(l10n.settingsExport, style: theme.textTheme.titleLarge),
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
        if (isExportShareSupported) ...[
          const SizedBox(height: 8),
          OutlinedButton(
            onPressed: () => _run(ExportDestination.share),
            child: Text(l10n.share),
          ),
        ],
        const SizedBox(height: 8),
        OutlinedButton(
          onPressed: () => _run(ExportDestination.copy),
          child: Text(
            '${l10n.copyAs} ${_format == ExportFormat.csv ? l10n.exportCsv : l10n.exportJson}',
          ),
        ),
        const SizedBox(height: 24),
        KeyedSubtree(
          key: _telegramKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (widget.highlightTelegram) ...[
                Material(
                  color: theme.colorScheme.secondaryContainer,
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Text(
                      l10n.telegramSetupNeeded,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSecondaryContainer,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
              ],
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
          ),
        ),
      ],
    );
  }
}
