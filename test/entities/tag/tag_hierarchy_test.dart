import 'package:flutter_test/flutter_test.dart';
import 'package:valtero/entities/tag/model/tag_hierarchy.dart';
import 'package:valtero/shared/database/app_database.dart';
import 'package:valtero/shared/utils/tag_label.dart';

Tag _tag({
  required int id,
  required String name,
  int? parentTagId,
  String kind = 'normal',
}) {
  return Tag(
    id: id,
    name: name,
    colorValue: null,
    isDefault: false,
    sortOrder: id,
    kind: kind,
    countryCode: null,
    stableKey: null,
    iconKey: null,
    parentTagId: parentTagId,
  );
}

void main() {
  group('tag hierarchy selection', () {
    test('selectTopLevelTag replaces same-kind category and clears old subtag',
        () {
      final health = _tag(id: 1, name: 'health');
      final doctor = _tag(id: 2, name: 'doctor', parentTagId: 1);
      final transport = _tag(id: 3, name: 'transport');
      final tagById = {1: health, 2: doctor, 3: transport};
      final selected = {1, 2};

      selectTopLevelTag(
        selected: selected,
        tag: transport,
        tagById: tagById,
      );

      expect(selected, {3});
    });

    test('selectSubtag toggles under selected parent', () {
      final health = _tag(id: 1, name: 'health');
      final doctor = _tag(id: 2, name: 'doctor', parentTagId: 1);
      final meds = _tag(id: 3, name: 'medications', parentTagId: 1);
      final tagById = {1: health, 2: doctor, 3: meds};
      final selected = {1};

      selectSubtag(selected: selected, tag: doctor, tagById: tagById);
      expect(selected, {1, 2});

      selectSubtag(selected: selected, tag: meds, tagById: tagById);
      expect(selected, {1, 3});

      selectSubtag(selected: selected, tag: meds, tagById: tagById);
      expect(selected, {1});
    });
  });

  group('formatTagLabelsCombined', () {
    test('orders parent before child with middle dot', () {
      final labels = {1: 'Health', 2: 'Doctor'};
      final parents = {1: null, 2: 1};
      expect(
        formatTagLabelsCombined([2, 1], labels, parents),
        'Health · Doctor',
      );
    });
  });
}
