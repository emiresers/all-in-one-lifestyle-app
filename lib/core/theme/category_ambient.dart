import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Products ekranının üst bölgesine, seçili kategoriye göre çok hafif bir
/// atmosfer rengi verir.
///
/// Renk yalnızca başlık bölgesinde hissedilir; %42'de nötr
/// [AppColors.background] tonunda biter. Böylece ürün grid'i her kategoride
/// aynı nötr zeminde kalır ve mavi ekranın tamamını kaplamaz.
///
/// Tüm gradient'ler aynı sayıda renk ve aynı stop değerlerini kullanır; bu,
/// [AnimatedContainer]'ın iki kategori arasında pürüzsüz lerp yapabilmesi için
/// gereklidir.
class CategoryAmbient {
  /// Ekranın en üstündeki ton.
  final Color top;

  /// Geçişin ortasındaki ara ton.
  final Color mid;

  const CategoryAmbient({required this.top, required this.mid});

  LinearGradient get gradient => LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [top, mid, AppColors.background],
    stops: const [0, 0.16, 0.42],
  );

  /// Varsayılan / "all" durumu: uygulamanın genel serin mavi atmosferi.
  static const CategoryAmbient neutral = CategoryAmbient(
    top: AppColors.backgroundTop,
    mid: AppColors.backgroundMid,
  );

  // Kategori tonları zeminin sıcak nötrüyle harmanlanmış hâlleriyle
  // tanımlanır: hiçbiri uygulamanın sakin kimliğinden kopmaz ve hepsi %42'de
  // aynı [AppColors.background] tonunda biter.

  /// Gül.
  static const CategoryAmbient _rose = CategoryAmbient(
    top: Color(0xFFF8ECF2),
    mid: Color(0xFFF6F1F4),
  );

  /// Menekşe.
  static const CategoryAmbient _violet = CategoryAmbient(
    top: Color(0xFFF1ECFD),
    mid: Color(0xFFF4F1F8),
  );

  /// Kiremit / sıcak bej.
  static const CategoryAmbient _clay = CategoryAmbient(
    top: Color(0xFFF9EFE6),
    mid: Color(0xFFF7F3EE),
  );

  /// Yeşil.
  static const CategoryAmbient _green = CategoryAmbient(
    top: Color(0xFFEAF5EF),
    mid: Color(0xFFF1F4F1),
  );

  /// Kehribar.
  static const CategoryAmbient _amber = CategoryAmbient(
    top: Color(0xFFFBF2E4),
    mid: Color(0xFFF8F4EC),
  );

  /// İndigo: teknoloji kategorileri.
  static const CategoryAmbient _indigo = CategoryAmbient(
    top: Color(0xFFECEDFA),
    mid: Color(0xFFF3F2F7),
  );

  /// DummyJSON kategori slug'larına göre atmosfer eşlemesi.
  static const Map<String, CategoryAmbient> _map = {
    'beauty': _rose,
    'skin-care': _green,
    'womens-dresses': _violet,
    'tops': _rose,

    'fragrances': _violet,
    'womens-jewellery': _violet,
    'mens-shirts': _violet,

    'furniture': _clay,
    'mens-shoes': _clay,
    'womens-bags': _clay,
    'womens-shoes': _clay,
    'sports-accessories': _clay,

    'groceries': _green,
    'mens-watches': _green,

    'home-decoration': _amber,
    'kitchen-accessories': _amber,
    'sunglasses': _amber,
    'womens-watches': _amber,
    'motorcycle': _amber,

    'laptops': _indigo,
    'smartphones': _indigo,
    'tablets': _indigo,
    'mobile-accessories': _indigo,
    'vehicle': _indigo,
  };

  /// Kategori için atmosferi döndürür; eşleşme yoksa nötr maviye düşer.
  static CategoryAmbient of(String category) {
    return _map[category] ?? neutral;
  }
}
