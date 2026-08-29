import 'package:valtero/entities/tag/model/tag_kind.dart';
import 'package:valtero/shared/database/app_database.dart';
import 'package:valtero/shared/utils/app_timezone.dart';

/// Tag maps and sort hints passed into expense groupers.
class ExpenseGroupingContext {
  final Map<int, List<int>> expenseTags;
  final Map<int, String> tagLabels;
  final Map<int, Tag> tagById;
  final Map<int, String> paymentMethodLabels;
  final String unspecifiedCountryLabel;
  final String unspecifiedCustomLabel;
  final String unspecifiedPaymentLabel;
  final bool ascending;
  final String timeZoneId;

  const ExpenseGroupingContext({
    required this.expenseTags,
    required this.tagLabels,
    required this.tagById,
    required this.paymentMethodLabels,
    required this.unspecifiedCountryLabel,
    required this.unspecifiedCustomLabel,
    required this.unspecifiedPaymentLabel,
    this.ascending = false,
    this.timeZoneId = kSystemTimeZoneId,
  });

  String unspecifiedLabelFor(TagKind kind) {
    return switch (kind) {
      TagKind.custom => unspecifiedCustomLabel,
    };
  }
}
