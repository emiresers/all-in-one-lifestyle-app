import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_spacing.dart';
import 'app_pressable.dart';
import 'category_tile.dart';

/// Kaydırma kullanmadan beş sütunda gösterilen kategori alanı.
///
/// İlk satırda All + ilk üç kategori + More bulunur. More, aranabilir kategori
/// penceresini açar.
class CategoryStrip extends StatefulWidget {
  final List<String> categories;
  final Set<String> selectedCategories;
  final ValueChanged<String> onSelect;
  final VoidCallback onMore;
  final String Function(String) formatCategory;

  const CategoryStrip({
    super.key,
    required this.categories,
    required this.selectedCategories,
    required this.onSelect,
    required this.onMore,
    required this.formatCategory,
  });

  @override
  State<CategoryStrip> createState() => _CategoryStripState();
}

class _CategoryStripState extends State<CategoryStrip> {
  static const int _initialCategoryCount = 3;
  static const double _gap = AppSpacing.xs;

  @override
  Widget build(BuildContext context) {
    final firstCategories = widget.categories
        .take(_initialCategoryCount)
        .toList();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final itemWidth = (constraints.maxWidth - _gap * 4) / 5;

          return AnimatedSize(
            duration: const Duration(milliseconds: 260),
            curve: Curves.easeOutCubic,
            alignment: Alignment.topCenter,
            child: Wrap(
              spacing: _gap,
              runSpacing: _gap,
              children: [
                CategoryStripItem(
                  width: itemWidth,
                  visual: CategoryVisual.all,
                  label: 'All',
                  selected: true,
                  onTap: () => widget.onSelect('all'),
                ),
                for (final category in firstCategories)
                  CategoryStripItem(
                    width: itemWidth,
                    visual: CategoryVisual.of(category),
                    label: widget.formatCategory(category),
                    selected: widget.selectedCategories.contains(category),
                    onTap: () => widget.onSelect(category),
                  ),
                _MoreCategoriesButton(width: itemWidth, onTap: widget.onMore),
              ],
            ),
          );
        },
      ),
    );
  }
}

class CategoryStripItem extends StatelessWidget {
  final double width;
  final CategoryVisual visual;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const CategoryStripItem({
    super.key,
    required this.width,
    required this.visual,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  static const Duration _transition = Duration(milliseconds: 260);
  static const double cardHeight = 76;
  static const double iconBoxSize = 32;
  static const double labelHeight = 22;

  @override
  Widget build(BuildContext context) {
    return AppPressable(
      onTap: onTap,
      child: AnimatedContainer(
        duration: _transition,
        curve: Curves.easeOutCubic,
        width: width,
        height: cardHeight,
        padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 5),
        decoration: BoxDecoration(
          color: selected ? AppColors.primarySoft : AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.sm - 1),
          border: Border.all(
            color: selected
                ? AppColors.primary.withValues(alpha: 0.35)
                : AppColors.border,
            width: 0.65,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: _transition,
              curve: Curves.easeOutCubic,
              width: iconBoxSize,
              height: iconBoxSize,
              decoration: BoxDecoration(
                color: selected ? AppColors.surface : visual.tint,
                borderRadius: BorderRadius.circular(AppRadius.sm - 3),
              ),
              child: Icon(
                visual.icon,
                size: 16,
                color: selected ? AppColors.primary : visual.iconColor,
              ),
            ),
            const SizedBox(height: 4),
            SizedBox(
              height: labelHeight,
              child: AnimatedDefaultTextStyle(
                duration: _transition,
                curve: Curves.easeOutCubic,
                style: TextStyle(
                  fontSize: 10,
                  height: 1.15,
                  fontWeight: FontWeight.w600,
                  color: selected ? AppColors.primary : AppColors.textPrimary,
                ),
                child: Text(
                  label,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MoreCategoriesButton extends StatelessWidget {
  final double width;
  final VoidCallback onTap;

  const _MoreCategoriesButton({required this.width, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return AppPressable(
      onTap: onTap,
      child: Container(
        width: width,
        height: CategoryStripItem.cardHeight,
        padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 5),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.sm - 1),
          border: Border.all(color: AppColors.border, width: 0.65),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: CategoryStripItem.iconBoxSize,
              height: CategoryStripItem.iconBoxSize,
              child: const Icon(
                Icons.more_horiz_rounded,
                size: 21,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 4),
            SizedBox(
              height: CategoryStripItem.labelHeight,
              child: const Text(
                'More',
                maxLines: 1,
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 10,
                  height: 1.15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
