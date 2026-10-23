import 'package:flutter/material.dart';

import 'package:flutter_client_oi/core/theme/app_theme.dart';
import 'package:flutter_client_oi/shared/widgets/base_icon.dart';

class SecurityNotice extends StatelessWidget {
  const SecurityNotice(
    this.text, {
    super.key,
    this.backgroundColor,
    this.textColor,
  });

  final String text;

  /// bg-primary/10 by default.
  final Color? backgroundColor;

  /// text-primary by default.
  final Color? textColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: backgroundColor ?? AppColors.primary10,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          const BaseIcon('secure', size: IconSize.sm, color: IconTint.green),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 11,
                color: textColor ?? AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
