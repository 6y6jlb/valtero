// OAuth client ids from `local.oauth.env` via Make / `--dart-define=…`.
// Prefer platform-specific keys; optional legacy [kGoogleOAuthClientId] as fallback.
// See `local.oauth.env.example` and `make run-linux` / `make android-sha1`.
import 'dart:io';

/// Legacy single-id define (any platform fallback).
const String kGoogleOAuthClientId = String.fromEnvironment(
  'GOOGLE_OAUTH_CLIENT_ID',
);

/// Desktop OAuth client (Linux / Windows / macOS loopback).
const String kGoogleOAuthClientIdDesktop = String.fromEnvironment(
  'GOOGLE_OAUTH_CLIENT_ID_DESKTOP',
);

/// Android OAuth client (package + SHA-1); redirect uses reverse client id.
const String kGoogleOAuthClientIdAndroid = String.fromEnvironment(
  'GOOGLE_OAUTH_CLIENT_ID_ANDROID',
);

/// Desktop OAuth client secret (Google Cloud → Desktop app credentials).
/// Google often still requires this on the token endpoint even with PKCE.
const String kGoogleOAuthClientSecretDesktop = String.fromEnvironment(
  'GOOGLE_OAUTH_CLIENT_SECRET_DESKTOP',
);

/// Hidden app-data scope — non-sensitive, no verification for personal sync.
const String kGoogleDriveAppDataScope =
    'https://www.googleapis.com/auth/drive.appdata';

/// Manage files created by the app — needed for cross-account shared sync.
/// Google classifies this as a sensitive scope (verification for >100 users).
const String kGoogleDriveFileScope =
    'https://www.googleapis.com/auth/drive.file';

const String kGoogleUserInfoEmailScope =
    'https://www.googleapis.com/auth/userinfo.email';

const String kGoogleOAuthAuthEndpoint =
    'https://accounts.google.com/o/oauth2/v2/auth';
const String kGoogleOAuthTokenEndpoint =
    'https://oauth2.googleapis.com/token';
const String kGoogleUserInfoEndpoint =
    'https://www.googleapis.com/oauth2/v2/userinfo';

/// Snapshot filename stored under Drive `appDataFolder`.
const String kGoogleDriveSyncFileName = 'valtero_sync.valterobackup';

/// Shared sync file name (visible when shared across accounts).
const String kGoogleDriveSharedSyncFileName = 'Valtero Shared Sync.valterobackup';

/// Fixed loopback port for desktop OAuth (`flutter_web_auth_2` + useWebview:false).
const int kGoogleOAuthDesktopLoopbackPort = 43823;

/// Client id for the current platform (empty if not configured for this OS).
String googleOAuthClientIdForPlatform() {
  if (Platform.isAndroid) {
    return _firstNonEmpty(
      kGoogleOAuthClientIdAndroid,
      kGoogleOAuthClientId,
    );
  }
  // Linux / Windows / macOS share the Desktop OAuth client.
  return _firstNonEmpty(
    kGoogleOAuthClientIdDesktop,
    kGoogleOAuthClientId,
  );
}

bool get isGoogleOAuthClientConfigured =>
    googleOAuthClientIdForPlatform().isNotEmpty;

/// Client secret for the current platform (desktop only; Android uses PKCE alone).
String googleOAuthClientSecretForPlatform() {
  if (Platform.isLinux || Platform.isWindows || Platform.isMacOS) {
    return kGoogleOAuthClientSecretDesktop.trim();
  }
  return '';
}

/// Desktop token exchange needs the Console client secret (even with PKCE).
bool get isGoogleOAuthDesktopClientSecretRequired =>
    Platform.isLinux || Platform.isWindows || Platform.isMacOS;

/// `com.googleusercontent.apps.<id-prefix>` from a full Client ID.
String googleOAuthReverseClientIdScheme(String clientId) {
  final id = clientId.trim();
  const suffix = '.apps.googleusercontent.com';
  final prefix =
      id.endsWith(suffix) ? id.substring(0, id.length - suffix.length) : id;
  return 'com.googleusercontent.apps.$prefix';
}

String _firstNonEmpty(String a, String b) {
  final left = a.trim();
  if (left.isNotEmpty) return left;
  return b.trim();
}

/// Platform-specific callback scheme / redirect URI for Authorization Code + PKCE.
class GoogleOAuthRedirect {
  final String callbackUrlScheme;
  final String redirectUri;
  final bool useWebview;

  const GoogleOAuthRedirect({
    required this.callbackUrlScheme,
    required this.redirectUri,
    required this.useWebview,
  });

  /// Desktop: loopback HTTP. Android: reverse Google client-id scheme.
  ///
  /// Prefer `127.0.0.1` over `localhost` (Google OAuth loopback guidance;
  /// [flutter_web_auth_2] binds the listener to 127.0.0.1).
  factory GoogleOAuthRedirect.forPlatform({String? clientId}) {
    if (Platform.isLinux || Platform.isWindows || Platform.isMacOS) {
      final scheme = 'http://127.0.0.1:$kGoogleOAuthDesktopLoopbackPort';
      return GoogleOAuthRedirect(
        callbackUrlScheme: scheme,
        redirectUri: '$scheme/oauth2redirect',
        useWebview: false,
      );
    }
    final id = (clientId ?? googleOAuthClientIdForPlatform()).trim();
    final scheme = googleOAuthReverseClientIdScheme(id);
    return GoogleOAuthRedirect(
      callbackUrlScheme: scheme,
      redirectUri: '$scheme:/oauth2redirect',
      useWebview: true,
    );
  }
}

/// Space-separated scopes for personal sync (and shared when [includeFileScope]).
String googleDriveSyncScopes({required bool includeFileScope}) {
  final scopes = <String>[
    kGoogleDriveAppDataScope,
    kGoogleUserInfoEmailScope,
    if (includeFileScope) kGoogleDriveFileScope,
  ];
  return scopes.join(' ');
}
