import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_spacing.dart';

/// Tüm ekranlarda kullanılan ortak hata görünümü.
class AppErrorState extends StatelessWidget {
  final String message;
  final String title;
  final IconData icon;
  final VoidCallback? onRetry;

  const AppErrorState({
    super.key,
    required this.message,
    this.title = 'Something went wrong',
    this.icon = Icons.error_outline_rounded,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 66,
              height: 66,
              decoration: BoxDecoration(
                color: AppColors.surfaceSecondary,
                borderRadius: BorderRadius.circular(AppRadius.card),
              ),
              child: Icon(icon, size: 30, color: AppColors.textSecondary),
            ),

            const SizedBox(height: AppSpacing.lg),

            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.3,
              ),
            ),

            const SizedBox(height: AppSpacing.xs),

            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13.5,
                height: 1.45,
                color: AppColors.textSecondary,
              ),
            ),

            if (onRetry != null) ...[
              const SizedBox(height: AppSpacing.xl),

              FilledButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_rounded, size: 19),
                label: const Text('Try Again'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
