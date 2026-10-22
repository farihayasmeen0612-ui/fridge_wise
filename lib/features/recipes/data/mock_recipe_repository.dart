import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/models/recipe.dart';

/// Seed recipes tailored to our inventory items to demonstrate zero-waste matching.
class MockRecipeRepository {
  List<Recipe> getRecipes() {
    return const [
      Recipe(
        id: 'recipe-1',
        name: 'Pan-Seared Salmon with Garlic Spinach',
        description: 'A nutritious, quick skillet meal prioritizing your fresh salmon and baby spinach before expiry.',
        prepTimeMinutes: 15,
        servings: 2,
        difficulty: 'Easy',
        matchedExpiringIngredients: ['Fresh Salmon Fillet', 'Organic Baby Spinach'],
        ingredients: [
          RecipeIngredient(
            name: 'Fresh Salmon Fillet',
            quantity: 400,
            unit: 'g',
            isAvailableInFridge: true,
            isExpiringSoon: true,
          ),
          RecipeIngredient(
            name: 'Organic Baby Spinach',
            quantity: 250,
            unit: 'g',
            isAvailableInFridge: true,
            isExpiringSoon: true,
          ),
          RecipeIngredient(
            name: 'Extra Virgin Olive Oil',
            quantity: 15,
            unit: 'ml',
            isAvailableInFridge: true,
          ),
          RecipeIngredient(
            name: 'Garlic Cloves',
            quantity: 2,
            unit: 'pcs',
            isAvailableInFridge: false,
          ),
        ],
        instructions: [
          'Pat salmon fillets dry and season both sides with salt and black pepper.',
          'Heat olive oil in a non-stick skillet over medium-high heat until shimmering.',
          'Sear salmon skin-side down for 4 minutes, flip and cook 3 minutes more until opaque.',
          'Transfer salmon to a warm plate. Add minced garlic to the pan and saute for 30 seconds.',
          'Toss in fresh baby spinach and cook for 1 minute until just wilted. Serve alongside salmon.',
        ],
      ),
      Recipe(
        id: 'recipe-2',
        name: 'Artisan French Toast with Fuji Apples',
        description: 'Golden breakfast toast repurposing sourdough bread and whole milk nearing shelf-life.',
        prepTimeMinutes: 20,
        servings: 2,
        difficulty: 'Easy',
        matchedExpiringIngredients: ['Whole Milk', 'Artisan Sourdough Loaf'],
        ingredients: [
          RecipeIngredient(
            name: 'Artisan Sourdough Loaf',
            quantity: 2,
            unit: 'slices',
            isAvailableInFridge: true,
            isExpiringSoon: true,
          ),
          RecipeIngredient(
            name: 'Whole Milk',
            quantity: 150,
            unit: 'ml',
            isAvailableInFridge: true,
            isExpiringSoon: true,
          ),
          RecipeIngredient(
            name: 'Fuji Apples',
            quantity: 1,
            unit: 'pcs',
            isAvailableInFridge: true,
          ),
          RecipeIngredient(
            name: 'Egg',
            quantity: 1,
            unit: 'pcs',
            isAvailableInFridge: false,
          ),
          RecipeIngredient(
            name: 'Ground Cinnamon',
            quantity: 1,
            unit: 'pinch',
            isAvailableInFridge: false,
          ),
        ],
        instructions: [
          'Whisk egg, whole milk, and cinnamon together in a shallow dish.',
          'Core and thinly slice the Fuji apple. Lightly caramelize in a skillet with a dash of water.',
          'Dip sourdough slices into the milk mixture for 20 seconds on each side.',
          'Cook in skillet over medium heat for 3 minutes per side until golden brown.',
          'Top with warm sliced apples and serve immediately.',
        ],
      ),
      Recipe(
        id: 'recipe-3',
        name: 'Greek Yogurt Berry Parfait',
        description: 'A protein-packed, zero-cooking breakfast or afternoon snack using cold storage staples.',
        prepTimeMinutes: 5,
        servings: 1,
        difficulty: 'Easy',
        matchedExpiringIngredients: [],
        ingredients: [
          RecipeIngredient(
            name: 'Greek Plain Yogurt',
            quantity: 200,
            unit: 'g',
            isAvailableInFridge: true,
          ),
          RecipeIngredient(
            name: 'Frozen Mixed Berries',
            quantity: 100,
            unit: 'g',
            isAvailableInFridge: true,
          ),
          RecipeIngredient(
            name: 'Honey or Maple Syrup',
            quantity: 15,
            unit: 'ml',
            isAvailableInFridge: false,
          ),
        ],
        instructions: [
          'Thaw mixed berries at room temperature for 5 minutes or microwave for 15 seconds.',
          'Spoon half the Greek yogurt into a glass or bowl.',
          'Add a layer of mixed berries, then top with remaining yogurt.',
          'Drizzle lightly with honey and enjoy fresh.',
        ],
      ),
    ];
  }
}

final recipeRepositoryProvider = Provider<MockRecipeRepository>((ref) {
  return MockRecipeRepository();
});

final recipesListProvider = Provider<List<Recipe>>((ref) {
  return ref.watch(recipeRepositoryProvider).getRecipes();
});

final recipeByIdProvider = Provider.family<Recipe?, String>((ref, id) {
  final list = ref.watch(recipesListProvider);
  try {
    return list.firstWhere((r) => r.id == id);
  } catch (_) {
    return null;
  }
});
