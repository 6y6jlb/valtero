import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:valtero/entities/exchange_rate/model/rate_providers.dart';
import 'package:valtero/shared/database/app_database.dart';
import 'package:valtero/shared/database/database_provider.dart';
import 'package:valtero/shared/utils/money.dart';

class AddExpenseInput {
  final int originalAmountMinor;
  final String originalCurrencyCode;
  final bool convert;
  final String? targetCurrencyCode;
  final List<int> tagIds;
  final int? paymentMethodId;
  final String? note;
  final DateTime occurredAt;

  const AddExpenseInput({
    required this.originalAmountMinor,
    required this.originalCurrencyCode,
    required this.convert,
    this.targetCurrencyCode,
    this.tagIds = const [],
    this.paymentMethodId,
    this.note,
    required this.occurredAt,
  });
}

class AddExpenseController {
  final Ref ref;

  AddExpenseController(this.ref);

  Future<double?> previewRate(String from, String to) {
    return ref.read(rateResolverProvider).getRate(from, to);
  }

  Future<int> save(AddExpenseInput input) async {
    final db = ref.read(appDatabaseProvider);
    final original = input.originalCurrencyCode.toUpperCase();
    var storedMinor = input.originalAmountMinor;
    var storedCurrency = original;
    double? rateUsed;
    DateTime? rateTimestamp;

    if (input.convert &&
        input.targetCurrencyCode != null &&
        input.targetCurrencyCode!.toUpperCase() != original) {
      final target = input.targetCurrencyCode!.toUpperCase();
      final rate = await ref.read(rateResolverProvider).getRate(original, target);
      if (rate == null) {
        throw StateError('rate_unavailable');
      }
      storedMinor = Money.convertMinor(
        originalMinor: input.originalAmountMinor,
        rate: rate,
      );
      storedCurrency = target;
      rateUsed = rate;
      rateTimestamp = DateTime.now();
    }

    final id = await db.insertExpense(
      ExpensesCompanion.insert(
        occurredAt: input.occurredAt,
        originalAmountMinor: input.originalAmountMinor,
        originalCurrencyCode: original,
        storedAmountMinor: storedMinor,
        storedCurrencyCode: storedCurrency,
        rateUsed: Value(rateUsed),
        rateTimestamp: Value(rateTimestamp),
        paymentMethodId: Value(input.paymentMethodId),
        note: Value(input.note?.trim().isEmpty == true ? null : input.note?.trim()),
        createdAt: DateTime.now(),
      ),
    );
    await db.setExpenseTags(id, input.tagIds);
    return id;
  }

  Future<void> delete(int id) {
    return ref.read(appDatabaseProvider).deleteExpenseById(id);
  }
}

final addExpenseControllerProvider = Provider<AddExpenseController>((ref) {
  return AddExpenseController(ref);
});
