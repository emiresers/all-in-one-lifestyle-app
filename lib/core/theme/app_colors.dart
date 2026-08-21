import 'package:flutter/material.dart';

/// Uygulamanın merkezi renk paleti: "Soft Indigo + Warm Neutral".
///
/// Zemin sıcak nötr, yüzeyler beyaz. Indigo yalnızca vurgu rengidir; büyük
/// yüzeylerde, başlıklarda ve kart kenarlıklarında kullanılmaz.
class AppColors {
  const AppColors._();

  // --- YÜZEY HİYERARŞİSİ ---

  /// Ekran arka planı: sıcak kırık beyaz.
  static const Color background = Color(0xFFF8F7F4);

  /// Ambient'in en tepesindeki çok açık indigo.
  static const Color backgroundTop = Color(0xFFEEEEFF);

  /// Ambient'in ara tonu; üstteki indigo ile zemin arasını bağlar.
  static const Color backgroundMid = Color(0xFFF3F1F8);

  /// Ekranın üstündeki yumuşak aydınlanma.
  ///
  /// %42'de nötr [background] tonuna kavuşur: gradient yalnızca başlık ve
  /// arama alanının arkasında hissedilir, ekranın tamamını kaplamaz.
  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [backgroundTop, backgroundMid, background],
    stops: [0, 0.16, 0.42],
  );

  /// Kart ve panel yüzeyi.
  static const Color surface = Color(0xFFFFFFFF);

  /// İkon kutuları, rozetler gibi ikincil yüzeyler.
  static const Color surfaceSecondary = Color(0xFFF4F2EF);

  /// Ürün görsellerinin arkasındaki sıcak nötr yüzey.
  ///
  /// Kartın beyazından belirgin biçimde ayrılır; görselin kenarları böyle
  /// daha net okunur.
  static const Color imageSurface = Color(0xFFF6F3EE);

  /// Standart kenarlık.
  static const Color border = Color(0xFFE7E5E4);

  /// Kenarlığın taşıyıcı olmadığı yerlerde daha da ince ayrım.
  static const Color borderSoft = Color(0xFFF0EEEB);

  /// Kart içindeki form alanlarının dolgusu.
  static const Color fieldFill = Color(0xFFF6F4F1);

  // --- MARKA RENGİ (yalnızca vurgu) ---

  static const Color primary = Color(0xFF5B5CE2);

  /// Basılı / aktif durumun koyu ucu.
  static const Color primaryDark = Color(0xFF4647C7);

  /// Aktif durumların çok açık zemini (kapsül, seçili kategori, filtre).
  static const Color primarySoft = Color(0xFFEEEEFF);

  /// Seçili durumlarda kullanılan ince indigo kenarlık.
  static const Color primaryBorder = Color(0xFFC9C9F2);

  /// Gradient başlangıcındaki açık indigo.
  static const Color primaryLight = Color(0xFF7B7CEA);

  // --- METİN ---

  static const Color textPrimary = Color(0xFF18181B);

  /// Puan gibi sayısal vurgular: birincil metinden bir tık yumuşak.
  static const Color textStrong = Color(0xFF3F3F46);

  static const Color textSecondary = Color(0xFF71717A);

  /// Metadata, pasif ikon ve placeholder.
  static const Color textTertiary = Color(0xFFA1A1AA);

  // --- SEMANTİK RENKLER (yalnızca anlamlı durumlarda) ---

  static const Color success = Color(0xFF16A37A);
  static const Color successSoft = Color(0xFFE6F6F0);

  static const Color danger = Color(0xFFE5484D);
  static const Color dangerSoft = Color(0xFFFCECEC);

  /// Yalnızca puan göstergeleri.
  static const Color amber = Color(0xFFF59E0B);

  /// [amber] için okunabilir alias.
  static const Color rating = amber;
  static const Color amberSoft = Color(0xFFFEF3C7);

  // --- FAVORİ ---

  static const Color favorite = Color(0xFFE85D75);
  static const Color favoriteSoft = Color(0xFFFCEEF3);
  static const Color favoriteBorder = Color(0xFFF8C7D5);

  // --- GÖLGELER ---
  //
  // Renkli gölge yok: hepsi siyahın çok düşük opaklığı. Ayrışmayı ağırlıklı
  // olarak kenarlık taşır.

  /// Kartlarda kullanılan çok hafif gölge.
  static List<BoxShadow> get softShadow => [
    BoxShadow(
      color: const Color(0xFF18181B).withValues(alpha: 0.05),
      blurRadius: 18,
      offset: const Offset(0, 6),
    ),
  ];

  /// Kenarlığın taşıyıcı olduğu, neredeyse gölgesiz yüzeyler için.
  static List<BoxShadow> get subtleShadow => [
    BoxShadow(
      color: const Color(0xFF18181B).withValues(alpha: 0.03),
      blurRadius: 10,
      offset: const Offset(0, 2),
    ),
  ];

  /// Yüzen alanlar (özet kartı gibi) için biraz daha belirgin gölge.
  static List<BoxShadow> get floatingShadow => [
    BoxShadow(
      color: const Color(0xFF18181B).withValues(alpha: 0.06),
      blurRadius: 24,
      offset: const Offset(0, 10),
    ),
  ];
}
