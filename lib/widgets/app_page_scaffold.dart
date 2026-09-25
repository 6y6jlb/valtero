import 'package:flutter/material.dart';
import 'package:valtero/widgets/add_operation_fab.dart';
import 'package:valtero/widgets/expand_fab_controller.dart';

/// Bottom inset so scrollable content clears the FAB row.
const double kFabBottomPadding = 96;

const double _kFabSize = 56;
const double _kFabGap = 12;

/// Page scaffold with optional add-operation FAB (`+` → expense / income).
///
/// Put extra FABs (e.g. Show list menu, bulk bars) in [extraFabs]; they sit to
/// the left of the add button. Each FAB is [Positioned] from the right with a
/// fixed offset so opening a submenu grows left/up and never moves its
/// neighbor. Expandable FABs use solid [GlassSurface] plates individually.
///
/// Expandable FABs share [ExpandFabScope]. The FAB slot is a full-area stack
/// so open menus keep a real hit target; a translucent barrier behind the
/// cluster dismisses on outside tap without remounting the FABs.
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

  List<Widget> _buildAnchoredFabs() {
    assert(
      !widget.showAddOperationFab ||
          (widget.onAddExpense != null && widget.onAddIncome != null),
      'AppPageScaffold(showAddOperationFab: true) requires '
      'onAddExpense and onAddIncome.',
    );

    final fabs = <Widget>[];
    var right = 0.0;

    if (widget.showAddOperationFab) {
      fabs.add(
        Positioned(
          key: const ValueKey('fab_slot_add'),
          right: right,
          bottom: 0,
          child: AddOperationFab(
            heroTag: widget.addOperationHeroTag,
            onAddExpense: widget.onAddExpense!,
            onAddIncome: widget.onAddIncome!,
          ),
        ),
      );
      right += _kFabSize + _kFabGap;
    }

    for (var i = widget.extraFabs.length - 1; i >= 0; i--) {
      fabs.add(
        Positioned(
          key: ValueKey('fab_slot_extra_$i'),
          right: right,
          bottom: 0,
          child: widget.extraFabs[i],
        ),
      );
      right += _kFabSize + _kFabGap;
    }

    return fabs;
  }

  @override
  Widget build(BuildContext context) {
    return ExpandFabScope(
      controller: _expandFab,
      child: ListenableBuilder(
        listenable: _expandFab,
        builder: (context, _) {
          final size = MediaQuery.sizeOf(context);
          final hasBuiltInFabs =
              widget.showAddOperationFab || widget.extraFabs.isNotEmpty;

          Widget? fab = widget.floatingActionButton;
          if (fab == null && hasBuiltInFabs) {
            fab = SizedBox(
              width: size.width - 32,
              height: size.height - 32,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned.fill(
                    key: const ValueKey('fab_dismiss_barrier'),
                    child: IgnorePointer(
                      ignoring: !_expandFab.hasOpen,
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: _expandFab.closeAll,
                        child: const ColoredBox(color: Colors.transparent),
                      ),
                    ),
                  ),
                  ..._buildAnchoredFabs(),
                ],
              ),
            );
          } else if (fab != null) {
            fab = SizedBox(
              width: size.width - 32,
              height: size.height - 32,
              child: Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.bottomRight,
                children: [
                  Positioned.fill(
                    key: const ValueKey('fab_dismiss_barrier'),
                    child: IgnorePointer(
                      ignoring: !_expandFab.hasOpen,
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: _expandFab.closeAll,
                        child: const ColoredBox(color: Colors.transparent),
                      ),
                    ),
                  ),
                  fab,
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
