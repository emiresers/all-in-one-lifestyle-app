import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Uygulamanın tipografi ölçeği.
///
/// Hiyerarşi ağırlık + boyut + renk ile kurulur; her şeyi bold yapmak yerine
/// yalnızca gerçekten öne çıkması gereken metinler w700/w800 kullanır.
class AppTextStyles {
  const AppTextStyles._();

  /// Ekranların büyük ana başlığı (Products, Todos, Quotes...).
  static const TextStyle screenTitle = TextStyle(
    fontSize: 30,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.7,
    height: 1.1,
    color: AppColors.textPrimary,
  );

  /// Ekran başlığının altındaki açıklama satırı.
  static const TextStyle screenSubtitle = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w500,
    height: 1.4,
    color: AppColors.textSecondary,
  );

  /// Alt ekranların (detay, form) kompakt AppBar başlığı.
  static const TextStyle appBarTitle = TextStyle(
    fontSize: 17,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.2,
    color: AppColors.textPrimary,
  );

  /// Bölüm başlığı.
  static const TextStyle sectionTitle = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.4,
    color: AppColors.textPrimary,
  );

  /// Kart içi başlık.
  static const TextStyle cardTitle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.2,
    height: 1.3,
    color: AppColors.textPrimary,
  );

  /// Küçük kart / liste satırı başlığı.
  static const TextStyle cardTitleSmall = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.1,
    height: 1.3,
    color: AppColors.textPrimary,
  );

  /// Ana gövde metni.
  static const TextStyle body = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w400,
    height: 1.55,
    color: AppColors.textPrimary,
  );

  /// İkincil gövde metni (açıklama, alt satır).
  static const TextStyle bodySecondary = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.5,
    color: AppColors.textSecondary,
  );

  /// Metadata: tarih, ID, sayaç gibi yardımcı bilgiler.
  static const TextStyle metadata = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
  );

  /// Rozet / chip metni.
  static const TextStyle badge = TextStyle(
    fontSize: 11.5,
    fontWeight: FontWeight.w600,
    color: AppColors.textSecondary,
  );

  /// Fiyat gibi güçlü sayısal vurgular.
  static const TextStyle price = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.4,
    color: AppColors.textPrimary,
  );

  /// Detay ekranlarındaki büyük fiyat vurgusu.
  static const TextStyle priceLarge = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.6,
    color: AppColors.textPrimary,
  );

  /// Form alanı etiketi.
  static const TextStyle fieldLabel = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.1,
    color: AppColors.textSecondary,
  );

  /// Buton metni.
  static const TextStyle button = TextStyle(
    fontSize: 15.5,
    fontWeight: FontWeight.w600,
  );
}
