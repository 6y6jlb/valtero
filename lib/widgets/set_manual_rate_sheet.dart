import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:valtero/entities/exchange_rate/model/rate_providers.dart';
import 'package:valtero/entities/exchange_rate/model/rate_resolver.dart';
import 'package:valtero/shared/l10n/generated/app_localizations.dart';
import 'package:valtero/shared/settings/app_settings_provider.dart';
import 'package:valtero/shared/utils/currency_label.dart';
import 'package:valtero/widgets/currency_picker.dart';
import 'package:valtero/widgets/flag_icon.dart';

/// Prompt to enter a manual FX rate.
/// Returns the saved rate, or `null` if cancelled.
Future<double?> showSetManualRateSheet(
  BuildContext context, {
  String? base,
  String? target,
  double? initialRate,
  bool allowPickPair = false,
}) {
  return showModalBottomSheet<double>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    showDragHandle: true,
    constraints: BoxConstraints(
      maxWidth: MediaQuery.sizeOf(context).width,
      minWidth: MediaQuery.sizeOf(context).width,
    ),
    builder: (context) {
      return Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: _SetManualRateBody(
          initialBase: base,
          initialTarget: target,
          initialRate: initialRate,
          allowPickPair: allowPickPair || base == null || target == null,
        ),
      );
    },
  );
}

class _SetManualRateBody extends ConsumerStatefulWidget {
  final String? initialBase;
  final String? initialTarget;
  final double? initialRate;
  final bool allowPickPair;

  const _SetManualRateBody({
    required this.initialBase,
    required this.initialTarget,
    required this.initialRate,
    required this.allowPickPair,
  });

  @override
  ConsumerState<_SetManualRateBody> createState() => _SetManualRateBodyState();
}

class _SetManualRateBodyState extends ConsumerState<_SetManualRateBody> {
  late final TextEditingController _controller;
  late String _base;
  late String _target;
  String? _error;
  bool _fetching = false;
  String? _fetchedNote;

  @override
  void initState() {
    super.initState();
    _base = (widget.initialBase ?? 'USD').toUpperCase();
    _target = (widget.initialTarget ?? 'RUB').toUpperCase();
    _controller = TextEditingController(
      text: widget.initialRate?.toString() ?? '',
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || widget.initialTarget != null) return;
      final primary =
          ref.read(appSettingsProvider).value?.primaryCurrency ?? 'RUB';
      setState(() => _target = primary);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _pickBase() async {
    final code = await showCurrencyPicker(context);
    if (code != null) setState(() => _base = code);
  }

  Future<void> _pickTarget() async {
    final code = await showCurrencyPicker(context);
    if (code != null) setState(() => _target = code);
  }

  Future<void> _fetchFromService() async {
    final l10n = AppLocalizations.of(context)!;
    setState(() {
      _fetching = true;
      _error = null;
      _fetchedNote = null;
    });
    final resolver = ref.read(rateResolverProvider);
    final serviceId = resolver.activeProviderId();
    final serviceLabel = serviceId == 'exchangerate_api'
        ? l10n.rateSourceApi
        : l10n.rateSourceFrankfurter;
    try {
      final rate = await resolver.forceRefreshRate(_base, _target);
      if (!mounted) return;
      setState(() {
        _fetching = false;
        if (rate == null) {
          _error = l10n.connectionFailed;
        } else {
          _controller.text = rate.toString();
          _fetchedNote = l10n.fetchRateFromService(serviceLabel);
        }
      });
    } on RatesCooldownException catch (e) {
      if (!mounted) return;
      final minutes = e.remaining.inMinutes.clamp(1, 60);
      setState(() {
        _fetching = false;
        _error = l10n.ratesFetchCooldown(minutes);
      });
    }
  }

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context)!;
    if (_base == _target) {
      setState(() => _error = l10n.rate);
      return;
    }
    final rate = double.tryParse(
      _controller.text.trim().replaceAll(',', '.'),
    );
    if (rate == null || rate <= 0) {
      setState(() => _error = l10n.rate);
      return;
    }
    await ref.read(rateResolverProvider).setManualRate(
          base: _base,
          target: _target,
          rate: rate,
        );
    if (!mounted) return;
    Navigator.of(context).pop(rate);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final lang = Localizations.localeOf(context).languageCode;
    final custom =
        ref.watch(appSettingsProvider).value?.customCurrencyCodes ?? const [];
    final serviceId = ref.read(rateResolverProvider).activeProviderId();
    final serviceLabel = serviceId == 'exchangerate_api'
        ? l10n.rateSourceApi
        : l10n.rateSourceFrankfurter;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            l10n.setManualRateTitle,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          if (widget.allowPickPair) ...[
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: FlagIcon.currency(_base, size: 28),
              title: Text(l10n.baseCurrency),
              subtitle: Text(
                currencyDisplayLabel(
                  _base,
                  languageCode: lang,
                  customCodes: custom,
                ),
              ),
              trailing: const Icon(Icons.edit_outlined),
              onTap: _pickBase,
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: FlagIcon.currency(_target, size: 28),
              title: Text(l10n.targetCurrency),
              subtitle: Text(
                currencyDisplayLabel(
                  _target,
                  languageCode: lang,
                  customCodes: custom,
                ),
              ),
              trailing: const Icon(Icons.edit_outlined),
              onTap: _pickTarget,
            ),
          ] else
            Row(
              children: [
                FlagIcon.currency(_base, size: 24),
                const SizedBox(width: 8),
                Text('1 $_base ='),
                const SizedBox(width: 8),
                FlagIcon.currency(_target, size: 24),
                const SizedBox(width: 8),
                Text(_target),
              ],
            ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerLeft,
            child: OutlinedButton.icon(
              onPressed: _fetching || _base == _target ? null : _fetchFromService,
              icon: _fetching
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.cloud_download_outlined),
              label: Text(l10n.fetchRateFromService(serviceLabel)),
            ),
          ),
          if (_fetchedNote != null) ...[
            const SizedBox(height: 8),
            Text(
              _fetchedNote!,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
          const SizedBox(height: 12),
          TextField(
            controller: _controller,
            autofocus: true,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              labelText: l10n.rate,
              hintText: l10n.setManualRateHint(_base, _target),
              errorText: _error,
            ),
            onSubmitted: (_) => _save(),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(l10n.cancel),
              ),
              const Spacer(),
              FilledButton(
                onPressed: _save,
                child: Text(l10n.save),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
