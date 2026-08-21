import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../models/cart.dart';
import '../../services/cart_service.dart';
import '../../widgets/app_card.dart';
import '../../widgets/app_empty_state.dart';
import '../../widgets/app_error_state.dart';
import '../../widgets/app_feedback.dart';
import '../../widgets/app_loading_state.dart';
import '../../widgets/app_screen_header.dart';

class CartScreen extends StatefulWidget {
  final int userId;

  const CartScreen({super.key, required this.userId});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final CartService _cartService = CartService();

  Cart? _cart;

  bool _isLoading = true;
  bool _isUpdating = false;

  String? _errorMessage;

  // Ürün adetlerini lokal olarak burada tutacağız.
  final Map<int, int> _quantities = {};

  @override
  void initState() {
    super.initState();

    _loadCart();
  }

  Future<void> _loadCart() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final carts = await _cartService.getUserCarts(widget.userId);

      if (!mounted) return;

      if (carts.isEmpty) {
        setState(() {
          _cart = null;
          _isLoading = false;
        });

        return;
      }

      final cart = carts.first;

      _quantities.clear();

      for (final product in cart.products) {
        _quantities[product.id] = product.quantity;
      }

      setState(() {
        _cart = cart;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  int _quantityFor(int productId) {
    return _quantities[productId] ?? 1;
  }

  int get _totalQuantity {
    if (_cart == null) {
      return 0;
    }

    return _cart!.products.fold<int>(
      0,
      (total, product) => total + _quantityFor(product.id),
    );
  }

  double get _totalPrice {
    if (_cart == null) {
      return 0;
    }

    return _cart!.products.fold<double>(0, (total, product) {
      final quantity = _quantityFor(product.id);

      return total + (product.price * quantity);
    });
  }

  double get _discountedTotal {
    if (_cart == null) {
      return 0;
    }

    /*
      DummyJSON'dan gelen orijinal toplam ve indirimli toplam
      arasındaki oranı koruyoruz.

      Böylece quantity değiştiğinde alttaki indirimli toplam da
      ekranda değişiyor.
    */

    if (_cart!.total <= 0) {
      return _totalPrice;
    }

    final discountRatio = _cart!.discountedTotal / _cart!.total;

    return _totalPrice * discountRatio;
  }

  Future<void> _changeQuantity({
    required int productId,
    required int newQuantity,
  }) async {
    if (_cart == null) {
      return;
    }

    // 1'den aşağı düşürme.
    if (newQuantity < 1) {
      return;
    }

    if (_isUpdating) {
      return;
    }

    final oldQuantity = _quantityFor(productId);

    // Kasıtlı ama küçük bir değişim: mesaj yerine yalnızca dokunsal tepki.
    AppFeedback.selection();

    // Önce UI'da anında değiştir.
    setState(() {
      _quantities[productId] = newQuantity;
      _isUpdating = true;
    });

    try {
      await _cartService.updateCart(
        cartId: _cart!.id,
        productId: productId,
        quantity: newQuantity,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Quantity updated: $newQuantity'),
          duration: const Duration(milliseconds: 700),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      // API başarısızsa eski adede geri dön.
      setState(() {
        _quantities[productId] = oldQuantity;
      });

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Could not update cart: $e')));
    } finally {
      if (mounted) {
        setState(() {
          _isUpdating = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,

      appBar: AppBar(
        toolbarHeight: 44,
        foregroundColor: Colors.white,
        flexibleSpace: const AppPrimaryHeaderSurface(child: SizedBox.expand()),
      ),

      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const AppLoadingState();
    }

    if (_errorMessage != null) {
      return AppErrorState(message: _errorMessage!, onRetry: _loadCart);
    }

    if (_cart == null || _cart!.products.isEmpty) {
      return const AppEmptyState(
        icon: Icons.shopping_cart_outlined,
        title: 'Your cart is empty',
        subtitle: 'Products you add will show up here.',
      );
    }

    final cart = _cart!;

    return SafeArea(
      top: false,
      child: Column(
        children: [
          AppPrimaryHeaderSurface(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.screenH,
                AppSpacing.md,
                AppSpacing.screenH,
                AppSpacing.lg,
              ),
              child: AppScreenHeader(
                title: 'My Cart',
                subtitle: '${cart.products.length} items in your cart',
                foregroundColor: Colors.white,
              ),
            ),
          ),

          const SizedBox(height: AppSpacing.md),

          Expanded(
            child: RefreshIndicator(
              onRefresh: _loadCart,
              child: ListView.separated(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.screenH,
                  2,
                  AppSpacing.screenH,
                  AppSpacing.lg,
                ),
                itemCount: cart.products.length,
                separatorBuilder: (_, _) =>
                    const SizedBox(height: AppSpacing.sm),
                itemBuilder: (context, index) {
                  final product = cart.products[index];

                  final quantity = _quantityFor(product.id);

                  return _CartProductCard(
                    product: product,
                    quantity: quantity,
                    isUpdating: _isUpdating,
                    onDecrease: () {
                      _changeQuantity(
                        productId: product.id,
                        newQuantity: quantity - 1,
                      );
                    },
                    onIncrease: () {
                      _changeQuantity(
                        productId: product.id,
                        newQuantity: quantity + 1,
                      );
                    },
                  );
                },
              ),
            ),
          ),

          _OrderSummary(
            productCount: cart.products.length,
            totalQuantity: _totalQuantity,
            subtotal: _totalPrice,
            discountedTotal: _discountedTotal,
          ),
        ],
      ),
    );
  }
}

class _CartProductCard extends StatelessWidget {
  final CartProduct product;
  final int quantity;
  final bool isUpdating;
  final VoidCallback onDecrease;
  final VoidCallback onIncrease;

  const _CartProductCard({
    required this.product,
    required this.quantity,
    required this.isUpdating,
    required this.onDecrease,
    required this.onIncrease,
  });

  @override
  Widget build(BuildContext context) {
    final double itemTotal = product.price * quantity;

    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 86,
            height: 86,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.surfaceSecondary,
              borderRadius: BorderRadius.circular(AppRadius.field),
            ),
            child: Image.network(
              product.thumbnail,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return const Icon(
                  Icons.image_not_supported_outlined,
                  size: 26,
                  color: AppColors.textTertiary,
                );
              },
            ),
          ),

          const SizedBox(width: AppSpacing.md),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    height: 1.3,
                  ),
                ),

                const SizedBox(height: 5),

                Text(
                  '\$${product.price.toStringAsFixed(2)} each',
                  style: const TextStyle(
                    fontSize: 12.5,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),

                const SizedBox(height: 12),

                Row(
                  children: [
                    _QuantityStepper(
                      quantity: quantity,
                      onDecrease: quantity <= 1 || isUpdating
                          ? null
                          : onDecrease,
                      onIncrease: isUpdating ? null : onIncrease,
                    ),

                    const SizedBox(width: AppSpacing.sm),

                    Expanded(
                      child: Text(
                        '\$${itemTotal.toStringAsFixed(2)}',
                        textAlign: TextAlign.right,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.2,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Kompakt [ − ] 3 [ + ] adet kontrolü.
class _QuantityStepper extends StatelessWidget {
  final int quantity;
  final VoidCallback? onDecrease;
  final VoidCallback? onIncrease;

  const _QuantityStepper({
    required this.quantity,
    required this.onDecrease,
    required this.onIncrease,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: AppSizes.stepperButton,
      decoration: BoxDecoration(
        color: AppColors.fieldFill,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _StepperButton(
            icon: Icons.remove_rounded,
            onTap: onDecrease,
            borderRadius: const BorderRadius.horizontal(
              left: Radius.circular(11),
            ),
          ),

          SizedBox(
            width: 30,
            child: Text(
              '$quantity',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14.5,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),

          _StepperButton(
            icon: Icons.add_rounded,
            onTap: onIncrease,
            accent: true,
            borderRadius: const BorderRadius.horizontal(
              right: Radius.circular(11),
            ),
          ),
        ],
      ),
    );
  }
}

class _StepperButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final BorderRadius borderRadius;
  final bool accent;

  const _StepperButton({
    required this.icon,
    required this.onTap,
    required this.borderRadius,
    this.accent = false,
  });

  @override
  Widget build(BuildContext context) {
    final bool enabled = onTap != null;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: borderRadius,
        child: SizedBox(
          width: AppSizes.stepperButton,
          height: AppSizes.stepperButton,
          child: Icon(
            icon,
            size: 18,
            color: !enabled
                ? AppColors.textTertiary
                : accent
                ? AppColors.primary
                : AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}

class _OrderSummary extends StatelessWidget {
  final int productCount;
  final int totalQuantity;
  final double subtotal;
  final double discountedTotal;

  const _OrderSummary({
    required this.productCount,
    required this.totalQuantity,
    required this.subtotal,
    required this.discountedTotal,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screenH,
        0,
        AppSpacing.screenH,
        AppSpacing.md,
      ),
      child: Container(
        padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.largeCard),
          border: Border.all(color: AppColors.border),
          boxShadow: AppColors.floatingShadow,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Order Summary',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.3,
              ),
            ),

            const SizedBox(height: AppSpacing.md),

            _SummaryRow(label: 'Products', value: '$productCount'),

            const SizedBox(height: 9),

            _SummaryRow(label: 'Total Quantity', value: '$totalQuantity'),

            const SizedBox(height: 9),

            _SummaryRow(
              label: 'Subtotal',
              value: '\$${subtotal.toStringAsFixed(2)}',
            ),

            const SizedBox(height: 9),

            _SummaryRow(
              label: 'Discount',
              value: '-\$${(subtotal - discountedTotal).toStringAsFixed(2)}',
              valueColor: AppColors.success,
            ),

            const Padding(
              padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
              child: Divider(color: AppColors.border, height: 1),
            ),

            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const Expanded(
                  child: Text(
                    'Total',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.2,
                    ),
                  ),
                ),

                const SizedBox(width: AppSpacing.sm),

                Text(
                  '\$${discountedTotal.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.7,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _SummaryRow({
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13.5,
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),

        Text(
          value,
          style: TextStyle(
            fontSize: 13.5,
            fontWeight: FontWeight.w700,
            color: valueColor ?? AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}
