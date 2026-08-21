import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';

/// Uygulamanın tamamının arkasında duran yumuşak renk geçişi.
///
/// `MaterialApp.builder` içinden bir kez uygulanır; ekranların kendi
/// Scaffold'ları saydam olduğu için geçiş her sayfada görünür.
class AppGradientBackground extends StatelessWidget {
  final Widget child;

  const AppGradientBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
      child: child,
    );
  }
}
