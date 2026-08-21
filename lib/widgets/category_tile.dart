import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';

/// Kategori slug'ını görsel bir kimliğe (ikon + yumuşak zemin + ikon rengi)
/// eşler.
///
/// DummyJSON kategori görseli döndürmediği için her kategori anlamına uygun
/// bir ikonla temsil ediliyor. Renk yalnızca ikonun arkasındaki küçük yüzeyde
/// kullanılır; kartın tamamı hiçbir zaman boyanmaz.
class CategoryVisual {
  /// Kategoriyi temsil eden ikon.
  final IconData icon;

  /// İkonun arkasındaki küçük yüzey.
  final Color tint;

  /// İkonun kendisi.
  final Color iconColor;

  const CategoryVisual(this.icon, this.tint, this.iconColor);

  /// Ürün görselinin arkasındaki yüzey.
  ///
  /// Temel ton her üründe [AppColors.imageSurface]; kategori rengi yalnızca
  /// çok düşük oranda karışır, böylece grid tek bir sıcak zemin gibi okunur.
  Color get imageTint => Color.lerp(AppColors.imageSurface, tint, 0.16)!;

  // --- TON AİLESİ ---
  //
  // Uygulamanın yumuşak vurgu paleti. Kategori ikonları ve gönderi
  // avatarları aynı aileden beslenir; renkler tek yerde tanımlıdır.

  /// Vurgu ailesi: indigo.
  static const Color indigoSurface = Color(0xFFEEEEFF);
  static const Color indigoInk = Color(0xFF5B5CE2);

  /// Vurgu ailesi: gül.
  static const Color roseSurface = Color(0xFFFCEEF3);
  static const Color roseInk = Color(0xFFC94B76);

  /// Vurgu ailesi: menekşe.
  static const Color violetSurface = Color(0xFFF2EDFF);
  static const Color violetInk = Color(0xFF7656C9);

  /// Vurgu ailesi: kiremit.
  static const Color claySurface = Color(0xFFFFF1E6);
  static const Color clayInk = Color(0xFFB96532);

  /// Vurgu ailesi: yeşil.
  static const Color greenSurface = Color(0xFFEAF7F1);
  static const Color greenInk = Color(0xFF27866B);

  /// Vurgu ailesi: kehribar.
  static const Color amberSurface = Color(0xFFFFF4E5);
  static const Color amberInk = Color(0xFFB7791F);

  /// Avatar gibi kimliği olmayan yerlerde sırayla kullanılan yüzeyler.
  static const List<Color> accentSurfaces = [
    indigoSurface,
    violetSurface,
    greenSurface,
    claySurface,
    roseSurface,
  ];

  /// [accentSurfaces] ile aynı sıradaki ikon renkleri.
  static const List<Color> accentInks = [
    indigoInk,
    violetInk,
    greenInk,
    clayInk,
    roseInk,
  ];

  /// Kategorisiz durumlar ("All") için indigo vurgusu.
  static const CategoryVisual all = CategoryVisual(
    Icons.auto_awesome_rounded,
    indigoSurface,
    indigoInk,
  );

  static const Map<String, CategoryVisual> _map = {
    'beauty': CategoryVisual(Icons.brush_rounded, roseSurface, roseInk),
    'skin-care': CategoryVisual(Icons.spa_rounded, greenSurface, greenInk),
    'fragrances': CategoryVisual(
      Icons.local_florist_rounded,
      violetSurface,
      violetInk,
    ),
    'furniture': CategoryVisual(Icons.chair_rounded, claySurface, clayInk),
    'groceries': CategoryVisual(
      Icons.local_grocery_store_rounded,
      greenSurface,
      greenInk,
    ),
    'home-decoration': CategoryVisual(
      Icons.home_rounded,
      amberSurface,
      amberInk,
    ),
    'kitchen-accessories': CategoryVisual(
      Icons.kitchen_rounded,
      amberSurface,
      amberInk,
    ),
    'laptops': CategoryVisual(
      Icons.laptop_mac_rounded,
      indigoSurface,
      indigoInk,
    ),
    'mens-shirts': CategoryVisual(
      Icons.checkroom_rounded,
      violetSurface,
      violetInk,
    ),
    'mens-shoes': CategoryVisual(Icons.hiking_rounded, claySurface, clayInk),
    'mens-watches': CategoryVisual(Icons.watch_rounded, greenSurface, greenInk),
    'mobile-accessories': CategoryVisual(
      Icons.headphones_rounded,
      indigoSurface,
      indigoInk,
    ),
    'motorcycle': CategoryVisual(
      Icons.two_wheeler_rounded,
      amberSurface,
      amberInk,
    ),
    'smartphones': CategoryVisual(
      Icons.smartphone_rounded,
      indigoSurface,
      indigoInk,
    ),
    'sports-accessories': CategoryVisual(
      Icons.sports_basketball_rounded,
      claySurface,
      clayInk,
    ),
    'sunglasses': CategoryVisual(Icons.sunny, amberSurface, amberInk),
    'tablets': CategoryVisual(
      Icons.tablet_mac_rounded,
      indigoSurface,
      indigoInk,
    ),
    'tops': CategoryVisual(Icons.checkroom_rounded, roseSurface, roseInk),
    'vehicle': CategoryVisual(
      Icons.directions_car_rounded,
      indigoSurface,
      indigoInk,
    ),
    'womens-bags': CategoryVisual(
      Icons.shopping_bag_rounded,
      claySurface,
      clayInk,
    ),
    'womens-dresses': CategoryVisual(
      Icons.checkroom_rounded,
      violetSurface,
      violetInk,
    ),
    'womens-jewellery': CategoryVisual(
      Icons.diamond_rounded,
      violetSurface,
      violetInk,
    ),
    'womens-shoes': CategoryVisual(Icons.woman_rounded, claySurface, clayInk),
    'womens-watches': CategoryVisual(
      Icons.watch_rounded,
      amberSurface,
      amberInk,
    ),
  };

  static CategoryVisual of(String slug) {
    return _map[slug] ??
        const CategoryVisual(Icons.category_rounded, indigoSurface, indigoInk);
  }
}
