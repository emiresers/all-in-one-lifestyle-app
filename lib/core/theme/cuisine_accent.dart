import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Tarif görselinin arkasındaki yüzeye, mutfağa göre çok hafif bir ton verir.
///
/// Renkler bilinçli olarak neredeyse beyaz: görselin kendisinden baskın
/// olmamalı, yalnızca kartın içinde görselin durduğu alanı ayırmalı.
class CuisineAccent {
  /// Görsel alanının zemini.
  final Color surface;

  /// Zeminin bir tık koyu hâli; saç teli kalınlığında kenarlık için.
  final Color border;

  const CuisineAccent({required this.surface, required this.border});

  /// Eşleşme bulunmayan mutfaklar için uygulamanın nötr mavisi.
  static const CuisineAccent neutral = CuisineAccent(
    surface: AppColors.surfaceSecondary,
    border: AppColors.border,
  );

  // Sıcak şeftali — İtalyan, pizza.
  static const CuisineAccent _peach = CuisineAccent(
    surface: Color(0xFFFCF1E9),
    border: Color(0xFFF2E1D4),
  );

  // Yumuşak yeşil — vejetaryen, akdeniz.
  static const CuisineAccent _green = CuisineAccent(
    surface: Color(0xFFEEF6F0),
    border: Color(0xFFDCEADF),
  );

  // Krem / kehribar — tatlı, fırın.
  static const CuisineAccent _cream = CuisineAccent(
    surface: Color(0xFFFCF5E6),
    border: Color(0xFFF1E6CF),
  );

  // Sıcak bej — makarna, hamur işi.
  static const CuisineAccent _beige = CuisineAccent(
    surface: Color(0xFFF8F3EB),
    border: Color(0xFFEBE1D3),
  );

  // Açık camgöbeği — deniz ürünleri.
  static const CuisineAccent _cyan = CuisineAccent(
    surface: Color(0xFFEBF4F7),
    border: Color(0xFFD8E8EE),
  );

  // Yumuşak lavanta — uzakdoğu.
  static const CuisineAccent _lavender = CuisineAccent(
    surface: Color(0xFFF1F0FA),
    border: Color(0xFFE1DFF2),
  );

  // Çok açık kiremit — baharatlı mutfaklar.
  static const CuisineAccent _terracotta = CuisineAccent(
    surface: Color(0xFFFBEFEC),
    border: Color(0xFFF0DCD7),
  );

  static const Map<String, CuisineAccent> _byCuisine = {
    'italian': _peach,
    'greek': _cyan,
    'mediterranean': _green,
    'turkish': _terracotta,
    'lebanese': _green,
    'moroccan': _terracotta,
    'mexican': _terracotta,
    'brazilian': _peach,
    'american': _cream,
    'asian': _lavender,
    'chinese': _lavender,
    'japanese': _lavender,
    'korean': _lavender,
    'thai': _lavender,
    'vietnamese': _lavender,
    'indian': _terracotta,
    'pakistani': _terracotta,
    'russian': _beige,
    'spanish': _peach,
    'smoothie': _green,
  };

  /// Mutfak adına göre ton döndürür; eşleşme yoksa nötr maviye düşer.
  ///
  /// [hints] tarifin etiket/öğün bilgisi gibi ek ipuçlarıdır: "dessert" veya
  /// "vegetarian" gibi bir ipucu, mutfak eşleşmesinden önce gelir çünkü
  /// yemeğin karakterini daha iyi anlatır.
  static CuisineAccent of(String cuisine, {Iterable<String> hints = const []}) {
    for (final String hint in hints) {
      final CuisineAccent? match = _byHint[hint.trim().toLowerCase()];
      if (match != null) {
        return match;
      }
    }

    return _byCuisine[cuisine.trim().toLowerCase()] ?? neutral;
  }

  static const Map<String, CuisineAccent> _byHint = {
    'dessert': _cream,
    'desserts': _cream,
    'snack': _cream,
    'snacks': _cream,
    'vegetarian': _green,
    'vegan': _green,
    'salad': _green,
    'pasta': _beige,
    'pizza': _peach,
    'seafood': _cyan,
    'fish': _cyan,
    'baking': _cream,
  };
}
