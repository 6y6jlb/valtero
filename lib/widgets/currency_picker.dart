import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:valtero/shared/consts/currencies.dart';
import 'package:valtero/shared/l10n/generated/app_localizations.dart';
import 'package:valtero/shared/settings/app_settings_provider.dart';
import 'package:valtero/shared/utils/currency_label.dart';
import 'package:valtero/widgets/flag_icon.dart';

enum CurrencyPickerFilter { all, fiat, crypto, custom }

Future<String?> showCurrencyPicker(
  BuildContext context, {
  CurrencyPickerFilter initialFilter = CurrencyPickerFilter.all,
  Set<String>? exclude,
}) {
  return showDialog<String>(
    context: context,
    builder: (context) => _CurrencyPickerDialog(
      initialFilter: initialFilter,
      exclude: exclude ?? const {},
    ),
  );
}

Future<String?> showAddCustomCurrencyDialog(BuildContext context) {
  final controller = TextEditingController();
  return showDialog<String>(
    context: context,
    builder: (context) {
      final l10n = AppLocalizations.of(context)!;
      return AlertDialog(
        title: Text(l10n.addCustomCurrency),
        content: TextField(
          controller: controller,
          autofocus: true,
          textCapitalization: TextCapitalization.characters,
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9]')),
            LengthLimitingTextInputFormatter(12),
          ],
          decoration: InputDecoration(
            labelText: l10n.currencyCode,
            hintText: 'BTC',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () {
              final code = controller.text.trim().toUpperCase();
              if (code.length < 2) return;
              Navigator.pop(context, code);
            },
            child: Text(l10n.add),
          ),
        ],
      );
    },
  );
}

class _CurrencyPickerDialog extends ConsumerStatefulWidget {
  final CurrencyPickerFilter initialFilter;
  final Set<String> exclude;

  const _CurrencyPickerDialog({
    required this.initialFilter,
    required this.exclude,
  });

  @override
  ConsumerState<_CurrencyPickerDialog> createState() =>
      _CurrencyPickerDialogState();
}

class _CurrencyPickerDialogState extends ConsumerState<_CurrencyPickerDialog> {
  late CurrencyPickerFilter _filter;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _filter = widget.initialFilter;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final lang = Localizations.localeOf(context).languageCode;
    final custom = ref.watch(appSettingsProvider).value?.customCurrencyCodes ??
        const [];
    final catalog = currenciesCatalog(customCodes: custom);
    final filtered = catalog.where((c) {
      if (widget.exclude.contains(c.code)) return false;
      final matchFilter = switch (_filter) {
        CurrencyPickerFilter.all => true,
        CurrencyPickerFilter.fiat => c.kind == CurrencyKind.fiat,
        CurrencyPickerFilter.crypto => c.kind == CurrencyKind.crypto,
        CurrencyPickerFilter.custom => c.kind == CurrencyKind.custom,
      };
      if (!matchFilter) return false;
      if (_query.isEmpty) return true;
      final q = _query.toLowerCase();
      final label = currencyDisplayLabel(
        c.code,
        languageCode: lang,
        customCodes: custom,
      ).toLowerCase();
      return c.code.toLowerCase().contains(q) || label.contains(q);
    }).toList();

    return AlertDialog(
      title: Text(l10n.currency),
      content: SizedBox(
        width: double.maxFinite,
        height: 460,
        child: Column(
          children: [
            TextField(
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                labelText: l10n.currency,
              ),
              onChanged: (v) => setState(() => _query = v),
            ),
            const SizedBox(height: 8),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  for (final f in CurrencyPickerFilter.values)
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(switch (f) {
                          CurrencyPickerFilter.all => l10n.all,
                          CurrencyPickerFilter.fiat => l10n.currencyFiat,
                          CurrencyPickerFilter.crypto => l10n.currencyCrypto,
                          CurrencyPickerFilter.custom => l10n.currencyCustom,
                        }),
                        selected: _filter == f,
                        onSelected: (_) => setState(() => _filter = f),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                itemCount: filtered.length,
                itemBuilder: (context, index) {
                  final c = filtered[index];
                  return ListTile(
                    leading: c.kind == CurrencyKind.crypto ||
                            c.kind == CurrencyKind.custom
                        ? Icon(
                            c.kind == CurrencyKind.crypto
                                ? Icons.currency_bitcoin
                                : Icons.toll_outlined,
                          )
                        : FlagIcon.currency(c.code, size: 28),
                    title: Text(
                      currencyDisplayLabel(
                        c.code,
                        languageCode: lang,
                        customCodes: custom,
                      ),
                    ),
                    onTap: () => Navigator.pop(context, c.code),
                  );
                },
              ),
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: () async {
                  final code = await showAddCustomCurrencyDialog(context);
                  if (code == null) return;
                  await ref
                      .read(appSettingsProvider.notifier)
                      .addCustomCurrency(code);
                  if (!context.mounted) return;
                  Navigator.pop(context, code);
                },
                icon: const Icon(Icons.add),
                label: Text(l10n.addCustomCurrency),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.cancel),
        ),
      ],
    );
  }
}
