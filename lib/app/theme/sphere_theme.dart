import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import 'sphere_colors.dart';
import 'sphere_text_theme.dart';

ThemeData buildSphereLightTheme() {
  const cs = ColorScheme(
    brightness: Brightness.light,
    primary: SphereColors.primary,
    onPrimary: SphereColors.onPrimary,
    primaryContainer: SphereColors.primaryLight,
    onPrimaryContainer: Color(0xFF14532D),
    secondary: SphereColors.accentBlue,
    onSecondary: SphereColors.onPrimary,
    secondaryContainer: SphereColors.accentBluePastel,
    onSecondaryContainer: Color(0xFF1E3A5F),
    tertiary: SphereColors.accentPurple,
    onTertiary: SphereColors.onPrimary,
    tertiaryContainer: SphereColors.accentPurplePastel,
    onTertiaryContainer: Color(0xFF3B1F6E),
    error: SphereColors.danger,
    onError: SphereColors.onPrimary,
    errorContainer: SphereColors.dangerLight,
    onErrorContainer: Color(0xFF7F1D1D),
    surface: SphereColors.surface,
    onSurface: SphereColors.onSurface,
    surfaceContainerHighest: SphereColors.surfaceElev1,
    surfaceContainerHigh: SphereColors.surfaceElev1,
    surfaceContainer: SphereColors.background,
    surfaceContainerLow: SphereColors.background,
    surfaceContainerLowest: SphereColors.surface,
    onSurfaceVariant: SphereColors.onSurfaceMuted,
    outline: SphereColors.border,
    outlineVariant: SphereColors.borderSubtle,
    shadow: Color(0x14000000),
    scrim: Color(0x33000000),
    inverseSurface: SphereColors.onSurface,
    onInverseSurface: SphereColors.surface,
    inversePrimary: SphereColors.primaryLight,
  );

  final textTheme = buildSphereTextTheme(cs);

  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: cs,
    textTheme: textTheme,
    scaffoldBackgroundColor: SphereColors.background,
    splashFactory: InkRipple.splashFactory,

    appBarTheme: AppBarTheme(
      backgroundColor: SphereColors.surface,
      elevation: 0,
      scrolledUnderElevation: 0.5,
      shadowColor: SphereColors.borderSubtle,
      foregroundColor: SphereColors.onSurface,
      systemOverlayStyle: SystemUiOverlayStyle.dark,
      titleTextStyle: GoogleFonts.lexend(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: SphereColors.onSurface,
        letterSpacing: -0.2,
      ),
    ),

    cardTheme: CardThemeData(
      color: SphereColors.surface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: SphereColors.borderSubtle),
      ),
      margin: EdgeInsets.zero,
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: SphereColors.primary,
        foregroundColor: SphereColors.onPrimary,
        minimumSize: const Size.fromHeight(52),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 0,
        textStyle: GoogleFonts.lexend(fontWeight: FontWeight.w600, fontSize: 15),
      ),
    ),

    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: SphereColors.primary,
        minimumSize: const Size.fromHeight(52),
        side: const BorderSide(color: SphereColors.primary),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: GoogleFonts.lexend(fontWeight: FontWeight.w600, fontSize: 15),
      ),
    ),

    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: SphereColors.primary,
        textStyle: GoogleFonts.lexend(fontWeight: FontWeight.w600, fontSize: 14),
      ),
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: SphereColors.surfaceElev1,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: SphereColors.borderSubtle),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: SphereColors.borderSubtle),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: SphereColors.primary, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: SphereColors.danger),
      ),
      hintStyle: GoogleFonts.lexend(
        fontSize: 14,
        color: SphereColors.onSurfaceSubtle,
      ),
      labelStyle: GoogleFonts.lexend(
        fontSize: 14,
        color: SphereColors.onSurfaceMuted,
      ),
    ),

    chipTheme: ChipThemeData(
      backgroundColor: SphereColors.surfaceElev1,
      selectedColor: SphereColors.primaryLight,
      labelStyle: GoogleFonts.lexend(fontSize: 13, fontWeight: FontWeight.w500),
      side: const BorderSide(color: SphereColors.borderSubtle),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    ),

    dividerTheme: const DividerThemeData(
      color: SphereColors.borderSubtle,
      thickness: 1,
      space: 1,
    ),

    listTileTheme: ListTileThemeData(
      tileColor: SphereColors.surface,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),

    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: SphereColors.surface,
      selectedItemColor: SphereColors.primary,
      unselectedItemColor: SphereColors.onSurfaceMuted,
      elevation: 0,
      type: BottomNavigationBarType.fixed,
    ),

    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: SphereColors.surface,
      indicatorColor: SphereColors.primaryLight,
      iconTheme: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return const IconThemeData(color: SphereColors.primary);
        }
        return const IconThemeData(color: SphereColors.onSurfaceMuted);
      }),
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        final selected = states.contains(WidgetState.selected);
        return GoogleFonts.lexend(
          fontSize: 11,
          fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
          color: selected ? SphereColors.primary : SphereColors.onSurfaceMuted,
        );
      }),
    ),

    snackBarTheme: SnackBarThemeData(
      backgroundColor: SphereColors.onSurface,
      contentTextStyle: GoogleFonts.lexend(color: SphereColors.surface),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      behavior: SnackBarBehavior.floating,
    ),

    dialogTheme: DialogThemeData(
      backgroundColor: SphereColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      titleTextStyle: GoogleFonts.lexend(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: SphereColors.onSurface,
      ),
    ),

    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: SphereColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      elevation: 0,
    ),
  );
}

// Keep a stub so any lingering references don't break compilation,
// but the app always runs in light mode.
ThemeData buildSphereTheme() => buildSphereLightTheme();
