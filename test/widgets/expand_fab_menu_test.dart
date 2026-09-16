import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:valtero/shared/l10n/generated/app_localizations.dart';
import 'package:valtero/widgets/expand_fab_controller.dart';
import 'package:valtero/widgets/expand_fab_menu.dart';

void main() {
  Widget wrap(Widget child, {required ExpandFabController controller}) {
    return MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('en'),
      home: Scaffold(
        body: const SizedBox.expand(),
        floatingActionButton: ExpandFabScope(
          controller: controller,
          child: child,
        ),
      ),
    );
  }

  testWidgets('first tap opens menu and shows hit-testable actions',
      (tester) async {
    final controller = ExpandFabController();
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      wrap(
        ExpandFabMenu(
          heroTag: 'test_add',
          closedTooltip: 'Add',
          closedChild: const Icon(Icons.add),
          actions: [
            ExpandFabAction(label: 'Add expense', onPressed: () async {}),
            ExpandFabAction(label: 'Add income', onPressed: () async {}),
          ],
        ),
        controller: controller,
      ),
    );

    expect(find.text('Add expense').hitTestable(), findsNothing);
    expect(controller.hasOpen, isFalse);

    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();

    expect(controller.hasOpen, isTrue);

    await tester.pumpAndSettle();

    expect(find.text('Add expense').hitTestable(), findsOneWidget);
    expect(find.text('Add income').hitTestable(), findsOneWidget);
  });

  testWidgets('plus trigger rotates open without swapping to close icon',
      (tester) async {
    final controller = ExpandFabController();
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      wrap(
        ExpandFabMenu(
          heroTag: 'test_anim',
          closedTooltip: 'Add',
          closedChild: const Icon(Icons.add),
          actions: [
            ExpandFabAction(label: 'Action A', onPressed: () async {}),
          ],
        ),
        controller: controller,
      ),
    );

    await tester.tap(find.byIcon(Icons.add));
    await tester.pump(const Duration(milliseconds: 100));

    expect(controller.hasOpen, isTrue);
    expect(find.byIcon(Icons.close), findsNothing);
    expect(find.byIcon(Icons.add), findsOneWidget);

    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.close), findsNothing);
    expect(find.byIcon(Icons.add), findsOneWidget);
  });

  testWidgets('first tap on sub-action runs callback and closes', (tester) async {
    final controller = ExpandFabController();
    addTearDown(controller.dispose);
    var expenseTaps = 0;

    await tester.pumpWidget(
      wrap(
        ExpandFabMenu(
          heroTag: 'test_action',
          closedTooltip: 'Add',
          closedChild: const Icon(Icons.add),
          actions: [
            ExpandFabAction(
              label: 'Add expense',
              onPressed: () async {
                expenseTaps++;
              },
            ),
            ExpandFabAction(label: 'Add income', onPressed: () async {}),
          ],
        ),
        controller: controller,
      ),
    );

    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Add expense'));
    await tester.pump();

    expect(expenseTaps, 1);
    expect(controller.hasOpen, isFalse);

    await tester.pumpAndSettle();
    expect(find.text('Add expense').hitTestable(), findsNothing);
  });

  testWidgets('second tap on rotated plus dismisses menu', (tester) async {
    final controller = ExpandFabController();
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      wrap(
        ExpandFabMenu(
          heroTag: 'test_close',
          closedTooltip: 'Add',
          closedChild: const Icon(Icons.add),
          actions: [
            ExpandFabAction(label: 'Action A', onPressed: () async {}),
          ],
        ),
        controller: controller,
      ),
    );

    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();
    expect(controller.hasOpen, isTrue);

    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();

    expect(controller.hasOpen, isFalse);

    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.add), findsOneWidget);
  });

  testWidgets('extended Show collapses label then morphs to rotated plus',
      (tester) async {
    final controller = ExpandFabController();
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      wrap(
        ExpandFabMenu(
          heroTag: 'test_show',
          closedTooltip: 'Show',
          closedExtended: true,
          closedLabel: 'Show',
          closedChild: const Icon(Icons.list_alt),
          actions: [
            ExpandFabAction(label: 'Show expenses', onPressed: () async {}),
          ],
        ),
        controller: controller,
      ),
    );

    expect(find.text('Show'), findsOneWidget);
    expect(find.byIcon(Icons.list_alt), findsOneWidget);

    await tester.tap(find.text('Show'));
    // Early: label still collapsing, list icon still visible.
    await tester.pump(const Duration(milliseconds: 80));
    expect(controller.hasOpen, isTrue);
    expect(find.byIcon(Icons.list_alt), findsOneWidget);

    await tester.pumpAndSettle();

    expect(find.text('Show expenses').hitTestable(), findsOneWidget);
    expect(find.byIcon(Icons.close), findsNothing);
    expect(find.byIcon(Icons.add), findsOneWidget);
    expect(find.byIcon(Icons.list_alt), findsNothing);
  });
}
