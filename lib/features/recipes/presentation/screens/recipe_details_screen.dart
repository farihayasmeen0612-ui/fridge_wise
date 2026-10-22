import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/presentation/components/app_button.dart';
import '../../../../core/presentation/components/app_confirm_dialog.dart';
import '../../../../core/theme/app_colors_extension.dart';
import '../../data/mock_recipe_repository.dart';

class RecipeDetailsScreen extends ConsumerWidget {
  const RecipeDetailsScreen({required this.recipeId, super.key});

  final String recipeId;

  Future<void> _handleCookRecipe(BuildContext context, String recipeName) async {
    final confirmed = await AppConfirmDialog.show(
      context,
      title: 'Cook Recipe & Deduct Stock?',
      message: 'Would you like to mark the available ingredients for "$recipeName" as consumed from your fridge?',
      confirmLabel: 'Cook & Deduct',
    );

    if (confirmed == true && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Ingredients for "$recipeName" marked as cooked!'),
          backgroundColor: context.appColors.freshnessSuccess,
        ),
      );
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.appColors;
    final colorScheme = Theme.of(context).colorScheme;
    final recipe = ref.watch(recipeByIdProvider(recipeId));

    if (recipe == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Recipe Details')),
        body: const Center(child: Text('Recipe not found.')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Recipe Details'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Recipe Header
              Text(
                recipe.name,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: colorScheme.onSurface,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                recipe.description,
                style: TextStyle(
                  fontSize: 14,
                  color: colors.textSecondary,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 14),

              // Metadata Pills
              Row(
                children: [
                  _MetaPill(icon: Icons.schedule_rounded, text: '${recipe.prepTimeMinutes} mins'),
                  const SizedBox(width: 8),
                  _MetaPill(icon: Icons.restaurant_menu_rounded, text: recipe.difficulty),
                  const SizedBox(width: 8),
                  _MetaPill(icon: Icons.people_outline_rounded, text: '${recipe.servings} Servings'),
                ],
              ),
              const SizedBox(height: 16),

              // Expiring ingredients highlight banner
              if (recipe.usesExpiringFood) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: colors.warningContainer.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: colors.warningBorder),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.eco_rounded, size: 20, color: colors.warningAmber),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Prioritizes expiring items: ${recipe.matchedExpiringIngredients.join(", ")}.',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: colors.warningAmber,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],

              // Ingredients Checklist
              Text(
                'INGREDIENTS',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: colors.textSecondary,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 10),

              Container(
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: colors.cardBorder),
                ),
                child: ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: recipe.ingredients.length,
                  separatorBuilder: (context, index) => Divider(height: 1, color: colors.cardBorder),
                  itemBuilder: (context, index) {
                    final ing = recipe.ingredients[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      child: Row(
                        children: [
                          Icon(
                            ing.isAvailableInFridge
                                ? Icons.check_circle_rounded
                                : Icons.radio_button_unchecked_rounded,
                            size: 18,
                            color: ing.isAvailableInFridge
                                ? colors.freshnessSuccess
                                : colors.textMuted,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              ing.name,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: colorScheme.onSurface,
                              ),
                            ),
                          ),
                          Text(
                            '${ing.quantity % 1 == 0 ? ing.quantity.toInt() : ing.quantity} ${ing.unit}',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: colors.textSecondary,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            ing.isAvailableInFridge ? 'In Fridge' : 'Missing',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: ing.isAvailableInFridge
                                  ? colors.freshnessSuccess
                                  : colors.textMuted,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),

              // Cooking Instructions
              Text(
                'INSTRUCTIONS',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: colors.textSecondary,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 10),

              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: recipe.instructions.length,
                separatorBuilder: (context, index) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: colors.surfaceElevated,
                          shape: BoxShape.circle,
                          border: Border.all(color: colors.cardBorder),
                        ),
                        child: Center(
                          child: Text(
                            '${index + 1}',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: colorScheme.onSurface,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          recipe.instructions[index],
                          style: TextStyle(
                            fontSize: 14,
                            color: colorScheme.onSurface,
                            height: 1.45,
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 32),

              // Cook Action
              AppButton(
                label: 'Cook Recipe (Deduct Ingredients)',
                icon: Icons.outdoor_grill_outlined,
                variant: AppButtonVariant.primary,
                isFullWidth: true,
                onPressed: () => _handleCookRecipe(context, recipe.name),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _MetaPill extends StatelessWidget {
  const _MetaPill({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: colors.surfaceElevated,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colors.cardBorder),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: colors.textSecondary),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}
