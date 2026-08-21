import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_spacing.dart';
import 'app_pressable.dart';

/// Arama alanının yanında duran dairesel sepet butonu.
class AppCartButton extends StatelessWidget {
  final VoidCallback onTap;

  const AppCartButton({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return AppPressable(
      onTap: onTap,
      pressedScale: 0.94,
      child: Container(
        width: AppSizes.fieldHeight,
        height: AppSizes.fieldHeight,
        decoration: BoxDecoration(
          color: AppColors.surface,
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.border),
          boxShadow: AppColors.softShadow,
        ),
        child: const Icon(
          Icons.shopping_cart_outlined,
          size: 22,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }
}
