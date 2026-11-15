import 'package:flutter_test/flutter_test.dart';
import 'package:food_management/core/services/supabase_service.dart';
import 'package:food_management/features/inventory/data/supabase_food_repository.dart';
import 'package:food_management/features/inventory/domain/models/expiry_status.dart';
import 'package:food_management/features/inventory/domain/models/food_item.dart';
import 'package:food_management/features/inventory/domain/models/storage_location.dart';

void main() {
  group('Supabase Constants & URL generation', () {
    test('SupabaseConstants produces correct public CDN photo URL', () {
      const filename = 'input_1792506_8492.jpg';
      final url = SupabaseConstants.getPublicPhotoUrl(filename);
      expect(
        url,
        'https://jwotitqnioaibeapqjgi.supabase.co/storage/v1/object/public/Photos/input_1792506_8492.jpg',
      );
    });

    test('getPublicPhotoUrl handles empty or already-qualified URLs', () {
      expect(SupabaseConstants.getPublicPhotoUrl(''), '');
      expect(
        SupabaseConstants.getPublicPhotoUrl('https://example.com/photo.jpg'),
        'https://example.com/photo.jpg',
      );
    });
  });

  group('SupabaseFoodRepository Tests', () {
    late SupabaseFoodRepository repository;

    setUp(() {
      repository = SupabaseFoodRepository();
    });

    tearDown(() {
      repository.dispose();
    });

    test('getItems returns empty list safely when uninitialized without demo data', () async {
      final items = await repository.getItems();
      expect(items, isEmpty);
    });

    test('getItemById returns null when item does not exist or uninitialized', () async {
      final retrieved = await repository.getItemById('non-existent-id');
      expect(retrieved, isNull);
    });

    test('getActivityLogs retrieves audit logs without crashing', () async {
      final logs = await repository.getActivityLogs();
      expect(logs, isNotNull);
      expect(logs, isEmpty);
    });

    test('deleteItem permanently removes item with full quantity from cache', () async {
      final testItem = FoodItem(
        id: 'sp_onion',
        name: 'Onion',
        storageLocation: StorageLocation.refrigerator,
        purchaseDate: DateTime.now(),
        expiryDate: DateTime.now().add(const Duration(days: 7)),
        quantity: 3,
        unit: 'pcs',
        status: ItemStatus.active,
        notes: 'Category: Vegetable',
      );

      await repository.addItem(testItem);
      expect(await repository.getItemById('sp_onion'), isNotNull);

      await repository.deleteItem('sp_onion');
      expect(await repository.getItemById('sp_onion'), isNull);
    });

    test('markConsumed with partial quantity decrements remaining balance', () async {
      final testItem = FoodItem(
        id: 'sp_garlic',
        name: 'Garlic',
        storageLocation: StorageLocation.refrigerator,
        purchaseDate: DateTime.now(),
        expiryDate: DateTime.now().add(const Duration(days: 7)),
        quantity: 4,
        unit: 'pcs',
        status: ItemStatus.active,
        notes: 'Category: Vegetable',
      );

      await repository.addItem(testItem);
      await repository.markConsumed('sp_garlic', quantity: 1);

      final updated = await repository.getItemById('sp_garlic');
      expect(updated, isNotNull);
      expect(updated!.quantity, 3);
    });

    test('markDiscarded removes item completely from inventory', () async {
      final testItem = FoodItem(
        id: 'sp_curry',
        name: 'Curry',
        storageLocation: StorageLocation.refrigerator,
        purchaseDate: DateTime.now(),
        expiryDate: DateTime.now().add(const Duration(days: 7)),
        quantity: 2,
        unit: 'pcs',
        status: ItemStatus.active,
        notes: 'Category: Cooked Meal',
      );

      await repository.addItem(testItem);
      await repository.markDiscarded('sp_curry');

      expect(await repository.getItemById('sp_curry'), isNull);
    });

    test('User isolation: Repository initialized with different user ID does not share cache or overrides', () async {
      final repoUserA = SupabaseFoodRepository(userId: 'user_a_123');
      final repoUserB = SupabaseFoodRepository(userId: 'user_b_456');

      final itemA = FoodItem(
        id: 'sp_apple',
        name: 'Apple',
        storageLocation: StorageLocation.refrigerator,
        purchaseDate: DateTime.now(),
        expiryDate: DateTime.now().add(const Duration(days: 5)),
        quantity: 2,
        unit: 'pcs',
        status: ItemStatus.active,
      );

      await repoUserA.addItem(itemA);

      // User A should have the item
      expect(await repoUserA.getItemById('sp_apple'), isNotNull);

      // User B should start completely clean and NOT see User A's item
      expect(await repoUserB.getItemById('sp_apple'), isNull);

      repoUserA.dispose();
      repoUserB.dispose();
    });
  });
}

