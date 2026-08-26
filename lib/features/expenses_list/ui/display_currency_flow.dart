import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:valtero/entities/exchange_rate/model/rate_providers.dart';
import 'package:valtero/entities/exchange_rate/model/rate_resolver.dart';
import 'package:valtero/shared/l10n/generated/app_localizations.dart';
import 'package:valtero/shared/settings/app_settings_provider.dart';
import 'package:valtero/widgets/currency_picker.dart';
import 'package:valtero/widgets/flag_icon.dart';
import 'package:valtero/widgets/set_manual_rate_sheet.dart';

typedef RatePair = ({String base, String target});

Future<List<RatePair>> findMissingRatePairs({
  required RateResolver resolver,
  required Iterable<String> sourceCurrencies,
  required String target,
}) async {
  final to = target.toUpperCase();
  final missing = <RatePair>[];
  final seen = <String>{};
  for (final raw in sourceCurrencies) {
    final from = raw.toUpperCase();
    if (from == to || !seen.add(from)) continue;
    final rate = await resolver.getRate(from, to);
    if (rate == null) {
      missing.add((base: from, target: to));
    }
  }
  missing.sort((a, b) => a.base.compareTo(b.base));
  return missing;
}

Future<Map<String, double>> loadDisplayRates({
  required RateResolver resolver,
  required Iterable<String> sourceCurrencies,
  required String target,
}) async {
  final to = target.toUpperCase();
  final rates = <String, double>{};
  for (final raw in sourceCurrencies) {
    final from = raw.toUpperCase();
    if (from == to) {
      rates[from] = 1.0;
      continue;
    }
    final rate = await resolver.getRate(from, to);
    if (rate != null) rates[from] = rate;
  }
  return rates;
}

/// Lets the user fill missing FX pairs. Returns `true` when all pairs exist.
Future<bool> ensureRatesForDisplay(
  BuildContext context,
  WidgetRef ref, {
  required Set<String> sourceCurrencies,
  required String target,
}) async {
  final resolver = ref.read(rateResolverProvider);
  final l10n = AppLocalizations.of(context)!;

  while (context.mounted) {
    final missing = await findMissingRatePairs(
      resolver: resolver,
      sourceCurrencies: sourceCurrencies,
      target: target,
    );
    if (missing.isEmpty) return true;

    if (missing.length == 1) {
      final pair = missing.first;
      if (!context.mounted) return false;
      final rate = await showSetManualRateSheet(
        context,
        base: pair.base,
        target: pair.target,
      );
      if (rate == null) return false;
      continue;
    }

    if (!context.mounted) return false;
    final action = await showDialog<_MissingRatesAction>(
      context: context,
      builder: (ctx) => _MissingRatesDialog(
        target: target,
        pairs: missing,
      ),
    );
    if (action == null || action.cancel) return false;
    if (action.setPair != null) {
      if (!context.mounted) return false;
      await showSetManualRateSheet(
        context,
        base: action.setPair!.base,
        target: action.setPair!.target,
      );
      continue;
    }
    // Retry after user may have set rates elsewhere.
    final stillMissing = await findMissingRatePairs(
      resolver: resolver,
      sourceCurrencies: sourceCurrencies,
      target: target,
    );
    if (stillMissing.isEmpty) return true;
    if (!context.mounted) return false;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.missingRatesStill(stillMissing.length))),
    );
  }
  return false;
}

class _MissingRatesAction {
  final bool cancel;
  final RatePair? setPair;

  const _MissingRatesAction.cancel()
      : cancel = true,
        setPair = null;

  const _MissingRatesAction.retry()
      : cancel = false,
        setPair = null;

  const _MissingRatesAction.set(this.setPair) : cancel = false;
}

class _MissingRatesDialog extends StatelessWidget {
  final String target;
  final List<RatePair> pairs;

  const _MissingRatesDialog({
    required this.target,
    required this.pairs,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return AlertDialog(
      title: Text(l10n.missingRatesTitle),
      content: SizedBox(
        width: 420,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(l10n.missingRatesBody(pairs.length, target)),
            const SizedBox(height: 12),
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 280),
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: pairs.length,
                separatorBuilder: (_, _) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final pair = pairs[index];
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text('${pair.base} → ${pair.target}'),
                    trailing: TextButton(
                      onPressed: () => Navigator.pop(
                        context,
                        _MissingRatesAction.set(pair),
                      ),
                      child: Text(l10n.setRateNow),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () =>
              Navigator.pop(context, const _MissingRatesAction.cancel()),
          child: Text(l10n.cancel),
        ),
        FilledButton(
          onPressed: () =>
              Navigator.pop(context, const _MissingRatesAction.retry()),
          child: Text(l10n.retryConversion),
        ),
      ],
    );
  }
}

/// Result of the display-currency picker.
sealed class DisplayCurrencyPick {
  const DisplayCurrencyPick();
}

class DisplayCurrencyCancelled extends DisplayCurrencyPick {
  const DisplayCurrencyCancelled();
}

class DisplayCurrencyCleared extends DisplayCurrencyPick {
  const DisplayCurrencyCleared();
}

class DisplayCurrencyChosen extends DisplayCurrencyPick {
  final String code;
  const DisplayCurrencyChosen(this.code);
}

/// Opens a selector of reporting currencies (with rate readiness) plus full picker.
Future<DisplayCurrencyPick> showDisplayCurrencyPicker(
  BuildContext context,
  WidgetRef ref, {
  required Set<String> sourceCurrencies,
  String? currentDisplayCurrency,
}) async {
  final result = await showDialog<DisplayCurrencyPick>(
    context: context,
    builder: (ctx) => _DisplayCurrencyDialog(
      sourceCurrencies: sourceCurrencies,
      currentDisplayCurrency: currentDisplayCurrency,
    ),
  );
  return result ?? const DisplayCurrencyCancelled();
}

class _DisplayCurrencyDialog extends ConsumerStatefulWidget {
  final Set<String> sourceCurrencies;
  final String? currentDisplayCurrency;

  const _DisplayCurrencyDialog({
    required this.sourceCurrencies,
    required this.currentDisplayCurrency,
  });

  @override
  ConsumerState<_DisplayCurrencyDialog> createState() =>
      _DisplayCurrencyDialogState();
}

class _DisplayCurrencyDialogState
    extends ConsumerState<_DisplayCurrencyDialog> {
  late Future<Map<String, List<RatePair>>> _statusFuture;

  @override
  void initState() {
    super.initState();
    _statusFuture = _loadStatuses();
  }

  Future<Map<String, List<RatePair>>> _loadStatuses() async {
    final settings = ref.read(appSettingsProvider).value;
    final candidates = <String>{
      if (settings != null) settings.primaryCurrency,
      ...?settings?.reportingCurrencies,
      ...widget.sourceCurrencies,
    }.map((c) => c.toUpperCase()).toList()
      ..sort();

    final resolver = ref.read(rateResolverProvider);
    final out = <String, List<RatePair>>{};
    for (final code in candidates) {
      out[code] = await findMissingRatePairs(
        resolver: resolver,
        sourceCurrencies: widget.sourceCurrencies,
        target: code,
      );
    }
    return out;
  }

  Future<void> _pickOther() async {
    final code = await showCurrencyPicker(context);
    if (!mounted || code == null) return;
    Navigator.pop(context, DisplayCurrencyChosen(code.toUpperCase()));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return AlertDialog(
      title: Text(l10n.displayIn),
      content: SizedBox(
        width: 420,
        child: FutureBuilder<Map<String, List<RatePair>>>(
          future: _statusFuture,
          builder: (context, snap) {
            if (!snap.hasData) {
              return const SizedBox(
                height: 120,
                child: Center(child: CircularProgressIndicator()),
              );
            }
            final statuses = snap.data!;
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 360),
                  child: ListView(
                    shrinkWrap: true,
                    children: [
                      ListTile(
                        leading: Icon(
                          widget.currentDisplayCurrency == null
                              ? Icons.check_circle
                              : Icons.money_off_outlined,
                        ),
                        title: Text(l10n.displayOriginal),
                        subtitle: Text(l10n.displayOriginalHint),
                        onTap: () => Navigator.pop(
                          context,
                          const DisplayCurrencyCleared(),
                        ),
                      ),
                      const Divider(),
                      for (final entry in statuses.entries)
                        ListTile(
                          leading: FlagIcon.currency(entry.key, size: 22),
                          title: Text(entry.key),
                          subtitle: Text(
                            entry.value.isEmpty
                                ? l10n.ratesReady
                                : l10n.ratesMissingCount(entry.value.length),
                          ),
                          trailing: entry.value.isEmpty
                              ? Icon(
                                  Icons.check,
                                  color: Theme.of(context).colorScheme.primary,
                                )
                              : Icon(
                                  Icons.warning_amber_outlined,
                                  color: Theme.of(context).colorScheme.error,
                                ),
                          selected:
                              widget.currentDisplayCurrency == entry.key,
                          onTap: () => Navigator.pop(
                            context,
                            DisplayCurrencyChosen(entry.key),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton.icon(
                    onPressed: _pickOther,
                    icon: const Icon(Icons.search),
                    label: Text(l10n.pickOtherCurrency),
                  ),
                ),
              ],
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () =>
              Navigator.pop(context, const DisplayCurrencyCancelled()),
          child: Text(l10n.cancel),
        ),
      ],
    );
  }
}
