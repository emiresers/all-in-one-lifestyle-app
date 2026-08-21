import 'package:flutter/material.dart';

import 'core/theme/app_theme.dart';
import 'screens/splash/splash_screen.dart';
import 'widgets/app_gradient_background.dart';

void main() {
  runApp(const DummyProjectApp());
}

class DummyProjectApp extends StatelessWidget {
  const DummyProjectApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'DummyProject',
      theme: AppTheme.light,
      builder: (context, child) {
        return AppGradientBackground(child: child ?? const SizedBox.shrink());
      },
      home: const SplashScreen(),
    );
  }
}
