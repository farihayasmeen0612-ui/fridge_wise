import 'package:flutter/foundation.dart';

@immutable
class RecipeIngredient {
  const RecipeIngredient({
    required this.name,
    required this.quantity,
    required this.unit,
    this.isAvailableInFridge = false,
    this.isExpiringSoon = false,
  });

  final String name;
  final double quantity;
  final String unit;
  final bool isAvailableInFridge;
  final bool isExpiringSoon;
}

/// Zero-waste recipe recommendation domain model.
@immutable
class Recipe {
  const Recipe({
    required this.id,
    required this.name,
    required this.description,
    required this.prepTimeMinutes,
    required this.servings,
    required this.difficulty,
    required this.ingredients,
    required this.instructions,
    required this.matchedExpiringIngredients,
    this.isSimulated = true,
  });

  final String id;
  final String name;
  final String description;
  final int prepTimeMinutes;
  final int servings;
  final String difficulty;
  final List<RecipeIngredient> ingredients;
  final List<String> instructions;
  final List<String> matchedExpiringIngredients;
  final bool isSimulated;

  int get availableIngredientsCount =>
      ingredients.where((i) => i.isAvailableInFridge).length;

  int get missingIngredientsCount =>
      ingredients.where((i) => !i.isAvailableInFridge).length;

  bool get usesExpiringFood => matchedExpiringIngredients.isNotEmpty;
}
