import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter_client_oi/core/theme/app_theme.dart';

class BaseInput extends StatefulWidget {
  const BaseInput({
    super.key,
    this.value = '',
    this.label,
    this.placeholder,
    this.iinMask = false,
    this.masked = false,
    this.error,
    this.disabled = false,
    this.maxLength,
    this.onChanged,
  });

  final String value;
  final String? label, placeholder, error;
  final bool iinMask, masked, disabled;
  final int? maxLength;
  final ValueChanged<String>? onChanged;

  @override
  State<BaseInput> createState() => _BaseInputState();
}

class _BaseInputState extends State<BaseInput> {
  late final TextEditingController _c;
  final _focus = FocusNode();

  String get _display {
    final v = widget.value;
    if (widget.iinMask &&
        widget.masked &&
        !_focus.hasFocus &&
        v.length == 12) {
      return '${v.substring(0, 6)}••••${v.substring(10)}';
    }
    return v;
  }

  @override
  void initState() {
    super.initState();
    _c = TextEditingController(text: _display);
    _focus.addListener(() => setState(_sync));
  }

  @override
  void didUpdateWidget(covariant BaseInput old) {
    super.didUpdateWidget(old);
    _sync();
  }

  void _sync() {
    if (_c.text != _display) _c.text = _display;
  }

  @override
  void dispose() {
    _c.dispose();
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hasError = widget.error != null && widget.error!.isNotEmpty;
    OutlineInputBorder border(Color c) => OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: c),
        );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label != null)
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 8),
            child: Text(
              widget.label!,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFF333333),
              ),
            ),
          ),
        Opacity(
          opacity: widget.disabled ? 0.6 : 1,
          child: SizedBox(
            height: 58,
            child: TextField(
              controller: _c,
              focusNode: _focus,
              enabled: !widget.disabled,
              autocorrect: false,
              keyboardType:
                  widget.iinMask ? TextInputType.number : TextInputType.text,
              inputFormatters: [
                if (widget.iinMask) ...[
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(12),
                ] else if (widget.maxLength != null)
                  LengthLimitingTextInputFormatter(widget.maxLength),
              ],
              style: const TextStyle(fontSize: 16, color: AppColors.inputText),
              onChanged: widget.onChanged,
              decoration: InputDecoration(
                filled: true,
                fillColor: AppColors.bg,
                hintText: widget.placeholder,
                hintStyle: const TextStyle(color: Color(0xFFA4AAA7)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                enabledBorder:
                    border(hasError ? Colors.red : const Color(0xFFD7D1D1)),
                disabledBorder: border(const Color(0xFFD7D1D1)),
                focusedBorder:
                    border(hasError ? Colors.red : AppColors.primary),
              ),
            ),
          ),
        ),
        if (hasError)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(
              widget.error!,
              style: const TextStyle(fontSize: 12, color: Colors.red),
            ),
          ),
      ],
    );
  }
}
