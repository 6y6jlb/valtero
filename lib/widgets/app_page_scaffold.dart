import 'package:flutter/material.dart';
import 'package:valtero/widgets/add_operation_fab.dart';
import 'package:valtero/widgets/expand_fab_controller.dart';

/// Bottom inset so scrollable content clears the FAB row.
const double kFabBottomPadding = 96;

/// Page scaffold with optional add-operation FAB (`+` → expense / income).
///
/// Put extra FABs (e.g. Show list menu) in [extraFabs]; they appear to the
/// left of the add button and stay bottom-aligned when a menu expands.
///
/// Expandable FABs share [ExpandFabScope]: opening one closes the other, and
/// a tap outside the FAB cluster dismisses the open menu.
class AppPageScaffold extends StatefulWidget {
  final PreferredSizeWidget? appBar;
  final Widget body;
  final bool showAddOperationFab;
  final String addOperationHeroTag;
  final Future<void> Function()? onAddExpense;
  final Future<void> Function()? onAddIncome;
  final List<Widget> extraFabs;
  final Widget? floatingActionButton;

  const AppPageScaffold({
    super.key,
    this.appBar,
    required this.body,
    this.showAddOperationFab = true,
    this.addOperationHeroTag = 'add_operation',
    this.onAddExpense,
    this.onAddIncome,
    this.extraFabs = const [],
    this.floatingActionButton,
  });

  @override
  State<AppPageScaffold> createState() => _AppPageScaffoldState();
}

class _AppPageScaffoldState extends State<AppPageScaffold> {
  final ExpandFabController _expandFab = ExpandFabController();

  @override
  void dispose() {
    _expandFab.dispose();
    super.dispose();
  }

  Widget? _buildFabCluster() {
    Widget? fab = widget.floatingActionButton;
    if (fab == null &&
        (widget.showAddOperationFab || widget.extraFabs.isNotEmpty)) {
      assert(
        !widget.showAddOperationFab ||
            (widget.onAddExpense != null && widget.onAddIncome != null),
        'AppPageScaffold(showAddOperationFab: true) requires '
        'onAddExpense and onAddIncome.',
      );
      final children = <Widget>[
        ...widget.extraFabs,
        if (widget.showAddOperationFab && widget.extraFabs.isNotEmpty)
          const SizedBox(width: 12),
        if (widget.showAddOperationFab)
          AddOperationFab(
            heroTag: widget.addOperationHeroTag,
            onAddExpense: widget.onAddExpense!,
            onAddIncome: widget.onAddIncome!,
          ),
      ];
      fab = children.length == 1
          ? children.first
          : Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: children,
            );
    }
    return fab;
  }

  @override
  Widget build(BuildContext context) {
    return ExpandFabScope(
      controller: _expandFab,
      child: ListenableBuilder(
        listenable: _expandFab,
        builder: (context, _) {
          final cluster = _buildFabCluster();
          Widget? fab = cluster;
          if (cluster != null && _expandFab.hasOpen) {
            final size = MediaQuery.sizeOf(context);
            // Fill the area above/left of the FAB anchor so outside taps
            // dismiss; Scaffold pins this child's bottom-right to the FAB slot.
            fab = SizedBox(
              width: size.width - 32,
              height: size.height - 32,
              child: Stack(
                alignment: Alignment.bottomRight,
                children: [
                  Positioned.fill(
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: _expandFab.closeAll,
                      child: const ColoredBox(color: Colors.transparent),
                    ),
                  ),
                  cluster,
                ],
              ),
            );
          }

          return Scaffold(
            appBar: widget.appBar,
            body: widget.body,
            floatingActionButton: fab,
          );
        },
      ),
    );
  }
}
