import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'sphere_colors.dart';

TextTheme buildSphereTextTheme(ColorScheme cs) {
  TextStyle base(double size, double height, FontWeight weight) {
    return GoogleFonts.lexend(
      fontSize: size,
      height: height / size,
      fontWeight: weight,
      color: cs.onSurface,
      letterSpacing: -0.1,
    );
  }

  return TextTheme(
    displayLarge: base(32, 40, FontWeight.w700),
    headlineMedium: base(24, 32, FontWeight.w600),
    titleLarge: base(20, 28, FontWeight.w600),
    titleMedium: base(16, 24, FontWeight.w600),
    bodyLarge: base(16, 24, FontWeight.w400),
    bodyMedium: base(14, 20, FontWeight.w400),
    bodySmall: base(12, 16, FontWeight.w500).copyWith(color: SphereColors.onSurfaceMuted),
    labelLarge: base(14, 20, FontWeight.w600),
    labelMedium: base(12, 16, FontWeight.w600),
    labelSmall: base(11, 14, FontWeight.w600),
  );
}
