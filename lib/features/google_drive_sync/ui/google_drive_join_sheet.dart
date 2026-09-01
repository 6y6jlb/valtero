import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:valtero/entities/integrations/google_drive_sync/model/google_drive_rest_client.dart';
import 'package:valtero/features/google_drive_sync/model/google_drive_sync_engine.dart';
import 'package:valtero/shared/l10n/generated/app_localizations.dart';
import 'package:valtero/widgets/app_button.dart';
import 'package:valtero/widgets/app_close_icon_button.dart';
import 'package:valtero/widgets/app_modal_sheet.dart';
import 'package:valtero/widgets/app_sheet_actions_bar.dart';
import 'package:valtero/widgets/app_sheet_header.dart';
import 'package:valtero/widgets/app_sheet_scaffold.dart';
import 'package:valtero/widgets/passphrase_text_field.dart';

/// Discovers shared sync files and lets the user join one with a passphrase.
Future<GoogleDriveSyncResult?> showJoinSharedSyncSheet(BuildContext context) {
  return showAppModalSheet<GoogleDriveSyncResult>(
    context: context,
    initialChildSize: 0.85,
    child: const _JoinSharedSyncBody(),
  );
}

class _JoinSharedSyncBody extends ConsumerStatefulWidget {
  const _JoinSharedSyncBody();

  @override
  ConsumerState<_JoinSharedSyncBody> createState() =>
      _JoinSharedSyncBodyState();
}

class _JoinSharedSyncBodyState extends ConsumerState<_JoinSharedSyncBody> {
  final _passphraseController = TextEditingController();
  bool _loading = true;
  bool _joining = false;
  String? _error;
  List<GoogleDriveFileMeta> _files = const [];
  GoogleDriveFileMeta? _selected;

  @override
  void initState() {
    super.initState();
    _passphraseController.addListener(() => setState(() {}));
    WidgetsBinding.instance.addPostFrameCallback((_) => _discover());
  }

  @override
  void dispose() {
    _passphraseController.dispose();
    super.dispose();
  }

  Future<void> _discover() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final files = await ref
          .read(googleDriveSyncEngineProvider)
          .discoverSharedSyncFiles();
      if (!mounted) return;
      setState(() {
        _files = files;
        _loading = false;
        if (files.length == 1) _selected = files.first;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = e.toString();
      });
    }
  }

  Future<void> _join() async {
    final selected = _selected;
    if (selected == null) return;
    final phrase = _passphraseController.text.trim();
    if (phrase.length < 8) return;
    setState(() => _joining = true);
    final result = await ref
        .read(googleDriveSyncEngineProvider)
        .joinSharedSync(fileId: selected.id, passphrase: phrase);
    if (!mounted) return;
    setState(() => _joining = false);
    Navigator.of(context).pop(result);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return AppSheetScaffold(
      header: AppSheetHeader(title: l10n.googleDriveJoinPickTitle),
      actions: AppSheetActionsBar(
        children: [
          const AppCloseIconButton(),
          AppFilledButton(
            onPressed:
                _joining ||
                    _selected == null ||
                    _passphraseController.text.trim().length < 8
                ? null
                : _join,
            busy: _joining,
            icon: Icons.check,
            label: l10n.googleDriveJoinConfirm,
          ),
        ],
      ),
      children: [
        if (_loading)
          const Padding(
            padding: EdgeInsets.all(24),
            child: Center(child: CircularProgressIndicator()),
          )
        else if (_error != null)
          Text(
            _error!,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.error,
            ),
          )
        else if (_files.isEmpty)
          Text(l10n.googleDriveJoinPickEmpty)
        else ...[
          for (final file in _files)
            RadioListTile<String>(
              value: file.id,
              // ignore: deprecated_member_use
              groupValue: _selected?.id,
              // ignore: deprecated_member_use
              onChanged: _joining
                  ? null
                  : (id) {
                      setState(() {
                        _selected = _files.firstWhere((f) => f.id == id);
                      });
                    },
              title: Text(
                file.ownerEmail != null && file.ownerEmail!.isNotEmpty
                    ? l10n.googleDriveSharedFrom(file.ownerEmail!)
                    : file.name,
              ),
              subtitle: file.modifiedTime != null
                  ? Text(file.modifiedTime!.toLocal().toString())
                  : null,
            ),
          const SizedBox(height: 12),
          PassphraseTextField(
            controller: _passphraseController,
            labelText: l10n.googleDriveSyncPassphrase,
            helperText: l10n.googleDriveSyncPassphraseHint,
            enabled: !_joining,
            showGenerate: false,
            showCopy: false,
          ),
        ],
      ],
    );
  }
}
