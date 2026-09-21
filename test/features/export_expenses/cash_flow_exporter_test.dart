import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:valtero/features/export_expenses/data/cash_flow_exporter.dart';
import 'package:valtero/shared/database/app_database.dart';

Expense _expense({
  required int id,
  required DateTime at,
  int amount = 1000,
  String currency = 'USD',
  int? paymentMethodId,
  String? countryCode,
  String? note,
}) {
  return Expense(
    kind: 'expense',
    id: id,
    syncId: 'sync-$id',
    occurredAt: at,
    originalAmountMinor: amount,
    originalCurrencyCode: currency,
    storedAmountMinor: amount,
    storedCurrencyCode: currency,
    paymentMethodId: paymentMethodId,
    countryCode: countryCode,
    note: note,
    createdAt: at,
    updatedAt: at,
    duplicateDismissed: false,
  );
}

Income _income({
  required int id,
  required DateTime at,
  int amount = 2000,
  String currency = 'EUR',
}) {
  return Income(
    kind: 'income',
    id: id,
    syncId: 'sync-$id',
    occurredAt: at,
    originalAmountMinor: amount,
    originalCurrencyCode: currency,
    storedAmountMinor: amount,
    storedCurrencyCode: currency,
    createdAt: at,
    updatedAt: at,
    duplicateDismissed: false,
  );
}

void main() {
  final exporter = CashFlowExporter();
  final at = DateTime.utc(2026, 3, 5, 14, 30);
  final tagNames = {10: 'Food', 20: 'Salary'};
  final paymentNames = {1: 'Card'};

  final rows = <CashFlowExportRow>[
    (
      operation: _expense(
        id: 1,
        at: at,
        paymentMethodId: 1,
        countryCode: 'US',
        note: 'Lunch',
      ),
      isIncome: false,
      tagIds: [10],
    ),
    (
      operation: _income(id: 2, at: at),
      isIncome: true,
      tagIds: [20],
    ),
  ];

  test('buildCsv includes type column and formatted amounts', () {
    final csv = exporter.buildCsv(rows, tagNames, paymentNames: paymentNames);
    expect(csv, contains('type,id,occurredAt'));
    expect(csv, contains('expense,1,'));
    expect(csv, contains('income,2,'));
    expect(csv, contains('10.00'));
    expect(csv, contains('20.00'));
    expect(csv, contains('Card'));
    expect(csv, contains('Food'));
    expect(csv, contains('Salary'));
    expect(csv, contains('Lunch'));
  });

  test('buildJson encodes direction, tags and payment names', () {
    final jsonText = exporter.buildJson(rows, tagNames, paymentNames: paymentNames);
    final decoded = jsonDecode(jsonText) as List<dynamic>;
    expect(decoded.length, 2);

    final expense = decoded[0] as Map<String, dynamic>;
    expect(expense['type'], CashFlowExporter.expenseType);
    expect(expense['id'], 1);
    expect(expense['storedAmount'], '10.00');
    expect(expense['paymentMethod'], 'Card');
    expect(expense['tags'], ['Food']);
    expect(expense['note'], 'Lunch');

    final income = decoded[1] as Map<String, dynamic>;
    expect(income['type'], CashFlowExporter.incomeType);
    expect(income['storedCurrency'], 'EUR');
    expect(income['tags'], ['Salary']);
    expect(income['paymentMethod'], isNull);
  });
}
