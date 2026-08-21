import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Her ana ekranın üst bölgesine kendi çok hafif atmosfer rengini verir.
///
/// Amaç, ekranlar arasında gezinirken "aynı sayfadayım" hissini kırmak.
/// Renk yalnızca başlık bölgesinde sezilir; %42'de nötr
/// [AppColors.background] tonunda biter, yani içerik her ekranda aynı zemin
/// üzerinde okunur.
enum ScreenAmbient {
  /// Menekşe.
  posts(Color(0xFFF1ECFD), Color(0xFFF4F1F8)),

  /// Sakin turkuaz.
  users(Color(0xFFE9F3F1), Color(0xFFF1F4F2)),

  /// Yeşil.
  todos(Color(0xFFEAF5EF), Color(0xFFF1F4F1)),

  /// İndigo.
  more(Color(0xFFEEEEFF), Color(0xFFF3F1F8));

  const ScreenAmbient(this.top, this.mid);

  final Color top;
  final Color mid;

  LinearGradient get gradient => LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [top, mid, AppColors.background],
    stops: const [0, 0.16, 0.42],
  );
}

/// Ekranın gövdesini kendi atmosferine sarar.
class ScreenAmbientBackground extends StatelessWidget {
  final ScreenAmbient ambient;
  final Widget child;

  const ScreenAmbientBackground({
    super.key,
    required this.ambient,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(gradient: ambient.gradient),
      child: child,
    );
  }
}
