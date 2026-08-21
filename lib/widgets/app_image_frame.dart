import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';

/// Görselin içinde durduğu, karttan hafifçe ayrışan yüzey.
///
/// Görsel doğrudan beyaz kartın üzerine oturmak yerine, çok hafif tonlu bir
/// zemine ve saç teli kalınlığında bir kenarlığa alınır. Böylece fotoğrafın
/// kenarları — arka planı beyaz olan ürün görsellerinde bile — belirgin olur.
///
/// Gölge kullanılmaz: ayrışmayı ton ve kenarlık taşır.
class AppImageFrame extends StatelessWidget {
  final String imageUrl;

  /// Dış köşe yarıçapı.
  final double radius;

  /// Görsel ile çerçeve arasındaki kontrollü boşluk.
  final double inset;

  /// Çerçevenin zemini.
  final Color surface;

  /// Çerçevenin kenarlığı.
  final Color border;

  final BoxFit fit;

  /// Hero geçişi için etiket; verilmezse Hero sarmalanmaz.
  final Object? heroTag;

  /// Decode boyutunu sınırlayarak büyük görsellerin bellekte şişmesini önler.
  final int? cacheWidth;

  const AppImageFrame({
    super.key,
    required this.imageUrl,
    this.radius = 18,
    this.inset = 6,
    this.surface = AppColors.surfaceSecondary,
    this.border = AppColors.border,
    this.fit = BoxFit.cover,
    this.heroTag,
    this.cacheWidth,
  });

  @override
  Widget build(BuildContext context) {
    final double innerRadius = (radius - inset).clamp(0, radius);

    Widget image = Image.network(
      imageUrl,
      fit: fit,
      cacheWidth: cacheWidth,
      // Yeniden çözümlenirken kartın boşalmasını engeller.
      gaplessPlayback: true,
      frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
        if (wasSynchronouslyLoaded) {
          return child;
        }

        // Görsel hazır olduğunda belirerek gelir; ani "zıplama" olmaz.
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
            size: 28,
            color: AppColors.textTertiary,
          ),
        );
      },
    );

    image = ClipRRect(
      borderRadius: BorderRadius.circular(innerRadius),
      child: SizedBox.expand(child: image),
    );

    if (heroTag != null) {
      image = Hero(tag: heroTag!, child: image);
    }

    return DecoratedBox(
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: border),
      ),
      child: Padding(padding: EdgeInsets.all(inset), child: image),
    );
  }
}
