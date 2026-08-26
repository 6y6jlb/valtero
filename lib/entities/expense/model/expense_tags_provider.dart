import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:valtero/shared/database/database_provider.dart';

/// expenseId → list of tag ids
final expenseTagIdsProvider = FutureProvider<Map<int, List<int>>>((ref) async {
  final db = ref.watch(appDatabaseProvider);
  final expenses = await db.getAllExpenses();
  return db.getTagIdsByExpenseIds(expenses.map((e) => e.id).toList());
});
