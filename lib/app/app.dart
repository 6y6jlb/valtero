import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:valtero/entities/exchange_rate/model/rate_providers.dart';
import 'package:valtero/features/google_drive_sync/model/google_drive_sync_scheduler.dart';
import 'package:valtero/features/manage_tags/model/manage_tags_controller.dart';
import 'package:valtero/features/manage_payment_methods/model/manage_payment_methods_controller.dart';
import 'package:valtero/features/tag_suggestions/model/country_detection.dart';
import 'package:valtero/pages/dashboard/dashboard_page.dart';
import 'package:valtero/shared/l10n/generated/app_localizations.dart';
import 'package:valtero/shared/settings/app_settings_provider.dart';

class App extends ConsumerStatefulWidget {
  const App({super.key});

  @override
  ConsumerState<App> createState() => _AppState();
}

class _AppState extends ConsumerState<App> {
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
    await ref.read(managePaymentMethodsControllerProvider).seedDefaults();
    var settings = ref.read(appSettingsProvider).value;
    if (settings?.detectedCountryCode == null) {
      await ref.read(detectCountryControllerProvider)();
    }
    // ignore: unawaited_futures
    ref.read(rateResolverProvider).refreshIfStale();
    ref.read(googleDriveSyncSchedulerProvider).start();
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
        'es' => const Locale('es'),
        'sr' => const Locale('sr'),
        _ => null,
      },
      loading: () => null,
      error: (_, _) => null,
    );

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
      localeResolutionCallback: (deviceLocale, supported) {
        if (locale != null) return locale;
        if (deviceLocale != null) {
          for (final supportedLocale in supported) {
            if (supportedLocale.languageCode == deviceLocale.languageCode) {
              return supportedLocale;
            }
          }
        }
        return const Locale('en');
      },
      home: const DashboardPage(),
    );
  }
}
