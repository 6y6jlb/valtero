import 'package:flutter_test/flutter_test.dart';
import 'package:valtero/shared/database/schema_version.dart';
import 'package:valtero/shared/logging/log_file_header.dart';

void main() {
  group('buildLogFileMetadata', () {
    test('banner includes product, version, schema, ids, account, date', () {
      final meta = buildLogFileMetadata(
        installId: 'install-aaa',
        sessionId: 'session-bbb',
        kind: 'session',
        accountEmail: 'owner@example.com',
        appVersion: '1.6.0+1',
        at: DateTime.utc(2026, 9, 9, 12, 0, 0),
      );
      final banner = meta.toBanner();
      expect(banner, contains('product=$kAppLogProductCode'));
      expect(banner, contains('version=1.6.0+1'));
      expect(banner, contains('schema=$kAppSchemaVersion'));
      expect(banner, contains('installId=install-aaa'));
      expect(banner, contains('sessionId=session-bbb'));
      expect(banner, contains('account=owner@example.com'));
      expect(banner, contains('at=2026-09-09T12:00:00.000Z'));
      expect(banner, contains('======== valtero log session ========'));
    });

    test('empty account becomes (none)', () {
      final banner = buildLogFileMetadata(
        installId: 'i',
        sessionId: 's',
        kind: 'export',
        accountEmail: '  ',
        appVersion: '',
      ).toBanner();
      expect(banner, contains('account=(none)'));
      expect(banner, contains('version=(unknown)'));
      expect(banner, contains('======== valtero log export ========'));
    });
  });

  group('newLogCorrelationId', () {
    test('returns 16 hex chars', () {
      final id = newLogCorrelationId();
      expect(id.length, 16);
      expect(RegExp(r'^[0-9a-f]{16}$').hasMatch(id), isTrue);
    });
  });
}
