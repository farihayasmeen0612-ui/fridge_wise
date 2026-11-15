import 'package:flutter_test/flutter_test.dart';
import 'package:food_management/features/inventory/domain/models/expiry_status.dart';
import 'package:food_management/features/inventory/domain/models/food_item.dart';
import 'package:food_management/features/inventory/domain/models/storage_location.dart';

void main() {
  group('FoodItem Model Tests', () {
    final now = DateTime(2026, 10, 22);

    final item = FoodItem(
      id: 'test-1',
      name: 'Organic Milk',
      storageLocation: StorageLocation.refrigerator,
      purchaseDate: now.subtract(const Duration(days: 2)),
      expiryDate: now.add(const Duration(days: 5)),
      quantity: 1.5,
      unit: 'L',
      status: ItemStatus.active,
      notes: 'Opened bottle',
    );

    test('FoodItem properties and defaults', () {
      expect(item.id, 'test-1');
      expect(item.name, 'Organic Milk');
      expect(item.storageLocation, StorageLocation.refrigerator);
      expect(item.quantity, 1.5);
      expect(item.unit, 'L');
      expect(item.status, ItemStatus.active);
      expect(item.notes, 'Opened bottle');
      expect(item.createdAt, item.purchaseDate);
    });

    test('FoodItem copyWith creates modified instance', () {
      final updated = item.copyWith(
        quantity: 0.75,
        notes: 'Half bottle remaining',
      );

      expect(updated.id, item.id);
      expect(updated.name, item.name);
      expect(updated.quantity, 0.75);
      expect(updated.notes, 'Half bottle remaining');
      expect(updated.storageLocation, item.storageLocation);
    });

    test('FoodItem serialization toMap and fromMap roundtrip', () {
      final map = item.toMap();
      final restored = FoodItem.fromMap(map);

      expect(restored.id, item.id);
      expect(restored.name, item.name);
      expect(restored.storageLocation, item.storageLocation);
      expect(restored.quantity, item.quantity);
      expect(restored.unit, item.unit);
      expect(restored.status, item.status);
      expect(restored.notes, item.notes);
    });

    test('FoodItem equality and hashCode', () {
      final itemCopy = item.copyWith();
      expect(item, equals(itemCopy));
      expect(item.hashCode, equals(itemCopy.hashCode));

      final differentItem = item.copyWith(id: 'different-id');
      expect(item, isNot(equals(differentItem)));
    });

    test('StorageLocation fromString supports Refrigerator, Freezer, Deep Fridge, and legacy Fridge', () {
      expect(StorageLocation.fromString('Refrigerator'), StorageLocation.refrigerator);
      expect(StorageLocation.fromString('refrigerator'), StorageLocation.refrigerator);
      expect(StorageLocation.fromString('Fridge'), StorageLocation.refrigerator);
      expect(StorageLocation.fromString('fridge'), StorageLocation.refrigerator);
      expect(StorageLocation.fromString('Freezer'), StorageLocation.freezer);
      expect(StorageLocation.fromString('freezer'), StorageLocation.freezer);
      expect(StorageLocation.fromString('Deep Fridge'), StorageLocation.deepFridge);
      expect(StorageLocation.fromString('deep_fridge'), StorageLocation.deepFridge);
      expect(StorageLocation.fromString('deepfridge'), StorageLocation.deepFridge);
      expect(StorageLocation.fromString(null), StorageLocation.refrigerator);
    });
  });
}
