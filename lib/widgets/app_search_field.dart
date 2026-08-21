import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_spacing.dart';

/// Products / Posts / Users ekranlarının paylaştığı arama alanı.
///
/// Odaklandığında kenarlığı primary renge geçer; ikon ve metin kutunun tam
/// ortasında hizalanır.
class AppSearchField extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  /// Alanın sağ ucunda gösterilecek ek aksiyon (ör. filtre düğmesi).
  final Widget? trailing;

  const AppSearchField({
    super.key,
    required this.controller,
    required this.hintText,
    required this.onChanged,
    required this.onClear,
    this.trailing,
  });

  @override
  State<AppSearchField> createState() => _AppSearchFieldState();
}

class _AppSearchFieldState extends State<AppSearchField> {
  final FocusNode _focusNode = FocusNode();

  bool _focused = false;

  @override
  void initState() {
    super.initState();

    _focusNode.addListener(() {
      if (_focused != _focusNode.hasFocus) {
        setState(() {
          _focused = _focusNode.hasFocus;
        });
      }
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOut,
      height: AppSizes.searchHeight,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.field),
        border: Border.all(
          color: _focused ? AppColors.primary : AppColors.border,
          width: _focused ? 1.4 : 1,
        ),
        boxShadow: _focused ? null : AppColors.subtleShadow,
      ),

      // Prefix/suffix'i InputDecoration'a bırakmak yerine satırı burada
      // kuruyoruz: ikon ve metin kutunun dikey merkezinde kalıyor.
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(width: AppSpacing.lg),

          TweenAnimationBuilder<Color?>(
            duration: const Duration(milliseconds: 180),
            tween: ColorTween(
              end: _focused ? AppColors.primary : AppColors.textTertiary,
            ),
            builder: (context, color, _) {
              return Icon(Icons.search_rounded, size: 22, color: color);
            },
          ),

          const SizedBox(width: AppSpacing.sm + 2),

          Expanded(
            child: TextField(
              controller: widget.controller,
              focusNode: _focusNode,
              onChanged: widget.onChanged,
              textInputAction: TextInputAction.search,
              textAlignVertical: TextAlignVertical.center,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
              decoration: InputDecoration(
                hintText: widget.hintText,
                hintStyle: const TextStyle(
                  fontSize: 15,
                  color: AppColors.textTertiary,
                  fontWeight: FontWeight.w400,
                ),
                filled: false,
                isCollapsed: true,
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                disabledBorder: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),

          if (widget.controller.text.isNotEmpty)
            IconButton(
              onPressed: widget.onClear,
              visualDensity: VisualDensity.compact,
              icon: const Icon(
                Icons.close_rounded,
                size: 18,
                color: AppColors.textSecondary,
              ),
            ),

          if (widget.trailing != null) ...[
            // İnce dikey ayraç: filtre alanı sonradan yapıştırılmış gibi
            // durmasın, aynı kutunun parçası olsun.
            Container(
              width: 1,
              height: 24,
              margin: const EdgeInsets.symmetric(horizontal: AppSpacing.sm + 2),
              color: AppColors.border,
            ),
            widget.trailing!,
            const SizedBox(width: AppSpacing.sm - 1),
          ] else
            const SizedBox(width: AppSpacing.lg),
        ],
      ),
    );
  }
}
