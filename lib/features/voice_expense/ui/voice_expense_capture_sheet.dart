import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:valtero/entities/payment_method/model/payment_methods_provider.dart';
import 'package:valtero/entities/tag/model/tags_provider.dart';
import 'package:valtero/features/voice_expense/model/voice_expense_draft.dart';
import 'package:valtero/features/voice_expense/model/voice_expense_parser.dart';
import 'package:valtero/features/voice_expense/model/voice_match_candidate.dart';
import 'package:valtero/features/voice_expense/model/voice_recognition_service.dart';
import 'package:valtero/shared/l10n/generated/app_localizations.dart';
import 'package:valtero/shared/logging/logging_providers.dart';
import 'package:valtero/shared/utils/money.dart';
import 'package:valtero/shared/utils/payment_method_label.dart';
import 'package:valtero/shared/utils/platform_support.dart';
import 'package:valtero/shared/utils/tag_label.dart';
import 'package:valtero/widgets/app_button.dart';
import 'package:valtero/widgets/app_modal_sheet.dart';

Future<VoiceExpenseDraft?> showVoiceExpenseCaptureSheet(
  BuildContext context,
) {
  if (!isVoiceInputSupported) return Future.value(null);
  return showAppModalSheet<VoiceExpenseDraft>(
    context: context,
    initialChildSize: 0.62,
    minChildSize: 0.4,
    child: const VoiceExpenseCaptureSheet(),
  );
}

enum _CapturePhase { initializing, listening, preview, error }

class VoiceExpenseCaptureSheet extends ConsumerStatefulWidget {
  const VoiceExpenseCaptureSheet({super.key});

  @override
  ConsumerState<VoiceExpenseCaptureSheet> createState() =>
      _VoiceExpenseCaptureSheetState();
}

class _VoiceExpenseCaptureSheetState
    extends ConsumerState<VoiceExpenseCaptureSheet> {
  late final VoiceRecognitionService _service;
  _CapturePhase _phase = _CapturePhase.initializing;
  String _partial = '';
  String _finalText = '';
  String? _errorKey;
  VoiceExpenseDraft? _draft;
  String? _localeId;
  bool _finishing = false;

  @override
  void initState() {
    super.initState();
    _service = VoiceRecognitionService();
    WidgetsBinding.instance.addPostFrameCallback((_) => _bootstrap());
  }

  Future<void> _bootstrap() async {
    final ok = await _service.initialize(
      onStatus: _onStatus,
      onError: (msg) {
        // Log engine error code/message only — never the spoken text.
        ref.read(appLoggerProvider).error(
              'Voice expense: speech engine error',
              error: msg,
            );
        if (!mounted) return;
        setState(() {
          _phase = _CapturePhase.error;
          _errorKey = 'voiceExpenseUnavailable';
        });
      },
    );
    if (!mounted) return;
    if (!ok) {
      ref.read(appLoggerProvider).error(
            'Voice expense: speech recognition initialize failed',
          );
      setState(() {
        _phase = _CapturePhase.error;
        _errorKey = 'voiceExpenseUnavailable';
      });
      return;
    }
    final system = await _service.systemLocale();
    if (!mounted) return;
    _localeId = system?.localeId;
    await _startListening();
  }

  void _onStatus(String status) {
    if (!mounted) return;
    // Android ends listening after a short pause — move to preview.
    if (status == 'done' || status == 'notListening') {
      if (_phase == _CapturePhase.listening) {
        _finishListening();
      }
    }
  }

  Future<void> _startListening() async {
    setState(() {
      _phase = _CapturePhase.listening;
      _partial = '';
      _finalText = '';
      _draft = null;
      _errorKey = null;
      _finishing = false;
    });
    try {
      await _service.startListening(
        localeId: _localeId,
        onResult: _onResult,
      );
    } catch (e, st) {
      ref.read(appLoggerProvider).error(
            'Voice expense: startListening failed',
            error: e,
            stackTrace: st,
          );
      if (!mounted) return;
      setState(() {
        _phase = _CapturePhase.error;
        _errorKey = 'voiceExpenseUnavailable';
      });
    }
  }

  void _onResult(SpeechRecognitionResult result) {
    if (!mounted) return;
    setState(() {
      _partial = result.recognizedWords;
      if (result.finalResult) {
        _finalText = result.recognizedWords;
      }
    });
    if (result.finalResult) {
      _finishListening();
    }
  }

  Future<void> _finishListening() async {
    if (_finishing || _phase == _CapturePhase.preview) return;
    _finishing = true;
    if (_service.isListening) {
      await _service.stopListening();
    }
    if (!mounted) return;
    final text = _finalText.trim().isNotEmpty
        ? _finalText.trim()
        : _partial.trim();
    if (text.isEmpty) {
      // No transcript content in logs — only the outcome.
      ref.read(appLoggerProvider).warning(
            'Voice expense: empty recognition result',
          );
      setState(() {
        _phase = _CapturePhase.error;
        _errorKey = 'voiceExpenseEmpty';
        _finishing = false;
      });
      return;
    }
    final tags = ref.read(tagsStreamProvider).value ?? const [];
    final payments = ref.read(paymentMethodsStreamProvider).value ?? const [];
    final tagCandidates = [
      for (final t in tags)
        VoiceMatchCandidate(id: t.id, label: localizedTagLabel(context, t)),
    ];
    final paymentCandidates = [
      for (final m in payments)
        VoiceMatchCandidate(
          id: m.id,
          label: localizedPaymentMethodLabel(context, m),
        ),
    ];
    // In-memory draft only — never written to disk/logs as transcript.
    final draft = parseVoiceTranscript(
      text,
      tags: tagCandidates,
      paymentMethods: paymentCandidates,
    );
    setState(() {
      _draft = draft;
      _phase = _CapturePhase.preview;
      _finishing = false;
    });
  }

  Future<void> _stopAndPreview() async {
    await _finishListening();
  }

  @override
  void dispose() {
    if (_service.isListening) {
      _service.cancelListening();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final scroll = PrimaryScrollController.maybeOf(context);

    return Column(
      children: [
        Expanded(
          child: ListView(
            controller: scroll,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            children: [
              Text(
                l10n.voiceExpenseTitle,
                style: theme.textTheme.titleLarge,
              ),
              const SizedBox(height: 12),
              _PatternHint(l10n: l10n, theme: theme),
              const SizedBox(height: 16),
              ..._buildBody(l10n, theme),
            ],
          ),
        ),
        SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: _buildActions(l10n),
          ),
        ),
      ],
    );
  }

  List<Widget> _buildBody(AppLocalizations l10n, ThemeData theme) {
    switch (_phase) {
      case _CapturePhase.initializing:
        return [
          Text(l10n.voiceExpenseInitializing),
          const SizedBox(height: 16),
          const LinearProgressIndicator(),
        ];
      case _CapturePhase.listening:
        return [
          Row(
            children: [
              Icon(Icons.mic, color: theme.colorScheme.primary),
              const SizedBox(width: 8),
              Expanded(child: Text(l10n.voiceExpenseListening)),
            ],
          ),
          const SizedBox(height: 12),
          const LinearProgressIndicator(),
          const SizedBox(height: 16),
          Text(
            _partial.isEmpty ? l10n.voiceExpenseSpeakHint : _partial,
            style: theme.textTheme.bodyLarge,
          ),
        ];
      case _CapturePhase.preview:
        final draft = _draft!;
        return [
          Text(l10n.voiceExpenseRecognized, style: theme.textTheme.titleMedium),
          const SizedBox(height: 12),
          _PreviewRow(
            label: l10n.amount,
            value: draft.hasAmount
                ? Money.formatMinor(draft.amountMinor!)
                : l10n.voiceExpenseNotDetected,
          ),
          _PreviewRow(
            label: l10n.currency,
            value: draft.currencyCode ?? l10n.voiceExpenseNotDetected,
          ),
          _PreviewRow(
            label: l10n.tag,
            value: _tagLabel(draft.tagId) ?? l10n.voiceExpenseNotDetected,
          ),
          _PreviewRow(
            label: l10n.paymentMethod,
            value: _paymentLabel(draft.paymentMethodId) ??
                l10n.voiceExpenseNotDetected,
          ),
          _PreviewRow(
            label: l10n.voiceExpenseHeardLabel,
            value: draft.transcript,
          ),
        ];
      case _CapturePhase.error:
        return [
          Text(
            _errorMessage(l10n),
            style: TextStyle(color: theme.colorScheme.error),
          ),
        ];
    }
  }

  Widget _buildActions(AppLocalizations l10n) {
    switch (_phase) {
      case _CapturePhase.initializing:
        return AppOutlinedButton(
          onPressed: () => Navigator.of(context).pop(null),
          label: l10n.cancel,
        );
      case _CapturePhase.listening:
        return Row(
          children: [
            Expanded(
              child: AppOutlinedButton(
                onPressed: () async {
                  await _service.cancelListening();
                  if (!mounted) return;
                  Navigator.of(context).pop(null);
                },
                label: l10n.cancel,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: AppFilledButton(
                onPressed: _stopAndPreview,
                label: l10n.voiceExpenseDoneListening,
              ),
            ),
          ],
        );
      case _CapturePhase.preview:
        return Row(
          children: [
            Expanded(
              child: AppOutlinedButton(
                onPressed: () => Navigator.of(context).pop(null),
                label: l10n.cancel,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: AppFilledButton(
                onPressed: () => Navigator.of(context).pop(_draft),
                label: l10n.voiceExpenseCreate,
              ),
            ),
          ],
        );
      case _CapturePhase.error:
        return Row(
          children: [
            Expanded(
              child: AppOutlinedButton(
                onPressed: () => Navigator.of(context).pop(null),
                label: l10n.cancel,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: AppFilledButton(
                onPressed: _startListening,
                label: l10n.voiceExpenseRetry,
              ),
            ),
          ],
        );
    }
  }

  String _errorMessage(AppLocalizations l10n) {
    return switch (_errorKey) {
      'voiceExpenseEmpty' => l10n.voiceExpenseEmpty,
      _ => l10n.voiceExpenseUnavailable,
    };
  }

  String? _tagLabel(int? id) {
    if (id == null) return null;
    final tags = ref.read(tagsStreamProvider).value ?? const [];
    for (final t in tags) {
      if (t.id == id) return localizedTagLabel(context, t);
    }
    return null;
  }

  String? _paymentLabel(int? id) {
    if (id == null) return null;
    final methods = ref.read(paymentMethodsStreamProvider).value ?? const [];
    for (final m in methods) {
      if (m.id == id) return localizedPaymentMethodLabel(context, m);
    }
    return null;
  }
}

class _PatternHint extends StatelessWidget {
  final AppLocalizations l10n;
  final ThemeData theme;

  const _PatternHint({required this.l10n, required this.theme});

  @override
  Widget build(BuildContext context) {
    final muted = theme.colorScheme.onSurfaceVariant;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.voiceExpensePatternHint,
          style: theme.textTheme.bodyMedium?.copyWith(color: muted),
        ),
        const SizedBox(height: 4),
        Text(
          l10n.voiceExpensePatternExample,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontStyle: FontStyle.italic,
            color: muted,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          l10n.voiceExpensePrivacyNote,
          style: theme.textTheme.bodySmall?.copyWith(color: muted),
        ),
      ],
    );
  }
}

class _PreviewRow extends StatelessWidget {
  final String label;
  final String value;

  const _PreviewRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(child: Text(value, style: theme.textTheme.bodyLarge)),
        ],
      ),
    );
  }
}
