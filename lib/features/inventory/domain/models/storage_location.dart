import 'package:flutter/material.dart';

/// Physical storage compartments for tracked food items.
enum StorageLocation {
  fridge(
    label: 'Fridge',
    icon: Icons.kitchen_rounded,
  ),
  freezer(
    label: 'Freezer',
    icon: Icons.ac_unit_rounded,
  ),
  pantry(
    label: 'Pantry',
    icon: Icons.inventory_rounded,
  );

  const StorageLocation({
    required this.label,
    required this.icon,
  });

  final String label;
  final IconData icon;

  static StorageLocation fromString(String? value) {
    if (value == null) return StorageLocation.fridge;
    return StorageLocation.values.firstWhere(
      (loc) => loc.name.toLowerCase() == value.toLowerCase() ||
               loc.label.toLowerCase() == value.toLowerCase(),
      orElse: () => StorageLocation.fridge,
    );
  }
}
