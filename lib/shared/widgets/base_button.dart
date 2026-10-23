import 'package:flutter/material.dart';

import 'package:flutter_client_oi/core/theme/app_theme.dart';
import 'package:flutter_client_oi/shared/widgets/base_icon.dart';

enum ButtonVariant { primary, secondary, ghost, icon, logout, login }

enum ButtonSize { sm, md, lg }

class BaseButton extends StatelessWidget {
  const BaseButton({
    super.key,
    this.text,
    this.icon,
    this.variant = ButtonVariant.primary,
    this.size = ButtonSize.md,
    this.block = false,
    this.loading = false,
    this.disabled = false,
    this.rounded = false,
    this.verticalPadding,
    this.onPressed,
  });

  final String? text;
  final String? icon;
  final ButtonVariant variant;
  final ButtonSize size;
  final bool block, loading, disabled, rounded;

  /// Replaces Tailwind "!py-4".
  final double? verticalPadding;
  final VoidCallback? onPressed;

  bool get _disabled => disabled || loading;

  double get _minH => switch (size) {
        ButtonSize.sm => 40,
        ButtonSize.md => 48,
        ButtonSize.lg => 56,
      };
  double get _fontSize => switch (size) {
        ButtonSize.sm => 14,
        ButtonSize.md => 16,
        ButtonSize.lg => 18,
      };
  double get _hPad => switch (size) {
        ButtonSize.sm => 16,
        ButtonSize.md => 20,
        ButtonSize.lg => 24,
      };

  ({Color? bg, Gradient? gradient, Color fg, Color? border}) get _style =>
      switch (variant) {
        ButtonVariant.primary => (
            bg: _disabled ? const Color(0xFF6DBB9F) : AppColors.primary,
            gradient: null,
            fg: Colors.white,
            border: null
          ),
        ButtonVariant.secondary => (
            bg: const Color(0xFFF8FAF9),
            gradient: null,
            fg: const Color(0xFF242424),
            border: const Color(0xFFDCE3DF)
          ),
        ButtonVariant.ghost => (
            bg: Colors.transparent,
            gradient: null,
            fg: const Color(0xFF242424),
            border: null
          ),
        ButtonVariant.icon => (
            bg: const Color(0xFFF5F5F5),
            gradient: null,
            fg: const Color(0xFFA4A4A4),
            border: null
          ),
        ButtonVariant.logout => (
            bg: const Color(0xFFEDEDED),
            gradient: null,
            fg: const Color(0xFF505050),
            border: const Color(0xFFC4C4C4)
          ),
        ButtonVariant.login => (
            bg: null,
            gradient: primaryLinearButton,
            fg: const Color(0xFFF5F5F5),
            border: const Color(0xFFC4C4C4)
          ),
      };

  @override
  Widget build(BuildContext context) {
    final s = _style;
    final radius = BorderRadius.circular(rounded ? 999 : 10);

    final content = loading
        ? SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2, color: s.fg),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                BaseIcon(icon!, size: IconSize.sm, color: s.fg),
                if (text != null) const SizedBox(width: 8),
              ],
              if (text != null)
                Text(
                  text!,
                  style: TextStyle(
                    fontSize: _fontSize,
                    fontWeight: FontWeight.w600,
                    color: s.fg,
                  ),
                ),
            ],
          );

    return Opacity(
      opacity: _disabled && variant != ButtonVariant.primary ? 0.8 : 1,
      child: Material(
        color: Colors.transparent,
        child: Ink(
          width: block ? double.infinity : null,
          decoration: BoxDecoration(
            color: s.bg,
            gradient: s.gradient,
            borderRadius: radius,
            border: s.border == null ? null : Border.all(color: s.border!),
          ),
          child: InkWell(
            borderRadius: radius,
            onTap: _disabled ? null : onPressed,
            child: Container(
              constraints: BoxConstraints(minHeight: _minH),
              padding: EdgeInsets.symmetric(
                horizontal: _hPad,
                vertical: verticalPadding ?? 0,
              ),
              alignment: Alignment.center,
              child: content,
            ),
          ),
        ),
      ),
    );
  }
}
