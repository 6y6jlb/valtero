import 'package:valtero/entities/tag/model/tag_kind.dart';
import 'package:valtero/shared/database/app_database.dart';
import 'package:valtero/shared/l10n/generated/app_localizations.dart';

enum ExpenseListViewMode { list, grouping, chart }

enum ExpenseChartBreakdown {
  /// Group by [Expense.countryCode] (ISO).
  country,
  payment,
  tagCustom,
  month,
  year,
  currency,
}

TagKind? tagKindFromChartBreakdown(ExpenseChartBreakdown breakdown) {
  return switch (breakdown) {
    ExpenseChartBreakdown.tagCustom => TagKind.custom,
    _ => null,
  };
}

/// Whether [tag] belongs to a tag-kind chart breakdown.
bool tagMatchesChartBreakdown(Tag tag, ExpenseChartBreakdown breakdown) {
  final kind = tagKindFromChartBreakdown(breakdown);
  if (kind == null) return false;
  return tagMatchesKind(tag, kind);
}

String unspecifiedLabelForChartBreakdown(
  AppLocalizations l10n,
  ExpenseChartBreakdown breakdown,
) {
  return switch (breakdown) {
    ExpenseChartBreakdown.payment => l10n.paymentMethodUnspecified,
    ExpenseChartBreakdown.country => l10n.tagKindUnspecifiedCountry,
    final b when tagKindFromChartBreakdown(b) != null =>
      tagKindUnspecifiedLabel(l10n, tagKindFromChartBreakdown(b)!),
    _ => l10n.untagged,
  };
}

/// Maps persisted settings value (incl. legacy names) to enum.
ExpenseChartBreakdown expenseChartBreakdownFromName(String? name) {
  if (name == null || name.isEmpty) return ExpenseChartBreakdown.currency;
  if (name == 'tags' || name == 'tagCustom') {
    return ExpenseChartBreakdown.tagCustom;
  }
  if (name == 'tagResource') return ExpenseChartBreakdown.payment;
  if (name == 'tagCountry') return ExpenseChartBreakdown.country;
  if (name == 'tagTrip') return ExpenseChartBreakdown.currency;
  return ExpenseChartBreakdown.values.firstWhere(
    (b) => b.name == name,
    orElse: () => ExpenseChartBreakdown.currency,
  );
}
