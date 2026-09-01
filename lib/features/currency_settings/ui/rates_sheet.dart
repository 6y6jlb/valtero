import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:valtero/entities/exchange_rate/model/rate_providers.dart';
import 'package:valtero/entities/exchange_rate/model/rate_resolver.dart';
import 'package:valtero/shared/database/app_database.dart';
import 'package:valtero/shared/database/database_provider.dart';
import 'package:valtero/shared/l10n/generated/app_localizations.dart';
import 'package:valtero/widgets/app_button.dart';
import 'package:valtero/widgets/app_modal_sheet.dart';
import 'package:valtero/widgets/app_sheet_header.dart';
import 'package:valtero/widgets/app_toast.dart';
import 'package:valtero/widgets/flag_icon.dart';
import 'package:valtero/widgets/set_manual_rate_sheet.dart';

final allExchangeRatesProvider = StreamProvider<List<ExchangeRate>>((ref) {
  return ref.watch(appDatabaseProvider).watchAllExchangeRates();
});

Future<void> showRatesSheet(BuildContext context) {
  return showAppModalSheet(context: context, child: const RatesSheetBody());
}

class RatesSheetBody extends ConsumerStatefulWidget {
  const RatesSheetBody({super.key});

  @override
  ConsumerState<RatesSheetBody> createState() => _RatesSheetBodyState();
}

class _RatesSheetBodyState extends ConsumerState<RatesSheetBody> {
  bool _refreshing = false;
  String? _refreshingPair;
  String? _bulkFetchStatus;

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

  Future<void> _refreshAll() async {
    setState(() {
      _refreshing = true;
      _bulkFetchStatus = null;
    });
    final resolver = ref.read(rateResolverProvider);
    final l10n = AppLocalizations.of(context)!;
    final cooldown = resolver.rateFetchCooldownRemaining();
    if (cooldown != null) {
      final minutes = cooldown.inMinutes.clamp(1, 60);
      setState(() {
        _refreshing = false;
        _bulkFetchStatus = l10n.ratesFetchCooldown(minutes);
      });
      return;
    }
    final serviceId = resolver.activeProviderId();
    final serviceLabel = serviceId == 'exchangerate_api'
        ? l10n.rateSourceApi
        : l10n.rateSourceFrankfurter;
    try {
      final count = await resolver.refreshAllRates();
      if (!mounted) return;
      setState(() {
        _refreshing = false;
        _bulkFetchStatus = null;
      });
      showAppToast(context, l10n.fetchAllRatesDone(count, serviceLabel));
    } on RatesCooldownException catch (e) {
      if (!mounted) return;
      final minutes = e.remaining.inMinutes.clamp(1, 60);
      setState(() {
        _refreshing = false;
        _bulkFetchStatus = l10n.ratesFetchCooldown(minutes);
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _refreshing = false;
        _bulkFetchStatus = l10n.connectionFailed;
      });
    }
  }

  Future<void> _refreshPair(String base, String target) async {
    final key = '$base-$target';
    setState(() => _refreshingPair = key);
    final l10n = AppLocalizations.of(context)!;
    try {
      final rate = await ref
          .read(rateResolverProvider)
          .forceRefreshRate(base, target);
      if (!mounted) return;
      setState(() => _refreshingPair = null);
      showAppToast(
        context,
        rate == null ? l10n.connectionFailed : l10n.ratesRefreshed,
      );
    } on RatesCooldownException catch (e) {
      if (!mounted) return;
      final minutes = e.remaining.inMinutes.clamp(1, 60);
      setState(() => _refreshingPair = null);
      showAppToast(context, l10n.ratesFetchCooldown(minutes));
    }
  }

  Future<void> _addOrEdit({String? base, String? target, double? rate}) async {
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
    final serviceId = ref.read(rateResolverProvider).activeProviderId();
    final serviceLabel = serviceId == 'exchangerate_api'
        ? l10n.rateSourceApi
        : l10n.rateSourceFrankfurter;

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
                    AppSheetHeader(title: l10n.allRates),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        AppFilledButton(
                          onPressed: () => _addOrEdit(),
                          icon: Icons.add,
                          label: l10n.addRate,
                        ),
                        AppOutlinedButton(
                          onPressed: _refreshing ? null : _refreshAll,
                          busy: _refreshing,
                          icon: Icons.cloud_download_outlined,
                          label: l10n.fetchAllRatesFrom(serviceLabel),
                        ),
                      ],
                    ),
                    if (_bulkFetchStatus != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        _bulkFetchStatus!,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
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
                  final pairKey =
                      '${rate.baseCurrencyCode}-${rate.targetCurrencyCode}';
                  final pairBusy = _refreshingPair == pairKey;
                  return ListTile(
                    onTap: () => _addOrEdit(
                      base: rate.baseCurrencyCode,
                      target: rate.targetCurrencyCode,
                      rate: rate.rate,
                    ),
                    // Align trailing with the title (flag + rate) row, not the
                    // full three-line tile height.
                    titleAlignment: ListTileTitleAlignment.titleHeight,
                    title: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
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
                      '${_sourceLabel(l10n, rate.source)} · ${_formatTime(rate.fetchedAt)}'
                      '${rate.source != 'manual' ? '\n${l10n.rateFetchedFromCache(_sourceLabel(l10n, rate.source))}' : ''}',
                    ),
                    isThreeLine: rate.source != 'manual',
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        if (rate.source != 'manual')
                          IconButton(
                            tooltip: l10n.rateRefreshPair,
                            visualDensity: VisualDensity.compact,
                            constraints: const BoxConstraints(
                              minWidth: 36,
                              minHeight: 36,
                            ),
                            padding: EdgeInsets.zero,
                            onPressed: pairBusy || _refreshing
                                ? null
                                : () => _refreshPair(
                                    rate.baseCurrencyCode,
                                    rate.targetCurrencyCode,
                                  ),
                            icon: pairBusy
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Icon(Icons.refresh, size: 20),
                          ),
                        IconButton(
                          visualDensity: VisualDensity.compact,
                          constraints: const BoxConstraints(
                            minWidth: 36,
                            minHeight: 36,
                          ),
                          padding: EdgeInsets.zero,
                          onPressed: () => _addOrEdit(
                            base: rate.baseCurrencyCode,
                            target: rate.targetCurrencyCode,
                            rate: rate.rate,
                          ),
                          icon: const Icon(Icons.edit_outlined, size: 20),
                        ),
                      ],
                    ),
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
