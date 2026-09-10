import 'package:flutter_test/flutter_test.dart';
import 'package:valtero/widgets/expand_fab_controller.dart';

void main() {
  test('ExpandFabController opens one menu and closes the other', () {
    final controller = ExpandFabController();
    final a = Object();
    final b = Object();

    expect(controller.hasOpen, isFalse);

    controller.open(a);
    expect(controller.isOpen(a), isTrue);
    expect(controller.isOpen(b), isFalse);

    controller.open(b);
    expect(controller.isOpen(a), isFalse);
    expect(controller.isOpen(b), isTrue);

    controller.toggle(b);
    expect(controller.hasOpen, isFalse);

    controller.toggle(a);
    expect(controller.isOpen(a), isTrue);
    controller.closeAll();
    expect(controller.hasOpen, isFalse);

    controller.dispose();
  });
}
