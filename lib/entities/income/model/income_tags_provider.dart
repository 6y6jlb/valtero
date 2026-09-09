import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:valtero/shared/database/database_provider.dart';

/// incomeId → list of tag ids (reactive via Drift watch).
final incomeTagIdsProvider = StreamProvider<Map<int, List<int>>>((ref) {
  return ref.watch(appDatabaseProvider).watchAllIncomeTagIds();
});
