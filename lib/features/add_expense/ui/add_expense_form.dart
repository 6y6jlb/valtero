import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:valtero/entities/tag/model/tags_provider.dart';
import 'package:valtero/entities/tag/ui/tag_chip.dart';
import 'package:valtero/entities/expense/model/expense_tags_provider.dart';
import 'package:valtero/features/add_expense/model/add_expense_controller.dart';
import 'package:valtero/features/add_expense/ui/country_picker_dialog.dart';
import 'package:valtero/features/manage_tags/model/manage_tags_controller.dart';
import 'package:valtero/shared/consts/countries.dart';
import 'package:valtero/shared/database/database_provider.dart';
import 'package:valtero/shared/l10n/generated/app_localizations.dart';
import 'package:valtero/shared/settings/app_settings_provider.dart';
import 'package:valtero/shared/utils/money.dart';
import 'package:valtero/widgets/app_toast.dart';
import 'package:valtero/widgets/currency_picker.dart';
import 'package:valtero/widgets/flag_icon.dart';
import 'package:valtero/widgets/set_manual_rate_sheet.dart';
import 'package:valtero/widgets/tag_color_picker.dart';

class AddExpenseForm extends ConsumerStatefulWidget {
  const AddExpenseForm({super.key});

  @override
  ConsumerState<AddExpenseForm> createState() => _AddExpenseFormState();
}

class _AddExpenseFormState extends ConsumerState<AddExpenseForm> {
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  final _newTagController = TextEditingController();

  String _currency = 'RUB';
  bool _convert = false;
  String? _targetCurrency;
  final Set<int> _tagIds = {};
  DateTime _occurredAt = DateTime.now();
  double? _rate;
  bool _loadingRate = false;
  String? _error;
  bool _countryPrimed = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _primeDefaults());
  }

  Future<void> _primeDefaults() async {
    final settings = ref.read(appSettingsProvider).value;
    if (settings != null) {
      setState(() {
        _currency = settings.primaryCurrency;
        _targetCurrency = settings.primaryCurrency;
        if (settings.defaultTagId != null) {
          _tagIds.add(settings.defaultTagId!);
        }
      });
    }
    await _ensureDetectedCountrySelected();
  }

  Future<void> _ensureDetectedCountrySelected() async {
    if (_countryPrimed) return;
    _countryPrimed = true;
    final settings = ref.read(appSettingsProvider).value;
    final code = settings?.detectedCountryCode;
    if (code == null || code.isEmpty) return;
    final lang = settings?.locale == 'ru'
        ? 'ru'
        : settings?.locale == 'en'
            ? 'en'
            : WidgetsBinding.instance.platformDispatcher.locale.languageCode;
    final id = await ref.read(appDatabaseProvider).ensureCountryTag(
          countryCode: code,
          displayName: countryDisplayName(code, languageCode: lang),
        );
    if (!mounted) return;
    setState(() => _tagIds.add(id));
  }

  Future<void> _pickCountry() async {
    final code = await showCountryPicker(context);
    if (code == null || !mounted) return;
    final lang = Localizations.localeOf(context).languageCode;
    final id = await ref.read(appDatabaseProvider).ensureCountryTag(
          countryCode: code,
          displayName: countryDisplayName(code, languageCode: lang),
        );
    await ref.read(appSettingsProvider.notifier).setDetectedLocation(
          countryCode: code,
          currency: ref.read(appSettingsProvider).value?.detectedCurrency,
        );
    if (!mounted) return;
    setState(() => _tagIds.add(id));
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    _newTagController.dispose();
    super.dispose();
  }

  Future<void> _offerSetRate() async {
    final target = _targetCurrency;
    if (target == null) return;
    final rate = await showSetManualRateSheet(
      context,
      base: _currency,
      target: target,
    );
    if (!mounted || rate == null) return;
    setState(() {
      _rate = rate;
      _error = null;
    });
  }

  Future<void> _refreshRate() async {
    if (!_convert || _targetCurrency == null || _targetCurrency == _currency) {
      setState(() => _rate = _currency == _targetCurrency ? 1.0 : null);
      return;
    }
    setState(() => _loadingRate = true);
    final rate = await ref
        .read(addExpenseControllerProvider)
        .previewRate(_currency, _targetCurrency!);
    if (!mounted) return;
    setState(() {
      _rate = rate;
      _loadingRate = false;
    });
  }

  Future<void> _save({bool retrying = false}) async {
    final l10n = AppLocalizations.of(context)!;
    final amount = Money.parseMajorToMinor(_amountController.text);
    if (amount <= 0) {
      setState(() => _error = l10n.amount);
      return;
    }
    if (_convert &&
        _targetCurrency != null &&
        _targetCurrency!.toUpperCase() != _currency.toUpperCase() &&
        _rate == null) {
      await _offerSetRate();
      if (_rate == null) {
        setState(() => _error = l10n.rateUnavailable);
        return;
      }
    }
    try {
      await ref.read(addExpenseControllerProvider).save(
            AddExpenseInput(
              originalAmountMinor: amount,
              originalCurrencyCode: _currency,
              convert: _convert,
              targetCurrencyCode: _targetCurrency,
              tagIds: _tagIds.toList(),
              note: _noteController.text,
              occurredAt: _occurredAt,
            ),
          );
      ref.invalidate(expenseTagIdsProvider);
      if (!mounted) return;
      _amountController.clear();
      _noteController.clear();
      setState(() => _error = null);
      final overlay = Overlay.of(context);
      final theme = Theme.of(context);
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
      showAppToastOn(
        overlay: overlay,
        theme: theme,
        message: l10n.save,
      );
    } catch (_) {
      if (!mounted) return;
      setState(() => _error = l10n.rateUnavailable);
      if (retrying) return;
      await _offerSetRate();
      if (_rate != null) {
        await _save(retrying: true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final settings = ref.watch(appSettingsProvider).value;
    final tags = ref.watch(tagsStreamProvider).value ?? const [];
    final reporting = settings?.reportingCurrencies ?? const ['RUB'];
    final normalTags = tags.where((t) => t.kind != 'country' && t.kind != 'resource').toList();
    final countryTags = tags.where((t) => t.kind == 'country').toList();
    final resourceTags = tags.where((t) => t.kind == 'resource').toList();
    final scrollController = PrimaryScrollController.maybeOf(context);

    return ListView(
      controller: scrollController,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      children: [
        Text(l10n.addExpense, style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 16),
        TextField(
          controller: _amountController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
          ],
          decoration: InputDecoration(labelText: l10n.amount),
        ),
        const SizedBox(height: 12),
        ListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(l10n.currency),
          subtitle: CurrencyCodeLabel(_currency),
          trailing: const Icon(Icons.arrow_drop_down),
          onTap: () async {
            final code = await showCurrencyPicker(context);
            if (code == null) return;
            setState(() => _currency = code);
            _refreshRate();
          },
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(_convert ? l10n.convertTo : l10n.saveAsIs),
          value: _convert,
          onChanged: (v) {
            setState(() => _convert = v);
            _refreshRate();
          },
        ),
        if (_convert) ...[
          DropdownButtonFormField<String>(
            // ignore: deprecated_member_use
            value: reporting.contains(_targetCurrency) ? _targetCurrency : reporting.first,
            isExpanded: true,
            decoration: InputDecoration(labelText: l10n.convertTo),
            items: [
              for (final code in reporting)
                DropdownMenuItem(
                  value: code,
                  child: CurrencyCodeLabel(code),
                ),
            ],
            onChanged: (v) {
              setState(() => _targetCurrency = v);
              _refreshRate();
            },
          ),
          const SizedBox(height: 8),
          if (_loadingRate)
            const LinearProgressIndicator()
          else if (_rate != null)
            Text(l10n.exchangeRate(_rate!.toStringAsFixed(6)))
          else ...[
            Text(
              l10n.rateUnavailable,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: _offerSetRate,
              icon: const Icon(Icons.edit_outlined),
              label: Text(l10n.setRateNow),
            ),
          ],
        ],
        const SizedBox(height: 12),
        Text(l10n.tag, style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final tag in countryTags)
              TagChip(
                tag: tag,
                selected: _tagIds.contains(tag.id),
                onTap: () {
                  setState(() {
                    if (_tagIds.contains(tag.id)) {
                      _tagIds.remove(tag.id);
                    } else {
                      _tagIds.add(tag.id);
                    }
                  });
                },
              ),
            ActionChip(
              avatar: const Icon(Icons.public, size: 18),
              label: Text(l10n.selectCountry),
              onPressed: _pickCountry,
            ),
            for (final tag in resourceTags)
              TagChip(
                tag: tag,
                selected: _tagIds.contains(tag.id),
                onTap: () {
                  setState(() {
                    if (_tagIds.contains(tag.id)) {
                      _tagIds.remove(tag.id);
                    } else {
                      _tagIds.add(tag.id);
                    }
                  });
                },
              ),
            for (final tag in normalTags)
              TagChip(
                tag: tag,
                selected: _tagIds.contains(tag.id),
                onTap: () {
                  setState(() {
                    if (_tagIds.contains(tag.id)) {
                      _tagIds.remove(tag.id);
                    } else {
                      _tagIds.add(tag.id);
                    }
                  });
                },
              ),
          ],
        ),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _newTagController,
                decoration: InputDecoration(labelText: l10n.newTag),
              ),
            ),
            IconButton(
              onPressed: () async {
                final result = await showTagEditDialog(
                  context,
                  title: l10n.newTag,
                  initialName: _newTagController.text,
                  confirmLabel: l10n.add,
                );
                if (result == null) return;
                final id = await ref.read(manageTagsControllerProvider).addTag(
                      result.name,
                      colorValue: result.colorValue,
                    );
                if (id > 0) {
                  _newTagController.clear();
                  setState(() => _tagIds.add(id));
                }
              },
              icon: const Icon(Icons.add),
              tooltip: l10n.addTag,
            ),
          ],
        ),
        TextField(
          controller: _noteController,
          decoration: InputDecoration(labelText: l10n.note),
        ),
        ListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(l10n.date),
          subtitle: Text(
            '${_occurredAt.year}-${_occurredAt.month.toString().padLeft(2, '0')}-${_occurredAt.day.toString().padLeft(2, '0')}',
          ),
          trailing: const Icon(Icons.calendar_today),
          onTap: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: _occurredAt,
              firstDate: DateTime(2000),
              lastDate: DateTime.now().add(const Duration(days: 365)),
            );
            if (picked != null) {
              setState(() {
                _occurredAt = DateTime(
                  picked.year,
                  picked.month,
                  picked.day,
                  _occurredAt.hour,
                  _occurredAt.minute,
                );
              });
            }
          },
        ),
        if (_error != null)
          Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
        const SizedBox(height: 16),
        FilledButton(onPressed: _save, child: Text(l10n.save)),
      ],
    );
  }
}
