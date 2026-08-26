import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:valtero/entities/exchange_rate/model/rate_providers.dart';
import 'package:valtero/shared/database/app_database.dart';
import 'package:valtero/shared/database/database_provider.dart';
import 'package:valtero/shared/l10n/generated/app_localizations.dart';
import 'package:valtero/widgets/app_modal_sheet.dart';
import 'package:valtero/widgets/flag_icon.dart';
import 'package:valtero/widgets/set_manual_rate_sheet.dart';

final allExchangeRatesProvider = StreamProvider<List<ExchangeRate>>((ref) {
  return ref.watch(appDatabaseProvider).watchAllExchangeRates();
});

Future<void> showRatesSheet(BuildContext context) {
  return showAppModalSheet(
    context: context,
    child: const RatesSheetBody(),
  );
}

class RatesSheetBody extends ConsumerStatefulWidget {
  const RatesSheetBody({super.key});

  @override
  ConsumerState<RatesSheetBody> createState() => _RatesSheetBodyState();
}

class _RatesSheetBodyState extends ConsumerState<RatesSheetBody> {
  bool _refreshing = false;
  String? _status;

  String _sourceLabel(AppLocalizations l10n, String source) {
    return switch (source) {
      'exchangerate_api' => l10n.rateSourceApi,
      'frankfurter' => l10n.rateSourceFrankfurter,
      'manual' => l10n.rateSourceManual,
      _ => source,
    };
  }

  String _formatTime(DateTime at) {
    final local = at.toLocal();
    return '${local.year}-'
        '${local.month.toString().padLeft(2, '0')}-'
        '${local.day.toString().padLeft(2, '0')} '
        '${local.hour.toString().padLeft(2, '0')}:'
        '${local.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _refresh() async {
    setState(() {
      _refreshing = true;
      _status = null;
    });
    await ref.read(rateResolverProvider).refreshIfStale(force: true);
    if (!mounted) return;
    final l10n = AppLocalizations.of(context)!;
    setState(() {
      _refreshing = false;
      _status = l10n.ratesRefreshed;
    });
  }

  Future<void> _addOrEdit({
    String? base,
    String? target,
    double? rate,
  }) async {
    await showSetManualRateSheet(
      context,
      base: base,
      target: target,
      initialRate: rate,
      allowPickPair: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final ratesAsync = ref.watch(allExchangeRatesProvider);
    final scrollController = PrimaryScrollController.of(context);

    return ratesAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('$e')),
      data: (rates) {
        return CustomScrollView(
          controller: scrollController,
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              sliver: SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      l10n.allRates,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        FilledButton.icon(
                          onPressed: () => _addOrEdit(),
                          icon: const Icon(Icons.add),
                          label: Text(l10n.addRate),
                        ),
                        OutlinedButton.icon(
                          onPressed: _refreshing ? null : _refresh,
                          icon: _refreshing
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Icon(Icons.refresh),
                          label: Text(l10n.refreshRates),
                        ),
                      ],
                    ),
                    if (_status != null) ...[
                      const SizedBox(height: 8),
                      Text(_status!),
                    ],
                  ],
                ),
              ),
            ),
            if (rates.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: Center(child: Text(l10n.noRatesYet)),
              )
            else
              SliverList.separated(
                itemCount: rates.length,
                separatorBuilder: (_, _) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final rate = rates[index];
                  return ListTile(
                    onTap: () => _addOrEdit(
                      base: rate.baseCurrencyCode,
                      target: rate.targetCurrencyCode,
                      rate: rate.rate,
                    ),
                    title: Row(
                      children: [
                        FlagIcon.currency(rate.baseCurrencyCode, size: 20),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            '1 ${rate.baseCurrencyCode} = '
                            '${rate.rate.toStringAsFixed(6)} ${rate.targetCurrencyCode}',
                          ),
                        ),
                        const SizedBox(width: 6),
                        FlagIcon.currency(rate.targetCurrencyCode, size: 20),
                      ],
                    ),
                    subtitle: Text(
                      '${_sourceLabel(l10n, rate.source)} · ${_formatTime(rate.fetchedAt)}',
                    ),
                    trailing: const Icon(Icons.edit_outlined, size: 18),
                  );
                },
              ),
            const SliverToBoxAdapter(child: SizedBox(height: 24)),
          ],
        );
      },
    );
  }
}
