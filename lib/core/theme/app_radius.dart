/// Uygulamanın köşe yarıçapı ölçeği.
class AppRadius {
  const AppRadius._();

  // --- ÖLÇEK ---
  static const double sm = 12;
  static const double md = 16;
  static const double lg = 20;
  static const double xl = 24;

  // --- SEMANTİK KULLANIMLAR ---

  /// Standart kart.
  static const double card = lg;

  /// Öne çıkan / büyük kart.
  static const double largeCard = lg;

  /// Form alanları ve arama kutusu.
  static const double field = md;

  /// Birincil ve ikincil butonlar.
  static const double button = md;

  /// Filtre chip'leri.
  static const double chip = md;

  /// Rozet, ikon kutusu gibi küçük yüzeyler.
  static const double badge = sm;

  static const double dialog = xl;
}
