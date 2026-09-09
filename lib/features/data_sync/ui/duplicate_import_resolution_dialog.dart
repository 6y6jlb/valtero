import 'package:flutter/material.dart';
import 'package:valtero/features/data_sync/model/data_sync_controller.dart';
import 'package:valtero/shared/consts/countries.dart';
import 'package:valtero/shared/database/app_database.dart';
import 'package:valtero/shared/l10n/generated/app_localizations.dart';
import 'package:valtero/widgets/app_button.dart';
import 'package:valtero/widgets/app_close_icon_button.dart';
import 'package:valtero/widgets/app_modal_sheet.dart';
import 'package:valtero/widgets/app_sheet_actions_bar.dart';
import 'package:valtero/widgets/app_sheet_header.dart';
import 'package:valtero/widgets/app_sheet_scaffold.dart';
import 'package:valtero/widgets/expense_duplicate_compare_tile.dart';

enum _ConflictChoice { duplicate, unique }

class ImportDuplicateResolutionResult {
  final Set<String> skipClientIds;
  final Set<String> markUniqueClientIds;

  const ImportDuplicateResolutionResult({
    required this.skipClientIds,
    required this.markUniqueClientIds,
  });
}

/// Returns null if the user cancels the whole import.
Future<ImportDuplicateResolutionResult?> showDuplicateImportResolutionDialog({
  required BuildContext context,
  required List<ImportConflict> conflicts,
  Map<int, String> paymentLabels = const {},
  Map<int, String> Function(Expense expense)? expenseTagsLabelFor,
  Map<int, String> Function(Income income)? incomeTagsLabelFor,
}) {
  return showAppModalSheet<ImportDuplicateResolutionResult>(
    context: context,
    initialChildSize: 0.92,
    minChildSize: 0.5,
    child: DuplicateImportResolutionDialog(
      conflicts: conflicts,
      paymentLabels: paymentLabels,
      expenseTagsLabelFor: expenseTagsLabelFor,
      incomeTagsLabelFor: incomeTagsLabelFor,
    ),
  );
}

class DuplicateImportResolutionDialog extends StatefulWidget {
  final List<ImportConflict> conflicts;
  final Map<int, String> paymentLabels;
  final Map<int, String> Function(Expense expense)? expenseTagsLabelFor;
  final Map<int, String> Function(Income income)? incomeTagsLabelFor;

  const DuplicateImportResolutionDialog({
    super.key,
    required this.conflicts,
    this.paymentLabels = const {},
    this.expenseTagsLabelFor,
    this.incomeTagsLabelFor,
  });

  @override
  State<DuplicateImportResolutionDialog> createState() =>
      _DuplicateImportResolutionDialogState();
}

class _DuplicateImportResolutionDialogState
    extends State<DuplicateImportResolutionDialog> {
  late final Map<String, _ConflictChoice> _choices;
  final Set<String> _selected = {};

  @override
  void initState() {
    super.initState();
    _choices = {
      for (final c in widget.conflicts) c.clientId: _ConflictChoice.duplicate,
    };
  }

  void _setSelected(_ConflictChoice choice) {
    setState(() {
      for (final id in _selected) {
        _choices[id] = choice;
      }
    });
  }

  void _setAll(_ConflictChoice choice) {
    setState(() {
      for (final id in _choices.keys) {
        _choices[id] = choice;
      }
    });
  }

  void _confirm() {
    final skip = <String>{};
    final unique = <String>{};
    for (final entry in _choices.entries) {
      if (entry.value == _ConflictChoice.duplicate) {
        skip.add(entry.key);
      } else {
        unique.add(entry.key);
      }
    }
    Navigator.of(context).pop(
      ImportDuplicateResolutionResult(
        skipClientIds: skip,
        markUniqueClientIds: unique,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final lang = Localizations.localeOf(context).languageCode;
    final allSelected =
        _selected.length == widget.conflicts.length &&
        widget.conflicts.isNotEmpty;
    final someSelected = _selected.isNotEmpty && !allSelected;

    return AppSheetScaffold(
      header: AppSheetHeader(
        title: l10n.dataSyncDuplicatesFoundTitle,
        description: l10n.dataSyncDuplicatesFoundHint,
      ),
      actions: AppSheetActionsBar(
        children: [
          const AppCloseIconButton(),
          AppFilledButton(
            onPressed: _confirm,
            icon: Icons.check,
            label: l10n.dataSyncContinueImport,
          ),
        ],
      ),
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            FilterChip(
              label: Text(l10n.dataSyncMarkAllAsDuplicate),
              selected: false,
              onSelected: (_) => _setAll(_ConflictChoice.duplicate),
            ),
            FilterChip(
              label: Text(l10n.dataSyncMarkAllAsUnique),
              selected: false,
              onSelected: (_) => _setAll(_ConflictChoice.unique),
            ),
            if (_selected.isNotEmpty) ...[
              FilterChip(
                label: Text(l10n.dataSyncMarkSelectedAsDuplicate),
                selected: false,
                onSelected: (_) => _setSelected(_ConflictChoice.duplicate),
              ),
              FilterChip(
                label: Text(l10n.dataSyncMarkSelectedAsUnique),
                selected: false,
                onSelected: (_) => _setSelected(_ConflictChoice.unique),
              ),
            ],
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Checkbox(
              tristate: true,
              value: allSelected ? true : (someSelected ? null : false),
              onChanged: (_) {
                setState(() {
                  if (allSelected) {
                    _selected.clear();
                  } else {
                    _selected
                      ..clear()
                      ..addAll(widget.conflicts.map((c) => c.clientId));
                  }
                });
              },
            ),
            Text(
              l10n.bulkSelectedCount(_selected.length),
              style: theme.textTheme.labelLarge,
            ),
          ],
        ),
        const Divider(height: 1),
        for (final conflict in widget.conflicts)
          _ConflictRow(
            view: _ConflictView.from(
              conflict,
              paymentLabels: widget.paymentLabels,
              expenseTagsLabelFor: widget.expenseTagsLabelFor,
              incomeTagsLabelFor: widget.incomeTagsLabelFor,
            ),
            choice: _choices[conflict.clientId]!,
            selected: _selected.contains(conflict.clientId),
            languageCode: lang,
            onToggleSelected: () {
              setState(() {
                final id = conflict.clientId;
                if (_selected.contains(id)) {
                  _selected.remove(id);
                } else {
                  _selected.add(id);
                }
              });
            },
            onChoice: (choice) {
              setState(() {
                _choices[conflict.clientId] = choice;
              });
            },
          ),
      ],
    );
  }
}

/// Normalizes an [ImportConflict] (expense or income) into primitive fields
/// so [_ConflictRow] doesn't need to branch on the entity type.
class _ConflictView {
  final bool isIncome;
  final String clientId;
  final DateTime incomingOccurredAt;
  final int incomingAmountMinor;
  final String incomingCurrencyCode;
  final String? incomingPaymentLabel;
  final String? incomingCountryCode;
  final String? incomingNote;
  final DateTime existingOccurredAt;
  final int existingAmountMinor;
  final String existingCurrencyCode;
  final String? existingPaymentLabel;
  final String? existingCountryCode;
  final String? existingNote;
  final String? existingTagsLabel;
  final int extraMatchesCount;

  const _ConflictView({
    required this.isIncome,
    required this.clientId,
    required this.incomingOccurredAt,
    required this.incomingAmountMinor,
    required this.incomingCurrencyCode,
    required this.incomingPaymentLabel,
    required this.incomingCountryCode,
    required this.incomingNote,
    required this.existingOccurredAt,
    required this.existingAmountMinor,
    required this.existingCurrencyCode,
    required this.existingPaymentLabel,
    required this.existingCountryCode,
    required this.existingNote,
    required this.existingTagsLabel,
    required this.extraMatchesCount,
  });

  factory _ConflictView.from(
    ImportConflict conflict, {
    required Map<int, String> paymentLabels,
    Map<int, String> Function(Expense expense)? expenseTagsLabelFor,
    Map<int, String> Function(Income income)? incomeTagsLabelFor,
  }) {
    if (conflict.isIncome) {
      final incoming = conflict.incomingIncome!;
      final existing = conflict.existingIncomeMatches.first;
      return _ConflictView(
        isIncome: true,
        clientId: incoming.clientId,
        incomingOccurredAt: incoming.occurredAt,
        incomingAmountMinor: incoming.originalAmountMinor,
        incomingCurrencyCode: incoming.originalCurrencyCode,
        incomingPaymentLabel: incoming.paymentName,
        incomingCountryCode: incoming.countryCode,
        incomingNote: incoming.note,
        existingOccurredAt: existing.occurredAt,
        existingAmountMinor: existing.originalAmountMinor,
        existingCurrencyCode: existing.originalCurrencyCode,
        existingPaymentLabel: existing.paymentMethodId == null
            ? null
            : paymentLabels[existing.paymentMethodId!],
        existingCountryCode: existing.countryCode,
        existingNote: existing.note,
        existingTagsLabel: incomeTagsLabelFor?.call(existing)[existing.id],
        extraMatchesCount: conflict.existingIncomeMatches.length - 1,
      );
    }

    final incoming = conflict.incomingExpense!;
    final existing = conflict.existingExpenseMatches.first;
    return _ConflictView(
      isIncome: false,
      clientId: incoming.clientId,
      incomingOccurredAt: incoming.occurredAt,
      incomingAmountMinor: incoming.originalAmountMinor,
      incomingCurrencyCode: incoming.originalCurrencyCode,
      incomingPaymentLabel: incoming.paymentName,
      incomingCountryCode: incoming.countryCode,
      incomingNote: incoming.note,
      existingOccurredAt: existing.occurredAt,
      existingAmountMinor: existing.originalAmountMinor,
      existingCurrencyCode: existing.originalCurrencyCode,
      existingPaymentLabel: existing.paymentMethodId == null
          ? null
          : paymentLabels[existing.paymentMethodId!],
      existingCountryCode: existing.countryCode,
      existingNote: existing.note,
      existingTagsLabel: expenseTagsLabelFor?.call(existing)[existing.id],
      extraMatchesCount: conflict.existingExpenseMatches.length - 1,
    );
  }
}

class _ConflictRow extends StatelessWidget {
  final _ConflictView view;
  final _ConflictChoice choice;
  final bool selected;
  final String languageCode;
  final VoidCallback onToggleSelected;
  final ValueChanged<_ConflictChoice> onChoice;

  const _ConflictRow({
    required this.view,
    required this.choice,
    required this.selected,
    required this.languageCode,
    required this.onToggleSelected,
    required this.onChoice,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    String? countryFor(String? code) => code == null || code.isEmpty
        ? null
        : countryDisplayName(code, languageCode: languageCode);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        children: [
          Row(
            children: [
              Checkbox(value: selected, onChanged: (_) => onToggleSelected()),
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Chip(
                  label: Text(view.isIncome ? l10n.income : l10n.expense),
                  visualDensity: VisualDensity.compact,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
              Expanded(
                child: SegmentedButton<_ConflictChoice>(
                  segments: [
                    ButtonSegment(
                      value: _ConflictChoice.duplicate,
                      label: Text(l10n.dataSyncMarkAsDuplicate),
                      icon: const Icon(Icons.copy_all_outlined, size: 16),
                    ),
                    ButtonSegment(
                      value: _ConflictChoice.unique,
                      label: Text(l10n.dataSyncMarkAsUnique),
                      icon: const Icon(Icons.fingerprint, size: 16),
                    ),
                  ],
                  selected: {choice},
                  onSelectionChanged: (s) => onChoice(s.first),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: ExpenseDuplicateCompareTile(
                  title: l10n.dataSyncIncomingExpense,
                  occurredAt: view.incomingOccurredAt,
                  amountMinor: view.incomingAmountMinor,
                  currencyCode: view.incomingCurrencyCode,
                  paymentLabel: view.incomingPaymentLabel,
                  countryLabel: countryFor(view.incomingCountryCode),
                  note: view.incomingNote,
                  borderColor: theme.colorScheme.primary.withValues(
                    alpha: 0.35,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ExpenseDuplicateCompareTile(
                  title: l10n.dataSyncExistingExpense,
                  occurredAt: view.existingOccurredAt,
                  amountMinor: view.existingAmountMinor,
                  currencyCode: view.existingCurrencyCode,
                  paymentLabel: view.existingPaymentLabel,
                  countryLabel: countryFor(view.existingCountryCode),
                  tagsLabel: view.existingTagsLabel,
                  note: view.existingNote,
                  borderColor: theme.colorScheme.error.withValues(alpha: 0.35),
                ),
              ),
            ],
          ),
          if (view.extraMatchesCount > 0)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  '+${view.extraMatchesCount}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
