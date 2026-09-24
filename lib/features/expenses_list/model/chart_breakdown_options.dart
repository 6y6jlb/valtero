import 'package:valtero/features/expenses_list/model/expense_list_view.dart';

/// Full expense/income chart breakdown order (matches icon row left → right).
const kExpenseChartBreakdownOrder = <ExpenseChartBreakdown>[
  ExpenseChartBreakdown.country,
  ExpenseChartBreakdown.payment,
  ExpenseChartBreakdown.tagCustom,
  ExpenseChartBreakdown.day,
  ExpenseChartBreakdown.week,
  ExpenseChartBreakdown.month,
  ExpenseChartBreakdown.year,
  ExpenseChartBreakdown.currency,
];

/// Cash-flow chart period order (day → year).
const kCashFlowChartBreakdownOrder = <ExpenseChartBreakdown>[
  ExpenseChartBreakdown.day,
  ExpenseChartBreakdown.week,
  ExpenseChartBreakdown.month,
  ExpenseChartBreakdown.year,
];
