import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_spacing.dart';
import 'app_card.dart';

/// Add / Edit ekranlarında kullanılan bölüm kartı.
///
/// Başlık kartın dışında, alanlar beyaz kartın içinde yer alır.
class AppFormSection extends StatelessWidget {
  final String? title;
  final List<Widget> children;
  final double gap;

  const AppFormSection({
    super.key,
    this.title,
    required this.children,
    this.gap = AppSpacing.lg,
  });

  @override
  Widget build(BuildContext context) {
    final List<Widget> spaced = [];

    for (int i = 0; i < children.length; i++) {
      if (i > 0) {
        spaced.add(SizedBox(height: gap));
      }

      spaced.add(children[i]);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (title != null) ...[
          Padding(
            padding: const EdgeInsets.only(left: 2),
            child: Text(
              title!,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.3,
              ),
            ),
          ),

          const SizedBox(height: AppSpacing.sm + 2),
        ],

        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: spaced,
          ),
        ),
      ],
    );
  }
}

/// Form alanının üstünde duran küçük etiket + opsiyonel yardımcı metin.
class AppLabeledField extends StatelessWidget {
  final String label;
  final Widget child;
  final String? helperText;

  const AppLabeledField({
    super.key,
    required this.label,
    required this.child,
    this.helperText,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.textSecondary,
              letterSpacing: 0.1,
            ),
          ),
        ),

        child,

        if (helperText != null)
          Padding(
            padding: const EdgeInsets.only(left: 4, top: 7),
            child: Text(
              helperText!,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textTertiary,
                height: 1.35,
              ),
            ),
          ),
      ],
    );
  }
}

/// Formların altındaki tam genişlik birincil aksiyon butonu.
class AppPrimaryButton extends StatelessWidget {
  final String label;
  final String? loadingLabel;
  final IconData? icon;
  final bool isLoading;
  final VoidCallback? onPressed;

  const AppPrimaryButton({
    super.key,
    required this.label,
    this.loadingLabel,
    this.icon,
    this.isLoading = false,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: AppSizes.primaryButtonHeight,
      child: FilledButton.icon(
        onPressed: isLoading ? null : onPressed,
        style: FilledButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.button),
          ),
        ),
        icon: isLoading
            ? const SizedBox(
                width: 19,
                height: 19,
                child: CircularProgressIndicator(
                  strokeWidth: 2.2,
                  color: Colors.white,
                ),
              )
            : (icon == null ? const SizedBox.shrink() : Icon(icon, size: 20)),
        label: Text(
          isLoading ? (loadingLabel ?? label) : label,
          style: const TextStyle(fontSize: 15.5, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}

/// Add / Edit ekranlarının üstündeki kısa açıklama bloğu.
class AppFormIntro extends StatelessWidget {
  final String text;
  final List<Widget> badges;

  const AppFormIntro({super.key, required this.text, this.badges = const []});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          text,
          style: const TextStyle(
            fontSize: 14.5,
            height: 1.45,
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),

        if (badges.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.md),
          Wrap(spacing: 8, runSpacing: 8, children: badges),
        ],
      ],
    );
  }
}

/// Todo formlarında kullanılan sade tamamlandı anahtarı.
class AppCompletedSwitch extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;

  const AppCompletedSwitch({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    // Kendi Material'ı olmadan, kartın dolgusu dokunma dalgasını örtüyor.
    return Material(
      type: MaterialType.transparency,
      child: SwitchListTile(
        contentPadding: EdgeInsets.zero,
        visualDensity: VisualDensity.compact,
        title: const Text(
          'Completed',
          style: TextStyle(fontSize: 15.5, fontWeight: FontWeight.w700),
        ),
        subtitle: Text(
          value ? 'This task is done.' : 'This task is still pending.',
          style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
        ),
        value: value,
        onChanged: onChanged,
      ),
    );
  }
}
