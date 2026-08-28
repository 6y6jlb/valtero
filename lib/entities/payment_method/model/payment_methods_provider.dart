import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:valtero/shared/database/app_database.dart';
import 'package:valtero/shared/database/database_provider.dart';

final paymentMethodsStreamProvider = StreamProvider<List<PaymentMethod>>((ref) {
  return ref.watch(appDatabaseProvider).watchAllPaymentMethods();
});
