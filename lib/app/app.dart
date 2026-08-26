import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:valtero/entities/exchange_rate/model/rate_providers.dart';
import 'package:valtero/features/manage_tags/model/manage_tags_controller.dart';
import 'package:valtero/features/tag_suggestions/model/country_detection.dart';
import 'package:valtero/pages/add_expense/add_expense_page.dart';
import 'package:valtero/pages/currency_settings/currency_settings_page.dart';
import 'package:valtero/pages/dashboard/dashboard_page.dart';
import 'package:valtero/pages/expenses_list/expenses_list_page.dart';
import 'package:valtero/pages/export/export_page.dart';
import 'package:valtero/pages/tags_settings/tags_settings_page.dart';
import 'package:valtero/shared/l10n/generated/app_localizations.dart';
import 'package:valtero/shared/settings/app_settings_provider.dart';

class App extends ConsumerStatefulWidget {
  const App({super.key});

  @override
  ConsumerState<App> createState() => _AppState();
}

class _AppState extends ConsumerState<App> {
  int _index = 0;
  bool _bootstrapped = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _bootstrap());
  }

  Future<void> _bootstrap() async {
    if (_bootstrapped) return;
    _bootstrapped = true;
    await ref.read(manageTagsControllerProvider).seedDefaultsIfEmpty();
    final settings = ref.read(appSettingsProvider).value;
    if (settings?.detectedCountryCode == null) {
      await ref.read(detectCountryControllerProvider)();
    }
    // Fire-and-forget daily rate refresh.
    // ignore: unawaited_futures
    ref.read(rateResolverProvider).refreshIfStale();
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(appSettingsProvider);
    final themeMode = settings.when(
      data: (s) => switch (s.themeMode) {
        'light' => ThemeMode.light,
        'dark' => ThemeMode.dark,
        _ => ThemeMode.system,
      },
      loading: () => ThemeMode.system,
      error: (_, _) => ThemeMode.system,
    );
    final locale = settings.when(
      data: (s) => switch (s.locale) {
        'en' => const Locale('en'),
        'ru' => const Locale('ru'),
        _ => null,
      },
      loading: () => null,
      error: (_, _) => null,
    );

    final pages = const [
      DashboardPage(),
      ExpensesListPage(),
      AddExpensePage(),
      TagsSettingsPage(),
      CurrencySettingsPage(),
      ExportPage(),
    ];

    return MaterialApp(
      onGenerateTitle: (context) => AppLocalizations.of(context)!.appTitle,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF2F6F5E)),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2F6F5E),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      themeMode: themeMode,
      locale: locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Builder(
        builder: (context) {
          final l10n = AppLocalizations.of(context)!;
          return Scaffold(
            body: SafeArea(child: pages[_index]),
            bottomNavigationBar: NavigationBar(
              selectedIndex: _index,
              onDestinationSelected: (i) => setState(() => _index = i),
              destinations: [
                NavigationDestination(
                  icon: const Icon(Icons.pie_chart_outline),
                  label: l10n.navDashboard,
                ),
                NavigationDestination(
                  icon: const Icon(Icons.list_alt),
                  label: l10n.navExpenses,
                ),
                NavigationDestination(
                  icon: const Icon(Icons.add_circle_outline),
                  label: l10n.navAdd,
                ),
                NavigationDestination(
                  icon: const Icon(Icons.label_outline),
                  label: l10n.navTags,
                ),
                NavigationDestination(
                  icon: const Icon(Icons.currency_exchange),
                  label: l10n.navCurrency,
                ),
                NavigationDestination(
                  icon: const Icon(Icons.ios_share),
                  label: l10n.navExport,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
