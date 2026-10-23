import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter_client_oi/core/theme/app_theme.dart';
import 'package:flutter_client_oi/features/auth/pin_mode.dart';
import 'package:flutter_client_oi/shared/widgets/base_icon.dart';

class PinCodeScreen extends StatefulWidget {
  const PinCodeScreen({
    super.key,
    this.mode = PinMode.enter,
    this.userName = 'Имя. Ф',
    this.loading = false,
    this.error = '',
    required this.onComplete,
    required this.onRecover,
  });

  final PinMode mode;
  final String userName, error;
  final bool loading;
  final ValueChanged<String> onComplete;
  final VoidCallback onRecover;

  @override
  State<PinCodeScreen> createState() => PinCodeScreenState();
}

class PinCodeScreenState extends State<PinCodeScreen> {
  String pin = '';

  static const _rows = [
    ['1', '2', '3'],
    ['4', '5', '6'],
    ['7', '8', '9'],
    ['empty', '0', 'backspace'],
  ];

  String get _title =>
      widget.mode == PinMode.enter ? widget.userName : 'PIN-код';

  String get _subtitle => switch (widget.mode) {
        PinMode.create => 'Придумайте 4-значный PIN-код',
        PinMode.confirm => 'Повторите PIN-код',
        PinMode.enter => 'Введите код доступа',
      };

  /// Exposed like defineExpose({ reset }) in Vue.
  void reset() => setState(() => pin = '');

  @override
  void didUpdateWidget(covariant PinCodeScreen old) {
    super.didUpdateWidget(old);
    if (old.mode != widget.mode) pin = ''; // watch(() => props.mode, reset)
  }

  void _press(String key) {
    if (widget.loading) return;
    if (key == 'backspace') {
      if (pin.isNotEmpty) {
        setState(() => pin = pin.substring(0, pin.length - 1));
      }
      return;
    }
    if (pin.length >= 4) return;
    HapticFeedback.selectionClick();
    setState(() => pin += key);
    if (pin.length == 4) widget.onComplete(pin);
  }

  Widget _dots(int filled, {bool solid = false}) => Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(4, (i) {
          final on = solid || i < filled;
          return Padding(
            padding: EdgeInsets.only(left: i == 0 ? 0 : 16),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              width: 14,
              height: 14,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: on ? AppColors.primary : AppColors.keyBg,
                border: Border.all(
                  color: on ? AppColors.primary : AppColors.border,
                ),
              ),
            ),
          );
        }),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 32, 24, 40),
          child: Column(
            children: [
              Container(
                width: 60,
                height: 60,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.keyBg, width: 6),
                ),
                child: const BaseIcon('logo', size: IconSize.lg),
              ),
              const SizedBox(height: 16),
              Text(
                _title,
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 4),
              Text(
                _subtitle,
                style: const TextStyle(fontSize: 13, color: AppColors.grey),
              ),
              const SizedBox(height: 28),
              if (widget.mode == PinMode.confirm) ...[
                _dots(4, solid: true),
                const SizedBox(height: 12),
              ],
              _dots(pin.length),
              if (widget.error.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Text(
                    widget.error,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 12, color: Colors.red),
                  ),
                ),
              const SizedBox(height: 32),
              for (var r = 0; r < _rows.length; r++)
                Padding(
                  padding: EdgeInsets.only(top: r == 0 ? 0 : 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      for (var c = 0; c < 3; c++) ...[
                        if (c > 0) const SizedBox(width: 24),
                        _rows[r][c] == 'empty'
                            ? const SizedBox(width: 75, height: 75)
                            : _KeyButton(
                                keyValue: _rows[r][c],
                                disabled: widget.loading,
                                onTap: () => _press(_rows[r][c]),
                              ),
                      ],
                    ],
                  ),
                ),
              const Spacer(),
              if (widget.mode == PinMode.enter)
                GestureDetector(
                  onTap: widget.onRecover,
                  child: const Text(
                    'Восстановить PIN-код',
                    style: TextStyle(fontSize: 12, color: Color(0xFF8A9290)),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _KeyButton extends StatefulWidget {
  const _KeyButton({
    required this.keyValue,
    required this.onTap,
    this.disabled = false,
  });

  final String keyValue;
  final VoidCallback onTap;
  final bool disabled;

  @override
  State<_KeyButton> createState() => _KeyButtonState();
}

class _KeyButtonState extends State<_KeyButton> {
  bool _down = false;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: widget.disabled ? 0.5 : 1,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: (_) => setState(() => _down = true),
        onTapCancel: () => setState(() => _down = false),
        onTapUp: (_) {
          setState(() => _down = false);
          if (!widget.disabled) widget.onTap();
        },
        child: AnimatedScale(
          scale: _down ? 0.9 : 1,
          duration: const Duration(milliseconds: 120),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 120),
            width: 75,
            height: 75,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _down ? AppColors.border : AppColors.keyBg,
              border: Border.all(color: AppColors.border),
            ),
            child: widget.keyValue == 'backspace'
                ? const BaseIcon('delete', size: IconSize.lg)
                : Text(
                    widget.keyValue,
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
