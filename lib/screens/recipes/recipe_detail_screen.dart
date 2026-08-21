import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/cuisine_accent.dart';
import '../../models/recipe.dart';
import '../../widgets/app_image_frame.dart';
import '../../widgets/app_skeleton.dart';

import '../../services/recipe_service.dart';

class RecipeDetailScreen extends StatefulWidget {
  final int recipeId;

  /// Listeden gelen tarif. Yalnızca ilk kareyi doldurmak için kullanılır:
  /// böylece Hero geçişinin hedefi ilk karede hazır olur ve ekran boş
  /// açılmaz. Gerçek veri yine [recipeId] ile servisten çekilir.
  final Recipe? initialRecipe;

  const RecipeDetailScreen({
    super.key,
    required this.recipeId,
    this.initialRecipe,
  });

  @override
  State<RecipeDetailScreen> createState() => _RecipeDetailScreenState();
}

class _RecipeDetailScreenState extends State<RecipeDetailScreen> {
  final RecipeService _recipeService = RecipeService();

  late Future<Recipe> _recipeFuture;

  @override
  void initState() {
    super.initState();

    _loadRecipe();
  }

  void _loadRecipe() {
    _recipeFuture = _recipeService.getRecipe(widget.recipeId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,

      appBar: AppBar(
        title: const Text(
          'Recipe Detail',

          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),

      body: FutureBuilder<Recipe>(
        future: _recipeFuture,

        builder: (context, snapshot) {
          final Recipe? recipe = snapshot.data ?? widget.initialRecipe;

          if (snapshot.connectionState == ConnectionState.waiting &&
              recipe == null) {
            return const _RecipeDetailSkeleton();
          }

          if (snapshot.hasError) {
            return _RecipeErrorState(
              message: snapshot.error.toString(),

              onRetry: () {
                setState(() {
                  _loadRecipe();
                });
              },
            );
          }

          if (recipe == null) {
            return const Center(child: Text('Recipe not found.'));
          }

          final CuisineAccent accent = CuisineAccent.of(
            recipe.cuisine,
            hints: recipe.name.toLowerCase().split(' '),
          );

          return SafeArea(
            top: false,

            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  // IMAGE

                  SizedBox(
                    width: double.infinity,
                    height: 320,
                    child: AppImageFrame(
                      imageUrl: recipe.image,
                      heroTag: 'recipe-${recipe.id}',
                      radius: 24,
                      inset: 6,
                      surface: accent.surface,
                      border: accent.border,
                    ),
                  ),

                  const SizedBox(height: 26),

                  // CUISINE + RATING
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,

                          vertical: 7,
                        ),

                        decoration: BoxDecoration(
                          color: AppColors.surface,

                          borderRadius: BorderRadius.circular(20),

                          border: Border.all(color: AppColors.border),
                        ),

                        child: Text(
                          recipe.cuisine,

                          style: TextStyle(
                            fontSize: 13,

                            color: AppColors.textSecondary,

                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),

                      const Spacer(),

                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,

                          vertical: 7,
                        ),

                        decoration: BoxDecoration(
                          color: AppColors.amberSoft,

                          borderRadius: BorderRadius.circular(20),
                        ),

                        child: Row(
                          children: [
                            const Icon(
                              Icons.star_rounded,

                              size: 18,

                              color: AppColors.amber,
                            ),

                            const SizedBox(width: 4),

                            Text(
                              recipe.rating.toStringAsFixed(1),

                              style: const TextStyle(
                                fontSize: 13,

                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 18),

                  // TITLE
                  Text(
                    recipe.name,

                    style: const TextStyle(
                      fontSize: 30,

                      fontWeight: FontWeight.w800,

                      letterSpacing: -0.8,

                      height: 1.15,
                    ),
                  ),

                  const SizedBox(height: 22),

                  // INFO GRID
                  Wrap(
                    spacing: 10,

                    runSpacing: 10,

                    children: [
                      _ModernInfoChip(
                        icon: Icons.speed_rounded,

                        text: recipe.difficulty,
                      ),

                      _ModernInfoChip(
                        icon: Icons.timer_outlined,

                        text: '${recipe.prepTimeMinutes} min prep',
                      ),

                      _ModernInfoChip(
                        icon: Icons.local_fire_department_outlined,

                        text: '${recipe.cookTimeMinutes} min cook',
                      ),

                      _ModernInfoChip(
                        icon: Icons.people_outline_rounded,

                        text: '${recipe.servings} servings',
                      ),
                    ],
                  ),

                  const SizedBox(height: 28),

                  // INGREDIENTS
                  _SectionCard(
                    title: 'Ingredients',

                    icon: Icons.shopping_basket_outlined,

                    child: Column(
                      children: recipe.ingredients
                          .map(
                            (ingredient) => Padding(
                              padding: const EdgeInsets.only(bottom: 12),

                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,

                                children: [
                                  Container(
                                    width: 7,

                                    height: 7,

                                    margin: const EdgeInsets.only(top: 7),

                                    decoration: BoxDecoration(
                                      color: AppColors.textSecondary,

                                      shape: BoxShape.circle,
                                    ),
                                  ),

                                  const SizedBox(width: 12),

                                  Expanded(
                                    child: Text(
                                      ingredient,

                                      style: TextStyle(
                                        fontSize: 15,

                                        height: 1.5,

                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ),

                  const SizedBox(height: 18),

                  // INSTRUCTIONS
                  _SectionCard(
                    title: 'Instructions',

                    icon: Icons.menu_book_outlined,

                    child: Column(
                      children: List.generate(recipe.instructions.length, (
                        index,
                      ) {
                        final instruction = recipe.instructions[index];

                        return Padding(
                          padding: EdgeInsets.only(
                            bottom: index == recipe.instructions.length - 1
                                ? 0
                                : 18,
                          ),

                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,

                            children: [
                              Container(
                                width: 34,

                                height: 34,

                                alignment: Alignment.center,

                                decoration: BoxDecoration(
                                  color: AppColors.surfaceSecondary,

                                  borderRadius: BorderRadius.circular(12),
                                ),

                                child: Text(
                                  '${index + 1}',

                                  style: const TextStyle(
                                    fontSize: 13,

                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),

                              const SizedBox(width: 14),

                              Expanded(
                                child: Text(
                                  instruction,

                                  style: TextStyle(
                                    fontSize: 15,

                                    height: 1.6,

                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ModernInfoChip extends StatelessWidget {
  final IconData icon;

  final String text;

  const _ModernInfoChip({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),

      decoration: BoxDecoration(
        color: AppColors.surface,

        borderRadius: BorderRadius.circular(16),

        border: Border.all(color: AppColors.border),
      ),

      child: Row(
        mainAxisSize: MainAxisSize.min,

        children: [
          Icon(icon, size: 18, color: AppColors.textSecondary),

          const SizedBox(width: 7),

          Text(
            text,

            style: TextStyle(
              fontSize: 12.5,

              color: AppColors.textSecondary,

              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;

  final IconData icon;

  final Widget child;

  const _SectionCard({
    required this.title,

    required this.icon,

    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,

      padding: const EdgeInsets.all(20),

      decoration: BoxDecoration(
        color: AppColors.surface,

        borderRadius: BorderRadius.circular(22),

        border: Border.all(color: AppColors.border),

        boxShadow: AppColors.softShadow,
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          Row(
            children: [
              Container(
                width: 40,

                height: 40,

                decoration: BoxDecoration(
                  color: AppColors.surfaceSecondary,

                  borderRadius: BorderRadius.circular(13),
                ),

                child: Icon(icon, size: 20),
              ),

              const SizedBox(width: 12),

              Text(
                title,

                style: const TextStyle(
                  fontSize: 19,

                  fontWeight: FontWeight.w800,

                  letterSpacing: -0.3,
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          child,
        ],
      ),
    );
  }
}

class _RecipeErrorState extends StatelessWidget {
  final String message;

  final VoidCallback onRetry;

  const _RecipeErrorState({required this.message, required this.onRetry});

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
              'Recipe couldn’t be loaded',

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

/// Tarif detayının yükleniyor hâli: gerçek yerleşimle aynı ölçülerde.
class _RecipeDetailSkeleton extends StatelessWidget {
  const _RecipeDetailSkeleton();

  @override
  Widget build(BuildContext context) {
    return const AppSkeleton(
      child: SingleChildScrollView(
        physics: NeverScrollableScrollPhysics(),
        padding: EdgeInsets.fromLTRB(
          AppSpacing.screenH,
          AppSpacing.sm,
          AppSpacing.screenH,
          AppSpacing.section,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppSkeletonBox(
              width: double.infinity,
              height: 320,
              radius: AppRadius.largeCard,
            ),

            SizedBox(height: 26),

            Row(
              children: [
                AppSkeletonBox(width: 96, height: 32, radius: 20),
                Spacer(),
                AppSkeletonBox(width: 64, height: 32, radius: 20),
              ],
            ),

            SizedBox(height: AppSpacing.lg),

            AppSkeletonBox(height: 26, radius: 10),
            SizedBox(height: 10),
            AppSkeletonBox(width: 200, height: 26, radius: 10),

            SizedBox(height: AppSpacing.xl),

            Row(
              children: [
                AppSkeletonBox(width: 92, height: 34, radius: 20),
                SizedBox(width: 10),
                AppSkeletonBox(width: 120, height: 34, radius: 20),
              ],
            ),

            SizedBox(height: AppSpacing.section),

            AppSkeletonBox(
              width: double.infinity,
              height: 180,
              radius: AppRadius.largeCard,
            ),
          ],
        ),
      ),
    );
  }
}
