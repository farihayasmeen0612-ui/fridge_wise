import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../inventory/data/inventory_providers.dart';
import '../../inventory/domain/models/food_item.dart';
import '../domain/models/recipe.dart';

/// Zero-waste recipe recommendation repository.
/// Generates culinary recipe recommendations dynamically matched against
/// the user's active inventory items. If the inventory is empty, returns an empty list.
class MockRecipeRepository {
  List<Recipe> getRecipes() {
    return const [];
  }

  /// Dynamically computes recipe recommendations based on the actual items in the user's fridge.
  /// Prioritizes food items that are expiring soonest so they can be consumed before spoiling.
  List<Recipe> getRecipesWithInventory(List<FoodItem> fridgeItems) {
    // Only consider active items with positive stock
    final activeItems = fridgeItems.where((item) => item.quantity > 0).toList();
    if (activeItems.isEmpty) {
      return const [];
    }

    // Sort active items so expiring items are prioritized
    final sortedItems = List<FoodItem>.from(activeItems)
      ..sort((a, b) => a.expiryDate.compareTo(b.expiryDate));

    final recipes = <Recipe>[];

    String cleanName(String name) {
      return name.trim();
    }

    // 1. Primary Zero-Waste Skillet / Sauté Recipe (Features top 1 or 2 urgent items)
    final top1 = sortedItems[0];
    final top2 = sortedItems.length > 1 ? sortedItems[1] : null;

    final recipe1Ingredients = <RecipeIngredient>[
      RecipeIngredient(
        name: cleanName(top1.name),
        quantity: top1.quantity,
        unit: top1.unit,
        isAvailableInFridge: true,
        isExpiringSoon: top1.isExpiringSoon || top1.isExpired,
      ),
      if (top2 != null)
        RecipeIngredient(
          name: cleanName(top2.name),
          quantity: top2.quantity,
          unit: top2.unit,
          isAvailableInFridge: true,
          isExpiringSoon: top2.isExpiringSoon || top2.isExpired,
        ),
      const RecipeIngredient(
        name: 'Extra Virgin Olive Oil',
        quantity: 15,
        unit: 'ml',
        isAvailableInFridge: false,
      ),
      const RecipeIngredient(
        name: 'Salt & Black Pepper',
        quantity: 1,
        unit: 'pinch',
        isAvailableInFridge: false,
      ),
    ];

    final matchedExpiring1 = recipe1Ingredients
        .where((i) => i.isAvailableInFridge && i.isExpiringSoon)
        .map((i) => i.name)
        .toList();

    final recipe1Name = top2 != null
        ? 'Zero-Waste ${cleanName(top1.name)} & ${cleanName(top2.name)} Skillet'
        : 'Zero-Waste Sautéed ${cleanName(top1.name)}';

    recipes.add(
      Recipe(
        id: 'zero-waste-recipe-1',
        name: recipe1Name,
        description: 'A nutritious, quick skillet meal prioritizing your ${cleanName(top1.name)}${top2 != null ? ' and ${cleanName(top2.name)}' : ''} before expiry.',
        prepTimeMinutes: 15,
        servings: 2,
        difficulty: 'Easy',
        matchedExpiringIngredients: matchedExpiring1,
        ingredients: recipe1Ingredients,
        instructions: [
          'Prepare and lightly slice the ${cleanName(top1.name)}${top2 != null ? ' and ${cleanName(top2.name)}' : ''}.',
          'Heat olive oil in a non-stick skillet over medium-high heat until shimmering.',
          'Add ${cleanName(top1.name)} to the pan and cook for 4 to 5 minutes until tender and fragrant.',
          if (top2 != null)
            'Add ${cleanName(top2.name)} and gently toss together for an additional 2 to 3 minutes.',
          'Season with a pinch of salt and freshly ground black pepper, then serve warm.',
        ],
      ),
    );

    // 2. Second Recipe: Oven Roast / Stew (if 2 or more items, or alternative preparation)
    if (sortedItems.length >= 2) {
      final itemForRoast = sortedItems.length > 2 ? sortedItems[2] : top2!;
      final recipe2Ingredients = <RecipeIngredient>[
        RecipeIngredient(
          name: cleanName(itemForRoast.name),
          quantity: itemForRoast.quantity,
          unit: itemForRoast.unit,
          isAvailableInFridge: true,
          isExpiringSoon: itemForRoast.isExpiringSoon || itemForRoast.isExpired,
        ),
        RecipeIngredient(
          name: cleanName(top1.name),
          quantity: (top1.quantity / 2).clamp(1.0, 999.0),
          unit: top1.unit,
          isAvailableInFridge: true,
          isExpiringSoon: top1.isExpiringSoon || top1.isExpired,
        ),
        const RecipeIngredient(
          name: 'Minced Garlic',
          quantity: 2,
          unit: 'cloves',
          isAvailableInFridge: false,
        ),
        const RecipeIngredient(
          name: 'Dried Mixed Herbs',
          quantity: 1,
          unit: 'tsp',
          isAvailableInFridge: false,
        ),
      ];

      final matchedExpiring2 = recipe2Ingredients
          .where((i) => i.isAvailableInFridge && i.isExpiringSoon)
          .map((i) => i.name)
          .toList();

      recipes.add(
        Recipe(
          id: 'zero-waste-recipe-2',
          name: 'Herb-Roasted ${cleanName(itemForRoast.name)} & ${cleanName(top1.name)}',
          description: 'A comforting, slow-roasted zero-waste dish caramelizing your fridge staples.',
          prepTimeMinutes: 25,
          servings: 2,
          difficulty: 'Easy',
          matchedExpiringIngredients: matchedExpiring2,
          ingredients: recipe2Ingredients,
          instructions: [
            'Preheat oven to 200°C (400°F).',
            'Evenly cut ${cleanName(itemForRoast.name)} and ${cleanName(top1.name)} into bite-sized pieces.',
            'Toss with olive oil, minced garlic, dried herbs, and salt.',
            'Spread evenly onto a baking sheet and roast for 18-20 minutes until edges are golden and caramelized.',
            'Serve warm as a wholesome standalone meal or side dish.',
          ],
        ),
      );
    }

    // 3. Third Recipe: Fresh Kitchen Prep Bowl (if 3 or more items)
    if (sortedItems.length >= 3) {
      final saladItems = sortedItems.take(3).toList();
      final recipe3Ingredients = <RecipeIngredient>[
        for (final item in saladItems)
          RecipeIngredient(
            name: cleanName(item.name),
            quantity: item.quantity,
            unit: item.unit,
            isAvailableInFridge: true,
            isExpiringSoon: item.isExpiringSoon || item.isExpired,
          ),
        const RecipeIngredient(
          name: 'Lemon Juice or Dressing',
          quantity: 15,
          unit: 'ml',
          isAvailableInFridge: false,
        ),
      ];

      final matchedExpiring3 = recipe3Ingredients
          .where((i) => i.isAvailableInFridge && i.isExpiringSoon)
          .map((i) => i.name)
          .toList();

      recipes.add(
        Recipe(
          id: 'zero-waste-recipe-3',
          name: 'Fresh Fridge Harvest Bowl',
          description: 'A refreshing zero-waste bowl utilizing multiple chilled ingredients at peak quality.',
          prepTimeMinutes: 10,
          servings: 2,
          difficulty: 'Easy',
          matchedExpiringIngredients: matchedExpiring3,
          ingredients: recipe3Ingredients,
          instructions: [
            'Wash, trim, and dice ${saladItems.map((i) => cleanName(i.name)).join(', ')}.',
            'Combine all ingredients gently in a medium salad or serving bowl.',
            'Drizzle with fresh lemon juice or dressing.',
            'Toss well to coat and serve immediately for maximum crispness.',
          ],
        ),
      );
    }

    return recipes;
  }
}

final recipeRepositoryProvider = Provider<MockRecipeRepository>((ref) {
  return MockRecipeRepository();
});

final recipesListProvider = Provider<List<Recipe>>((ref) {
  final inventory = ref.watch(inventoryNotifierProvider);
  return ref.watch(recipeRepositoryProvider).getRecipesWithInventory(inventory);
});

final recipeByIdProvider = Provider.family<Recipe?, String>((ref, id) {
  final list = ref.watch(recipesListProvider);
  try {
    return list.firstWhere((r) => r.id == id);
  } catch (_) {
    return null;
  }
});
