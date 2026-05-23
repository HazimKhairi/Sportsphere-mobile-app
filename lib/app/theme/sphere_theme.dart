import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'sphere_colors.dart';
import 'sphere_text_theme.dart';

ThemeData buildSphereLightTheme() {
  final cs = ColorScheme.fromSeed(
    seedColor: SphereColors.primary,
    brightness: Brightness.light,
  );
  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: cs,
    scaffoldBackgroundColor: const Color(0xFFF5F5F5),
    splashFactory: InkRipple.splashFactory,
    appBarTheme: AppBarTheme(
      backgroundColor: cs.surface,
      elevation: 0,
      scrolledUnderElevation: 0,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: SphereColors.primary,
        foregroundColor: SphereColors.onPrimary,
        minimumSize: const Size.fromHeight(52),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: GoogleFonts.geist(fontWeight: FontWeight.w600, fontSize: 16),
      ),
    ),
  );
}

ThemeData buildSphereTheme() {
  const cs = ColorScheme(
    brightness: Brightness.dark,
    primary: SphereColors.primary,
    onPrimary: SphereColors.onPrimary,
    secondary: SphereColors.primary,
    onSecondary: SphereColors.onPrimary,
    error: SphereColors.danger,
    onError: SphereColors.onSurface,
    surface: SphereColors.surface,
    onSurface: SphereColors.onSurface,
    surfaceContainerHighest: SphereColors.surfaceElev1,
    outline: SphereColors.borderSubtle,
  );

  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: cs,
    scaffoldBackgroundColor: SphereColors.surface,
    textTheme: buildSphereTextTheme(cs),
    splashFactory: InkRipple.splashFactory,
    appBarTheme: const AppBarTheme(
      backgroundColor: SphereColors.surface,
      elevation: 0,
      scrolledUnderElevation: 0,
      foregroundColor: SphereColors.onSurface,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: SphereColors.primary,
        foregroundColor: SphereColors.onPrimary,
        minimumSize: const Size.fromHeight(52),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        textStyle: GoogleFonts.geist(
          fontWeight: FontWeight.w600,
          fontSize: 16,
        ),
      ),
    ),
  );
}
