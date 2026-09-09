import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:valtero/shared/database/app_database.dart';
import 'package:valtero/shared/database/database_provider.dart';

final allIncomeProvider = StreamProvider<List<Income>>((ref) {
  return ref.watch(appDatabaseProvider).watchIncome();
});
