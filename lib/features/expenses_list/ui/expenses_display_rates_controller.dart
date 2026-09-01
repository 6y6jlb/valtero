import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:valtero/entities/exchange_rate/model/rate_providers.dart';
import 'package:valtero/features/expenses_list/ui/display_currency_flow.dart';
import 'package:valtero/shared/database/app_database.dart';
import 'package:valtero/features/expenses_list/model/expense_list_filtering.dart';

/// Owns display-currency + rate-map state for the expenses sheet.
class ExpensesDisplayRatesController {
  ExpensesDisplayRatesController({required this.onChanged});

  final VoidCallback onChanged;

  String? displayCurrency;
  Map<String, double>? displayRates;
  String? displayRatesSourcesKey;
  bool syncingDisplayRates = false;
  int _syncGen = 0;
  String? _syncInFlightKey;

  int? convertedMinor(Expense expense) => expenseConvertedMinor(
        expense,
        displayRates: displayRates,
        displayCurrency: displayCurrency,
      );

  Future<void> pickDisplayCurrency({
    required BuildContext context,
    required WidgetRef ref,
    required Set<String> sources,
    required bool Function() isMounted,
  }) async {
    _syncGen++;
    if (isMounted()) {
      _syncInFlightKey = null;
      syncingDisplayRates = false;
      onChanged();
    }
    final pick = await showDisplayCurrencyPicker(
      context,
      ref,
      sourceCurrencies: sources,
      currentDisplayCurrency: displayCurrency,
    );
    if (!context.mounted) return;
    switch (pick) {
      case DisplayCurrencyCancelled():
        return;
      case DisplayCurrencyCleared():
        displayCurrency = null;
        displayRates = null;
        displayRatesSourcesKey = null;
        _syncInFlightKey = null;
        syncingDisplayRates = false;
        onChanged();
      case DisplayCurrencyChosen(:final code):
        final ok = await ensureRatesForDisplay(
          context,
          ref,
          sourceCurrencies: sources,
          target: code,
        );
        if (!ok || !context.mounted) return;
        final rates = await loadDisplayRates(
          resolver: ref.read(rateResolverProvider),
          sourceCurrencies: sources,
          target: code,
        );
        if (!context.mounted) return;
        displayCurrency = code;
        displayRates = rates;
        displayRatesSourcesKey =
            '${code.toUpperCase()}|${([...sources]..sort()).join(',')}';
        onChanged();
    }
  }

  Future<void> syncDisplayRates({
    required BuildContext context,
    required WidgetRef ref,
    required Set<String> sources,
    required bool Function() isMounted,
  }) async {
    final target = displayCurrency;
    if (target == null) {
      if (isMounted()) {
        displayRatesSourcesKey = null;
        syncingDisplayRates = false;
        onChanged();
      }
      return;
    }
    final key = '${target.toUpperCase()}|${([...sources]..sort()).join(',')}';
    if (key == displayRatesSourcesKey && displayRates != null) return;
    if (key == _syncInFlightKey) return;

    final syncGen = ++_syncGen;
    _syncInFlightKey = key;
    if (isMounted()) {
      syncingDisplayRates = true;
      onChanged();
    }

    final ok = await ensureRatesForDisplay(
      context,
      ref,
      sourceCurrencies: sources,
      target: target,
    );
    if (!_isActive(syncGen, target, isMounted: isMounted)) {
      if (syncGen == _syncGen) _syncInFlightKey = null;
      return;
    }
    if (!ok) {
      _syncInFlightKey = null;
      displayCurrency = null;
      displayRates = null;
      displayRatesSourcesKey = null;
      syncingDisplayRates = false;
      onChanged();
      return;
    }
    final rates = await loadDisplayRates(
      resolver: ref.read(rateResolverProvider),
      sourceCurrencies: sources,
      target: target,
    );
    if (!_isActive(syncGen, target, isMounted: isMounted)) {
      if (syncGen == _syncGen) _syncInFlightKey = null;
      return;
    }
    displayRates = rates;
    displayRatesSourcesKey = key;
    _syncInFlightKey = null;
    syncingDisplayRates = false;
    onChanged();
  }

  bool _isActive(
    int syncGen,
    String target, {
    required bool Function() isMounted,
  }) {
    if (!isMounted()) return false;
    if (syncGen != _syncGen) return false;
    if (displayCurrency != target) {
      _syncInFlightKey = null;
      syncingDisplayRates = false;
      onChanged();
      return false;
    }
    return true;
  }
}
