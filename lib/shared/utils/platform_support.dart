import 'dart:io';

bool get isDesktop =>
    Platform.isLinux || Platform.isWindows || Platform.isMacOS;
