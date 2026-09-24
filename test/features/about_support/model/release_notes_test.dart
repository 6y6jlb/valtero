import 'package:flutter_test/flutter_test.dart';
import 'package:valtero/features/about_support/model/release_notes.dart';

void main() {
  group('kAppReleaseNotes', () {
    test('is non-empty', () {
      expect(kAppReleaseNotes, isNotEmpty);
    });

    test('versions are unique', () {
      final versions = kAppReleaseNotes.map((e) => e.version).toList();
      expect(versions.toSet().length, versions.length);
    });

    test('newest version first', () {
      final versions = kAppReleaseNotes.map((e) => e.version).toList();
      final sorted = [...versions]..sort((a, b) {
          final pa = a.split('.').map(int.parse).toList();
          final pb = b.split('.').map(int.parse).toList();
          for (var i = 0; i < 3; i++) {
            final c = pb[i].compareTo(pa[i]);
            if (c != 0) return c;
          }
          return 0;
        });
      expect(versions, sorted);
    });

    test('each entry has at least one line', () {
      for (final entry in kAppReleaseNotes) {
        expect(entry.lines, isNotEmpty, reason: entry.version);
      }
    });
  });
}
