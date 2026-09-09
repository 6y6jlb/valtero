import 'package:flutter/material.dart';

/// Curated icon keys for category tags (expense + income).
///
/// Stored as [Tags.iconKey]; resolved to [IconData] via [iconDataForTagKey].
const List<String> curatedTagIconKeys = [
  // Expense categories
  'groceries',
  'transport',
  'housing',
  'dining',
  'health',
  'entertainment',
  'shopping',
  'travel',
  'utilities',
  // Income categories
  'salary',
  'sale',
  'gift',
  'refund',
  'investment',
  'other',
  // Generic
  'work',
  'education',
  'pets',
  'sports',
  'coffee',
  'phone',
  'subscriptions',
];

/// Default [iconKey] for a seeded [stableKey], if known.
String? defaultIconKeyForStableKey(String stableKey) {
  const map = <String, String>{
    'groceries': 'groceries',
    'transport': 'transport',
    'housing': 'housing',
    'dining': 'dining',
    'health': 'health',
    'entertainment': 'entertainment',
    'shopping': 'shopping',
    'travel': 'travel',
    'utilities': 'utilities',
    'salary': 'salary',
    'sale': 'sale',
    'gift': 'gift',
    'refund': 'refund',
    'investment': 'investment',
    'other_income': 'other',
  };
  return map[stableKey];
}

IconData? iconDataForTagKey(String? iconKey) {
  if (iconKey == null || iconKey.isEmpty) return null;
  return switch (iconKey) {
    'groceries' => Icons.shopping_basket_outlined,
    'transport' => Icons.directions_bus_outlined,
    'housing' => Icons.home_outlined,
    'dining' => Icons.restaurant_outlined,
    'health' => Icons.local_hospital_outlined,
    'entertainment' => Icons.movie_outlined,
    'shopping' => Icons.shopping_bag_outlined,
    'travel' => Icons.flight_outlined,
    'utilities' => Icons.bolt_outlined,
    'salary' => Icons.payments_outlined,
    'sale' => Icons.sell_outlined,
    'gift' => Icons.card_giftcard_outlined,
    'refund' => Icons.undo_outlined,
    'investment' => Icons.trending_up_outlined,
    'other' => Icons.more_horiz,
    'work' => Icons.work_outline,
    'education' => Icons.school_outlined,
    'pets' => Icons.pets_outlined,
    'sports' => Icons.sports_soccer_outlined,
    'coffee' => Icons.coffee_outlined,
    'phone' => Icons.phone_android_outlined,
    'subscriptions' => Icons.subscriptions_outlined,
    _ => null,
  };
}
