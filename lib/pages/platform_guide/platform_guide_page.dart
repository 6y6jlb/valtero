import 'package:flutter/material.dart';
import 'package:valtero/features/add_expense/ui/add_expense_sheet.dart';
import 'package:valtero/features/add_income/ui/add_income_sheet.dart';
import 'package:valtero/features/platform_guide/ui/platform_guide_body.dart';
import 'package:valtero/pages/settings/settings_app_bar_button.dart';
import 'package:valtero/shared/l10n/generated/app_localizations.dart';
import 'package:valtero/widgets/app_page_scaffold.dart';

class PlatformGuidePage extends StatelessWidget {
  const PlatformGuidePage({super.key});

  static Future<void> open(BuildContext context) {
    return Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => const PlatformGuidePage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return AppPageScaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: Text(l10n.guideTitle),
        actions: const [SettingsAppBarButton()],
      ),
      addOperationHeroTag: 'guide_add_operation',
      onAddExpense: () => showAddExpenseSheet(context),
      onAddIncome: () => showAddIncomeSheet(context),
      body: const PlatformGuideBody(
        showHeader: false,
        padding: EdgeInsets.fromLTRB(16, 8, 16, kFabBottomPadding),
      ),
    );
  }
}
