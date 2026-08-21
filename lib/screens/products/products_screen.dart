import 'package:flutter/material.dart';

import '../../core/app_page_route.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../models/product.dart';
import '../../services/cart_service.dart';
import '../../services/product_service.dart';
import '../../widgets/app_empty_state.dart';
import '../../widgets/app_error_state.dart';
import '../../widgets/app_feedback.dart';
import '../../widgets/app_pressable.dart';
import '../../widgets/app_search_field.dart';
import '../../widgets/app_screen_header.dart';
import '../../widgets/app_skeleton.dart';
import '../../widgets/category_strip.dart';
import '../../widgets/category_tile.dart';
import '../../widgets/product_card.dart';
import '../carts/cart_screen.dart';
import '../users/user_detail_screen.dart';
import 'product_detail_screen.dart';

class ProductsScreen extends StatefulWidget {
  final int userId;
  final ScrollController? scrollController;

  const ProductsScreen({
    super.key,
    required this.userId,
    this.scrollController,
  });

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  static const int _productsPageSize = 10;

  final ProductService _productService = ProductService();
  final CartService _cartService = CartService();

  final TextEditingController _searchController = TextEditingController();
  late final ScrollController _scrollController;
  late final bool _ownsScrollController;

  late Future<List<Product>> _productsFuture;
  late Future<List<String>> _categoriesFuture;

  final Set<String> _selectedCategories = <String>{};
  bool _isPaginatedAllView = true;
  bool _isLoadingMore = false;
  bool _hasMoreProducts = true;
  int _productsRequestGeneration = 0;

  /// Sepet ikonunun üzerindeki sayaç.
  int _cartItemCount = 0;

  /// Favoriler yalnızca arayüzde tutulur; DummyJSON'da favori uç noktası yok.
  final Set<int> _favoriteIds = <int>{};

  /// Sepete eklenmeyi bekleyen ürünler; kartın butonu bunlara bakar.
  final Set<int> _addingToCartIds = <int>{};

  @override
  void initState() {
    super.initState();

    _ownsScrollController = widget.scrollController == null;
    _scrollController = widget.scrollController ?? ScrollController();
    _productsFuture = _productService.getProducts(limit: _productsPageSize);
    _categoriesFuture = _productService.getCategories();
    _scrollController.addListener(_loadMoreWhenNeeded);

    _loadCartCount();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.removeListener(_loadMoreWhenNeeded);

    if (_ownsScrollController) {
      _scrollController.dispose();
    }

    super.dispose();
  }

  void _loadMoreWhenNeeded() {
    if (_scrollController.position.extentAfter < 500) {
      _loadMoreProducts();
    }
  }

  Future<void> _loadMoreProducts() async {
    if (!_isPaginatedAllView || _isLoadingMore || !_hasMoreProducts) {
      return;
    }

    final int generation = _productsRequestGeneration;

    setState(() {
      _isLoadingMore = true;
    });

    try {
      final currentProducts = await _productsFuture;
      final nextProducts = await _productService.getProducts(
        limit: _productsPageSize,
        skip: currentProducts.length,
      );

      if (!mounted || generation != _productsRequestGeneration) return;

      setState(() {
        _productsFuture = Future.value([...currentProducts, ...nextProducts]);
        _hasMoreProducts = nextProducts.length == _productsPageSize;
      });
    } catch (e) {
      if (!mounted || generation != _productsRequestGeneration) return;

      AppFeedback.failure(context, 'Could not load more products: $e');
    } finally {
      if (mounted && generation == _productsRequestGeneration) {
        setState(() {
          _isLoadingMore = false;
        });
      }
    }
  }

  void _resetPagination({required bool enabled}) {
    _productsRequestGeneration++;
    _isPaginatedAllView = enabled;
    _isLoadingMore = false;
    _hasMoreProducts = enabled;
  }

  /// Sepet rozetini kullanıcının mevcut sepetlerinden hesaplar.
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
      // Sepet okunamazsa rozet gösterilmez.
    }
  }

  void _searchProducts(String query) {
    final cleanQuery = query.trim();

    setState(() {
      _selectedCategories.clear();

      if (cleanQuery.isEmpty) {
        _resetPagination(enabled: true);
        _productsFuture = _productService.getProducts(limit: _productsPageSize);
      } else {
        _resetPagination(enabled: false);
        _productsFuture = _productService.searchProducts(cleanQuery);
      }
    });
  }

  void _selectCategory(String category) {
    _searchController.clear();

    if (category == 'all') {
      _applySelectedCategories(<String>{});
      return;
    }

    // Üstteki yatay kategori şeridi tek seçimlidir. Çoklu seçim yalnızca
    // filtre alt sayfasından yapılır.
    if (_selectedCategories.length == 1 &&
        _selectedCategories.contains(category)) {
      _applySelectedCategories(<String>{});
      return;
    }

    _applySelectedCategories(<String>{category});
  }

  void _applySelectedCategories(Set<String> categories) {
    _searchController.clear();

    setState(() {
      _selectedCategories
        ..clear()
        ..addAll(categories);
      _resetPagination(enabled: _selectedCategories.isEmpty);
      _productsFuture = _selectedCategories.isEmpty
          ? _productService.getProducts(limit: _productsPageSize)
          : _getSelectedCategoryProducts(_selectedCategories);
    });
  }

  Future<List<Product>> _getSelectedCategoryProducts(
    Set<String> categories,
  ) async {
    final categoryProducts = await Future.wait(
      categories.map(_productService.getProductsByCategory),
    );
    final productsById = <int, Product>{};

    for (final products in categoryProducts) {
      for (final product in products) {
        productsById[product.id] = product;
      }
    }

    return productsById.values.toList();
  }

  /// Ürün listesini varsayılan, filtresiz durumuna getirir.
  void _showAllProducts() {
    _searchController.clear();

    setState(() {
      _selectedCategories.clear();
      _resetPagination(enabled: true);
      _productsFuture = _productService.getProducts(limit: _productsPageSize);
    });
  }

  Future<void> _refreshProducts() async {
    setState(() {
      if (_selectedCategories.isEmpty) {
        _resetPagination(enabled: true);
        _productsFuture = _productService.getProducts(limit: _productsPageSize);
      } else {
        _resetPagination(enabled: false);
        _productsFuture = _getSelectedCategoryProducts(_selectedCategories);
      }
    });

    await _productsFuture;

    await _loadCartCount();
  }

  void _toggleFavorite(int productId) {
    setState(() {
      if (!_favoriteIds.remove(productId)) {
        _favoriteIds.add(productId);
      }
    });
  }

  Future<void> _addToCart(Product product) async {
    if (_addingToCartIds.contains(product.id)) {
      return;
    }

    setState(() {
      _addingToCartIds.add(product.id);
    });

    try {
      await _cartService.addToCart(
        userId: widget.userId,
        productId: product.id,
      );

      if (!mounted) return;

      setState(() {
        _cartItemCount += 1;
      });

      AppFeedback.success(context, '${product.title} added to cart.');
    } catch (e) {
      if (!mounted) return;

      AppFeedback.failure(context, 'Could not add product to cart: $e');
    } finally {
      if (mounted) {
        setState(() {
          _addingToCartIds.remove(product.id);
        });
      }
    }
  }

  void _openCart() {
    Navigator.push(
      context,
      AppPageRoute.zoomFade(CartScreen(userId: widget.userId)),
    ).then((_) => _loadCartCount());
  }

  void _openProfile() {
    Navigator.push(
      context,
      AppPageRoute.to(
        UserDetailScreen(userId: widget.userId, showSignOut: true),
      ),
    );
  }

  void _openProduct(Product product) {
    Navigator.push(
      context,
      AppPageRoute.to(
        ProductDetailScreen(productId: product.id, userId: widget.userId),
      ),
    ).then((_) => _loadCartCount());
  }

  /// Şeride sığmayan kategoriler için tam liste.
  Future<void> _openCategorySheet() async {
    final List<String> categories;

    try {
      categories = await _categoriesFuture;
    } catch (_) {
      return;
    }

    if (!mounted || categories.isEmpty) return;

    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.surface,
      showDragHandle: true,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
      ),
      builder: (context) {
        return _CategorySheet(
          categories: categories,
          selectedCategories: _selectedCategories,
          formatCategory: _formatCategory,
          onSelectionChanged: _applySelectedCategories,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: RefreshIndicator(
        onRefresh: _refreshProducts,
        edgeOffset: 12,
        child: CustomScrollView(
          controller: _scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: AppPrimaryHeaderSurface(
                child: Column(
                  children: [
                    _HomeHeader(
                      cartItemCount: _cartItemCount,
                      onCartTap: _openCart,
                      onProfileTap: _openProfile,
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.lg,
                        AppSpacing.lg + 2,
                        AppSpacing.lg,
                        0,
                      ),
                      child: AppSearchField(
                        controller: _searchController,
                        hintText: 'Search products',
                        onChanged: _searchProducts,
                        onClear: () {
                          _searchController.clear();
                          _showAllProducts();
                        },
                        trailing: _FilterButton(onTap: _openCategorySheet),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                  ],
                ),
              ),
            ),

            // KATEGORİLER
            SliverToBoxAdapter(
              child: FutureBuilder<List<String>>(
                future: _categoriesFuture,
                builder: (context, snapshot) {
                  final categories = snapshot.data ?? const <String>[];

                  if (categories.isEmpty) {
                    return const SizedBox(height: AppSpacing.lg);
                  }

                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: AppSpacing.xs,
                    ),
                    child: CategoryStrip(
                      categories: categories,
                      selectedCategories: _selectedCategories,
                      onSelect: _selectCategory,
                      onMore: _openCategorySheet,
                      formatCategory: _formatCategory,
                    ),
                  );
                },
              ),
            ),

            // ÜRÜNLER
            FutureBuilder<List<Product>>(
              future: _productsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting &&
                    !snapshot.hasData) {
                  return const SliverToBoxAdapter(child: ProductGridSkeleton());
                }

                if (snapshot.hasError) {
                  return SliverFillRemaining(
                    hasScrollBody: false,
                    child: AppErrorState(
                      message: snapshot.error.toString(),
                      onRetry: _showAllProducts,
                    ),
                  );
                }

                final products = snapshot.data ?? const <Product>[];

                if (products.isEmpty) {
                  return const SliverFillRemaining(
                    hasScrollBody: false,
                    child: AppEmptyState(
                      icon: Icons.inventory_2_outlined,
                      title: 'No products found',
                      subtitle: 'Try another search or category.',
                    ),
                  );
                }

                return SliverPadding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.sm,
                    0,
                    AppSpacing.sm,
                    AppSpacing.xxl,
                  ),
                  sliver: SliverGrid(
                    gridDelegate: productGridDelegateFor(context),
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final product = products[index];

                      return ProductCard(
                        product: product,
                        isFavorite: _favoriteIds.contains(product.id),
                        isAddingToCart: _addingToCartIds.contains(product.id),
                        onTap: () => _openProduct(product),
                        onToggleFavorite: () => _toggleFavorite(product.id),
                        onAddToCart: () => _addToCart(product),
                      );
                    }, childCount: products.length),
                  ),
                );
              },
            ),

            if (_isLoadingMore)
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.only(bottom: AppSpacing.xxl),
                  child: Center(child: CircularProgressIndicator()),
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _formatCategory(String value) {
    if (value.isEmpty) {
      return value;
    }

    return value
        .split('-')
        .map(
          (word) => word.isEmpty
              ? word
              : '${word[0].toUpperCase()}${word.substring(1)}',
        )
        .join(' ');
  }
}

/// Başlıktaki yuvarlak aksiyon düğmelerinin ölçüsü.
const double _actionButtonSize = 44;

/// Ekran başlığı ve sağdaki profil / sepet aksiyonları.
class _HomeHeader extends StatelessWidget {
  final int cartItemCount;
  final VoidCallback onCartTap;
  final VoidCallback onProfileTap;

  const _HomeHeader({
    required this.cartItemCount,
    required this.onCartTap,
    required this.onProfileTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.sm,
        AppSpacing.lg,
        0,
      ),

      // Başlık ve yuvarlak butonlar aynı satırda, dikeyde ortalı.
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Text(
              'Products',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.screenTitle.copyWith(color: Colors.white),
            ),
          ),

          const SizedBox(width: AppSpacing.md),

          _ProfileAvatar(onTap: onProfileTap),

          const SizedBox(width: AppSpacing.sm + 2),

          _CartButton(itemCount: cartItemCount, onTap: onCartTap),
        ],
      ),
    );
  }
}

/// Baş harfi gösteren sade avatar.
class _ProfileAvatar extends StatelessWidget {
  final VoidCallback onTap;

  const _ProfileAvatar({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return AppPressable(
      onTap: onTap,
      pressedScale: 0.94,
      child: Container(
        width: _actionButtonSize,
        height: _actionButtonSize,
        decoration: BoxDecoration(
          color: AppColors.surface,
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.border),
        ),
        child: const Icon(
          Icons.person_outline_rounded,
          size: 21,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }
}

/// Rozetli sepet düğmesi.
class _CartButton extends StatelessWidget {
  final int itemCount;
  final VoidCallback onTap;

  const _CartButton({required this.itemCount, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return AppPressable(
      onTap: onTap,
      pressedScale: 0.94,
      child: SizedBox(
        width: _actionButtonSize,
        height: _actionButtonSize,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: _actionButtonSize,
              height: _actionButtonSize,
              decoration: BoxDecoration(
                color: AppColors.surface,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.border),
              ),
              child: const Icon(
                Icons.shopping_bag_outlined,
                size: 20,
                color: AppColors.textPrimary,
              ),
            ),

            if (itemCount > 0)
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
                    itemCount > 99 ? '99+' : '$itemCount',
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
    );
  }
}

/// Arama alanının içindeki filtre düğmesi.
class _FilterButton extends StatelessWidget {
  final VoidCallback onTap;

  const _FilterButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return AppPressable(
      onTap: onTap,
      pressedScale: 0.92,
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: AppColors.primarySoft,
          borderRadius: BorderRadius.circular(AppRadius.sm),
        ),
        child: const Icon(
          Icons.tune_rounded,
          size: 20,
          color: AppColors.primary,
        ),
      ),
    );
  }
}

/// Aranabilir ve çoklu seçim yapılabilen kategori alt sayfası.
class _CategorySheet extends StatefulWidget {
  final List<String> categories;
  final Set<String> selectedCategories;
  final String Function(String) formatCategory;
  final ValueChanged<Set<String>> onSelectionChanged;

  const _CategorySheet({
    required this.categories,
    required this.selectedCategories,
    required this.formatCategory,
    required this.onSelectionChanged,
  });

  @override
  State<_CategorySheet> createState() => _CategorySheetState();
}

class _CategorySheetState extends State<_CategorySheet> {
  final TextEditingController _searchController = TextEditingController();
  late final Set<String> _selectedCategories;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _selectedCategories = Set<String>.from(widget.selectedCategories);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _toggleCategory(String category) {
    setState(() {
      if (category == 'all') {
        _selectedCategories.clear();
      } else if (!_selectedCategories.remove(category)) {
        _selectedCategories.add(category);
      }
    });

    widget.onSelectionChanged(Set<String>.from(_selectedCategories));
  }

  @override
  Widget build(BuildContext context) {
    final cleanQuery = _query.trim().toLowerCase();
    final visibleCategories = widget.categories.where((category) {
      return widget
          .formatCategory(category)
          .toLowerCase()
          .startsWith(cleanQuery);
    }).toList();

    return SafeArea(
      top: false,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * 0.7,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.xl,
                0,
                AppSpacing.xl,
                AppSpacing.md,
              ),
              child: Row(
                children: [
                  const Expanded(
                    child: Text(
                      'All categories',
                      style: AppTextStyles.sectionTitle,
                    ),
                  ),
                  IconButton(
                    tooltip: 'Close',
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.xl,
                0,
                AppSpacing.xl,
                AppSpacing.md,
              ),
              child: AppSearchField(
                controller: _searchController,
                hintText: 'Search categories',
                onChanged: (value) {
                  setState(() {
                    _query = value;
                  });
                },
                onClear: () {
                  _searchController.clear();
                  setState(() {
                    _query = '';
                  });
                },
              ),
            ),

            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.xl,
                  0,
                  AppSpacing.xl,
                  AppSpacing.xxl,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _CategorySheetChip(
                      label: 'All',
                      icon: Icons.auto_awesome_rounded,
                      selected: true,
                      onTap: () => _toggleCategory('all'),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    if (visibleCategories.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: AppSpacing.xl),
                        child: Text(
                          'No categories found.',
                          style: AppTextStyles.metadata,
                        ),
                      )
                    else
                      Wrap(
                        spacing: AppSpacing.sm,
                        runSpacing: AppSpacing.sm,
                        children: [
                          for (final category in visibleCategories)
                            _CategorySheetChip(
                              label: widget.formatCategory(category),
                              icon: CategoryVisual.of(category).icon,
                              selected: _selectedCategories.contains(category),
                              onTap: () => _toggleCategory(category),
                            ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategorySheetChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _CategorySheetChip({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AppPressable(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm + 2,
        ),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.sm),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.border,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: selected ? Colors.white : AppColors.textSecondary,
            ),

            const SizedBox(width: AppSpacing.sm - 2),

            Text(
              label,
              style: TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w600,
                color: selected ? Colors.white : AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
