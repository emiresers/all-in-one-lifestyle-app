import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_spacing.dart';

/// Bottom navigation'da tek bir sekmeyi tanımlar.
class AppBottomNavItem {
  final IconData icon;
  final IconData selectedIcon;
  final String label;

  const AppBottomNavItem({
    required this.icon,
    required this.selectedIcon,
    required this.label,
  });
}

/// Ekranın altına sabit, beyaz yüzeyli bottom navigation.
///
/// Aktif sekmenin ikonu, sekmeler arasında kayan yumuşak mavi bir kapsülün
/// içinde durur. iPhone'un alt güvenli alanı [SafeArea] ile korunur.
class AppBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final List<AppBottomNavItem> items;

  /// Kapsülün ölçüleri; gösterge ile sekme içeriği aynı değerleri kullanır.
  static const double _capsuleWidth = 48;
  static const double _capsuleHeight = 30;

  const AppBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.borderSoft)),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: AppSizes.navBarHeight,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final double tabWidth = constraints.maxWidth / items.length;

              return Stack(
                children: [
                  // KAPSÜL
                  //
                  // Her sekmede ayrı ayrı belirip kaybolmak yerine tek bir
                  // yüzey yeni sekmenin ikonunun arkasına kayar.
                  AnimatedPositioned(
                    duration: const Duration(milliseconds: 280),
                    curve: Curves.easeOutCubic,
                    left: tabWidth * currentIndex,
                    top: AppSpacing.sm - 2,
                    width: tabWidth,
                    height: _capsuleHeight,
                    child: Center(
                      child: Container(
                        width: _capsuleWidth,
                        height: _capsuleHeight,
                        decoration: BoxDecoration(
                          color: AppColors.primarySoft,
                          borderRadius: BorderRadius.circular(
                            _capsuleHeight / 2,
                          ),
                        ),
                      ),
                    ),
                  ),

                  Row(
                    children: [
                      for (int i = 0; i < items.length; i++)
                        Expanded(
                          child: _NavTab(
                            item: items[i],
                            selected: i == currentIndex,
                            onTap: () => onTap(i),
                          ),
                        ),
                    ],
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _NavTab extends StatelessWidget {
  final AppBottomNavItem item;
  final bool selected;
  final VoidCallback onTap;

  const _NavTab({
    required this.item,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        children: [
          const SizedBox(height: AppSpacing.sm - 2),

          SizedBox(
            height: AppBottomNav._capsuleHeight,
            child: Center(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 180),
                child: Icon(
                  selected ? item.selectedIcon : item.icon,
                  key: ValueKey<bool>(selected),
                  size: selected ? 27 : 22,
                  color: selected ? AppColors.primary : AppColors.textTertiary,
                ),
              ),
            ),
          ),

          const SizedBox(height: AppSpacing.xs + 1),

          AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 180),
            style: TextStyle(
              fontSize: 11,
              height: 1.1,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              color: selected ? AppColors.primary : AppColors.textTertiary,
            ),
            child: Text(
              item.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
