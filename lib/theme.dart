import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PairlyColors {
  static const bg = Color(0xFFF2EEE6);
  static const surface = Color(0xFFFBF8F2);
  static const surface2 = Color(0xFFEBE6DB);
  static const ink = Color(0xFF1C1915);
  static const muted = Color(0xFF6B655C);
  static const subtle = Color(0xFF8A847A);
  static const line = Color(0xFFDDD6C8);
  static const sage = Color(0xFF2F5D4A);
  static const sageFg = Color(0xFFF4F7F4);
  static const sageSoft = Color(0xFFDCE8E1);
  static const terra = Color(0xFFA32D21);
  static const terraSoft = Color(0xFFF3D9D4);
}

ThemeData buildPairlyTheme() {
  final base = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    scaffoldBackgroundColor: PairlyColors.bg,
    colorScheme: const ColorScheme.light(
      primary: PairlyColors.ink,
      onPrimary: PairlyColors.surface,
      secondary: PairlyColors.sage,
      onSecondary: PairlyColors.sageFg,
      surface: PairlyColors.surface,
      onSurface: PairlyColors.ink,
      error: PairlyColors.terra,
    ),
  );

  return base.copyWith(
    textTheme: GoogleFonts.manropeTextTheme(base.textTheme).apply(
      bodyColor: PairlyColors.ink,
      displayColor: PairlyColors.ink,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: PairlyColors.bg,
      foregroundColor: PairlyColors.ink,
      elevation: 0,
      scrolledUnderElevation: 0,
    ),
  );
}

TextStyle displayStyle({
  double size = 28,
  FontWeight weight = FontWeight.w500,
  Color color = PairlyColors.ink,
  double height = 1.15,
}) {
  return GoogleFonts.fraunces(
    fontSize: size,
    fontWeight: weight,
    color: color,
    height: height,
    letterSpacing: -0.4,
  );
}
