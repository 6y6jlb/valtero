import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:valtero/shared/database/database_provider.dart';

/// expenseId → list of tag ids (reactive via Drift watch).
final expenseTagIdsProvider = StreamProvider<Map<int, List<int>>>((ref) {
  return ref.watch(appDatabaseProvider).watchAllExpenseTagIds();
});
