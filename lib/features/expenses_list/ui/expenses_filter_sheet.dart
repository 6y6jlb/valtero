import 'package:flutter/material.dart';
import 'package:valtero/features/expenses_list/model/expense_list_query.dart';
import 'package:valtero/features/expenses_list/ui/expenses_filter_form.dart';
import 'package:valtero/shared/l10n/generated/app_localizations.dart';
import 'package:valtero/widgets/app_modal_sheet.dart';

/// Full-screen-ish filter sheet. Returns the applied draft on Apply, or null.
Future<ExpenseListQuery?> showExpensesFilterSheet({
  required BuildContext context,
  required ExpenseListQuery initial,
  required List<String> currencyOptions,
  required Map<int, String> tagLabels,
  required Map<int, String> paymentLabels,
  required Future<ExpenseListQuery?> Function(ExpenseListQuery draft)
      onPickPeriod,
  required Future<ExpenseListQuery?> Function(ExpenseListQuery draft) onPickTags,
  required Future<ExpenseListQuery?> Function(ExpenseListQuery draft)
      onPickPayment,
}) {
  return showAppModalSheet<ExpenseListQuery>(
    context: context,
    initialChildSize: 0.95,
    minChildSize: 0.5,
    maxChildSize: 1.0,
    child: _ExpensesFilterSheetBody(
      initial: initial,
      currencyOptions: currencyOptions,
      tagLabels: tagLabels,
      paymentLabels: paymentLabels,
      onPickPeriod: onPickPeriod,
      onPickTags: onPickTags,
      onPickPayment: onPickPayment,
    ),
  );
}

class _ExpensesFilterSheetBody extends StatefulWidget {
  final ExpenseListQuery initial;
  final List<String> currencyOptions;
  final Map<int, String> tagLabels;
  final Map<int, String> paymentLabels;
  final Future<ExpenseListQuery?> Function(ExpenseListQuery draft) onPickPeriod;
  final Future<ExpenseListQuery?> Function(ExpenseListQuery draft) onPickTags;
  final Future<ExpenseListQuery?> Function(ExpenseListQuery draft) onPickPayment;

  const _ExpensesFilterSheetBody({
    required this.initial,
    required this.currencyOptions,
    required this.tagLabels,
    required this.paymentLabels,
    required this.onPickPeriod,
    required this.onPickTags,
    required this.onPickPayment,
  });

  @override
  State<_ExpensesFilterSheetBody> createState() =>
      _ExpensesFilterSheetBodyState();
}

class _ExpensesFilterSheetBodyState extends State<_ExpensesFilterSheetBody> {
  late ExpenseListQuery _draft = widget.initial;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final scrollController = PrimaryScrollController.maybeOf(context);

    return ListView(
      controller: scrollController,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      children: [
        Text(l10n.filtersTitle, style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 16),
        ExpensesFilterForm(
          draft: _draft,
          currencyOptions: widget.currencyOptions,
          onPickPeriod: () async {
            final next = await widget.onPickPeriod(_draft);
            if (next != null && mounted) setState(() => _draft = next);
          },
          onCurrencyChanged: (v) {
            setState(() {
              _draft = v == null
                  ? _draft.copyWith(clearCurrencyCode: true)
                  : _draft.copyWith(currencyCode: v);
            });
          },
          onPickTags: () async {
            final next = await widget.onPickTags(_draft);
            if (next != null && mounted) setState(() => _draft = next);
          },
          onPickPayment: () async {
            final next = await widget.onPickPayment(_draft);
            if (next != null && mounted) setState(() => _draft = next);
          },
          onApply: () => Navigator.of(context).pop(_draft),
          onClear: () {
            final defaults = ExpenseListQuery.sessionDefaults();
            setState(() {
              _draft = _draft.copyWith(
                tagIds: {},
                paymentMethodIds: {},
                countryCodes: {},
                clearCurrencyCode: true,
                from: defaults.from,
                to: defaults.to,
                clearFrom: defaults.from == null,
                clearTo: defaults.to == null,
              );
            });
          },
          tagLabels: widget.tagLabels,
          paymentLabels: widget.paymentLabels,
          onClearCurrency: () {
            setState(() => _draft = _draft.copyWith(clearCurrencyCode: true));
          },
          onClearPeriod: () {
            setState(() {
              _draft = _draft.copyWith(clearFrom: true, clearTo: true);
            });
          },
          onClearTags: () {
            setState(() => _draft = _draft.copyWith(tagIds: {}));
          },
          onClearPayment: () {
            setState(() => _draft = _draft.copyWith(paymentMethodIds: {}));
          },
        ),
      ],
    );
  }
}
