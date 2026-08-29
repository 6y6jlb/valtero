import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:valtero/features/data_sync/model/backup_crypto.dart';
import 'package:valtero/features/data_sync/model/backup_format.dart';
import 'package:valtero/features/data_sync/model/data_sync_controller.dart';
import 'package:valtero/features/data_sync/model/passphrase_generator.dart';
import 'package:valtero/shared/l10n/generated/app_localizations.dart';
import 'package:valtero/widgets/app_toast.dart';

enum DataSyncTab { export, import }

bool get _isShareSupported =>
    Platform.isAndroid ||
    Platform.isIOS ||
    Platform.isWindows ||
    Platform.isMacOS;

class DataSyncPanel extends ConsumerStatefulWidget {
  final DataSyncTab initialTab;

  const DataSyncPanel({super.key, this.initialTab = DataSyncTab.export});

  @override
  ConsumerState<DataSyncPanel> createState() => _DataSyncPanelState();
}

class _DataSyncPanelState extends ConsumerState<DataSyncPanel> {
  late DataSyncTab _tab;
  final _exportPassphrase = TextEditingController();
  final _importPassphrase = TextEditingController();
  String? _pickedPath;
  bool _applySettings = false;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _tab = widget.initialTab;
  }

  @override
  void dispose() {
    _exportPassphrase.dispose();
    _importPassphrase.dispose();
    super.dispose();
  }

  Future<void> _generatePassphrase() async {
    setState(() => _exportPassphrase.text = generatePassphrase());
  }

  Future<void> _copyPassphrase() async {
    final text = _exportPassphrase.text.trim();
    if (text.isEmpty) return;
    await Clipboard.setData(ClipboardData(text: text));
    if (!mounted) return;
    showAppToast(context, AppLocalizations.of(context)!.copiedToClipboard);
  }

  Future<void> _exportSave() async {
    final l10n = AppLocalizations.of(context)!;
    final passphrase = _exportPassphrase.text.trim();
    if (passphrase.isEmpty) {
      showAppToast(context, l10n.dataSyncPassphrase);
      return;
    }
    setState(() => _busy = true);
    try {
      final path = await ref
          .read(dataSyncControllerProvider)
          .exportToSaveDialog(passphrase: passphrase);
      if (!mounted || path == null) return;
      showAppToast(context, l10n.dataSyncExportDone);
    } catch (_) {
      if (!mounted) return;
      showAppToast(context, l10n.dataSyncUnsupportedFormat);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _exportShare() async {
    final l10n = AppLocalizations.of(context)!;
    if (!_isShareSupported) {
      await showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          content: Text(l10n.shareUnsupported),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(l10n.dismiss),
            ),
          ],
        ),
      );
      return;
    }
    final passphrase = _exportPassphrase.text.trim();
    if (passphrase.isEmpty) {
      showAppToast(context, l10n.dataSyncPassphrase);
      return;
    }
    setState(() => _busy = true);
    try {
      await ref
          .read(dataSyncControllerProvider)
          .exportShare(passphrase: passphrase);
      if (!mounted) return;
      showAppToast(context, l10n.dataSyncExportDone);
    } catch (_) {
      if (!mounted) return;
      await showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          content: Text(l10n.shareFailed),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(l10n.dismiss),
            ),
          ],
        ),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _pickFile() async {
    final path =
        await ref.read(dataSyncControllerProvider).pickBackupFilePath();
    if (!mounted || path == null) return;
    setState(() => _pickedPath = path);
  }

  Future<void> _import() async {
    final l10n = AppLocalizations.of(context)!;
    final passphrase = _importPassphrase.text.trim();
    final path = _pickedPath;
    if (path == null) {
      showAppToast(context, l10n.dataSyncImport);
      return;
    }
    if (passphrase.isEmpty) {
      showAppToast(context, l10n.dataSyncPassphrase);
      return;
    }
    setState(() => _busy = true);
    try {
      final report = await ref.read(dataSyncControllerProvider).importFromPath(
            path: path,
            passphrase: passphrase,
            applySettings: _applySettings,
          );
      if (!mounted) return;
      showAppToast(
        context,
        l10n.dataSyncImportDone(
          report.expensesAdded,
          report.tagsAdded,
          report.paymentsAdded,
        ),
      );
      Navigator.of(context).maybePop();
    } on BackupWrongPassphraseException {
      if (!mounted) return;
      showAppToast(context, l10n.dataSyncWrongPassphrase);
    } on BackupNewerSchemaException {
      if (!mounted) return;
      showAppToast(context, l10n.dataSyncNewerSchema);
    } on BackupUnsupportedFormatException {
      if (!mounted) return;
      showAppToast(context, l10n.dataSyncUnsupportedFormat);
    } on BackupCryptoException {
      if (!mounted) return;
      showAppToast(context, l10n.dataSyncUnsupportedFormat);
    } catch (_) {
      if (!mounted) return;
      showAppToast(context, l10n.dataSyncUnsupportedFormat);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final scrollController = PrimaryScrollController.maybeOf(context);

    return ListView(
      controller: scrollController,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      children: [
        Text(l10n.dataSyncTitle, style: theme.textTheme.titleLarge),
        const SizedBox(height: 16),
        SegmentedButton<DataSyncTab>(
          segments: [
            ButtonSegment(
              value: DataSyncTab.export,
              label: Text(l10n.dataSyncExport),
            ),
            ButtonSegment(
              value: DataSyncTab.import,
              label: Text(l10n.dataSyncImport),
            ),
          ],
          selected: {_tab},
          onSelectionChanged: _busy
              ? null
              : (s) => setState(() => _tab = s.first),
        ),
        const SizedBox(height: 16),
        Text(
          l10n.dataSyncPassphraseWarning,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          l10n.dataSyncIntegrationsNotTransferred,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 16),
        if (_tab == DataSyncTab.export) ...[
          TextField(
            controller: _exportPassphrase,
            decoration: InputDecoration(
              labelText: l10n.dataSyncPassphrase,
            ),
            obscureText: true,
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              OutlinedButton(
                onPressed: _busy ? null : _generatePassphrase,
                child: Text(l10n.dataSyncGeneratePassphrase),
              ),
              OutlinedButton(
                onPressed: _busy ? null : _copyPassphrase,
                child: Text(l10n.dataSyncCopyPassphrase),
              ),
            ],
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: _busy ? null : _exportSave,
            child: Text(l10n.saveFile),
          ),
          const SizedBox(height: 8),
          OutlinedButton(
            onPressed: _busy ? null : _exportShare,
            child: Text(l10n.share),
          ),
        ] else ...[
          OutlinedButton(
            onPressed: _busy ? null : _pickFile,
            child: Text(
              _pickedPath == null ? l10n.dataSyncImport : _pickedPath!,
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _importPassphrase,
            decoration: InputDecoration(
              labelText: l10n.dataSyncPassphrase,
            ),
            obscureText: true,
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(l10n.settingsAppearance),
            value: _applySettings,
            onChanged:
                _busy ? null : (v) => setState(() => _applySettings = v),
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: _busy ? null : _import,
            child: Text(l10n.dataSyncImport),
          ),
        ],
      ],
    );
  }
}
