import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:flutter_client_oi/core/theme/app_theme.dart';

/// Equivalent of the .icon-* size classes.
class IconSize {
  static const xs2 = 14.0, xs = 16.0, sm = 18.0, md = 24.0, big = 26.0;
  static const lg = 28.0, xl = 31.0, xxl = 36.0, xxxl = 42.0;
  static const xxxxl = 54.0, xxxxxl = 64.0;
}

/// Equivalent of the .icon-green / .icon-grey / ... filter classes.
class IconTint {
  static const green = AppColors.primary;
  static const grey = AppColors.grey;
  static const white = Colors.white;
  static const dark = AppColors.dark;
  static const red = Color(0xFFD32F2F);
}

class BaseIcon extends StatelessWidget {
  const BaseIcon(
    this.name, {
    super.key,
    this.size,
    this.width,
    this.height,
    this.color,
  });

  final String name;
  final double? size, width, height; // all null = natural SVG size, like <img>
  final Color? color;

  @override
  Widget build(BuildContext context) => SvgPicture.asset(
        'assets/icons/icon-$name.svg',
        width: width ?? size,
        height: height ?? size,
        colorFilter:
            color == null ? null : ColorFilter.mode(color!, BlendMode.srcIn),
      );
}
