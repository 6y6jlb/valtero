import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:valtero/shared/l10n/generated/app_localizations.dart';
import 'package:valtero/widgets/app_button.dart';
import 'package:valtero/widgets/app_close_icon_button.dart';
import 'package:valtero/widgets/app_ok_button.dart';
import 'package:valtero/widgets/app_sheet_actions_bar.dart';
import 'package:valtero/widgets/app_sheet_header.dart';
import 'package:valtero/widgets/app_sheet_scaffold.dart';

Widget _wrap(Widget child) {
  return MaterialApp(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    locale: const Locale('en'),
    home: Scaffold(body: child),
  );
}

void main() {
  testWidgets('AppFilledButton shows trailing icon after label', (tester) async {
    await tester.pumpWidget(
      _wrap(
        AppFilledButton(
          label: 'Save',
          icon: Icons.check,
          onPressed: () {},
        ),
      ),
    );
    await tester.pump();

    expect(find.text('Save'), findsOneWidget);
    expect(find.byIcon(Icons.check), findsOneWidget);

    final row = tester.widget<Row>(
      find.descendant(
        of: find.byType(AppFilledButton),
        matching: find.byType(Row),
      ),
    );
    expect(row.children.first, isA<Text>());
    expect(row.children.last, isA<Icon>());
  });

  testWidgets('AppFilledButton busy hides label and shows spinner', (tester) async {
    await tester.pumpWidget(
      _wrap(
        AppFilledButton(
          label: 'Save',
          icon: Icons.check,
          busy: true,
          onPressed: () {},
        ),
      ),
    );
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    final opacity = tester.widget<Opacity>(
      find.descendant(
        of: find.byType(AppFilledButton),
        matching: find.byType(Opacity),
      ),
    );
    expect(opacity.opacity, 0);
  });

  testWidgets('AppCloseIconButton shows close label and icon', (tester) async {
    await tester.pumpWidget(_wrap(const AppCloseIconButton()));
    await tester.pump();
    expect(find.text('Close'), findsOneWidget);
    expect(find.byIcon(Icons.close), findsOneWidget);
  });

  testWidgets('AppOkButton uses success icon and ok label', (tester) async {
    await tester.pumpWidget(_wrap(const AppOkButton()));
    await tester.pump();
    expect(find.text('OK'), findsOneWidget);
    expect(find.byIcon(Icons.check_circle_outline), findsOneWidget);
  });

  testWidgets('AppSheetHeader shows title and description', (tester) async {
    await tester.pumpWidget(
      _wrap(
        const AppSheetHeader(
          title: 'Title',
          description: 'Description',
        ),
      ),
    );
    await tester.pump();
    expect(find.text('Title'), findsOneWidget);
    expect(find.text('Description'), findsOneWidget);
  });

  testWidgets('AppSheetScaffold keeps actions outside scroll body', (tester) async {
    const actionsKey = Key('sheet-actions');
    final scrollController = ScrollController();
    addTearDown(scrollController.dispose);

    await tester.pumpWidget(
      _wrap(
        PrimaryScrollController(
          controller: scrollController,
          child: SizedBox(
            height: 400,
            child: AppSheetScaffold(
              header: const AppSheetHeader(title: 'Sheet'),
              actions: const AppSheetActionsBar(
                key: actionsKey,
                children: [AppOkButton()],
              ),
              children: const [
                Text('row 0'),
                Text('row 1'),
              ],
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('Sheet'), findsOneWidget);
    expect(find.byKey(actionsKey), findsOneWidget);
    expect(find.text('OK'), findsOneWidget);

    final scaffold = tester.widget<AppSheetScaffold>(find.byType(AppSheetScaffold));
    expect(scaffold.actions, isNotNull);

    final column = tester.widget<Column>(
      find.descendant(
        of: find.byType(AppSheetScaffold),
        matching: find.byType(Column),
      ).first,
    );
    expect(column.children.length, 2);
    expect(column.children.last, isA<AppSheetActionsBar>());
  });
}
