import 'package:flutter/material.dart';

/// Categories for food inventory classification.
/// Adheres strictly to zero-emoji design standard with vector iconography.
enum FoodCategory {
  produce(
    label: 'Produce',
    icon: Icons.eco_rounded,
  ),
  dairy(
    label: 'Dairy & Eggs',
    icon: Icons.egg_outlined,
  ),
  meatPoultry(
    label: 'Meat & Poultry',
    icon: Icons.restaurant_rounded,
  ),
  seafood(
    label: 'Seafood',
    icon: Icons.water_drop_rounded,
  ),
  bakery(
    label: 'Bakery',
    icon: Icons.bakery_dining_rounded,
  ),
  beverages(
    label: 'Beverages',
    icon: Icons.local_cafe_rounded,
  ),
  leftovers(
    label: 'Leftovers',
    icon: Icons.takeout_dining_rounded,
  ),
  condiments(
    label: 'Condiments',
    icon: Icons.science_rounded,
  ),
  frozen(
    label: 'Frozen',
    icon: Icons.ac_unit_rounded,
  ),
  other(
    label: 'Other',
    icon: Icons.inventory_2_rounded,
  );

  const FoodCategory({
    required this.label,
    required this.icon,
  });

  final String label;
  final IconData icon;

  /// Helper to parse category from string safely
  static FoodCategory fromString(String? value) {
    if (value == null) return FoodCategory.other;
    return FoodCategory.values.firstWhere(
      (c) => c.name.toLowerCase() == value.toLowerCase() ||
             c.label.toLowerCase() == value.toLowerCase(),
      orElse: () => FoodCategory.other,
    );
  }
}
