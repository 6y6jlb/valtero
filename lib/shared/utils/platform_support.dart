import 'dart:io';

bool get isDesktop =>
    Platform.isLinux || Platform.isWindows || Platform.isMacOS;

bool get isAndroid => Platform.isAndroid;

/// Voice expense dictation is Android-only (`speech_to_text` has no Linux support).
bool get isVoiceInputSupported => Platform.isAndroid;
