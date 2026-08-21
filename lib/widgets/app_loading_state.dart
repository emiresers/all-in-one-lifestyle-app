import 'package:flutter/material.dart';

/// Tüm ekranlarda aynı görünen sade yükleniyor göstergesi.
class AppLoadingState extends StatelessWidget {
  const AppLoadingState({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: SizedBox(
        width: 30,
        height: 30,
        child: CircularProgressIndicator(strokeWidth: 2.6),
      ),
    );
  }
}
