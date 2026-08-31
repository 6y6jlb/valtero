import 'package:flutter_test/flutter_test.dart';
import 'package:valtero/features/expenses_list/model/dashboard_sample_slices.dart';
import 'package:valtero/features/expenses_list/model/expense_list_view.dart';
import 'package:valtero/shared/l10n/generated/app_localizations_en.dart';

void main() {
  final l10n = AppLocalizationsEn();
  final now = DateTime(2026, 8, 15);

  test('dashboardSampleSlices currency has three demo currencies', () {
    final slices =
        dashboardSampleSlices(l10n, ExpenseChartBreakdown.currency, now: now);
    expect(slices.map((s) => s.key), ['RUB', 'USD', 'EUR']);
  });

  test('dashboardSampleSlices month keys are relative to now', () {
    final slices =
        dashboardSampleSlices(l10n, ExpenseChartBreakdown.month, now: now);
    expect(slices.map((s) => s.key), ['2026-06', '2026-07', '2026-08']);
  });
}
