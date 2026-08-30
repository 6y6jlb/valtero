import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:valtero/entities/integrations/google_drive_sync/model/google_drive_rest_client.dart';
import 'package:valtero/entities/integrations/google_drive_sync/model/google_oauth_config.dart';
import 'package:valtero/entities/integrations/google_drive_sync/model/google_oauth_service.dart';
import 'package:valtero/entities/integrations/google_drive_sync/model/google_oauth_tokens.dart';
import 'package:valtero/entities/integrations/google_drive_sync/model/google_drive_sync_integration.dart';
import 'package:valtero/shared/settings/app_settings.dart';

class _RecordingAdapter implements HttpClientAdapter {
  _RecordingAdapter(this.handler);

  final Future<ResponseBody> Function(RequestOptions options) handler;
  final List<RequestOptions> requests = [];

  @override
  void close({bool force = false}) {}

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<List<int>>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(options);
    return handler(options);
  }
}

void main() {
  group('GoogleOAuthTokens', () {
    test('fromJson keeps previous refresh token when absent', () {
      final tokens = GoogleOAuthTokens.fromJson(
        {
          'access_token': 'a1',
          'expires_in': 3600,
          'token_type': 'Bearer',
        },
        previousRefreshToken: 'r-old',
      );
      expect(tokens.accessToken, 'a1');
      expect(tokens.refreshToken, 'r-old');
      expect(tokens.isExpired, isFalse);
    });

    test('isExpired considers 60s skew', () {
      final tokens = GoogleOAuthTokens(
        accessToken: 'a',
        refreshToken: 'r',
        expiresAt: DateTime.now().add(const Duration(seconds: 30)),
      );
      expect(tokens.isExpired, isTrue);
    });
  });

  group('GoogleOAuthService.refreshAccessToken', () {
    test('posts form body and parses tokens', () async {
      final dio = Dio();
      final adapter = _RecordingAdapter((options) async {
        expect(options.path, kGoogleOAuthTokenEndpoint);
        expect(options.method, 'POST');
        final data = options.data as Map;
        expect(data['grant_type'], 'refresh_token');
        expect(data['refresh_token'], 'refresh-1');
        expect(data['client_id'], 'client-xyz');
        return ResponseBody.fromString(
          '{"access_token":"access-2","expires_in":1800,"token_type":"Bearer"}',
          200,
          headers: {
            Headers.contentTypeHeader: [Headers.jsonContentType],
          },
        );
      });
      dio.httpClientAdapter = adapter;

      final service = GoogleOAuthService(dio);
      final tokens = await service.refreshAccessToken(
        refreshToken: 'refresh-1',
        clientId: 'client-xyz',
      );
      expect(tokens.accessToken, 'access-2');
      expect(tokens.refreshToken, 'refresh-1');
      expect(adapter.requests, hasLength(1));
    });

    test('maps Google error JSON body (not only HTTP status)', () async {
      final dio = Dio();
      dio.httpClientAdapter = _RecordingAdapter((options) async {
        return ResponseBody.fromString(
          '{"error":"invalid_request","error_description":"client_secret is missing."}',
          400,
          headers: {
            Headers.contentTypeHeader: [Headers.jsonContentType],
          },
        );
      });
      final service = GoogleOAuthService(dio);
      expect(
        () => service.refreshAccessToken(
          refreshToken: 'bad',
          clientId: 'client',
          clientSecret: 'secret',
        ),
        throwsA(
          isA<GoogleOAuthException>().having(
            (e) => e.code,
            'code',
            'missing_client_secret',
          ),
        ),
      );
    });

    test('maps 401 invalid_grant from Google JSON', () async {
      final dio = Dio();
      dio.httpClientAdapter = _RecordingAdapter((options) async {
        return ResponseBody.fromString(
          '{"error":"invalid_grant"}',
          401,
          headers: {
            Headers.contentTypeHeader: [Headers.jsonContentType],
          },
        );
      });
      final service = GoogleOAuthService(dio);
      expect(
        () => service.refreshAccessToken(
          refreshToken: 'bad',
          clientId: 'client',
          clientSecret: 'secret',
        ),
        throwsA(
          isA<GoogleOAuthException>().having(
            (e) => e.code,
            'code',
            'invalid_grant',
          ),
        ),
      );
    });

    test('sends client_secret when provided', () async {
      final dio = Dio();
      final adapter = _RecordingAdapter((options) async {
        final data = options.data as Map;
        expect(data['client_secret'], 'GOCSPX-test');
        return ResponseBody.fromString(
          '{"access_token":"access-2","expires_in":1800,"token_type":"Bearer"}',
          200,
          headers: {
            Headers.contentTypeHeader: [Headers.jsonContentType],
          },
        );
      });
      dio.httpClientAdapter = adapter;

      final service = GoogleOAuthService(dio);
      await service.refreshAccessToken(
        refreshToken: 'refresh-1',
        clientId: 'client-xyz',
        clientSecret: 'GOCSPX-test',
      );
      expect(adapter.requests, hasLength(1));
    });
  });

  group('GoogleDriveRestClient', () {
    test('findAppDataSyncFile queries appDataFolder', () async {
      final dio = Dio();
      final adapter = _RecordingAdapter((options) async {
        expect(options.queryParameters['spaces'], 'appDataFolder');
        expect(
          options.queryParameters['q'],
          contains(kGoogleDriveSyncFileName),
        );
        return ResponseBody.fromString(
          '{"files":[{"id":"file-1","name":"$kGoogleDriveSyncFileName",'
          '"modifiedTime":"2026-01-02T03:04:05.000Z","size":"12"}]}',
          200,
          headers: {
            Headers.contentTypeHeader: [Headers.jsonContentType],
          },
        );
      });
      dio.httpClientAdapter = adapter;

      final client = GoogleDriveRestClient(dio);
      final meta = await client.findAppDataSyncFile('token');
      expect(meta?.id, 'file-1');
      expect(meta?.modifiedTime, DateTime.parse('2026-01-02T03:04:05.000Z'));
      expect(adapter.requests.first.headers['Authorization'], 'Bearer token');
    });

    test('uploadAppDataSyncFile creates multipart POST into appDataFolder',
        () async {
      final dio = Dio();
      final adapter = _RecordingAdapter((options) async {
        expect(options.method, 'POST');
        expect(options.queryParameters['uploadType'], 'multipart');
        final body = options.data as String;
        expect(body, contains('appDataFolder'));
        expect(body, contains(kGoogleDriveSyncFileName));
        expect(body, contains('{"hello":true}'));
        return ResponseBody.fromString(
          '{"id":"new-id","name":"$kGoogleDriveSyncFileName"}',
          200,
          headers: {
            Headers.contentTypeHeader: [Headers.jsonContentType],
          },
        );
      });
      dio.httpClientAdapter = adapter;

      final client = GoogleDriveRestClient(dio);
      final meta = await client.uploadAppDataSyncFile(
        accessToken: 'tok',
        content: '{"hello":true}',
      );
      expect(meta.id, 'new-id');
    });

    test('shareFileWithEmail posts writer permission', () async {
      final dio = Dio();
      final adapter = _RecordingAdapter((options) async {
        expect(options.path, contains('/permissions'));
        expect(options.data['role'], 'writer');
        expect(options.data['emailAddress'], 'friend@example.com');
        return ResponseBody.fromString(
          '{"id":"perm-1"}',
          200,
          headers: {
            Headers.contentTypeHeader: [Headers.jsonContentType],
          },
        );
      });
      dio.httpClientAdapter = adapter;

      final client = GoogleDriveRestClient(dio);
      await client.shareFileWithEmail(
        accessToken: 'tok',
        fileId: 'file-9',
        email: 'friend@example.com',
      );
      expect(adapter.requests, hasLength(1));
    });
  });

  group('GoogleDriveSyncIntegration.isConfigured', () {
    test('requires enabled + refresh token + passphrase', () {
      final integration = GoogleDriveSyncIntegration.fromDio(Dio());
      expect(
        integration.isConfigured(AppSettings.initial()),
        isFalse,
      );
      expect(
        integration.isConfigured(
          AppSettings.initial().copyWith(
            googleDriveSyncEnabled: true,
            googleDriveRefreshToken: 'r',
            googleDriveSyncPassphrase: 'secret-phrase',
          ),
        ),
        isTrue,
      );
    });
  });

  group('googleDriveSyncScopes', () {
    test('personal excludes drive.file; shared includes it', () {
      final personal = googleDriveSyncScopes(includeFileScope: false);
      expect(personal, contains(kGoogleDriveAppDataScope));
      expect(personal, isNot(contains(kGoogleDriveFileScope)));

      final shared = googleDriveSyncScopes(includeFileScope: true);
      expect(shared, contains(kGoogleDriveFileScope));
    });
  });

  group('googleOAuthReverseClientIdScheme', () {
    test('builds com.googleusercontent.apps.<prefix>', () {
      expect(
        googleOAuthReverseClientIdScheme(
          '123-abc.apps.googleusercontent.com',
        ),
        'com.googleusercontent.apps.123-abc',
      );
    });
  });
}
