import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_spacing.dart';
import '../core/theme/app_typography.dart';
import 'app_pressable.dart';

/// Ana ekranların büyük başlık bloğu: başlık + açıklama + opsiyonel aksiyon.
class AppScreenHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? action;
  final Color foregroundColor;

  const AppScreenHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.action,
    this.foregroundColor = AppColors.textPrimary,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.screenTitle.copyWith(
                  color: foregroundColor,
                ),
              ),
            ),

            if (action != null) ...[
              const SizedBox(width: AppSpacing.md),
              action!,
            ],
          ],
        ),

        if (subtitle != null) ...[
          const SizedBox(height: AppSpacing.xs),

          Text(
            subtitle!,
            style: AppTextStyles.screenSubtitle.copyWith(
              color: foregroundColor.withValues(alpha: 0.78),
            ),
          ),
        ],
      ],
    );
  }
}

/// Başlık satırındaki kompakt birincil aksiyon (Add gibi).
class AppHeaderButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool inverted;

  const AppHeaderButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.inverted = false,
  });

  @override
  Widget build(BuildContext context) {
    return FilledButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 18),
      label: Text(label),
      style: FilledButton.styleFrom(
        backgroundColor: inverted ? Colors.white : AppColors.primary,
        foregroundColor: inverted ? AppColors.primaryDark : Colors.white,
        minimumSize: const Size(0, 40),
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.chip),
        ),
        textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
      ),
    );
  }
}

/// Ana ekranların üst kısmında kullanılan marka renkli ortak yüzey.
class AppPrimaryHeaderSurface extends StatelessWidget {
  final Widget child;

  const AppPrimaryHeaderSurface({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primaryLight,
            AppColors.primary,
            AppColors.primaryDark,
          ],
        ),
      ),
      child: SafeArea(bottom: false, child: child),
    );
  }
}

/// Liste bölümlerinin üstündeki başlık + sağda ikincil bilgi.
class AppSectionHeader extends StatelessWidget {
  final String title;
  final String? trailingLabel;

  /// Verilirse sağdaki metin pasif bir etiket yerine "See all →" düğmesi olur.
  final VoidCallback? onSeeAll;

  const AppSectionHeader({
    super.key,
    required this.title,
    this.trailingLabel,
    this.onSeeAll,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.sectionTitle,
          ),
        ),

        if (onSeeAll != null)
          AppPressable(
            onTap: onSeeAll,
            child: const Padding(
              padding: EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: AppSpacing.xs,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'See all',
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w500,
                      color: AppColors.primary,
                    ),
                  ),

                  SizedBox(width: 3),

                  Icon(
                    Icons.arrow_forward_rounded,
                    size: 14,
                    color: AppColors.primary,
                  ),
                ],
              ),
            ),
          )
        else if (trailingLabel != null)
          Text(
            trailingLabel!,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textTertiary,
              fontWeight: FontWeight.w600,
            ),
          ),
      ],
    );
  }
}
