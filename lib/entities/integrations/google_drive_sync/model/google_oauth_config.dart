import 'dart:io';

/// OAuth client id from `--dart-define=GOOGLE_OAUTH_CLIENT_ID=…`.
///
/// Create an OAuth client in Google Cloud Console (Desktop app type works for
/// Linux/Windows loopback; for Android also register the reverse-client-id
/// redirect / Android client). See README / platform guide.
const String kGoogleOAuthClientId = String.fromEnvironment(
  'GOOGLE_OAUTH_CLIENT_ID',
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

bool get isGoogleOAuthClientConfigured => kGoogleOAuthClientId.trim().isNotEmpty;

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

  /// Desktop: loopback HTTP listener. Android: custom app scheme.
  factory GoogleOAuthRedirect.forPlatform() {
    if (Platform.isLinux || Platform.isWindows || Platform.isMacOS) {
      final scheme = 'http://localhost:$kGoogleOAuthDesktopLoopbackPort';
      return GoogleOAuthRedirect(
        callbackUrlScheme: scheme,
        redirectUri: '$scheme/oauth2redirect',
        useWebview: false,
      );
    }
    // Android / iOS: stable custom scheme (register
    // com.valtero.oauth:/oauth2redirect in Google Cloud OAuth client).
    const scheme = 'com.valtero.oauth';
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
