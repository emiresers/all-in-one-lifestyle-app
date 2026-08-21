export 'app_radius.dart';

/// Uygulamanın boşluk ölçeği.
class AppSpacing {
  const AppSpacing._();

  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 24;
  static const double xxxl = 32;

  /// Bölümler arası büyük boşluk.
  static const double section = 28;

  /// Ekranların yatay ana padding değeri.
  static const double screenH = 20;

  /// Liste elemanları arası boşluk.
  static const double listGap = 12;

  /// Kart iç padding değeri.
  static const double cardPadding = 16;
}

/// Tekrarlanan yükseklik değerleri.
class AppSizes {
  const AppSizes._();

  static const double primaryButtonHeight = 56;
  static const double fieldHeight = 54;

  /// Arama alanı: form alanlarından bir tık daha ferah.
  static const double searchHeight = 56;
  static const double iconBox = 48;
  static const double smallIconBox = 40;
  static const double stepperButton = 36;
  static const double navBarHeight = 62;
}
