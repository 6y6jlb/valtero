import 'package:flutter/material.dart';
import 'package:valtero/widgets/add_operation_fab.dart';

/// Bottom inset so scrollable content clears the FAB row.
const double kFabBottomPadding = 96;

/// Page scaffold with optional add-operation FAB (`+` → expense / income).
///
/// Put extra FABs (e.g. Show list menu) in [extraFabs]; they appear to the
/// left of the add button and stay bottom-aligned when a menu expands.
class AppPageScaffold extends StatelessWidget {
  final PreferredSizeWidget? appBar;
  final Widget body;
  final bool showAddOperationFab;
  final String addOperationHeroTag;
  final List<Widget> extraFabs;
  final Widget? floatingActionButton;

  const AppPageScaffold({
    super.key,
    this.appBar,
    required this.body,
    this.showAddOperationFab = true,
    this.addOperationHeroTag = 'add_operation',
    this.extraFabs = const [],
    this.floatingActionButton,
  });

  @override
  Widget build(BuildContext context) {
    Widget? fab = floatingActionButton;
    if (fab == null && (showAddOperationFab || extraFabs.isNotEmpty)) {
      final children = <Widget>[
        ...extraFabs,
        if (showAddOperationFab && extraFabs.isNotEmpty)
          const SizedBox(width: 12),
        if (showAddOperationFab)
          AddOperationFab(heroTag: addOperationHeroTag),
      ];
      fab = children.length == 1
          ? children.first
          : Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: children,
            );
    }

    return Scaffold(
      appBar: appBar,
      body: body,
      floatingActionButton: fab,
    );
  }
}
