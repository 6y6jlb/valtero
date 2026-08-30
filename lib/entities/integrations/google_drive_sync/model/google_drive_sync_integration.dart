import 'package:dio/dio.dart';
import 'package:valtero/entities/integrations/google_drive_sync/model/google_drive_rest_client.dart';
import 'package:valtero/entities/integrations/google_drive_sync/model/google_oauth_config.dart';
import 'package:valtero/entities/integrations/google_drive_sync/model/google_oauth_service.dart';
import 'package:valtero/entities/integrations/model/app_integration.dart';
import 'package:valtero/entities/integrations/model/integration_test_result.dart';
import 'package:valtero/shared/settings/app_settings.dart';

const kGoogleDriveSyncIntegrationId = 'google_drive_sync';

class GoogleDriveSyncIntegration implements AppIntegration {
  GoogleDriveSyncIntegration(this._oauth, this._drive);

  factory GoogleDriveSyncIntegration.fromDio(Dio dio) {
    return GoogleDriveSyncIntegration(
      GoogleOAuthService(dio),
      GoogleDriveRestClient(dio),
    );
  }

  final GoogleOAuthService _oauth;
  final GoogleDriveRestClient _drive;

  GoogleOAuthService get oauth => _oauth;
  GoogleDriveRestClient get drive => _drive;

  @override
  String get id => kGoogleDriveSyncIntegrationId;

  @override
  bool isConfigured(AppSettings settings) {
    return settings.googleDriveSyncEnabled &&
        settings.googleDriveRefreshToken.trim().isNotEmpty &&
        settings.googleDriveSyncPassphrase.trim().isNotEmpty;
  }

  @override
  Future<IntegrationTestResult> testConnection(AppSettings settings) async {
    if (!isGoogleOAuthClientConfigured) {
      return IntegrationTestResult.fail('connectionMissingClientId');
    }
    final refresh = settings.googleDriveRefreshToken.trim();
    if (refresh.isEmpty) {
      return IntegrationTestResult.fail('connectionMissingFields');
    }
    try {
      final tokens = await _oauth.refreshAccessToken(refreshToken: refresh);
      await _drive.about(tokens.accessToken);
      return IntegrationTestResult.ok();
    } on GoogleOAuthException catch (e) {
      if (e.code == 'invalid_grant') {
        return IntegrationTestResult.fail('connectionInvalidToken');
      }
      return IntegrationTestResult.fail('connectionFailed');
    } on DioException {
      return IntegrationTestResult.fail('connectionFailed');
    } catch (_) {
      return IntegrationTestResult.fail('connectionFailed');
    }
  }
}
