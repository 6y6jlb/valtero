import 'package:flutter/material.dart';
import 'package:valtero/widgets/add_expense_fab.dart';

/// Bottom inset so scrollable content clears the FAB row.
const double kFabBottomPadding = 96;

/// Page scaffold with an optional shared “+” add-expense FAB.
///
/// Put extra FABs (e.g. “Show expenses”) in [extraFabs]; they appear to the
/// left of the add button when [showAddExpenseFab] is true.
class AppPageScaffold extends StatelessWidget {
  final PreferredSizeWidget? appBar;
  final Widget body;
  final bool showAddExpenseFab;
  final String addExpenseHeroTag;
  final List<Widget> extraFabs;
  final Widget? floatingActionButton;

  const AppPageScaffold({
    super.key,
    this.appBar,
    required this.body,
    this.showAddExpenseFab = true,
    this.addExpenseHeroTag = 'add_expense',
    this.extraFabs = const [],
    this.floatingActionButton,
  });

  @override
  Widget build(BuildContext context) {
    Widget? fab = floatingActionButton;
    if (fab == null && (showAddExpenseFab || extraFabs.isNotEmpty)) {
      final children = <Widget>[
        ...extraFabs,
        if (showAddExpenseFab && extraFabs.isNotEmpty)
          const SizedBox(width: 12),
        if (showAddExpenseFab) addExpenseFab(context, heroTag: addExpenseHeroTag),
      ];
      fab = children.length == 1
          ? children.first
          : Row(mainAxisSize: MainAxisSize.min, children: children);
    }

    return Scaffold(
      appBar: appBar,
      body: body,
      floatingActionButton: fab,
    );
  }
}
