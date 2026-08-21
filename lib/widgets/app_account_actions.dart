import 'package:flutter/material.dart';

import '../core/app_page_route.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_spacing.dart';
import '../screens/carts/cart_screen.dart';
import '../screens/users/user_detail_screen.dart';
import '../services/cart_service.dart';
import 'app_pressable.dart';

/// Ana sekmelerde ortak kullanılan profil ve sepet aksiyonları.
class AppAccountActions extends StatefulWidget {
  final int userId;

  const AppAccountActions({super.key, required this.userId});

  @override
  State<AppAccountActions> createState() => _AppAccountActionsState();
}

class _AppAccountActionsState extends State<AppAccountActions> {
  final CartService _cartService = CartService();
  int _cartItemCount = 0;

  @override
  void initState() {
    super.initState();
    _loadCartCount();
  }

  Future<void> _loadCartCount() async {
    try {
      final carts = await _cartService.getUserCarts(widget.userId);

      if (!mounted) return;

      setState(() {
        _cartItemCount = carts.fold<int>(
          0,
          (total, cart) => total + cart.totalQuantity,
        );
      });
    } catch (_) {
      // Sepet okunamazsa buton çalışmaya devam eder, yalnızca rozet gizlenir.
    }
  }

  void _openProfile() {
    Navigator.push(
      context,
      AppPageRoute.to(
        UserDetailScreen(userId: widget.userId, showSignOut: true),
      ),
    );
  }

  Future<void> _openCart() async {
    await Navigator.push(
      context,
      AppPageRoute.zoomFade(CartScreen(userId: widget.userId)),
    );

    if (mounted) {
      await _loadCartCount();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _RoundHeaderButton(
          tooltip: 'Profile',
          icon: Icons.person_outline_rounded,
          onTap: _openProfile,
        ),
        const SizedBox(width: AppSpacing.sm + 2),
        _RoundHeaderButton(
          tooltip: 'Cart',
          icon: Icons.shopping_bag_outlined,
          badgeCount: _cartItemCount,
          onTap: _openCart,
        ),
      ],
    );
  }
}

class _RoundHeaderButton extends StatelessWidget {
  static const double _size = 44;

  final String tooltip;
  final IconData icon;
  final int badgeCount;
  final VoidCallback onTap;

  const _RoundHeaderButton({
    required this.tooltip,
    required this.icon,
    required this.onTap,
    this.badgeCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: AppPressable(
        onTap: onTap,
        pressedScale: 0.94,
        child: SizedBox(
          width: _size,
          height: _size,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: _size,
                height: _size,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.border),
                ),
                child: Icon(icon, size: 21, color: AppColors.textPrimary),
              ),
              if (badgeCount > 0)
                Positioned(
                  top: -2,
                  right: -2,
                  child: Container(
                    constraints: const BoxConstraints(minWidth: 18),
                    height: 18,
                    padding: const EdgeInsets.symmetric(horizontal: 5),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.surface, width: 1.5),
                    ),
                    child: Text(
                      badgeCount > 99 ? '99+' : '$badgeCount',
                      style: const TextStyle(
                        fontSize: 10.5,
                        height: 1,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
