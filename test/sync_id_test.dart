import 'package:flutter_test/flutter_test.dart';
import 'package:valtero/shared/utils/sync_id.dart';

void main() {
  test('newSyncId returns UUID v4 shape', () {
    final id = newSyncId();
    expect(
      id,
      matches(
        RegExp(
          r'^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$',
        ),
      ),
    );
    expect(newSyncId(), isNot(id));
  });
}
