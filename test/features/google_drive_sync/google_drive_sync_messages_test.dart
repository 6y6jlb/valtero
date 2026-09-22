import 'package:flutter_test/flutter_test.dart';
import 'package:valtero/features/google_drive_sync/model/google_drive_sync_engine.dart';
import 'package:valtero/features/google_drive_sync/model/google_drive_sync_messages.dart';
import 'package:valtero/shared/l10n/generated/app_localizations_en.dart';

void main() {
  final l10n = AppLocalizationsEn();

  group('needsGoogleReauth', () {
    test('true for stale-credential message keys', () {
      expect(needsGoogleReauth('invalid_grant'), isTrue);
      expect(needsGoogleReauth('missing_refresh_token'), isTrue);
      expect(needsGoogleReauth('connectionInvalidToken'), isTrue);
      expect(needsGoogleReauth('shared_file_inaccessible'), isTrue);
      expect(needsGoogleReauth('needs_file_scope'), isTrue);
    });

    test('false for unrelated / null message keys', () {
      expect(needsGoogleReauth('network_error'), isFalse);
      expect(needsGoogleReauth('sync_failed'), isFalse);
      expect(needsGoogleReauth(null), isFalse);
    });
  });

  group('googleDriveConnectionMessage', () {
    test('maps connectionInvalidToken to the Google reauth string', () {
      expect(
        googleDriveConnectionMessage(l10n, 'connectionInvalidToken'),
        l10n.googleDriveReauthRequired,
      );
    });

    test('delegates other keys to the generic connection message', () {
      expect(
        googleDriveConnectionMessage(l10n, 'connectionOk'),
        l10n.connectionOk,
      );
    });
  });

  group('googleDriveSyncSuccessMessage', () {
    test('uses syncOk when nothing was imported', () {
      expect(
        googleDriveSyncSuccessMessage(
          l10n,
          const GoogleDriveSyncResult.ok(),
        ),
        l10n.googleDriveSyncOk,
      );
    });

    test('uses counts message when rows were added', () {
      expect(
        googleDriveSyncSuccessMessage(
          l10n,
          const GoogleDriveSyncResult.ok(expensesAdded: 2, incomesAdded: 1),
        ),
        l10n.googleDriveSyncDoneWithCounts(2, 1),
      );
    });

    test('uses duplicates message when skips are present', () {
      expect(
        googleDriveSyncSuccessMessage(
          l10n,
          const GoogleDriveSyncResult.ok(
            expensesAdded: 1,
            incomesAdded: 0,
            expensesSkippedDuplicate: 2,
          ),
        ),
        l10n.googleDriveSyncDoneWithDuplicates(1, 0, 2),
      );
    });
  });

  group('googleDriveSyncResultMessage', () {
    test('invalid_grant and missing_refresh_token map to reauth string', () {
      expect(
        googleDriveSyncResultMessage(
          l10n,
          const GoogleDriveSyncResult.fail('invalid_grant'),
        ),
        l10n.googleDriveReauthRequired,
      );
      expect(
        googleDriveSyncResultMessage(
          l10n,
          const GoogleDriveSyncResult.fail('missing_refresh_token'),
        ),
        l10n.googleDriveReauthRequired,
      );
    });

    test('maps revoke and share success/failure keys', () {
      expect(
        googleDriveSyncResultMessage(
          l10n,
          const GoogleDriveSyncResult.ok(messageKey: 'revokeOk'),
        ),
        l10n.googleDriveRevokeOk,
      );
      expect(
        googleDriveSyncResultMessage(
          l10n,
          const GoogleDriveSyncResult.fail('revoke_failed'),
        ),
        l10n.googleDriveRevokeFailed,
      );
      expect(
        googleDriveSyncResultMessage(
          l10n,
          const GoogleDriveSyncResult.ok(messageKey: 'shareOk'),
        ),
        l10n.googleDriveShareOk,
      );
    });

    test('maps shared file inaccessible keys', () {
      expect(
        googleDriveSyncResultMessage(
          l10n,
          const GoogleDriveSyncResult.fail('shared_file_inaccessible'),
        ),
        l10n.googleDriveSharedFileInaccessible,
      );
      expect(
        googleDriveSyncResultMessage(
          l10n,
          const GoogleDriveSyncResult.fail('shared_sync_failed'),
        ),
        l10n.googleDriveSharedFileInaccessible,
      );
    });
  });
}
