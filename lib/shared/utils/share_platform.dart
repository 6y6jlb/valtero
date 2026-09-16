import 'dart:io';

/// Whether the platform has a usable system share sheet for files.
///
/// `share_plus` has no usable file-share UI on Linux — use clipboard / email
/// fallbacks there instead.
bool get isFileShareSupported =>
    Platform.isAndroid ||
    Platform.isIOS ||
    Platform.isWindows ||
    Platform.isMacOS;
