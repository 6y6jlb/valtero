import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:valtero/entities/income/model/income_tags_provider.dart';
import 'package:valtero/entities/payment_method/model/payment_methods_provider.dart';
import 'package:valtero/entities/tag/model/tags_provider.dart';
import 'package:valtero/features/add_expense/ui/duplicate_conflict_dialog.dart';
import 'package:valtero/features/add_income/model/add_income_controller.dart';
import 'package:valtero/features/add_income/ui/income_duplicate_conflict_dialog.dart';
import 'package:valtero/shared/database/app_database.dart';
import 'package:valtero/shared/l10n/generated/app_localizations.dart';
import 'package:valtero/shared/utils/payment_method_label.dart';
import 'package:valtero/shared/utils/tag_label.dart';
import 'package:valtero/widgets/app_toast.dart';

/// Resolves soft-duplicate conflicts (if any) then persists [input].
///
/// Returns `true` when the income was saved, `false` when the user cancelled.
Future<bool> saveIncomeWithDuplicateCheck({
  required BuildContext context,
  required WidgetRef ref,
  required AddIncomeInput input,
  required Income? editing,
  required String? draftPaymentLabel,
  required String? draftTagsLabel,
}) async {
  final l10n = AppLocalizations.of(context)!;
  final controller = ref.read(addIncomeControllerProvider);
  final matches = await controller.findPotentialDuplicates(
    input,
    excludeId: editing?.id,
  );
  if (!context.mounted) return false;

  var markUnique = false;
  if (matches.isNotEmpty) {
    final tags = ref.read(tagsStreamProvider).value ?? const [];
    final payments = ref.read(paymentMethodsStreamProvider).value ?? const [];
    final incomeTags =
        ref.read(incomeTagIdsProvider).value ?? const <int, List<int>>{};
    final tagLabels = {
      for (final t in tags) t.id: localizedTagLabel(context, t),
    };
    final paymentLabels = {
      for (final m in payments) m.id: localizedPaymentMethodLabel(context, m),
    };
    String tagsFor(int incomeId) {
      final ids = incomeTags[incomeId] ?? const <int>[];
      if (ids.isEmpty) return '';
      return ids.map((id) => tagLabels[id] ?? '?').join(', ');
    }

    final decision = await showIncomeDuplicateConflictDialog(
      context: context,
      draftOccurredAt: input.occurredAt,
      draftAmountMinor: input.originalAmountMinor,
      draftCurrencyCode: input.originalCurrencyCode,
      draftPaymentLabel: draftPaymentLabel,
      draftCountryCode: input.countryCode,
      draftTagsLabel: draftTagsLabel,
      draftNote: input.note,
      matches: matches,
      paymentLabels: paymentLabels,
      tagsLabelFor: tagsFor,
    );
    if (!context.mounted) return false;
    if (decision == null ||
        decision.action == DuplicateConflictAction.cancel) {
      return false;
    }
    if (decision.action == DuplicateConflictAction.deleteMatchAndSave) {
      await controller.deleteMany(decision.matchIdsToDelete);
    } else if (decision.action == DuplicateConflictAction.saveAsUnique) {
      markUnique = true;
    }
  }

  if (editing != null) {
    await controller.update(editing.id, input, markUnique: markUnique);
  } else {
    await controller.save(input, markUnique: markUnique);
  }
  if (!context.mounted) return false;

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
  return true;
}
