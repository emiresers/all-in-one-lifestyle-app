import 'package:flutter/material.dart';

import '../../core/app_page_route.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../models/product.dart';
import '../../services/cart_service.dart';
import '../../services/product_service.dart';
import '../carts/cart_screen.dart';
import '../../widgets/app_error_state.dart';
import '../../widgets/app_feedback.dart';
import '../../widgets/app_loading_state.dart';

class ProductDetailScreen extends StatefulWidget {
  final int productId;
  final int userId;

  const ProductDetailScreen({
    super.key,
    required this.productId,
    required this.userId,
  });

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  final ProductService _productService = ProductService();

  final CartService _cartService = CartService();

  late Future<Product> _productFuture;

  bool _isAddingToCart = false;

  // Açıklama kartının açık/kapalı durumu.
  bool _isDescriptionExpanded = false;

  @override
  void initState() {
    super.initState();

    _productFuture = _productService.getProduct(widget.productId);
  }

  Future<void> _addToCart(Product product) async {
    setState(() {
      _isAddingToCart = true;
    });

    try {
      await _cartService.addToCart(
        userId: widget.userId,
        productId: product.id,
        quantity: 1,
      );

      if (!mounted) return;

      AppFeedback.success(context, 'Product added to cart.');
    } catch (e) {
      if (!mounted) return;

      AppFeedback.failure(context, 'Could not add product to cart: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isAddingToCart = false;
        });
      }
    }
  }

  /// "Buy Now": mevcut sepete ekleme akışını çalıştırıp doğrudan sepete
  /// götürür. DummyJSON'da checkout uç noktası olmadığı için ayrıca bir
  /// satın alma akışı tanımlanmadı.
  Future<void> _buyNow(Product product) async {
    await _addToCart(product);

    if (!mounted) return;

    await Navigator.push(
      context,
      AppPageRoute.zoomFade(CartScreen(userId: widget.userId)),
    );
  }

  String _formatCategory(String category) {
    return category
        .split('-')
        .map(
          (word) => word.isEmpty
              ? word
              : '${word[0].toUpperCase()}${word.substring(1)}',
        )
        .join(' ');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,

      appBar: AppBar(
        title: const Text('Product Detail'),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                AppPageRoute.zoomFade(CartScreen(userId: widget.userId)),
              );
            },
            tooltip: 'Cart',
            icon: const Icon(Icons.shopping_cart_outlined, size: 22),
          ),

          const SizedBox(width: AppSpacing.xs),
        ],
      ),

      body: FutureBuilder<Product>(
        future: _productFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const AppLoadingState();
          }

          if (snapshot.hasError) {
            return AppErrorState(
              message: snapshot.error.toString(),
              onRetry: () {
                setState(() {
                  _productFuture = _productService.getProduct(widget.productId);
                });
              },
            );
          }

          if (!snapshot.hasData) {
            return const AppErrorState(message: 'Product not found.');
          }

          final product = snapshot.data!;

          return _ProductBody(
            product: product,
            categoryLabel: _formatCategory(product.category),
            isDescriptionExpanded: _isDescriptionExpanded,
            onToggleDescription: () {
              setState(() {
                _isDescriptionExpanded = !_isDescriptionExpanded;
              });
            },
          );
        },
      ),

      // Sticky CTA: içerik ne kadar uzun olursa olsun sepete ekleme her zaman
      // ekranda kalır. Scaffold bottomNavigationBar kullandığı için içerik
      // butonun arkasında kalmaz.
      bottomNavigationBar: FutureBuilder<Product>(
        future: _productFuture,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const SizedBox.shrink();
          }

          final product = snapshot.data!;

          return _BottomCartBar(
            price: product.price,
            isAddingToCart: _isAddingToCart,
            onAddToCart: () {
              _addToCart(product);
            },
            onBuyNow: () {
              _buyNow(product);
            },
          );
        },
      ),
    );
  }
}

class _ProductBody extends StatelessWidget {
  final Product product;
  final String categoryLabel;
  final bool isDescriptionExpanded;
  final VoidCallback onToggleDescription;

  const _ProductBody({
    required this.product,
    required this.categoryLabel,
    required this.isDescriptionExpanded,
    required this.onToggleDescription,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screenH,
        AppSpacing.xs,
        AppSpacing.screenH,
        AppSpacing.xl,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ÜRÜN GÖRSELİ
          Container(
            width: double.infinity,
            height: 280,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppColors.border),
              boxShadow: AppColors.softShadow,
            ),
            child: Padding(
              padding: const EdgeInsets.all(22),
              child: Hero(
                tag: 'product-${product.id}',
                child: Image.network(
                  product.thumbnail,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(
                      Icons.image_not_supported_outlined,
                      size: 52,
                      color: AppColors.textTertiary,
                    );
                  },
                ),
              ),
            ),
          ),

          const SizedBox(height: AppSpacing.lg),

          // BAŞLIK
          Text(
            product.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.7,
              height: 1.2,
            ),
          ),

          const SizedBox(height: AppSpacing.lg),

          // ÖZET BİLGİLER
          Row(
            children: [
              Expanded(
                child: _StatTile(
                  icon: Icons.star_rounded,
                  iconColor: AppColors.amber,
                  value: product.rating.toStringAsFixed(1),
                  label: 'Rating',
                ),
              ),

              const SizedBox(width: AppSpacing.sm),

              Expanded(
                child: _StatTile(
                  icon: Icons.category_outlined,
                  value: categoryLabel,
                  label: 'Category',
                ),
              ),

              const SizedBox(width: AppSpacing.sm),

              Expanded(
                child: _StatTile(
                  icon: Icons.qr_code_rounded,
                  value: '#${product.id}',
                  label: 'Product ID',
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.lg),

          // AÇIKLAMA (katlanabilir)
          _DescriptionCard(
            description: product.description,
            expanded: isDescriptionExpanded,
            onTap: onToggleDescription,
          ),
        ],
      ),
    );
  }
}

/// Ürün detayındaki kompakt bilgi kutucuğu.
class _StatTile extends StatelessWidget {
  final IconData icon;
  final Color? iconColor;
  final String value;
  final String label;

  const _StatTile({
    required this.icon,
    required this.value,
    required this.label,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 13),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.field),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Icon(icon, size: 18, color: iconColor ?? AppColors.textSecondary),

          const SizedBox(height: 7),

          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.2,
            ),
          ),

          const SizedBox(height: 2),

          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.textTertiary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

/// Başlangıçta tek satır önizleme gösteren, dokunulduğunda animasyonlu şekilde
/// açılan kompakt açıklama kartı.
class _DescriptionCard extends StatelessWidget {
  final String description;
  final bool expanded;
  final VoidCallback onTap;

  const _DescriptionCard({
    required this.description,
    required this.expanded,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: AppColors.border),
        boxShadow: AppColors.softShadow,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppRadius.card),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: AppColors.surfaceSecondary,
                        borderRadius: BorderRadius.circular(11),
                      ),
                      child: const Icon(
                        Icons.description_outlined,
                        size: 17,
                        color: AppColors.textSecondary,
                      ),
                    ),

                    const SizedBox(width: AppSpacing.sm),

                    const Expanded(
                      child: Text(
                        'Description',
                        style: TextStyle(
                          fontSize: 15.5,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.2,
                        ),
                      ),
                    ),

                    Text(
                      expanded ? 'Less' : 'More',
                      style: const TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textSecondary,
                      ),
                    ),

                    const SizedBox(width: 2),

                    AnimatedRotation(
                      turns: expanded ? 0.5 : 0,
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.easeInOut,
                      child: const Icon(
                        Icons.keyboard_arrow_down_rounded,
                        size: 22,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: AppSpacing.sm),

                AnimatedSize(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeInOut,
                  alignment: Alignment.topCenter,
                  child: SizedBox(
                    width: double.infinity,
                    child: Text(
                      description,
                      maxLines: expanded ? null : 1,
                      overflow: expanded
                          ? TextOverflow.clip
                          : TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14.5,
                        height: 1.55,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Ekranın altında sabit duran fiyat + aksiyon alanı.
class _BottomCartBar extends StatelessWidget {
  final double price;
  final bool isAddingToCart;
  final VoidCallback onAddToCart;
  final VoidCallback onBuyNow;

  const _BottomCartBar({
    required this.price,
    required this.isAddingToCart,
    required this.onAddToCart,
    required this.onBuyNow,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.screenH,
            AppSpacing.md,
            AppSpacing.screenH,
            AppSpacing.md,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Text(
                    'Price',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textTertiary,
                    ),
                  ),

                  const SizedBox(width: AppSpacing.sm),

                  Text(
                    '\$${price.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: AppSpacing.md),

              Row(
                children: [
                  // HEMEN AL
                  Expanded(
                    child: SizedBox(
                      height: AppSizes.primaryButtonHeight,
                      child: OutlinedButton(
                        onPressed: isAddingToCart ? null : onBuyNow,
                        style: OutlinedButton.styleFrom(
                          backgroundColor: AppColors.surface,
                          foregroundColor: AppColors.primary,
                          side: const BorderSide(
                            color: AppColors.primary,
                            width: 1.4,
                          ),
                          shape: const StadiumBorder(),
                        ),
                        child: const Text(
                          'Buy Now',
                          style: TextStyle(
                            fontSize: 15.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: AppSpacing.md),

                  // SEPETE EKLE
                  Expanded(
                    child: SizedBox(
                      height: AppSizes.primaryButtonHeight,
                      child: FilledButton.icon(
                        onPressed: isAddingToCart ? null : onAddToCart,
                        style: FilledButton.styleFrom(
                          shape: const StadiumBorder(),
                        ),
                        icon: isAddingToCart
                            ? const SizedBox(
                                width: 19,
                                height: 19,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(Icons.shopping_bag_outlined, size: 20),
                        label: Text(
                          isAddingToCart ? 'Adding...' : 'Add to Cart',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 15.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
