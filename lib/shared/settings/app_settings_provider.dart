import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_ce/hive.dart';
import 'package:valtero/shared/settings/app_settings.dart';
import 'package:valtero/shared/settings/hive_service.dart';

class AppSettingsNotifier extends AsyncNotifier<AppSettings> {
  static const _boxName = 'app_settings';
  static const _key = 'settings';

  late Box<dynamic> _box;

  @override
  Future<AppSettings> build() async {
    _box = await HiveService.openBox<dynamic>(_boxName);
    final raw = _box.get(_key);
    if (raw is Map) {
      return AppSettings.fromJson(Map<dynamic, dynamic>.from(raw));
    }
    final initial = AppSettings.initial();
    await _box.put(_key, initial.toJson());
    return initial;
  }

  Future<void> _save(AppSettings settings) async {
    await _box.put(_key, settings.toJson());
    state = AsyncValue.data(settings);
  }

  Future<void> updateSettings(AppSettings settings) => _save(settings);

  Future<void> setReportingCurrencies(List<String> codes) async {
    final current = state.value;
    if (current == null) return;
    var primary = current.primaryCurrency;
    if (!codes.contains(primary) && codes.isNotEmpty) {
      primary = codes.first;
    }
    await _save(current.copyWith(
      reportingCurrencies: codes,
      primaryCurrency: primary,
    ));
  }

  Future<void> setPrimaryCurrency(String code) async {
    final current = state.value;
    if (current == null) return;
    await _save(current.copyWith(primaryCurrency: code));
  }

  Future<void> setExchangeRateApiKey(String? key) async {
    final current = state.value;
    if (current == null) return;
    final trimmed = key?.trim();
    if (trimmed == null || trimmed.isEmpty) {
      await _save(current.copyWith(
        clearApiKey: true,
        activeRateProviderId: 'frankfurter',
      ));
    } else {
      await _save(current.copyWith(
        exchangeRateApiKey: trimmed,
        activeRateProviderId: 'exchangerate_api',
      ));
    }
  }

  Future<void> setActiveRateProviderId(String id) async {
    final current = state.value;
    if (current == null) return;
    await _save(current.copyWith(activeRateProviderId: id));
  }

  Future<void> setLastRateRefreshAt(DateTime? at) async {
    final current = state.value;
    if (current == null) return;
    if (at == null) {
      await _save(current.copyWith(clearLastRateRefreshAt: true));
    } else {
      await _save(current.copyWith(lastRateRefreshAt: at));
    }
  }

  Future<void> setDetectedLocation({
    required String? countryCode,
    required String? currency,
  }) async {
    final current = state.value;
    if (current == null) return;
    await _save(current.copyWith(
      detectedCountryCode: countryCode,
      detectedCurrency: currency,
      countryDetectedAt: DateTime.now(),
    ));
  }

  Future<void> setThemeMode(String mode) async {
    final current = state.value;
    if (current == null) return;
    await _save(current.copyWith(themeMode: mode));
  }

  Future<void> setLocale(String locale) async {
    final current = state.value;
    if (current == null) return;
    await _save(current.copyWith(locale: locale));
  }

  Future<void> setMoneyDisplayFormat(String format) async {
    final current = state.value;
    if (current == null) return;
    await _save(current.copyWith(moneyDisplayFormat: format));
  }

  Future<void> setDateDisplayFormat(String format) async {
    final current = state.value;
    if (current == null) return;
    await _save(current.copyWith(dateDisplayFormat: format));
  }

  Future<void> setTimeZoneId(String timeZoneId) async {
    final current = state.value;
    if (current == null) return;
    await _save(current.copyWith(timeZoneId: timeZoneId));
  }

  Future<void> addCustomCurrency(String code) async {
    final current = state.value;
    if (current == null) return;
    final upper = code.trim().toUpperCase();
    if (upper.length < 2 || upper.length > 12) return;
    if (!RegExp(r'^[A-Z0-9]+$').hasMatch(upper)) return;
    if (current.customCurrencyCodes.contains(upper)) return;
    await _save(current.copyWith(
      customCurrencyCodes: [...current.customCurrencyCodes, upper],
    ));
  }

  Future<void> removeCustomCurrency(String code) async {
    final current = state.value;
    if (current == null) return;
    final upper = code.toUpperCase();
    await _save(current.copyWith(
      customCurrencyCodes:
          current.customCurrencyCodes.where((c) => c != upper).toList(),
    ));
  }

  Future<void> setTelegram({
    bool? enabled,
    String? botToken,
    String? chatId,
  }) async {
    final current = state.value;
    if (current == null) return;
    await _save(current.copyWith(
      telegramEnabled: enabled,
      telegramBotToken: botToken,
      telegramChatId: chatId,
    ));
  }

  Future<void> dismissTagSuggestion(String name) async {
    final current = state.value;
    if (current == null) return;
    if (current.dismissedTagSuggestions.contains(name)) return;
    await _save(current.copyWith(
      dismissedTagSuggestions: [...current.dismissedTagSuggestions, name],
    ));
  }

  Future<void> setDefaultTagId(int? id) async {
    final current = state.value;
    if (current == null) return;
    if (id == null) {
      await _save(current.copyWith(clearDefaultTagId: true));
    } else {
      await _save(current.copyWith(defaultTagId: id));
    }
  }

  Future<void> setDefaultPaymentMethodId(int? id) async {
    final current = state.value;
    if (current == null) return;
    if (id == null) {
      await _save(current.copyWith(clearDefaultPaymentMethodId: true));
    } else {
      await _save(current.copyWith(defaultPaymentMethodId: id));
    }
  }

  Future<void> setExpensesListDisplay({
    String? view,
    String? group,
    String? chartBreakdown,
  }) async {
    final current = state.value;
    if (current == null) return;
    await _save(current.copyWith(
      expensesListView: view,
      expensesListGroup: group,
      expensesChartBreakdown: chartBreakdown,
    ));
  }

  Future<void> setDebugLoggingEnabled(bool enabled) async {
    final current = state.value;
    if (current == null) return;
    await _save(current.copyWith(debugLoggingEnabled: enabled));
  }
}

final appSettingsProvider =
    AsyncNotifierProvider<AppSettingsNotifier, AppSettings>(
  AppSettingsNotifier.new,
);
