import 'package:valtero/entities/tag/model/tag_kind.dart';
import 'package:valtero/features/expenses_list/model/expense_list_query.dart';
import 'package:valtero/features/expenses_list/model/grouping/income_grouper.dart';
import 'package:valtero/shared/consts/countries.dart';
import 'package:valtero/shared/database/app_database.dart';
import 'package:valtero/shared/utils/app_timezone.dart';

final class _CurrencyIncomeGrouper extends IncomeGrouperBase {
  const _CurrencyIncomeGrouper();

  @override
  Iterable<String> labelsFor(Income income, IncomeGroupingContext context) =>
      [income.storedCurrencyCode];
}

final class _DateIncomeGrouper extends IncomeGrouperBase {
  const _DateIncomeGrouper();

  @override
  Iterable<String> labelsFor(Income income, IncomeGroupingContext context) =>
      [calendarDayKey(income.occurredAt, context.timeZoneId)];

  @override
  int compareGroupLabels(
    String a,
    String b,
    IncomeGroupingContext context,
  ) =>
      context.ascending ? a.compareTo(b) : b.compareTo(a);
}

final class _CountryIncomeGrouper extends IncomeGrouperBase {
  const _CountryIncomeGrouper();

  @override
  Iterable<String> labelsFor(Income income, IncomeGroupingContext context) {
    final code = income.countryCode;
    if (code == null || code.isEmpty) {
      return [context.unspecifiedCountryLabel];
    }
    return [countryDisplayName(code)];
  }
}

final class _PaymentIncomeGrouper extends IncomeGrouperBase {
  const _PaymentIncomeGrouper();

  @override
  Iterable<String> labelsFor(Income income, IncomeGroupingContext context) {
    final id = income.paymentMethodId;
    if (id == null) return [context.unspecifiedPaymentLabel];
    return [context.paymentMethodLabels[id] ?? '?'];
  }
}

final class _TagIncomeGrouper extends IncomeGrouperBase {
  const _TagIncomeGrouper();

  @override
  Iterable<String> labelsFor(Income income, IncomeGroupingContext context) {
    final ids = context.incomeTags[income.id] ?? const <int>[];
    final matching = <int>[
      for (final id in ids)
        if (context.tagById[id] != null &&
            tagKindOf(context.tagById[id]!) == TagKind.income)
          id,
    ];
    if (matching.isEmpty) return [context.unspecifiedIncomeLabel];
    matching.sort(
      (a, b) => (context.tagById[a]?.sortOrder ?? 0)
          .compareTo(context.tagById[b]?.sortOrder ?? 0),
    );
    return [context.tagLabels[matching.first] ?? '?'];
  }
}

const _currency = _CurrencyIncomeGrouper();
const _date = _DateIncomeGrouper();
const _payment = _PaymentIncomeGrouper();
const _country = _CountryIncomeGrouper();
const _tag = _TagIncomeGrouper();

IncomeGrouper incomeGrouperFor(ExpenseListGroup group) {
  return switch (group) {
    ExpenseListGroup.none || ExpenseListGroup.currency => _currency,
    ExpenseListGroup.date => _date,
    ExpenseListGroup.payment => _payment,
    ExpenseListGroup.tag || ExpenseListGroup.tagCustom => _tag,
    ExpenseListGroup.country => _country,
  };
}
