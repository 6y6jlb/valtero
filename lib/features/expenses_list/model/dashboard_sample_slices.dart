import 'package:valtero/features/expenses_list/model/donut_chart_slice.dart';
import 'package:valtero/features/expenses_list/model/expense_list_view.dart';
import 'package:valtero/shared/consts/palette.dart';
import 'package:valtero/shared/l10n/generated/app_localizations.dart';

/// Demo donut slices shown on an empty dashboard (no real expenses yet).
List<DonutChartSlice> dashboardSampleSlices(
  AppLocalizations l10n,
  ExpenseChartBreakdown breakdown, {
  DateTime? now,
}) {
  final clock = now ?? DateTime.now();
  switch (breakdown) {
    case ExpenseChartBreakdown.country:
      return [
        DonutChartSlice(
          key: 'sample_ru',
          label: l10n.guideSampleCountryRu,
          amountMinor: 520000,
          color: chartColorAt(0),
        ),
        DonutChartSlice(
          key: 'sample_ge',
          label: l10n.guideSampleCountryGe,
          amountMinor: 210000,
          color: chartColorAt(1),
        ),
        DonutChartSlice(
          key: 'sample_tr',
          label: l10n.guideSampleCountryTr,
          amountMinor: 150000,
          color: chartColorAt(2),
        ),
      ];
    case ExpenseChartBreakdown.payment:
      return [
        DonutChartSlice(
          key: 'sample_cash',
          label: l10n.tagCash,
          amountMinor: 380000,
          color: chartColorAt(0),
        ),
        DonutChartSlice(
          key: 'sample_card',
          label: l10n.tagCard,
          amountMinor: 450000,
          color: chartColorAt(1),
        ),
        DonutChartSlice(
          key: 'sample_crypto',
          label: l10n.tagCrypto,
          amountMinor: 120000,
          color: chartColorAt(2),
        ),
      ];
    case ExpenseChartBreakdown.tagCustom:
      return [
        DonutChartSlice(
          key: 'sample_groceries',
          label: l10n.guideSampleGroceries,
          amountMinor: 420000,
          color: chartColorAt(0),
        ),
        DonutChartSlice(
          key: 'sample_transport',
          label: l10n.guideSampleTransport,
          amountMinor: 180000,
          color: chartColorAt(1),
        ),
        DonutChartSlice(
          key: 'sample_dining',
          label: l10n.guideSampleDining,
          amountMinor: 260000,
          color: chartColorAt(2),
        ),
      ];
    case ExpenseChartBreakdown.day:
      String dayKey(DateTime d) =>
          '${d.year}-${d.month.toString().padLeft(2, '0')}-'
          '${d.day.toString().padLeft(2, '0')}';
      return [
        DonutChartSlice(
          key: dayKey(clock.subtract(const Duration(days: 2))),
          label: dayKey(clock.subtract(const Duration(days: 2))),
          amountMinor: 90000,
          color: chartColorAt(0),
        ),
        DonutChartSlice(
          key: dayKey(clock.subtract(const Duration(days: 1))),
          label: dayKey(clock.subtract(const Duration(days: 1))),
          amountMinor: 140000,
          color: chartColorAt(1),
        ),
        DonutChartSlice(
          key: dayKey(clock),
          label: dayKey(clock),
          amountMinor: 110000,
          color: chartColorAt(2),
        ),
      ];
    case ExpenseChartBreakdown.week:
      DateTime mondayOf(DateTime d) =>
          DateTime(d.year, d.month, d.day)
              .subtract(Duration(days: d.weekday - DateTime.monday));
      String weekKey(DateTime d) {
        final m = mondayOf(d);
        return '${m.year}-${m.month.toString().padLeft(2, '0')}-'
            '${m.day.toString().padLeft(2, '0')}';
      }
      return [
        DonutChartSlice(
          key: weekKey(clock.subtract(const Duration(days: 14))),
          label: weekKey(clock.subtract(const Duration(days: 14))),
          amountMinor: 310000,
          color: chartColorAt(0),
        ),
        DonutChartSlice(
          key: weekKey(clock.subtract(const Duration(days: 7))),
          label: weekKey(clock.subtract(const Duration(days: 7))),
          amountMinor: 450000,
          color: chartColorAt(1),
        ),
        DonutChartSlice(
          key: weekKey(clock),
          label: weekKey(clock),
          amountMinor: 280000,
          color: chartColorAt(2),
        ),
      ];
    case ExpenseChartBreakdown.month:
      String monthKey(DateTime d) =>
          '${d.year}-${d.month.toString().padLeft(2, '0')}';
      return [
        DonutChartSlice(
          key: monthKey(DateTime(clock.year, clock.month - 2)),
          label: monthKey(DateTime(clock.year, clock.month - 2)),
          amountMinor: 310000,
          color: chartColorAt(0),
        ),
        DonutChartSlice(
          key: monthKey(DateTime(clock.year, clock.month - 1)),
          label: monthKey(DateTime(clock.year, clock.month - 1)),
          amountMinor: 450000,
          color: chartColorAt(1),
        ),
        DonutChartSlice(
          key: monthKey(clock),
          label: monthKey(clock),
          amountMinor: 280000,
          color: chartColorAt(2),
        ),
      ];
    case ExpenseChartBreakdown.year:
      return [
        DonutChartSlice(
          key: '${clock.year - 2}',
          label: '${clock.year - 2}',
          amountMinor: 720000,
          color: chartColorAt(0),
        ),
        DonutChartSlice(
          key: '${clock.year - 1}',
          label: '${clock.year - 1}',
          amountMinor: 890000,
          color: chartColorAt(1),
        ),
        DonutChartSlice(
          key: '${clock.year}',
          label: '${clock.year}',
          amountMinor: 540000,
          color: chartColorAt(2),
        ),
      ];
    case ExpenseChartBreakdown.currency:
      return [
        DonutChartSlice(
          key: 'RUB',
          label: 'RUB',
          amountMinor: 520000,
          color: chartColorAt(0),
        ),
        DonutChartSlice(
          key: 'USD',
          label: 'USD',
          amountMinor: 210000,
          color: chartColorAt(1),
        ),
        DonutChartSlice(
          key: 'EUR',
          label: 'EUR',
          amountMinor: 150000,
          color: chartColorAt(2),
        ),
      ];
  }
}
