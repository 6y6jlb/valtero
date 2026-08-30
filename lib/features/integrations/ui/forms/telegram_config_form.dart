import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:valtero/entities/integrations/model/integration_registry.dart';
import 'package:valtero/entities/integrations/telegram/model/telegram_integration.dart';
import 'package:valtero/features/integrations/model/integration_ui_meta.dart';
import 'package:valtero/shared/l10n/generated/app_localizations.dart';
import 'package:valtero/shared/settings/app_settings.dart';
import 'package:valtero/shared/settings/app_settings_provider.dart';
import 'package:valtero/widgets/app_toast.dart';

class TelegramConfigForm extends ConsumerStatefulWidget {
  const TelegramConfigForm({super.key});

  @override
  ConsumerState<TelegramConfigForm> createState() => _TelegramConfigFormState();
}

class _TelegramConfigFormState extends ConsumerState<TelegramConfigForm> {
  final _tokenController = TextEditingController();
  final _chatController = TextEditingController();
  bool _enabled = false;
  bool _testing = false;
  bool _saving = false;
  String? _status;
  bool _statusOk = false;
  String? _verifiedFingerprint;

  @override
  void initState() {
    super.initState();
    _tokenController.addListener(_onFieldsChanged);
    _chatController.addListener(_onFieldsChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final s = ref.read(appSettingsProvider).value;
      if (s == null) return;
      _tokenController.removeListener(_onFieldsChanged);
      _chatController.removeListener(_onFieldsChanged);
      _tokenController.text = s.telegramBotToken;
      _chatController.text = s.telegramChatId;
      _tokenController.addListener(_onFieldsChanged);
      _chatController.addListener(_onFieldsChanged);
      setState(() {
        _enabled = s.telegramEnabled;
        if (s.telegramEnabled &&
            s.telegramBotToken.trim().isNotEmpty &&
            s.telegramChatId.trim().isNotEmpty) {
          // Already connected — treat saved values as verified for Save.
          _verifiedFingerprint = _fingerprint(
            s.telegramBotToken,
            s.telegramChatId,
          );
          _statusOk = true;
        }
      });
    });
  }

  @override
  void dispose() {
    _tokenController.removeListener(_onFieldsChanged);
    _chatController.removeListener(_onFieldsChanged);
    _tokenController.dispose();
    _chatController.dispose();
    super.dispose();
  }

  void _onFieldsChanged() {
    final fp = _fingerprint(_tokenController.text, _chatController.text);
    setState(() {
      if (_verifiedFingerprint != null && _verifiedFingerprint != fp) {
        _verifiedFingerprint = null;
        _statusOk = false;
        _status = null;
      }
    });
  }

  String _fingerprint(String token, String chatId) =>
      '${token.trim()}|${chatId.trim()}';

  bool get _fieldsFilled =>
      _tokenController.text.trim().isNotEmpty &&
      _chatController.text.trim().isNotEmpty;

  bool get _draftVerified =>
      _fieldsFilled &&
      _verifiedFingerprint ==
          _fingerprint(_tokenController.text, _chatController.text);

  bool get _busy => _testing || _saving;

  AppSettings _draftFrom(AppSettings current) {
    return current.copyWith(
      telegramEnabled: _enabled,
      telegramBotToken: _tokenController.text,
      telegramChatId: _chatController.text,
    );
  }

  Future<void> _test() async {
    final l10n = AppLocalizations.of(context)!;
    final current = ref.read(appSettingsProvider).value;
    if (current == null || !_fieldsFilled) return;
    setState(() {
      _testing = true;
      _status = null;
    });
    final result = await ref
        .read(telegramIntegrationProvider)
        .testConnection(_draftFrom(current));
    if (!mounted) return;
    setState(() {
      _testing = false;
      _statusOk = result.success;
      _status = connectionMessage(l10n, result.messageKey);
      _verifiedFingerprint = result.success
          ? _fingerprint(_tokenController.text, _chatController.text)
          : null;
    });
  }

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context)!;
    if (!_draftVerified) return;
    setState(() => _saving = true);
    final token = _tokenController.text.trim();
    final chatId = _chatController.text.trim();
    final enable = _enabled || (token.isNotEmpty && chatId.isNotEmpty);
    await ref.read(appSettingsProvider.notifier).setTelegram(
          enabled: enable,
          botToken: token,
          chatId: chatId,
        );
    if (!mounted) return;
    setState(() {
      _saving = false;
      _enabled = enable;
    });
    showAppToast(context, l10n.integrationSave);
  }

  Future<void> _disconnect() async {
    final l10n = AppLocalizations.of(context)!;
    final connected = ref.read(
      isIntegrationConfiguredProvider(kTelegramIntegrationId),
    );
    if (!connected) return;
    await ref.read(appSettingsProvider.notifier).setTelegram(
          enabled: false,
          botToken: '',
          chatId: '',
        );
    if (!mounted) return;
    setState(() {
      _enabled = false;
      _tokenController.clear();
      _chatController.clear();
      _status = null;
      _statusOk = false;
      _verifiedFingerprint = null;
    });
    showAppToast(context, l10n.integrationDisconnect);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final connected = ref.watch(
      isIntegrationConfiguredProvider(kTelegramIntegrationId),
    );
    final canTest = !_busy && _fieldsFilled;
    final canSave = !_busy && _draftVerified;
    final canDisconnect = !_busy && connected;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(l10n.telegramEnabled),
          value: _enabled,
          onChanged: _busy ? null : (v) => setState(() => _enabled = v),
        ),
        TextField(
          controller: _tokenController,
          decoration: InputDecoration(labelText: l10n.telegramBotToken),
          obscureText: true,
          enabled: !_busy,
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _chatController,
          decoration: InputDecoration(labelText: l10n.telegramChatId),
          enabled: !_busy,
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            FilledButton(
              onPressed: canTest ? _test : null,
              child: _testing
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(l10n.integrationTestConnection),
            ),
            FilledButton.tonal(
              onPressed: canSave ? _save : null,
              child: Text(l10n.integrationSave),
            ),
            OutlinedButton(
              onPressed: canDisconnect ? _disconnect : null,
              child: Text(l10n.integrationDisconnect),
            ),
          ],
        ),
        if (_status != null) ...[
          const SizedBox(height: 12),
          Text(
            _status!,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: _statusOk
                  ? theme.colorScheme.primary
                  : theme.colorScheme.error,
            ),
          ),
        ],
      ],
    );
  }
}
