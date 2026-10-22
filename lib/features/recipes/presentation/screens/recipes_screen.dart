import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors_extension.dart';
import '../../data/mock_recipe_repository.dart';
import '../../domain/models/recipe.dart';

class RecipesScreen extends ConsumerWidget {
  const RecipesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.appColors;
    final recipes = ref.watch(recipesListProvider);

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Zero-Waste Recipes',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
            ),
            Text(
              'Cook meals utilizing ingredients approaching expiry',
              style: TextStyle(fontSize: 12, color: colors.textSecondary),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Honest Simulation Notice
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colors.surfaceElevated,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: colors.cardBorder),
                ),
                child: Row(
                  children: [
                    Icon(Icons.auto_awesome_rounded, size: 18, color: colors.secondaryAction),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Simulated AI Recommendations: Matched against your active fridge items.',
                        style: TextStyle(fontSize: 12, color: colors.textSecondary),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              Text(
                'SUGGESTIONS FOR YOU',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: colors.textSecondary,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 10),

              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: recipes.length,
                separatorBuilder: (context, index) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final recipe = recipes[index];
                  return _RecipeCard(recipe: recipe);
                },
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

class _RecipeCard extends StatelessWidget {
  const _RecipeCard({required this.recipe});

  final Recipe recipe;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final colorScheme = Theme.of(context).colorScheme;

    return Material(
      color: colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: colors.cardBorder),
      ),
      child: InkWell(
        onTap: () => context.push('/recipe-details/${recipe.id}'),
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top tag badges
              Row(
                children: [
                  if (recipe.usesExpiringFood)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: colors.freshnessContainer,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: colors.freshnessBorder),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.eco_rounded, size: 12, color: colors.freshnessSuccess),
                          const SizedBox(width: 4),
                          Text(
                            'USES EXPIRING INGREDIENTS',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: colors.freshnessSuccess,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                  const Spacer(),
                  Text(
                    '${recipe.prepTimeMinutes} min • ${recipe.difficulty}',
                    style: TextStyle(fontSize: 12, color: colors.textSecondary),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Recipe Title
              Text(
                recipe.name,
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 4),

              // Description
              Text(
                recipe.description,
                style: TextStyle(fontSize: 13, color: colors.textSecondary, height: 1.35),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),

              // Match Indicator
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: colors.surfaceElevated,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.inventory_2_outlined,
                      size: 14,
                      color: colors.freshnessSuccess,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${recipe.availableIngredientsCount} of ${recipe.ingredients.length} ingredients in your fridge',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
