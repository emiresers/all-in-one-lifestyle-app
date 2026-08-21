import 'package:flutter/material.dart';

import '../widgets/app_gradient_background.dart';

/// Uygulamanın özel sayfa geçişleri.
///
/// Ekranların Scaffold'ları saydam olduğu için (arka plan geçişi
/// [AppGradientBackground] ile tek yerden veriliyor) sayfalar rotaya
/// doğrudan konulduğunda geçiş sırasında alttaki sayfa yenisinin içinden
/// görünür ve ekran "donmuş / iç içe geçmiş" gibi görünür.
///
/// Bu yüzden her sayfa rotaya konmadan önce burada kendi opak arka planına
/// sarılır; böylece geçiş boyunca yalnızca tek bir ekran görünür.
class AppPageRoute {
  const AppPageRoute._();

  /// Sayfayı kendi opak arka planına sarar.
  static Widget _opaque(Widget page) => AppGradientBackground(child: page);

  /// Standart ileri geçiş.
  ///
  /// Platformun kendi sayfa geçişini (iOS'ta kenardan geri kaydırma dâhil)
  /// korur, tek farkı sayfanın opak olması.
  static Route<T> to<T>(Widget page) {
    return MaterialPageRoute<T>(builder: (context) => _opaque(page));
  }

  /// Sepet gibi öne çıkan hedefler için yakınlaşarak açılan geçiş.
  ///
  /// Yeni sayfa hafifçe büyüyerek ve belirginleşerek gelir; geri dönerken
  /// aynı hareketi tersine oynatır. Material'ın "fade through" desenine yakın,
  /// ekstra paket gerektirmez.
  static Route<T> zoomFade<T>(Widget page) {
    return PageRouteBuilder<T>(
      transitionDuration: const Duration(milliseconds: 420),
      reverseTransitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, animation, secondaryAnimation) => _opaque(page),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final Animation<double> curved = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
          reverseCurve: Curves.easeInCubic,
        );

        // Çıkan sayfa hafifçe geri çekilir; böylece derinlik hissi oluşur.
        final Animation<double> outgoing = CurvedAnimation(
          parent: secondaryAnimation,
          curve: Curves.easeOutCubic,
          reverseCurve: Curves.easeInCubic,
        );

        return FadeTransition(
          opacity: curved,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.9, end: 1).animate(curved),
            child: ScaleTransition(
              scale: Tween<double>(begin: 1, end: 0.96).animate(outgoing),
              child: child,
            ),
          ),
        );
      },
    );
  }
}
