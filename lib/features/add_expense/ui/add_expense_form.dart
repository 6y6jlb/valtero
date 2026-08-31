import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:valtero/entities/payment_method/model/payment_methods_provider.dart';
import 'package:valtero/entities/tag/model/tags_provider.dart';
import 'package:valtero/entities/tag/model/tag_kind.dart';
import 'package:valtero/features/add_expense/model/add_expense_controller.dart';
import 'package:valtero/features/add_expense/ui/add_expense_actions_bar.dart';
import 'package:valtero/features/add_expense/ui/add_expense_meta_section.dart';
import 'package:valtero/features/add_expense/ui/add_expense_save_flow.dart';
import 'package:valtero/features/add_expense/ui/country_picker_dialog.dart';
import 'package:valtero/features/manage_tags/model/manage_tags_controller.dart';
import 'package:valtero/shared/consts/countries.dart';
import 'package:valtero/shared/database/app_database.dart';
import 'package:valtero/shared/database/database_provider.dart';
import 'package:valtero/shared/l10n/generated/app_localizations.dart';
import 'package:valtero/shared/settings/app_settings_provider.dart';
import 'package:valtero/shared/utils/app_timezone.dart';
import 'package:valtero/shared/utils/money.dart';
import 'package:valtero/shared/utils/payment_method_label.dart';
import 'package:valtero/widgets/currency_picker.dart';
import 'package:valtero/widgets/date_text.dart';
import 'package:valtero/widgets/flag_icon.dart';
import 'package:valtero/widgets/set_manual_rate_sheet.dart';
import 'package:valtero/widgets/app_toast.dart';
import 'package:valtero/widgets/tag_color_picker.dart';

class AddExpenseForm extends ConsumerStatefulWidget {
  final Expense? expense;

  const AddExpenseForm({super.key, this.expense});

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
  int? _paymentMethodId;
  String? _countryCode;
  DateTime _occurredAt = DateTime.now();
  double? _rate;
  bool _loadingRate = false;
  bool _primed = false;

  bool get _isEdit => widget.expense != null;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _primeDefaults());
  }

  Future<void> _primeDefaults() async {
    if (_primed) return;
    _primed = true;

    if (_isEdit) {
      await _primeFromExpense(widget.expense!);
      return;
    }

    final settings = ref.read(appSettingsProvider).value;
    if (settings != null) {
      setState(() {
        _currency = settings.primaryCurrency;
        _targetCurrency = settings.primaryCurrency;
        if (settings.defaultTagId != null) {
          _tagIds.add(settings.defaultTagId!);
        }
        _paymentMethodId = settings.defaultPaymentMethodId;
        final detected = settings.detectedCountryCode;
        if (detected != null && detected.isNotEmpty) {
          _countryCode = detected.toUpperCase();
        }
      });
    }
  }

  Future<void> _primeFromExpense(Expense expense) async {
    final settings = ref.read(appSettingsProvider).value;
    final tagIds =
        await ref.read(appDatabaseProvider).getTagIdsForExpense(expense.id);
    if (!mounted) return;
    final converted =
        expense.originalCurrencyCode != expense.storedCurrencyCode;
    setState(() {
      _amountController.text = Money.formatMinor(expense.originalAmountMinor);
      _currency = expense.originalCurrencyCode;
      _convert = converted;
      _targetCurrency = converted
          ? expense.storedCurrencyCode
          : (settings?.primaryCurrency ?? expense.storedCurrencyCode);
      _tagIds
        ..clear()
        ..addAll(tagIds);
      _paymentMethodId = expense.paymentMethodId;
      _countryCode = expense.countryCode;
      _noteController.text = expense.note ?? '';
      _occurredAt = expense.occurredAt;
      _rate = expense.rateUsed;
    });
    if (_convert) await _refreshRate();
  }

  Future<void> _pickCountry() async {
    final code = await showCountryPicker(context);
    if (code == null || !mounted) return;
    await ref.read(appSettingsProvider.notifier).setDetectedLocation(
          countryCode: code,
          currency: ref.read(appSettingsProvider).value?.detectedCurrency,
        );
    if (!mounted) return;
    setState(() => _countryCode = code.toUpperCase());
  }

  void _clearCountry() {
    setState(() => _countryCode = null);
  }

  void _toggleTag(Tag tag, Map<int, Tag> tagById) {
    setState(() {
      toggleTagSelection(
        selected: _tagIds,
        tag: tag,
        tagById: tagById,
        singleSelectPerKind: true,
      );
    });
  }

  Future<void> _addTag() async {
    final l10n = AppLocalizations.of(context)!;
    final result = await showTagEditDialog(
      context,
      title: l10n.newTag,
      initialName: _newTagController.text,
      confirmLabel: l10n.add,
    );
    if (result == null || !mounted) return;
    final id = await ref.read(manageTagsControllerProvider).addTag(
          result.name,
          colorValue: result.colorValue,
        );
    if (!mounted || id <= 0) return;
    _newTagController.clear();
    setState(() {
      _tagIds
        ..clear()
        ..add(id);
    });
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
      showAppToast(context, l10n.amountRequired);
      return;
    }
    if (_convert &&
        _targetCurrency != null &&
        _targetCurrency!.toUpperCase() != _currency.toUpperCase() &&
        _rate == null) {
      await _offerSetRate();
      if (!mounted) return;
      if (_rate == null) {
        showAppToast(context, l10n.rateUnavailable);
        return;
      }
    }
    if (!mounted) return;
    final tags = ref.read(tagsStreamProvider).value ?? const [];
    final payments = ref.read(paymentMethodsStreamProvider).value ?? const [];
    final tagLabels = {for (final t in tags) t.id: t.name};
    final paymentLabels = {
      for (final m in payments) m.id: localizedPaymentMethodLabel(context, m),
    };
    final draftPaymentLabel =
        _paymentMethodId == null ? null : paymentLabels[_paymentMethodId!];
    final draftTagsLabel = _tagIds.isEmpty
        ? null
        : _tagIds.map((id) => tagLabels[id] ?? '?').join(', ');
    final input = AddExpenseInput(
      originalAmountMinor: amount,
      originalCurrencyCode: _currency,
      convert: _convert,
      targetCurrencyCode: _targetCurrency,
      tagIds: _tagIds.toList(),
      paymentMethodId: _paymentMethodId,
      countryCode: _countryCode,
      note: _noteController.text,
      occurredAt: _occurredAt,
    );
    try {
      final saved = await saveExpenseWithDuplicateCheck(
        context: context,
        ref: ref,
        input: input,
        editing: widget.expense,
        draftPaymentLabel: draftPaymentLabel,
        draftTagsLabel: draftTagsLabel,
      );
      if (!mounted) return;
      if (!saved) return;
      if (!_isEdit) {
        _amountController.clear();
        _noteController.clear();
      }
    } catch (_) {
      if (!mounted) return;
      showAppToast(context, l10n.rateUnavailable);
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
    final paymentMethods =
        ref.watch(paymentMethodsStreamProvider).value ?? const [];
    final tagById = {for (final t in tags) t.id: t};
    final reporting = settings?.reportingCurrencies ?? const ['RUB'];
    final scrollController = PrimaryScrollController.maybeOf(context);
    final theme = Theme.of(context);
    final lang = Localizations.localeOf(context).languageCode;
    final tagsSubtitle = _tagIds.isEmpty
        ? l10n.tagsNoneSelected
        : l10n.tagsSelectedCount(_tagIds.length);
    final paymentSubtitle = () {
      if (_paymentMethodId == null) return l10n.paymentMethodNone;
      for (final m in paymentMethods) {
        if (m.id == _paymentMethodId) {
          return localizedPaymentMethodLabel(context, m);
        }
      }
      return l10n.paymentMethodNone;
    }();
    final countrySubtitle = _countryCode == null
        ? l10n.tagKindUnspecifiedCountry
        : countryDisplayName(_countryCode!, languageCode: lang);

    return Column(
      children: [
        Expanded(
          child: ListView(
            controller: scrollController,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            children: [
              Text(
                _isEdit ? l10n.editExpense : l10n.addExpense,
                style: theme.textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _amountController,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
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
              if (!_convert)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    l10n.saveAsIsDescription,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              if (_convert) ...[
                DropdownButtonFormField<String>(
                  // ignore: deprecated_member_use
                  value: reporting.contains(_targetCurrency)
                      ? _targetCurrency
                      : reporting.first,
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
                    style: TextStyle(color: theme.colorScheme.error),
                  ),
                  const SizedBox(height: 8),
                  OutlinedButton.icon(
                    onPressed: _offerSetRate,
                    icon: const Icon(Icons.edit_outlined),
                    label: Text(l10n.setRateNow),
                  ),
                ],
              ],
              const SizedBox(height: 8),
              AddExpenseMetaSection(
                paymentMethods: paymentMethods,
                paymentMethodId: _paymentMethodId,
                paymentSubtitle: paymentSubtitle,
                onPaymentMethodChanged: (id) =>
                    setState(() => _paymentMethodId = id),
                countryCode: _countryCode,
                countrySubtitle: countrySubtitle,
                onPickCountry: _pickCountry,
                onClearCountry: _clearCountry,
                tags: tags,
                tagIds: _tagIds,
                tagsSubtitle: tagsSubtitle,
                onTagTap: (tag) => _toggleTag(tag, tagById),
                newTagController: _newTagController,
                onAddTag: _addTag,
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _noteController,
                decoration: InputDecoration(labelText: l10n.note),
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(l10n.date),
                subtitle: DateText(instant: _occurredAt),
                trailing: const Icon(Icons.calendar_today),
                onTap: () async {
                  final tzId = ref.read(appSettingsProvider).value?.timeZoneId ??
                      kSystemTimeZoneId;
                  final zoned = zonedFromInstant(_occurredAt, tzId);
                  final initial = DateTime(zoned.year, zoned.month, zoned.day);
                  final nowZ = nowInTimeZone(tzId);
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: initial,
                    firstDate: DateTime(2000),
                    lastDate: DateTime(nowZ.year, nowZ.month, nowZ.day)
                        .add(const Duration(days: 365)),
                  );
                  if (picked != null) {
                    setState(() {
                      _occurredAt = wallClockInTimeZone(
                        tzId,
                        year: picked.year,
                        month: picked.month,
                        day: picked.day,
                        hour: zoned.hour,
                        minute: zoned.minute,
                      );
                    });
                  }
                },
              ),
            ],
          ),
        ),
        AddExpenseActionsBar(
          isEdit: _isEdit,
          expenseId: widget.expense?.id,
          onSave: _save,
        ),
      ],
    );
  }
}
