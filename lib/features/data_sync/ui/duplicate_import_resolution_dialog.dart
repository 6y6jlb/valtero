import 'package:flutter/material.dart';
import 'package:valtero/features/data_sync/model/data_sync_controller.dart';
import 'package:valtero/shared/consts/countries.dart';
import 'package:valtero/shared/database/app_database.dart';
import 'package:valtero/shared/l10n/generated/app_localizations.dart';
import 'package:valtero/widgets/app_modal_sheet.dart';
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
  Map<int, String> Function(Expense expense)? tagsLabelFor,
}) {
  return showAppModalSheet<ImportDuplicateResolutionResult>(
    context: context,
    initialChildSize: 0.92,
    minChildSize: 0.5,
    child: DuplicateImportResolutionDialog(
      conflicts: conflicts,
      paymentLabels: paymentLabels,
      tagsLabelFor: tagsLabelFor,
    ),
  );
}

class DuplicateImportResolutionDialog extends StatefulWidget {
  final List<ImportConflict> conflicts;
  final Map<int, String> paymentLabels;
  final Map<int, String> Function(Expense expense)? tagsLabelFor;

  const DuplicateImportResolutionDialog({
    super.key,
    required this.conflicts,
    this.paymentLabels = const {},
    this.tagsLabelFor,
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
      for (final c in widget.conflicts)
        c.incoming.clientId: _ConflictChoice.duplicate,
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
    final scrollController = PrimaryScrollController.maybeOf(context);
    final lang = Localizations.localeOf(context).languageCode;
    final allSelected = _selected.length == widget.conflicts.length &&
        widget.conflicts.isNotEmpty;
    final someSelected = _selected.isNotEmpty && !allSelected;

    return Column(
      children: [
        Expanded(
          child: ListView(
            controller: scrollController,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            children: [
              Text(
                l10n.dataSyncDuplicatesFoundTitle,
                style: theme.textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(
                l10n.dataSyncDuplicatesFoundHint,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 12),
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
                      onSelected: (_) =>
                          _setSelected(_ConflictChoice.duplicate),
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
                    value: allSelected
                        ? true
                        : (someSelected ? null : false),
                    onChanged: (_) {
                      setState(() {
                        if (allSelected) {
                          _selected.clear();
                        } else {
                          _selected
                            ..clear()
                            ..addAll(
                              widget.conflicts.map((c) => c.incoming.clientId),
                            );
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
                  conflict: conflict,
                  choice: _choices[conflict.incoming.clientId]!,
                  selected: _selected.contains(conflict.incoming.clientId),
                  paymentLabels: widget.paymentLabels,
                  tagsLabelFor: widget.tagsLabelFor,
                  languageCode: lang,
                  onToggleSelected: () {
                    setState(() {
                      final id = conflict.incoming.clientId;
                      if (_selected.contains(id)) {
                        _selected.remove(id);
                      } else {
                        _selected.add(id);
                      }
                    });
                  },
                  onChoice: (choice) {
                    setState(() {
                      _choices[conflict.incoming.clientId] = choice;
                    });
                  },
                ),
            ],
          ),
        ),
        SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: Row(
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(l10n.dismiss),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: FilledButton(
                    onPressed: _confirm,
                    child: Text(l10n.dataSyncContinueImport),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _ConflictRow extends StatelessWidget {
  final ImportConflict conflict;
  final _ConflictChoice choice;
  final bool selected;
  final Map<int, String> paymentLabels;
  final Map<int, String> Function(Expense expense)? tagsLabelFor;
  final String languageCode;
  final VoidCallback onToggleSelected;
  final ValueChanged<_ConflictChoice> onChoice;

  const _ConflictRow({
    required this.conflict,
    required this.choice,
    required this.selected,
    required this.paymentLabels,
    required this.tagsLabelFor,
    required this.languageCode,
    required this.onToggleSelected,
    required this.onChoice,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final incoming = conflict.incoming;
    final existing = conflict.existingMatches.first;

    String? paymentFor(Expense e) =>
        e.paymentMethodId == null ? null : paymentLabels[e.paymentMethodId!];
    String? countryFor(String? code) =>
        code == null || code.isEmpty
            ? null
            : countryDisplayName(code, languageCode: languageCode);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        children: [
          Row(
            children: [
              Checkbox(
                value: selected,
                onChanged: (_) => onToggleSelected(),
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
                  occurredAt: incoming.occurredAt,
                  amountMinor: incoming.originalAmountMinor,
                  currencyCode: incoming.originalCurrencyCode,
                  paymentLabel: incoming.paymentName,
                  countryLabel: countryFor(incoming.countryCode),
                  note: incoming.note,
                  borderColor: theme.colorScheme.primary.withValues(alpha: 0.35),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ExpenseDuplicateCompareTile(
                  title: l10n.dataSyncExistingExpense,
                  occurredAt: existing.occurredAt,
                  amountMinor: existing.originalAmountMinor,
                  currencyCode: existing.originalCurrencyCode,
                  paymentLabel: paymentFor(existing),
                  countryLabel: countryFor(existing.countryCode),
                  tagsLabel: tagsLabelFor?.call(existing)[existing.id],
                  note: existing.note,
                  borderColor: theme.colorScheme.error.withValues(alpha: 0.35),
                ),
              ),
            ],
          ),
          if (conflict.existingMatches.length > 1)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  '+${conflict.existingMatches.length - 1}',
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
