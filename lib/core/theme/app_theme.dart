
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static const primary = Color(0xFF088B55);
  static const orange = Color(0xFFFF8D28);
  static const grey2 = Color(0xFFB9B9B9);
  static const grey = Color(0xFF69736F);
  static const primaryLight = Color(0xFFC6E9D9);
  static const dark = Color(0xFF0D1822);

  static const bg = Color(0xFFF7F9F8);
  static const text = Color(0xFF2E2E2E);
  static const inputText = Color(0xFF292D34);
  static const border = Color(0xFFE5E7EB);
  static const keyBg = Color(0xFFF3F4F6);
  static const cardBorder = Color(0xFFDDE5E1);
  static const cardBorderLight = Color(0xFFECF1EE);
  static const divider = Color(0xFFDCE3DF);

  /// bg-primary/10
  static Color get primary10 => primary.withOpacity(0.1);

  /// color-mix(in srgb, primary 10%, white)
  static Color get primary10OnWhite =>
      Color.alphaBlend(primary.withOpacity(0.1), Colors.white);
}

// CSS 132.34deg -> direction vector (sin, -cos)
const _a = Alignment(-0.737, -0.676);
const _b = Alignment(0.737, 0.676);

/// .bg-primary-linear
const primaryLinear = LinearGradient(
  begin: _a,
  end: _b,
  colors: [Color(0xFF0D1822), Color(0xFF093F2E)],
  stops: [0.061, 1.0],
);

/// .bg-primary-linear-button
const primaryLinearButton = LinearGradient(
  begin: _a,
  end: _b,
  colors: [Color(0xFF0D1822), Color(0xFF093F2E)],
  stops: [0.061, 0.5641],
);

/// linear-gradient(120deg, #0D1822, #064D36): splash background
const splashGradient = LinearGradient(
  begin: Alignment(-0.866, -0.5),
  end: Alignment(0.866, 0.5),
  colors: [Color(0xFF0D1822), Color(0xFF064D36)],
);

ThemeData buildTheme() {
  final base = ThemeData.light(useMaterial3: true);
  final inter = GoogleFonts.inter().fontFamily;

  return base.copyWith(
    scaffoldBackgroundColor: AppColors.bg,
    colorScheme: base.colorScheme.copyWith(primary: AppColors.primary),
    textTheme: base.textTheme.apply(
      fontFamily: inter,
      bodyColor: AppColors.text,
      displayColor: AppColors.text,
    ),
    primaryTextTheme: base.primaryTextTheme.apply(
      fontFamily: inter,
    ),
  );
}
