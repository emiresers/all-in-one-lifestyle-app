import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_spacing.dart';
import '../models/product.dart';
import 'app_feedback.dart';
import 'category_tile.dart';

/// Ürün kartının sabit ölçüleri.
///
/// Kart yüksekliği bir orana değil, bu değerlerden hesaplanan piksellere
/// dayanır: metin bloğu kart daraldıkça kısalmadığı için sabit oran dar
/// ekranlarda taşmaya yol açıyor.
class ProductCardMetrics {
  const ProductCardMetrics._();

  /// Kartın iç boşluğu.
  static const double padding = AppSpacing.sm - 2;

  /// Kart kenarlığının iki yandan toplamı.
  static const double borderWidth = 1.3;

  /// Görsel alanı ile bilgi bloğu arasındaki boşluk.
  static const double imageToInfoGap = 4;

  /// Görsel yüzeyinin yükseklik / genişlik oranı.
  ///
  /// Hafifçe dikey: ürün fotoğrafı kare alana göre belirgin biçimde büyür.
  static const double imageAspect = 1.10;

  /// Görselin yüzeyle arasındaki boşluk.
  static const double imageInset = AppSpacing.sm - 2;

  /// Ürün adı için her kartta ayrılan yükseklik (iki satır).
  ///
  /// Kısa adlı ürünlerde de aynı yükseklik ayrılır; böylece puan ve fiyat
  /// satırları bütün kartlarda aynı hizada durur.
  static const double titleBlockHeight = 28;

  /// Sepete ekleme düğmesinin görünen ölçüsü.
  static const double addButtonSize = 36;

  /// Sepete ekleme düğmesinin kompakt dokunma alanı.
  static const double addTouchTarget = 38;

  /// Dokunma alanı: görünen düğme daha küçük olsa da hedef 44 px kalır.
  static const double touchTarget = 44;

  /// Favori düğmesinin görünen ölçüsü.
  static const double favoriteSize = 32;

  /// Favori düğmesinin görsel alanının köşesine uzaklığı.
  static const double favoriteInset = AppSpacing.sm;
}

/// Kategori → başlık → puan → fiyat bloğunun yüksekliği.
///
/// Sistem yazı ölçeği büyütüldüğünde blok da onunla birlikte büyür.
double productInfoHeight(double textScale) {
  final categoryHeight = 10.5 * textScale;
  final titleHeight = ProductCardMetrics.titleBlockHeight * textScale;
  final ratingHeight = (12 * 1.05 * textScale).clamp(14.0, double.infinity);

  return (categoryHeight +
              1 +
              titleHeight +
              3 +
              ratingHeight +
              5 +
              ProductCardMetrics.addTouchTarget)
          .ceilToDouble() +
      1;
}

/// Ürün grid'inin ölçüsü.
///
/// Yüksekliği orana bırakmak yerine `mainAxisExtent` ile piksel olarak verir:
/// görsel alanı her ekranda aynı oranda, bilgi bloğu ise her ekranda aynı
/// yükseklikte kalır. Gerçek grid ile iskelet aynı hesabı kullanır.
SliverGridDelegateWithFixedCrossAxisCount productGridDelegateFor(
  BuildContext context, {
  double horizontalPadding = AppSpacing.sm,
}) {
  const int columns = 2;
  const double spacing = 6;

  final double availableWidth =
      MediaQuery.sizeOf(context).width - horizontalPadding * 2;

  final double tileWidth = (availableWidth - spacing * (columns - 1)) / columns;

  final double imageWidth =
      tileWidth -
      ProductCardMetrics.borderWidth -
      ProductCardMetrics.padding * 2;

  final double textScale = MediaQuery.textScalerOf(context)
      .scale(1)
      .clamp(1.0, 1.35);

  final double tileHeight =
      ProductCardMetrics.borderWidth +
      ProductCardMetrics.padding * 2 +
      imageWidth * ProductCardMetrics.imageAspect +
      ProductCardMetrics.imageToInfoGap +
      productInfoHeight(textScale);

  return SliverGridDelegateWithFixedCrossAxisCount(
    crossAxisCount: columns,
    crossAxisSpacing: spacing,
    mainAxisSpacing: 6,
    mainAxisExtent: tileHeight,
  );
}

/// Ürün grid'indeki tek kart.
///
/// Görsel, kategoriye göre çok hafif tonlanmış bir yüzeyin üzerinde durur;
/// altında kategori, başlık, puan ve fiyat sırasıyla yer alır. Favori ve
/// sepete ekleme düğmeleri karta basma davranışından bağımsız çalışır.
class ProductCard extends StatefulWidget {
  final Product product;

  /// Kartın ana alanına basıldığında (ürün detayına gider).
  final VoidCallback onTap;

  final bool isFavorite;
  final VoidCallback onToggleFavorite;

  /// Sepete ekleme; işlem sürerken düğme kendi yükleniyor hâlini gösterir.
  final VoidCallback onAddToCart;
  final bool isAddingToCart;

  const ProductCard({
    super.key,
    required this.product,
    required this.onTap,
    required this.isFavorite,
    required this.onToggleFavorite,
    required this.onAddToCart,
    this.isAddingToCart = false,
  });

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  bool _pressed = false;

  void _setPressed(bool value) {
    if (_pressed == value) return;

    setState(() {
      _pressed = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    final Product product = widget.product;

    return AnimatedScale(
      scale: _pressed ? 0.98 : 1,
      duration: const Duration(milliseconds: 140),
      curve: Curves.easeOutCubic,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(color: AppColors.border, width: 0.65),
        ),
        child: GestureDetector(
          onTapDown: (_) => _setPressed(true),
          onTapUp: (_) => _setPressed(false),
          onTapCancel: () => _setPressed(false),
          onTap: widget.onTap,
          behavior: HitTestBehavior.opaque,
          child: Padding(
            padding: const EdgeInsets.all(ProductCardMetrics.padding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // GÖRSEL + FAVORİ
                AspectRatio(
                  aspectRatio: 1 / ProductCardMetrics.imageAspect,
                  child: Stack(
                    children: [
                      Positioned.fill(child: _ProductImage(product: product)),

                      Positioned(
                        top:
                            ProductCardMetrics.favoriteInset -
                            (ProductCardMetrics.touchTarget -
                                    ProductCardMetrics.favoriteSize) /
                                2,
                        right:
                            ProductCardMetrics.favoriteInset -
                            (ProductCardMetrics.touchTarget -
                                    ProductCardMetrics.favoriteSize) /
                                2,
                        child: FavoriteButton(
                          isFavorite: widget.isFavorite,
                          onTap: widget.onToggleFavorite,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: ProductCardMetrics.imageToInfoGap),

                Padding(
                  padding: EdgeInsets.zero,
                  child: _ProductInfo(
                    product: product,
                    isAddingToCart: widget.isAddingToCart,
                    onAddToCart: widget.onAddToCart,
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

/// Görselin durduğu, kategoriye göre çok hafif tonlanmış yüzey.
class _ProductImage extends StatelessWidget {
  final Product product;

  const _ProductImage({required this.product});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: CategoryVisual.of(product.category).imageTint,
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      padding: const EdgeInsets.all(ProductCardMetrics.imageInset),
      child: Center(
        child: Hero(
          tag: 'product-${product.id}',
          child: Image.network(
            product.thumbnail,
            fit: BoxFit.contain,
            gaplessPlayback: true,
            frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
              if (wasSynchronouslyLoaded) return child;

              return AnimatedOpacity(
                opacity: frame == null ? 0 : 1,
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOut,
                child: child,
              );
            },
            errorBuilder: (context, error, stackTrace) {
              return const Center(
                child: Icon(
                  Icons.image_not_supported_outlined,
                  size: 32,
                  color: AppColors.textTertiary,
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

/// Kategori → başlık → puan → fiyat + sepet düğmesi.
class _ProductInfo extends StatelessWidget {
  final Product product;
  final bool isAddingToCart;
  final VoidCallback onAddToCart;

  const _ProductInfo({
    required this.product,
    required this.isAddingToCart,
    required this.onAddToCart,
  });

  @override
  Widget build(BuildContext context) {
    final textScale = MediaQuery.textScalerOf(context)
        .scale(1)
        .clamp(1.0, 1.35);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _prettyCategory(product.category),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 10.5,
            height: 1,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.1,
            color: AppColors.textTertiary,
          ),
        ),

        const SizedBox(height: 1),

        // Kısa adlı ürünlerde de aynı yükseklik ayrılır.
        SizedBox(
          height: ProductCardMetrics.titleBlockHeight * textScale,
          child: Text(
            product.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 13,
              height: 1.05,
              fontWeight: FontWeight.w600,
              letterSpacing: -0.2,
              color: AppColors.textPrimary,
            ),
          ),
        ),

        const SizedBox(height: 3),

        _RatingRow(rating: product.rating, reviewCount: product.reviewCount),

        const SizedBox(height: 5),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Text(
                '\$${product.price.toStringAsFixed(2)}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 20,
                  height: 1.05,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.6,
                  color: AppColors.textPrimary,
                ),
              ),
            ),

            const SizedBox(width: AppSpacing.sm),

            AddToCartButton(isBusy: isAddingToCart, onTap: onAddToCart),
          ],
        ),
      ],
    );
  }

  String _prettyCategory(String category) {
    return category
        .split('-')
        .map(
          (word) => word.isEmpty
              ? word
              : '${word[0].toUpperCase()}${word.substring(1)}',
        )
        .join(' ');
  }
}

/// Rozet yerine sade "★ 4.8 · 128" satırı.
class _RatingRow extends StatelessWidget {
  final double rating;
  final int reviewCount;

  const _RatingRow({required this.rating, required this.reviewCount});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.star_rounded, size: 14, color: AppColors.rating),

        const SizedBox(width: AppSpacing.xs),

        Text(
          rating.toStringAsFixed(1),
          style: const TextStyle(
            fontSize: 12,
            height: 1.05,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),

        if (reviewCount > 0) ...[
          const SizedBox(width: 4),
          const Text(
            '·',
            style: TextStyle(
              fontSize: 11,
              height: 1.05,
              fontWeight: FontWeight.w500,
              color: AppColors.textTertiary,
            ),
          ),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              '$reviewCount',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 11,
                height: 1.05,
                fontWeight: FontWeight.w500,
                color: AppColors.textTertiary,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

/// Görselin sağ üstündeki favori düğmesi.
///
/// Görünen daire 32 px; dokunma alanı 44 px'e genişletilir.
class FavoriteButton extends StatelessWidget {
  final bool isFavorite;
  final VoidCallback onTap;

  const FavoriteButton({
    super.key,
    required this.isFavorite,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: ProductCardMetrics.touchTarget,
        height: ProductCardMetrics.touchTarget,
        child: Center(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOutCubic,
            width: ProductCardMetrics.favoriteSize,
            height: ProductCardMetrics.favoriteSize,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: isFavorite ? AppColors.favoriteSoft : AppColors.surface,
              shape: BoxShape.circle,
              border: Border.all(
                color: isFavorite ? AppColors.favoriteSoft : AppColors.border,
              ),
            ),
            child: AppBounceOnChange(
              value: isFavorite,
              child: Icon(
                isFavorite
                    ? Icons.favorite_rounded
                    : Icons.favorite_border_rounded,
                size: 16,
                color: isFavorite ? AppColors.favorite : AppColors.textTertiary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Fiyatın yanındaki yuvarlatılmış "+" düğmesi.
///
/// Görünen kare 36 px, kompakt dokunma alanı 38 px'tir.
class AddToCartButton extends StatefulWidget {
  final bool isBusy;
  final VoidCallback onTap;

  const AddToCartButton({super.key, required this.isBusy, required this.onTap});

  @override
  State<AddToCartButton> createState() => _AddToCartButtonState();
}

class _AddToCartButtonState extends State<AddToCartButton> {
  bool _pressed = false;

  /// Ekleme bittikten sonra kısa süre onay işareti gösterir.
  bool _justAdded = false;

  void _setPressed(bool value) {
    if (_pressed == value) return;

    setState(() {
      _pressed = value;
    });
  }

  @override
  void didUpdateWidget(covariant AddToCartButton oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.isBusy && !widget.isBusy) {
      setState(() {
        _justAdded = true;
      });

      Future.delayed(const Duration(milliseconds: 1100), () {
        if (mounted) {
          setState(() {
            _justAdded = false;
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _setPressed(true),
      onTapUp: (_) => _setPressed(false),
      onTapCancel: () => _setPressed(false),
      onTap: widget.isBusy ? null : widget.onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: ProductCardMetrics.addTouchTarget,
        height: ProductCardMetrics.addTouchTarget,
        child: Center(
          child: AnimatedScale(
            scale: _pressed ? 0.96 : 1,
            duration: const Duration(milliseconds: 120),
            curve: Curves.easeOutCubic,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOutCubic,
              width: ProductCardMetrics.addButtonSize,
              height: ProductCardMetrics.addButtonSize,
              decoration: BoxDecoration(
                color: _justAdded
                    ? AppColors.success
                    : _pressed
                    ? AppColors.primaryDark
                    : AppColors.primary,
                borderRadius: BorderRadius.circular(AppRadius.sm + 1),
              ),
              child: Center(child: _buildIcon()),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIcon() {
    if (widget.isBusy) {
      return const SizedBox(
        width: 15,
        height: 15,
        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
      );
    }

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 200),
      transitionBuilder: (child, animation) =>
          ScaleTransition(scale: animation, child: child),
      child: Icon(
        _justAdded ? Icons.check_rounded : Icons.add_rounded,
        key: ValueKey<bool>(_justAdded),
        size: 20,
        color: Colors.white,
      ),
    );
  }
}
