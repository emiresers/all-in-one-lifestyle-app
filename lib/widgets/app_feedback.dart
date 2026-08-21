import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/theme/app_colors.dart';

/// Başarılı aksiyonların geri bildirimi.
///
/// Ekranı kaplayan bir diyalog yerine: kısa bir dokunsal tepki + içinde
/// beliren onay işareti olan ince bir snackbar. Dokunsal tepki yalnızca
/// anlamlı aksiyonlarda (sepete ekleme gibi) verilir, her dokunuşta değil.
class AppFeedback {
  const AppFeedback._();

  static void success(BuildContext context, String message) {
    HapticFeedback.lightImpact();
    _show(context, message, const _AnimatedCheck());
  }

  /// Sepet adedi gibi küçük ama kasıtlı değişimler için yalnızca dokunsal
  /// tepki; ekranda zaten görünen sayı değiştiği için mesaja gerek yok.
  static void selection() {
    HapticFeedback.selectionClick();
  }

  static void failure(BuildContext context, String message) {
    _show(
      context,
      message,
      const Icon(
        Icons.error_outline_rounded,
        size: 18,
        color: AppColors.danger,
      ),
    );
  }

  static void _show(BuildContext context, String message, Widget leading) {
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);

    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          duration: const Duration(milliseconds: 1800),
          content: Row(
            children: [
              leading,
              const SizedBox(width: 10),
              Expanded(child: Text(message)),
            ],
          ),
        ),
      );
  }
}

/// Snackbar açılırken beliren onay işareti.
class _AnimatedCheck extends StatelessWidget {
  const _AnimatedCheck();

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: 1),
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOutBack,
      builder: (context, value, child) {
        return Transform.scale(scale: value, child: child);
      },
      child: const Icon(
        Icons.check_circle_rounded,
        size: 18,
        color: AppColors.success,
      ),
    );
  }
}

/// Durumu değiştiğinde kısa bir "zıplama" yapan sarmalayıcı.
///
/// [value] değiştiğinde 1.0 → 1.20 → 0.95 → 1.0 sırası oynatılır; geri
/// alındığında (ör. işareti kaldırınca) daha sakin bir eğri kullanılır.
class AppBounceOnChange extends StatefulWidget {
  final bool value;
  final Widget child;

  const AppBounceOnChange({
    super.key,
    required this.value,
    required this.child,
  });

  @override
  State<AppBounceOnChange> createState() => _AppBounceOnChangeState();
}

class _AppBounceOnChangeState extends State<AppBounceOnChange>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 320),
  );

  late final Animation<double> _bounce = TweenSequence<double>([
    TweenSequenceItem(tween: Tween<double>(begin: 1, end: 1.20), weight: 35),
    TweenSequenceItem(tween: Tween<double>(begin: 1.20, end: 0.95), weight: 35),
    TweenSequenceItem(tween: Tween<double>(begin: 0.95, end: 1), weight: 30),
  ]).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

  /// Geri alırken daha sakin, tek yönlü bir çöküş.
  late final Animation<double> _settle = TweenSequence<double>([
    TweenSequenceItem(tween: Tween<double>(begin: 1, end: 0.92), weight: 45),
    TweenSequenceItem(tween: Tween<double>(begin: 0.92, end: 1), weight: 55),
  ]).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

  @override
  void didUpdateWidget(covariant AppBounceOnChange oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.value != widget.value) {
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Açarken zıplar, kapatırken sakin kalır.
    final Animation<double> animation = widget.value ? _bounce : _settle;

    return ScaleTransition(scale: animation, child: widget.child);
  }
}
