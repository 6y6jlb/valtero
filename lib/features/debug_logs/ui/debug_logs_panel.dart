import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:valtero/features/debug_logs/model/debug_logs_controller.dart';
import 'package:valtero/shared/consts/developer_contact.dart';
import 'package:valtero/shared/l10n/generated/app_localizations.dart';
import 'package:valtero/shared/settings/app_settings_provider.dart';
import 'package:valtero/widgets/app_button.dart';
import 'package:valtero/widgets/app_modal_sheet.dart';
import 'package:valtero/widgets/app_sheet_header.dart';
import 'package:valtero/widgets/app_sheet_scaffold.dart';
import 'package:valtero/widgets/app_toast.dart';

Future<void> showDebugLogsSheet(BuildContext context) {
  return showAppModalSheet(
    context: context,
    initialChildSize: 0.85,
    child: const DebugLogsPanel(),
  );
}

class DebugLogsPanel extends ConsumerStatefulWidget {
  const DebugLogsPanel({super.key});

  @override
  ConsumerState<DebugLogsPanel> createState() => _DebugLogsPanelState();
}

class _DebugLogsPanelState extends ConsumerState<DebugLogsPanel> {
  String _logText = '';
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _reload());
  }

  Future<void> _reload() async {
    setState(() => _loading = true);
    final text = await ref.read(debugLogsControllerProvider).readLogs();
    if (!mounted) return;
    setState(() {
      _logText = text;
      _loading = false;
    });
  }

  Future<void> _share() async {
    final l10n = AppLocalizations.of(context)!;
    final result =
        await ref.read(debugLogsControllerProvider).shareOrCopyLogs();
    if (!mounted) return;
    if (result == null) {
      showAppToast(context, l10n.debugLogsEmpty);
    } else if (result == 'shared') {
      showAppToast(context, l10n.debugLogsShared);
    } else {
      showAppToast(context, l10n.debugLogsCopied);
    }
  }

  Future<void> _copy() async {
    final l10n = AppLocalizations.of(context)!;
    final text = await ref.read(debugLogsControllerProvider).readLogs();
    if (!mounted) return;
    if (text.trim().isEmpty) {
      showAppToast(context, l10n.debugLogsEmpty);
      return;
    }
    await ref.read(debugLogsControllerProvider).copyLogs();
    if (!mounted) return;
    showAppToast(context, l10n.debugLogsCopied);
  }

  Future<void> _clear() async {
    final l10n = AppLocalizations.of(context)!;
    await ref.read(debugLogsControllerProvider).clearLogs();
    if (!mounted) return;
    showAppToast(context, l10n.debugLogsCleared);
    await _reload();
  }

  Future<void> _copyDeveloperEmail() async {
    final l10n = AppLocalizations.of(context)!;
    await Clipboard.setData(
      const ClipboardData(text: DeveloperContact.email),
    );
    if (!mounted) return;
    showAppToast(context, l10n.copiedToClipboard);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final settings = ref.watch(appSettingsProvider).value;
    final display = _logText.trim().isEmpty
        ? l10n.debugLogsEmpty
        : _logText.split('\n').reversed.where((l) => l.isNotEmpty).join('\n');

    return AppSheetScaffold(
      header: AppSheetHeader(
        title: l10n.settingsDebug,
        description: l10n.debugLoggingDescription,
      ),
      children: [
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(l10n.debugLoggingEnabled),
          value: settings?.debugLoggingEnabled ?? false,
          onChanged: (v) {
            ref.read(appSettingsProvider.notifier).setDebugLoggingEnabled(v);
          },
        ),
        const SizedBox(height: 8),
        Text(
          l10n.debugLogsSendHint(DeveloperContact.email),
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerLeft,
          child: AppOutlinedButton(
            label: l10n.contactDeveloperCopyEmail,
            icon: Icons.copy_outlined,
            onPressed: _copyDeveloperEmail,
          ),
        ),
        const SizedBox(height: 16),
        Text(l10n.debugViewLogs, style: theme.textTheme.titleMedium),
        const SizedBox(height: 8),
        Container(
          constraints: const BoxConstraints(minHeight: 180, maxHeight: 320),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(12),
          ),
          child: _loading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                  child: SelectableText(
                    display,
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontFamily: 'monospace',
                    ),
                  ),
                ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            IconButton.filledTonal(
              onPressed: _reload,
              icon: const Icon(Icons.refresh),
            ),
            AppFilledButton(
              onPressed: _share,
              label: l10n.debugShareLogs,
              icon: Icons.share_outlined,
            ),
            AppOutlinedButton(
              onPressed: _copy,
              label: l10n.debugCopyLogs,
              icon: Icons.copy_outlined,
            ),
            AppOutlinedButton(
              onPressed: _clear,
              label: l10n.debugClearLogs,
              icon: Icons.delete_outline,
              destructive: true,
            ),
          ],
        ),
      ],
    );
  }
}
