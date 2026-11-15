import 'package:flutter_test/flutter_test.dart';
import 'package:food_management/features/inventory/domain/models/food_item.dart';
import 'package:food_management/features/inventory/domain/models/storage_location.dart';
import 'package:food_management/features/recipes/data/mock_recipe_repository.dart';

void main() {
  group('Dynamic Zero-Waste Recipe Generator Tests', () {
    final repository = MockRecipeRepository();
    final now = DateTime.now();

    test('Returns empty list when fridge has no active items', () {
      final recipes = repository.getRecipesWithInventory([]);
      expect(recipes, isEmpty);
    });

    test('Generates tailored recipe when fridge has a single active item', () {
      final singleItem = [
        FoodItem(
          id: 'item-onion',
          name: 'Onion',
          storageLocation: StorageLocation.refrigerator,
          purchaseDate: now.subtract(const Duration(days: 2)),
          expiryDate: now.add(const Duration(days: 5)),
          quantity: 2.0,
          unit: 'pcs',
        ),
      ];

      final recipes = repository.getRecipesWithInventory(singleItem);
      expect(recipes, isNotEmpty);
      expect(recipes.first.name, 'Zero-Waste Sautéed Onion');
      expect(recipes.first.ingredients.any((i) => i.name == 'Onion' && i.isAvailableInFridge), isTrue);
      // Pantry staples should NOT be marked as available in fridge unless actually in fridge
      expect(recipes.first.ingredients.any((i) => i.name == 'Extra Virgin Olive Oil' && !i.isAvailableInFridge), isTrue);
    });

    test('Generates zero-waste recipes prioritizing expiring items when multiple items exist', () {
      final items = [
        FoodItem(
          id: 'item-milk',
          name: 'Whole Milk',
          storageLocation: StorageLocation.refrigerator,
          purchaseDate: now.subtract(const Duration(days: 5)),
          expiryDate: now.add(const Duration(days: 1)), // Expiring soonest
          quantity: 1.0,
          unit: 'L',
        ),
        FoodItem(
          id: 'item-spinach',
          name: 'Organic Spinach',
          storageLocation: StorageLocation.refrigerator,
          purchaseDate: now.subtract(const Duration(days: 1)),
          expiryDate: now.add(const Duration(days: 2)),
          quantity: 200.0,
          unit: 'g',
        ),
        FoodItem(
          id: 'item-apples',
          name: 'Fuji Apples',
          storageLocation: StorageLocation.refrigerator,
          purchaseDate: now.subtract(const Duration(days: 1)),
          expiryDate: now.add(const Duration(days: 10)), // Fresher
          quantity: 4.0,
          unit: 'pcs',
        ),
      ];

      final recipes = repository.getRecipesWithInventory(items);
      expect(recipes.length, greaterThanOrEqualTo(2));

      // Recipe 1 should prioritize Whole Milk (earliest expiry)
      final topRecipe = recipes.first;
      expect(topRecipe.name, contains('Whole Milk'));
      expect(topRecipe.name, contains('Organic Spinach'));
      expect(topRecipe.usesExpiringFood, isTrue);

      // Verify ingredient availability
      final availableIngredients = topRecipe.ingredients.where((i) => i.isAvailableInFridge).toList();
      expect(availableIngredients.length, 2);
      expect(availableIngredients.map((i) => i.name), containsAll(['Whole Milk', 'Organic Spinach']));
    });

    test('Ignores items with zero quantity', () {
      final items = [
        FoodItem(
          id: 'item-empty',
          name: 'Consumed Cheese',
          storageLocation: StorageLocation.refrigerator,
          purchaseDate: now.subtract(const Duration(days: 5)),
          expiryDate: now.add(const Duration(days: 1)),
          quantity: 0.0,
          unit: 'g',
        ),
      ];

      final recipes = repository.getRecipesWithInventory(items);
      expect(recipes, isEmpty);
    });
  });
}
