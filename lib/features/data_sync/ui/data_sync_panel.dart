import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:valtero/features/data_sync/model/backup_crypto.dart';
import 'package:valtero/features/data_sync/model/backup_format.dart';
import 'package:valtero/features/data_sync/model/data_sync_controller.dart';
import 'package:valtero/features/data_sync/model/passphrase_generator.dart';
import 'package:valtero/features/data_sync/ui/data_sync_passphrase_field.dart';
import 'package:valtero/shared/l10n/generated/app_localizations.dart';
import 'package:valtero/shared/logging/logging_providers.dart';
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
  String? _exportedPath;
  bool _applySettings = false;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _tab = widget.initialTab;
    _exportPassphrase.text = generatePassphrase();
    _exportPassphrase.addListener(_onExportPassphraseChanged);
  }

  void _onExportPassphraseChanged() {
    if (_exportedPath == null) return;
    setState(() => _exportedPath = null);
  }

  @override
  void dispose() {
    _exportPassphrase.removeListener(_onExportPassphraseChanged);
    _exportPassphrase.dispose();
    _importPassphrase.dispose();
    super.dispose();
  }

  Future<void> _generatePassphrase() async {
    setState(() {
      _exportedPath = null;
      _exportPassphrase.text = generatePassphrase();
    });
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
      setState(() => _exportedPath = path);
      showAppToast(context, l10n.dataSyncExportDone);
    } catch (e, st) {
      // ignore: unawaited_futures
      ref.read(appLoggerProvider).error(
            'Backup export failed',
            error: e,
            stackTrace: st,
          );
      if (!mounted) return;
      showAppToast(context, l10n.dataSyncExportFailed);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _exportShare() async {
    final l10n = AppLocalizations.of(context)!;
    final path = _exportedPath;
    if (path == null) return;
    if (!_isShareSupported) {
      await _showShareManualGuide(path);
      return;
    }
    setState(() => _busy = true);
    try {
      await ref.read(dataSyncControllerProvider).shareBackupFile(path);
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

  Future<void> _showShareManualGuide(String path) async {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.dataSyncShareManualTitle),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(l10n.dataSyncShareManualGuide),
              const SizedBox(height: 16),
              Text(
                path,
                style: theme.textTheme.bodySmall?.copyWith(
                  fontFamily: 'monospace',
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () async {
              await Clipboard.setData(ClipboardData(text: path));
              if (!context.mounted) return;
              showAppToast(context, l10n.copiedToClipboard);
            },
            child: Text(l10n.dataSyncCopyFilePath),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.dismiss),
          ),
        ],
      ),
    );
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
      showAppToast(context, l10n.dataSyncChooseFile);
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
    } catch (e, st) {
      // ignore: unawaited_futures
      ref.read(appLoggerProvider).error(
            'Backup import failed',
            error: e,
            stackTrace: st,
          );
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
    final fileSelected = _pickedPath != null;
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    return ListView(
      controller: scrollController,
      padding: EdgeInsets.fromLTRB(16, 0, 16, 32 + bottomInset),
      children: [
        Text(l10n.dataSyncTitle, style: theme.textTheme.titleLarge),
        const SizedBox(height: 12),
        Card(
          margin: EdgeInsets.zero,
          color: theme.colorScheme.surfaceContainerHighest.withValues(
            alpha: 0.5,
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.info_outline,
                  size: 20,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    l10n.dataSyncGuide,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
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
          DataSyncPassphraseField(
            controller: _exportPassphrase,
            enabled: !_busy,
            showGenerate: true,
            showCopy: true,
            initiallyObscured: false,
            onGenerate: _generatePassphrase,
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: FilledButton(
                  onPressed: _busy ? null : _exportSave,
                  child: Text(l10n.saveFile),
                ),
              ),
              const SizedBox(width: 8),
              IconButton.filledTonal(
                tooltip: l10n.share,
                onPressed:
                    (_busy || _exportedPath == null) ? null : _exportShare,
                icon: const Icon(Icons.share_outlined),
              ),
            ],
          ),
        ] else ...[
          DataSyncPassphraseField(
            controller: _importPassphrase,
            enabled: !_busy,
            showCopy: false,
          ),
          const SizedBox(height: 8),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(l10n.dataSyncApplyAppearance),
            subtitle: Text(l10n.dataSyncApplyAppearanceHint),
            value: _applySettings,
            onChanged:
                _busy ? null : (v) => setState(() => _applySettings = v),
          ),
          const SizedBox(height: 16),
          Text(
            l10n.dataSyncImportMergeHint,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              IconButton.filledTonal(
                tooltip: fileSelected
                    ? '${l10n.dataSyncFileSelected}: ${p.basename(_pickedPath!)}'
                    : l10n.dataSyncChooseFile,
                onPressed: _busy ? null : _pickFile,
                style: fileSelected
                    ? IconButton.styleFrom(
                        foregroundColor: theme.colorScheme.primary,
                      )
                    : null,
                icon: Icon(
                  fileSelected
                      ? Icons.check_circle_outline
                      : Icons.attach_file,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: FilledButton(
                  onPressed: (_busy || !fileSelected) ? null : _import,
                  child: Text(l10n.dataSyncImportFromFile),
                ),
              ),
            ],
          ),
          if (fileSelected) ...[
            const SizedBox(height: 8),
            Text(
              p.basename(_pickedPath!),
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ],
    );
  }
}
