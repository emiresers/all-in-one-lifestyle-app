import 'package:flutter/material.dart';

import '../../core/app_page_route.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/cuisine_accent.dart';
import '../../widgets/app_image_frame.dart';
import '../../widgets/app_account_actions.dart';
import '../../widgets/app_pressable.dart';
import '../../widgets/app_screen_header.dart';
import '../../widgets/app_skeleton.dart';
import '../../models/recipe.dart';

import '../../services/recipe_service.dart';

import 'recipe_detail_screen.dart';

class RecipesScreen extends StatefulWidget {
  final int userId;
  final ScrollController? scrollController;

  const RecipesScreen({super.key, required this.userId, this.scrollController});

  @override
  State<RecipesScreen> createState() => _RecipesScreenState();
}

class _RecipesScreenState extends State<RecipesScreen> {
  final RecipeService _recipeService = RecipeService();

  late Future<List<Recipe>> _recipesFuture;

  @override
  void initState() {
    super.initState();

    _loadRecipes();
  }

  void _loadRecipes() {
    _recipesFuture = _recipeService.getRecipes();
  }

  Future<void> _refreshRecipes() async {
    setState(() {
      _loadRecipes();
    });

    await _recipesFuture;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          AppPrimaryHeaderSurface(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.screenH,
                AppSpacing.lg,
                AppSpacing.screenH,
                AppSpacing.lg,
              ),
              child: AppScreenHeader(
                title: 'Recipes',
                subtitle: 'Discover delicious recipes and cooking ideas',
                foregroundColor: Colors.white,
                action: AppAccountActions(userId: widget.userId),
              ),
            ),
          ),

          const SizedBox(height: AppSpacing.xl),

          Expanded(
            child: FutureBuilder<List<Recipe>>(
              future: _recipesFuture,

              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const RecipeListSkeleton();
                }

                if (snapshot.hasError) {
                  return _RecipesErrorState(
                    message: snapshot.error.toString(),

                    onRetry: () {
                      setState(() {
                        _loadRecipes();
                      });
                    },
                  );
                }

                final recipes = snapshot.data ?? [];

                if (recipes.isEmpty) {
                  return const _RecipesEmptyState();
                }

                return RefreshIndicator(
                  onRefresh: _refreshRecipes,

                  child: ListView.builder(
                    controller: widget.scrollController,
                    physics: const AlwaysScrollableScrollPhysics(),

                    padding: const EdgeInsets.fromLTRB(20, 4, 20, 28),

                    itemCount: recipes.length,

                    itemBuilder: (context, index) {
                      final recipe = recipes[index];

                      return _RecipeCard(
                        recipe: recipe,

                        onTap: () {
                          Navigator.push(
                            context,

                            AppPageRoute.to(
                              RecipeDetailScreen(
                                recipeId: recipe.id,
                                initialRecipe: recipe,
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _RecipeCard extends StatelessWidget {
  final Recipe recipe;

  final VoidCallback onTap;

  const _RecipeCard({required this.recipe, required this.onTap});

  @override
  Widget build(BuildContext context) {
    // Görsel alanının tonu mutfağa göre değişir; renk fotoğrafın önüne
    // geçmeyecek kadar açık tutulur.
    final CuisineAccent accent = CuisineAccent.of(
      recipe.cuisine,
      hints: recipe.name.toLowerCase().split(' '),
    );

    return Container(
      margin: const EdgeInsets.only(bottom: 14),

      decoration: BoxDecoration(
        color: AppColors.surface,

        borderRadius: BorderRadius.circular(22),

        border: Border.all(color: AppColors.border),

        boxShadow: AppColors.softShadow,
      ),

      child: AppPressable(
        onTap: onTap,

        child: Padding(
          padding: const EdgeInsets.all(12),

          child: Row(
            children: [
              SizedBox(
                width: 112,
                height: 112,
                child: AppImageFrame(
                  imageUrl: recipe.image,
                  heroTag: 'recipe-${recipe.id}',
                  radius: 18,
                  inset: 5,
                  surface: accent.surface,
                  border: accent.border,
                  cacheWidth: 336,
                ),
              ),

              const SizedBox(width: 16),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    Text(
                      recipe.name,

                      maxLines: 2,

                      overflow: TextOverflow.ellipsis,

                      style: const TextStyle(
                        fontSize: 17,

                        fontWeight: FontWeight.w800,

                        height: 1.25,

                        letterSpacing: -0.2,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      recipe.cuisine,

                      style: TextStyle(
                        fontSize: 13,

                        color: AppColors.textSecondary,

                        fontWeight: FontWeight.w500,
                      ),
                    ),

                    const SizedBox(height: 10),

                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 9,

                            vertical: 5,
                          ),

                          decoration: BoxDecoration(
                            color: AppColors.surfaceSecondary,

                            borderRadius: BorderRadius.circular(18),
                          ),

                          child: Row(
                            mainAxisSize: MainAxisSize.min,

                            children: [
                              Icon(
                                Icons.speed_rounded,

                                size: 14,

                                color: AppColors.textSecondary,
                              ),

                              const SizedBox(width: 5),

                              Text(
                                recipe.difficulty,

                                style: TextStyle(
                                  fontSize: 11.5,

                                  color: AppColors.textSecondary,

                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(width: 8),

                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 9,

                            vertical: 5,
                          ),

                          decoration: BoxDecoration(
                            color: AppColors.amberSoft,

                            borderRadius: BorderRadius.circular(18),
                          ),

                          child: Row(
                            mainAxisSize: MainAxisSize.min,

                            children: [
                              const Icon(
                                Icons.star_rounded,

                                size: 14,

                                color: AppColors.amber,
                              ),

                              const SizedBox(width: 4),

                              Text(
                                recipe.rating.toStringAsFixed(1),

                                style: const TextStyle(
                                  fontSize: 11.5,

                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),

                    Row(
                      children: [
                        Icon(
                          Icons.timer_outlined,

                          size: 15,

                          color: AppColors.textTertiary,
                        ),

                        const SizedBox(width: 5),

                        Text(
                          '${recipe.prepTimeMinutes + recipe.cookTimeMinutes} min',

                          style: TextStyle(
                            fontSize: 12,

                            color: AppColors.textSecondary,

                            fontWeight: FontWeight.w500,
                          ),
                        ),

                        const Spacer(),

                        Icon(
                          Icons.chevron_right_rounded,

                          color: AppColors.textTertiary,
                        ),
                      ],
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

class _RecipesErrorState extends StatelessWidget {
  final String message;

  final VoidCallback onRetry;

  const _RecipesErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),

        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,

          children: [
            const Icon(Icons.error_outline_rounded, size: 52),

            const SizedBox(height: 16),

            const Text(
              'Recipes couldn’t be loaded',

              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),

            const SizedBox(height: 8),

            Text(
              message,

              textAlign: TextAlign.center,

              style: TextStyle(color: AppColors.textSecondary),
            ),

            const SizedBox(height: 20),

            FilledButton.icon(
              onPressed: onRetry,

              icon: const Icon(Icons.refresh_rounded),

              label: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }
}

class _RecipesEmptyState extends StatelessWidget {
  const _RecipesEmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),

        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,

          children: [
            const Icon(Icons.restaurant_menu_rounded, size: 58),

            const SizedBox(height: 16),

            const Text(
              'No recipes found',

              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),

            const SizedBox(height: 6),

            Text(
              'Recipes will appear here.',

              style: TextStyle(color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}
