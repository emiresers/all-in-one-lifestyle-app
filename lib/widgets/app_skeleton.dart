import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_spacing.dart';
import 'product_card.dart';

/// İskelet parçalarını hep birlikte, tek bir controller ile nefes aldırır.
///
/// Her kutu kendi animasyonunu çalıştırsaydı listedeki onlarca parça ayrı ayrı
/// tick alırdı; burada tek [AnimationController] var ve [FadeTransition] yalnız
/// opaklık katmanını yeniden çiziyor, alt ağaç yeniden build edilmiyor.
class AppSkeleton extends StatefulWidget {
  final Widget child;

  const AppSkeleton({super.key, required this.child});

  @override
  State<AppSkeleton> createState() => _AppSkeletonState();
}

class _AppSkeletonState extends State<AppSkeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..repeat(reverse: true);

  late final Animation<double> _opacity = Tween<double>(
    begin: 0.55,
    end: 1,
  ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(opacity: _opacity, child: widget.child);
  }
}

/// İskelet içindeki tek bir dolgu bloğu.
class AppSkeletonBox extends StatelessWidget {
  final double? width;
  final double height;
  final double radius;

  const AppSkeletonBox({
    super.key,
    this.width,
    required this.height,
    this.radius = 8,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.surfaceSecondary,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}

/// Tarif listesinin yükleniyor hâli: gerçek kartlarla aynı ölçülerde.
class RecipeListSkeleton extends StatelessWidget {
  final int itemCount;

  const RecipeListSkeleton({super.key, this.itemCount = 5});

  @override
  Widget build(BuildContext context) {
    return AppSkeleton(
      child: ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.screenH,
          4,
          AppSpacing.screenH,
          AppSpacing.section,
        ),
        itemCount: itemCount,
        itemBuilder: (context, index) => const _RecipeCardSkeleton(),
      ),
    );
  }
}

class _RecipeCardSkeleton extends StatelessWidget {
  const _RecipeCardSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.largeCard),
        border: Border.all(color: AppColors.borderSoft),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppSkeletonBox(width: 112, height: 112, radius: 18),

          SizedBox(width: AppSpacing.lg),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Başlık
                AppSkeletonBox(height: 15),
                SizedBox(height: 8),
                AppSkeletonBox(width: 120, height: 15),

                SizedBox(height: 12),

                // Mutfak
                AppSkeletonBox(width: 70, height: 12),

                SizedBox(height: 12),

                // Zorluk + puan rozetleri
                Row(
                  children: [
                    AppSkeletonBox(width: 74, height: 24, radius: 18),
                    SizedBox(width: 8),
                    AppSkeletonBox(width: 56, height: 24, radius: 18),
                  ],
                ),

                SizedBox(height: 12),

                // Süre
                AppSkeletonBox(width: 62, height: 12),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Ürün grid'inin yükleniyor hâli.
class ProductGridSkeleton extends StatelessWidget {
  final int itemCount;

  const ProductGridSkeleton({super.key, this.itemCount = 4});

  @override
  Widget build(BuildContext context) {
    return AppSkeleton(
      child: GridView.builder(
        // Sliver içinde yükseklik sınırsız gelir; kendi içeriğine göre ölçülür.
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.sm,
          0,
          AppSpacing.sm,
          AppSpacing.xxl,
        ),
        gridDelegate: productGridDelegateFor(context),
        itemCount: itemCount,
        itemBuilder: (context, index) => const _ProductCardSkeleton(),
      ),
    );
  }
}

class _ProductCardSkeleton extends StatelessWidget {
  const _ProductCardSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(ProductCardMetrics.padding),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.borderSoft),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: AppSkeletonBox(
              width: double.infinity,
              height: double.infinity,
              radius: AppRadius.md,
            ),
          ),

          SizedBox(height: ProductCardMetrics.imageToInfoGap),

          // Kategori
          AppSkeletonBox(width: 54, height: 11, radius: 6),
          SizedBox(height: AppSpacing.xs),

          // Başlık (iki satır)
          AppSkeletonBox(height: 13, radius: 6),
          SizedBox(height: 5),
          AppSkeletonBox(width: 90, height: 13, radius: 6),
          SizedBox(height: AppSpacing.sm),

          // Puan
          AppSkeletonBox(width: 62, height: 12, radius: 6),

          // Gerçek karttaki bilgi bloğuyla aynı yüksekliği tutturur; veri
          // gelince görsel alanı yer değiştirmez.
          SizedBox(height: AppSpacing.xxl),

          // Fiyat + sepet düğmesi
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              AppSkeletonBox(width: 74, height: 22, radius: 6),
              AppSkeletonBox(
                width: ProductCardMetrics.addButtonSize,
                height: ProductCardMetrics.addButtonSize,
                radius: AppRadius.sm + 1,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Liste ekranlarının (Posts, Users, Todos) ortak yükleniyor hâli.
///
/// Kart yüksekliği ekrana göre verilir; böylece gerçek kartlarla aynı ritmi
/// tutturur ve yükleme bitince liste zıplamaz.
class ListCardSkeleton extends StatelessWidget {
  final int itemCount;
  final double cardHeight;

  /// Solda avatar / ikon bloğu olup olmadığı.
  final bool hasLeading;

  const ListCardSkeleton({
    super.key,
    this.itemCount = 5,
    required this.cardHeight,
    this.hasLeading = true,
  });

  @override
  Widget build(BuildContext context) {
    return AppSkeleton(
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.xl,
          0,
          AppSpacing.xl,
          AppSpacing.xxl,
        ),
        itemCount: itemCount,
        separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.listGap),
        itemBuilder: (context, index) =>
            _ListCardSkeletonItem(height: cardHeight, hasLeading: hasLeading),
      ),
    );
  }
}

class _ListCardSkeletonItem extends StatelessWidget {
  final double height;
  final bool hasLeading;

  const _ListCardSkeletonItem({required this.height, required this.hasLeading});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.borderSoft),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (hasLeading) ...[
            const AppSkeletonBox(width: 40, height: 40, radius: 20),
            const SizedBox(width: AppSpacing.md),
          ],

          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppSkeletonBox(width: 110, height: 12, radius: 6),
                SizedBox(height: 10),
                AppSkeletonBox(height: 13, radius: 6),
                SizedBox(height: 7),
                AppSkeletonBox(width: 160, height: 13, radius: 6),
                Spacer(),
                AppSkeletonBox(width: 130, height: 11, radius: 6),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
