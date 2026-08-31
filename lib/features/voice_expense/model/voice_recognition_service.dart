import 'dart:async';

import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:valtero/shared/utils/platform_support.dart';

/// Thin Android-only wrapper around [SpeechToText].
class VoiceRecognitionService {
  final SpeechToText _speech;

  VoiceRecognitionService({SpeechToText? speech})
      : _speech = speech ?? SpeechToText();

  bool get isSupported => isVoiceInputSupported;

  bool get isAvailable => _speech.isAvailable;

  bool get isListening => _speech.isListening;

  Future<bool> initialize({
    void Function(String status)? onStatus,
    void Function(String error)? onError,
  }) async {
    if (!isSupported) return false;
    return _speech.initialize(
      onStatus: onStatus,
      onError: onError == null
          ? null
          : (e) => onError(e.errorMsg),
    );
  }

  Future<List<LocaleName>> locales() async {
    if (!isAvailable) return const [];
    return _speech.locales();
  }

  Future<LocaleName?> systemLocale() async {
    if (!isAvailable) return null;
    return _speech.systemLocale();
  }

  Future<void> startListening({
    required void Function(SpeechRecognitionResult result) onResult,
    String? localeId,
    Duration listenFor = const Duration(seconds: 30),
    Duration pauseFor = const Duration(seconds: 3),
  }) {
    return _speech.listen(
      onResult: onResult,
      listenOptions: SpeechListenOptions(
        localeId: localeId,
        listenFor: listenFor,
        pauseFor: pauseFor,
        partialResults: true,
        cancelOnError: true,
        listenMode: ListenMode.confirmation,
      ),
    );
  }

  Future<void> stopListening() => _speech.stop();

  Future<void> cancelListening() => _speech.cancel();
}
