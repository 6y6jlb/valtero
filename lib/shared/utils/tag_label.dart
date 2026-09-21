import 'package:flutter/widgets.dart';
import 'package:valtero/shared/database/app_database.dart';
import 'package:valtero/shared/l10n/generated/app_localizations.dart';

String tagLabelForKey(AppLocalizations l10n, String key, {String? languageCode}) {
  return switch (key) {
    'groceries' => l10n.tagGroceries,
    'transport' => l10n.tagTransport,
    'housing' => l10n.tagHousing,
    'dining' => l10n.tagDining,
    'health' => l10n.tagHealth,
    'entertainment' => l10n.tagEntertainment,
    'shopping' => l10n.tagShopping,
    'travel' => l10n.tagTravel,
    'utilities' => l10n.tagUtilities,
    'cash' => l10n.tagCash,
    'card' => l10n.tagCard,
    'crypto' => l10n.tagCrypto,
    'transfer' => l10n.tagTransfer,
    'ewallet' => l10n.tagEwallet,
    'salary' => l10n.tagSalary,
    'sale' => l10n.tagSale,
    'gift' => l10n.tagGift,
    'refund' => l10n.tagRefund,
    'investment' => l10n.tagInvestment,
    'other_income' => l10n.tagOtherIncome,
    'household_supplies' => l10n.tagHouseholdSupplies,
    'alcohol' => l10n.tagAlcohol,
    'snacks' => l10n.tagSnacks,
    'pet_food' => l10n.tagPetFood,
    'baby_food' => l10n.tagBabyFood,
    'fuel' => l10n.tagFuel,
    'repair' => l10n.tagRepair,
    'tuning' => l10n.tagTuning,
    'parking' => l10n.tagParking,
    'taxi' => l10n.tagTaxi,
    'public_transit' => l10n.tagPublicTransit,
    'rent' => l10n.tagRent,
    'utilities_bill' => l10n.tagUtilitiesBill,
    'furniture' => l10n.tagFurniture,
    'dacha' => l10n.tagDacha,
    'home_repairs' => l10n.tagHomeRepairs,
    'cleaning' => l10n.tagCleaning,
    'internet' => l10n.tagInternet,
    'restaurant' => l10n.tagRestaurant,
    'cafe' => l10n.tagCafe,
    'delivery' => l10n.tagDelivery,
    'lab_tests' => l10n.tagLabTests,
    'doctor' => l10n.tagDoctor,
    'medications' => l10n.tagMedications,
    'dentistry' => l10n.tagDentistry,
    'optics' => l10n.tagOptics,
    'cinema' => l10n.tagCinema,
    'games' => l10n.tagGames,
    'streaming' => l10n.tagStreaming,
    'events' => l10n.tagEvents,
    'hobbies' => l10n.tagHobbies,
    'clothing' => l10n.tagClothing,
    'electronics' => l10n.tagElectronics,
    'gifts_shopping' => l10n.tagGiftsShopping,
    'home_goods' => l10n.tagHomeGoods,
    'beauty' => l10n.tagBeauty,
    'flights' => l10n.tagFlights,
    'hotels' => l10n.tagHotels,
    'tours' => l10n.tagTours,
    'travel_insurance' => l10n.tagTravelInsurance,
    'visas' => l10n.tagVisas,
    'bonus' => l10n.tagBonus,
    'overtime' => l10n.tagOvertime,
    'advance' => l10n.tagAdvance,
    'personal_items' => l10n.tagPersonalItems,
    'property_sale' => l10n.tagPropertySale,
    'vehicle_sale' => l10n.tagVehicleSale,
    'family_gift' => l10n.tagFamilyGift,
    'friends_gift' => l10n.tagFriendsGift,
    'holiday_gift' => l10n.tagHolidayGift,
    'tax_refund' => l10n.tagTaxRefund,
    'purchase_refund' => l10n.tagPurchaseRefund,
    'insurance_refund' => l10n.tagInsuranceRefund,
    'dividends' => l10n.tagDividends,
    'interest_income' => l10n.tagInterestIncome,
    'capital_gains' => l10n.tagCapitalGains,
    'freelance' => l10n.tagFreelance,
    'cashback' => l10n.tagCashback,
    'side_gig' => l10n.tagSideGig,
    _ => key,
  };
}

String localizedTagLabel(BuildContext context, Tag tag) {
  final l10n = AppLocalizations.of(context)!;
  final lang = Localizations.localeOf(context).languageCode;
  final key = tag.stableKey;
  if (key != null && key.isNotEmpty) {
    return tagLabelForKey(l10n, key, languageCode: lang);
  }
  return tag.name;
}

String tagDisplayLabel(AppLocalizations l10n, Tag tag) {
  final key = tag.stableKey;
  if (key != null && key.isNotEmpty) {
    return tagLabelForKey(l10n, key);
  }
  return tag.name;
}

/// Orders tag ids parent-before-child and joins as "Category · Subcategory".
/// Unrelated top-level tags join with ", ".
String formatOperationTagLabels(
  AppLocalizations l10n,
  List<int> tagIds,
  Map<int, Tag> tagById, {
  Map<int, String>? labelOverrides,
}) {
  if (tagIds.isEmpty) return '';

  String labelOf(Tag tag) =>
      labelOverrides?[tag.id] ?? tagDisplayLabel(l10n, tag);

  final tops = <Tag>[];
  final childrenByParent = <int, List<Tag>>{};
  final orphans = <Tag>[];

  for (final id in tagIds) {
    final tag = tagById[id];
    if (tag == null) continue;
    final parentId = tag.parentTagId;
    if (parentId == null) {
      tops.add(tag);
    } else if (tagIds.contains(parentId) || tagById.containsKey(parentId)) {
      childrenByParent.putIfAbsent(parentId, () => []).add(tag);
    } else {
      orphans.add(tag);
    }
  }

  // Prefer parents that appear in the selection; append orphan children last.
  final parts = <String>[];
  final seenParents = <int>{};
  for (final top in tops) {
    seenParents.add(top.id);
    final kids = childrenByParent[top.id] ?? const [];
    if (kids.isEmpty) {
      parts.add(labelOf(top));
    } else {
      for (final kid in kids) {
        parts.add('${labelOf(top)} · ${labelOf(kid)}');
      }
    }
  }
  for (final entry in childrenByParent.entries) {
    if (seenParents.contains(entry.key)) continue;
    final parent = tagById[entry.key];
    for (final kid in entry.value) {
      if (parent != null) {
        parts.add('${labelOf(parent)} · ${labelOf(kid)}');
      } else {
        parts.add(labelOf(kid));
      }
    }
  }
  for (final orphan in orphans) {
    parts.add(labelOf(orphan));
  }
  return parts.join(', ');
}

/// Combined "Category · Subcategory" labels using id→name and id→parentId maps.
String formatTagLabelsCombined(
  List<int> tagIds,
  Map<int, String> tagLabels,
  Map<int, int?> parentIdByTagId,
) {
  if (tagIds.isEmpty) return '';
  final idSet = tagIds.toSet();
  final ordered = orderTagIdsParentFirst(tagIds, parentIdByTagId);
  final parts = <String>[];
  final used = <int>{};
  for (final id in ordered) {
    if (used.contains(id)) continue;
    final parent = parentIdByTagId[id];
    if (parent != null && idSet.contains(parent)) {
      continue;
    }
    used.add(id);
    final kids = [
      for (final c in ordered)
        if (parentIdByTagId[c] == id) c,
    ];
    final self = tagLabels[id] ?? '?';
    if (kids.isEmpty) {
      parts.add(self);
    } else {
      for (final k in kids) {
        used.add(k);
        parts.add('$self · ${tagLabels[k] ?? '?'}');
      }
    }
  }
  for (final id in ordered) {
    if (!used.contains(id)) {
      parts.add(tagLabels[id] ?? '?');
    }
  }
  return parts.join(', ');
}

/// Subtitle tag text for a recent expense/income/cash-flow row.
String? recentOperationTagsLabel({
  required List<int> tagIds,
  required Map<int, String> tagLabels,
  Map<int, int?> tagParentIds = const {},
}) {
  if (tagIds.isEmpty) return null;
  final combined = formatTagLabelsCombined(tagIds, tagLabels, tagParentIds);
  return combined.isEmpty ? null : combined;
}

/// Orders tag ids so each parent appears before its selected children.
List<int> orderTagIdsParentFirst(
  List<int> tagIds,
  Map<int, int?> parentIdByTagId,
) {
  if (tagIds.length <= 1) return List<int>.from(tagIds);
  final idSet = tagIds.toSet();
  final tops = <int>[];
  final children = <int, List<int>>{};
  final orphans = <int>[];
  for (final id in tagIds) {
    final parent = parentIdByTagId[id];
    if (parent == null) {
      tops.add(id);
    } else if (idSet.contains(parent)) {
      children.putIfAbsent(parent, () => []).add(id);
    } else {
      orphans.add(id);
    }
  }
  final result = <int>[];
  for (final top in tops) {
    result.add(top);
    result.addAll(children[top] ?? const []);
  }
  result.addAll(orphans);
  return result;
}

/// Ordered list of selected tags for display (category then its subcategory).
List<Tag> orderedSelectedTags(
  Iterable<int> tagIds,
  Map<int, Tag> tagById,
) {
  final ids = tagIds.toList();
  final tops = <Tag>[];
  final children = <Tag>[];
  for (final id in ids) {
    final tag = tagById[id];
    if (tag == null) continue;
    if (tag.parentTagId == null) {
      tops.add(tag);
    } else {
      children.add(tag);
    }
  }
  return [...tops, ...children];
}
