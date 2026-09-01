import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:valtero/shared/consts/currencies.dart';
import 'package:valtero/shared/l10n/generated/app_localizations.dart';
import 'package:valtero/shared/settings/app_settings_provider.dart';
import 'package:valtero/shared/utils/currency_label.dart';
import 'package:valtero/widgets/app_button.dart';
import 'package:valtero/widgets/app_close_icon_button.dart';
import 'package:valtero/widgets/app_modal_sheet.dart';
import 'package:valtero/widgets/app_sheet_actions_bar.dart';
import 'package:valtero/widgets/app_sheet_header.dart';
import 'package:valtero/widgets/app_sheet_scaffold.dart';
import 'package:valtero/widgets/flag_icon.dart';

enum CurrencyPickerFilter { all, fiat, crypto, custom }

Future<String?> showCurrencyPicker(
  BuildContext context, {
  CurrencyPickerFilter initialFilter = CurrencyPickerFilter.all,
  Set<String>? exclude,
}) {
  return showAppModalSheet<String>(
    context: context,
    initialChildSize: 0.85,
    minChildSize: 0.5,
    maxChildSize: 0.95,
    child: _CurrencyPickerSheet(
      initialFilter: initialFilter,
      exclude: exclude ?? const {},
    ),
  );
}

Future<String?> showAddCustomCurrencyDialog(BuildContext context) {
  final controller = TextEditingController();
  return showAppModalSheet<String>(
    context: context,
    initialChildSize: 0.4,
    minChildSize: 0.3,
    maxChildSize: 0.55,
    child: Builder(
      builder: (context) {
        final l10n = AppLocalizations.of(context)!;
        return AppSheetScaffold(
          header: AppSheetHeader(title: l10n.addCustomCurrency),
          contentPadding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
          actions: AppSheetActionsBar(
            children: [
              const AppCloseIconButton(),
              AppFilledButton(
                onPressed: () {
                  final code = controller.text.trim().toUpperCase();
                  if (code.length < 2) return;
                  Navigator.pop(context, code);
                },
                icon: Icons.add,
                label: l10n.add,
              ),
            ],
          ),
          children: [
            TextField(
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
          ],
        );
      },
    ),
  );
}

class _CurrencyPickerSheet extends ConsumerStatefulWidget {
  final CurrencyPickerFilter initialFilter;
  final Set<String> exclude;

  const _CurrencyPickerSheet({
    required this.initialFilter,
    required this.exclude,
  });

  @override
  ConsumerState<_CurrencyPickerSheet> createState() =>
      _CurrencyPickerSheetState();
}

class _CurrencyPickerSheetState extends ConsumerState<_CurrencyPickerSheet> {
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
    final custom =
        ref.watch(appSettingsProvider).value?.customCurrencyCodes ?? const [];
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

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
          child: Align(
            alignment: Alignment.centerLeft,
            child: AppSheetHeader(title: l10n.currency),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: TextField(
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.search),
              labelText: l10n.currency,
            ),
            onChanged: (v) => setState(() => _query = v),
          ),
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: SingleChildScrollView(
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
        ),
        const SizedBox(height: 8),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            itemCount: filtered.length,
            itemBuilder: (context, index) {
              final c = filtered[index];
              return ListTile(
                leading:
                    c.kind == CurrencyKind.crypto ||
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
        AppSheetActionsBar(
          children: [
            AppTextButton(
              onPressed: () async {
                final code = await showAddCustomCurrencyDialog(context);
                if (code == null) return;
                await ref
                    .read(appSettingsProvider.notifier)
                    .addCustomCurrency(code);
                if (!context.mounted) return;
                Navigator.pop(context, code);
              },
              icon: Icons.add,
              label: l10n.addCustomCurrency,
            ),
            const AppCloseIconButton(),
          ],
        ),
      ],
    );
  }
}
