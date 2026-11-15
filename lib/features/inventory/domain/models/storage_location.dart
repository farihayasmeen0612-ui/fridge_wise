import 'package:flutter/material.dart';

/// Physical storage compartments for tracked food items.
enum StorageLocation {
  refrigerator(
    label: 'Refrigerator',
    icon: Icons.kitchen_rounded,
  ),
  freezer(
    label: 'Freezer',
    icon: Icons.ac_unit_rounded,
  ),
  deepFridge(
    label: 'Deep Fridge',
    icon: Icons.severe_cold_rounded,
  );

  const StorageLocation({
    required this.label,
    required this.icon,
  });

  final String label;
  final IconData icon;

  static StorageLocation fromString(String? value) {
    if (value == null) return StorageLocation.refrigerator;
    final normalized = value.trim().toLowerCase();

    // Backward compatibility for existing records
    if (normalized == 'fridge' || normalized == 'refrigerator') {
      return StorageLocation.refrigerator;
    }
    if (normalized == 'freezer') {
      return StorageLocation.freezer;
    }
    if (normalized == 'deep fridge' ||
        normalized == 'deep_fridge' ||
        normalized == 'deepfridge') {
      return StorageLocation.deepFridge;
    }

    return StorageLocation.values.firstWhere(
      (loc) =>
          loc.name.toLowerCase() == normalized ||
          loc.label.toLowerCase() == normalized,
      orElse: () => StorageLocation.refrigerator,
    );
  }
}
