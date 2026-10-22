import 'package:flutter_test/flutter_test.dart';
import 'package:food_management/features/dashboard/domain/models/inventory_summary.dart';
import 'package:food_management/features/inventory/data/mock_food_repository.dart';
import 'package:food_management/features/inventory/domain/models/activity_log_item.dart';
import 'package:food_management/features/inventory/domain/models/expiry_status.dart';
import 'package:food_management/features/inventory/domain/models/food_category.dart';
import 'package:food_management/features/inventory/domain/models/food_item.dart';
import 'package:food_management/features/inventory/domain/models/storage_location.dart';

void main() {
  group('MockFoodRepository Tests', () {
    late MockFoodRepository repository;

    setUp(() {
      repository = MockFoodRepository();
    });

    tearDown(() {
      repository.dispose();
    });

    test('Initial repository loads seed data with 10 items', () async {
      final items = await repository.getItems();
      expect(items.length, 10);

      final summary = InventorySummary.fromItems(items);
      expect(summary.totalActive, 10);
      expect(summary.expiredCount, greaterThan(0));
      expect(summary.expiringSoonCount, greaterThan(0));
      expect(summary.freshCount, greaterThan(0));
    });

    test('Filter items by StorageLocation (Fridge, Freezer, Pantry)', () async {
      final fridgeItems = await repository.getItems(location: StorageLocation.fridge);
      final freezerItems = await repository.getItems(location: StorageLocation.freezer);
      final pantryItems = await repository.getItems(location: StorageLocation.pantry);

      expect(fridgeItems.every((i) => i.storageLocation == StorageLocation.fridge), isTrue);
      expect(freezerItems.every((i) => i.storageLocation == StorageLocation.freezer), isTrue);
      expect(pantryItems.every((i) => i.storageLocation == StorageLocation.pantry), isTrue);

      expect(fridgeItems.length + freezerItems.length + pantryItems.length, 10);
    });

    test('Filter items by FoodCategory', () async {
      final dairyItems = await repository.getItems(category: FoodCategory.dairy);
      expect(dairyItems.length, 3);
      expect(dairyItems.every((i) => i.category == FoodCategory.dairy), isTrue);
    });

    test('addItem adds item and generates ActivityLog', () async {
      final newItem = FoodItem(
        id: 'custom-item-1',
        name: 'Avocado',
        category: FoodCategory.produce,
        storageLocation: StorageLocation.fridge,
        purchaseDate: DateTime.now(),
        expiryDate: DateTime.now().add(const Duration(days: 4)),
        quantity: 2.0,
        unit: 'pcs',
      );

      await repository.addItem(newItem);

      final fetched = await repository.getItemById('custom-item-1');
      expect(fetched, isNotNull);
      expect(fetched!.name, 'Avocado');

      final logs = await repository.getActivityLogs();
      expect(logs.any((l) => l.actionType == LogActionType.added && l.itemName == 'Avocado'), isTrue);
    });

    test('deleteItem removes item', () async {
      await repository.deleteItem('seed-item-1');
      final fetched = await repository.getItemById('seed-item-1');
      expect(fetched, isNull);

      final items = await repository.getItems();
      expect(items.length, 9);
    });

    test('markConsumed partial deduction and complete consumption', () async {
      // seed-item-3 is Whole Milk, 1.0 L
      await repository.markConsumed('seed-item-3', quantity: 0.4);
      var item = await repository.getItemById('seed-item-3');
      expect(item!.quantity, closeTo(0.6, 0.001));
      expect(item.status, ItemStatus.active);

      // Deduct rest
      await repository.markConsumed('seed-item-3', quantity: 0.6);
      item = await repository.getItemById('seed-item-3');
      expect(item!.quantity, 0.0);
      expect(item.status, ItemStatus.consumed);

      final logs = await repository.getActivityLogs();
      expect(logs.where((l) => l.actionType == LogActionType.consumed).length, 2);
    });

    test('markDiscarded updates status to discarded and logs event', () async {
      await repository.markDiscarded('seed-item-1');
      final item = await repository.getItemById('seed-item-1');
      expect(item!.status, ItemStatus.discarded);

      // Active items count should decrease by 1
      final activeItems = await repository.getItems(status: ItemStatus.active);
      expect(activeItems.length, 9);

      final logs = await repository.getActivityLogs();
      expect(logs.any((l) => l.actionType == LogActionType.discarded), isTrue);
    });
  });
}
