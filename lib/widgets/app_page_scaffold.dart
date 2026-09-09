import 'package:flutter/material.dart';
import 'package:valtero/widgets/add_expense_fab.dart';
import 'package:valtero/widgets/add_income_fab.dart';

/// Bottom inset so scrollable content clears the FAB row.
const double kFabBottomPadding = 96;

/// Page scaffold with optional shared “+” add-expense / add-income FABs.
///
/// Put extra FABs (e.g. “Show expenses”) in [extraFabs]; they appear to the
/// left of the add button(s).
class AppPageScaffold extends StatelessWidget {
  final PreferredSizeWidget? appBar;
  final Widget body;
  final bool showAddExpenseFab;
  final bool showAddIncomeFab;
  final String addExpenseHeroTag;
  final String addIncomeHeroTag;
  final List<Widget> extraFabs;
  final Widget? floatingActionButton;

  const AppPageScaffold({
    super.key,
    this.appBar,
    required this.body,
    this.showAddExpenseFab = true,
    this.showAddIncomeFab = false,
    this.addExpenseHeroTag = 'add_expense',
    this.addIncomeHeroTag = 'add_income',
    this.extraFabs = const [],
    this.floatingActionButton,
  });

  @override
  Widget build(BuildContext context) {
    Widget? fab = floatingActionButton;
    if (fab == null &&
        (showAddExpenseFab || showAddIncomeFab || extraFabs.isNotEmpty)) {
      final children = <Widget>[
        ...extraFabs,
        if ((showAddExpenseFab || showAddIncomeFab) && extraFabs.isNotEmpty)
          const SizedBox(width: 12),
        if (showAddExpenseFab && showAddIncomeFab) ...[
          addExpenseFab(context, heroTag: addExpenseHeroTag),
          const SizedBox(width: 12),
          addIncomeFab(context, heroTag: addIncomeHeroTag),
        ] else if (showAddIncomeFab)
          addIncomeFab(context, heroTag: addIncomeHeroTag)
        else if (showAddExpenseFab)
          addExpenseFab(context, heroTag: addExpenseHeroTag),
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
