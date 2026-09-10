import 'package:flutter/material.dart';

/// Coordinates expandable FABs: at most one open, dismissible from outside.
class ExpandFabController extends ChangeNotifier {
  Object? _openId;

  bool get hasOpen => _openId != null;

  bool isOpen(Object id) => identical(_openId, id);

  void open(Object id) {
    if (identical(_openId, id)) return;
    _openId = id;
    notifyListeners();
  }

  void close(Object id) {
    if (!identical(_openId, id)) return;
    _openId = null;
    notifyListeners();
  }

  void closeAll() {
    if (_openId == null) return;
    _openId = null;
    notifyListeners();
  }

  void toggle(Object id) {
    if (identical(_openId, id)) {
      closeAll();
    } else {
      open(id);
    }
  }
}

/// Provides [ExpandFabController] to [ExpandFabMenu] descendants.
class ExpandFabScope extends InheritedNotifier<ExpandFabController> {
  const ExpandFabScope({
    super.key,
    required ExpandFabController controller,
    required super.child,
  }) : super(notifier: controller);

  static ExpandFabController of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<ExpandFabScope>();
    assert(
      scope != null,
      'ExpandFabMenu requires ExpandFabScope (e.g. via AppPageScaffold).',
    );
    return scope!.notifier!;
  }
}
