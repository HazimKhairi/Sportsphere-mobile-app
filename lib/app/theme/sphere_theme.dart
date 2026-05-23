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
    surfaceContainerHigh: SphereColors.surfaceElev2,
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

ThemeData buildSphereDarkTheme() {
  // Green-tinted dark palette — SportSphere brand, zero blue/slate.
  const bg = Color(0xFF091410);         // near-black, green tint
  const surf = Color(0xFF111E15);       // dark green surface
  const elev1 = Color(0xFF1A2B1E);      // cards / surfaceElev1
  const elev2 = Color(0xFF243529);      // surfaceElev2
  const onSurf = Color(0xFFF0FDF4);     // green-50 — readable white
  const muted = Color(0xFF9CA3AF);      // neutral-400 — readable muted text
  const borderSub = Color(0xFF1E3024);  // subtle border
  const borderMain = Color(0xFF2A4032); // main border
  const green400 = Color(0xFF4ADE80);   // primary bright green
  const green900 = Color(0xFF14532D);   // primary container dark

  const cs = ColorScheme(
    brightness: Brightness.dark,
    primary: green400,
    onPrimary: Color(0xFF052E16),
    primaryContainer: green900,
    onPrimaryContainer: Color(0xFFBBF7D0),
    secondary: Color(0xFF34D399),        // emerald-400
    onSecondary: Color(0xFF022C22),
    secondaryContainer: Color(0xFF065F46),
    onSecondaryContainer: Color(0xFFA7F3D0),
    tertiary: Color(0xFF86EFAC),         // green-300
    onTertiary: Color(0xFF052E16),
    tertiaryContainer: Color(0xFF166534),
    onTertiaryContainer: Color(0xFFDCFCE7),
    error: Color(0xFFF87171),
    onError: Color(0xFF450A0A),
    errorContainer: Color(0xFF7F1D1D),
    onErrorContainer: Color(0xFFFECACA),
    surface: surf,
    onSurface: onSurf,
    surfaceContainerHighest: elev1,      // → sc.surfaceElev1
    surfaceContainerHigh: elev2,         // → sc.surfaceElev2
    surfaceContainer: bg,                // → sc.background
    surfaceContainerLow: bg,
    surfaceContainerLowest: Color(0xFF050C08),
    onSurfaceVariant: muted,             // → sc.onSurfaceMuted
    outline: borderMain,
    outlineVariant: borderSub,
    shadow: Color(0x33000000),
    scrim: Color(0x80000000),
    inverseSurface: onSurf,
    onInverseSurface: surf,
    inversePrimary: SphereColors.primary,
  );

  final textTheme = buildSphereTextTheme(cs);

  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: cs,
    textTheme: textTheme,
    scaffoldBackgroundColor: bg,
    splashFactory: InkRipple.splashFactory,

    appBarTheme: AppBarTheme(
      backgroundColor: surf,
      elevation: 0,
      scrolledUnderElevation: 0.5,
      shadowColor: borderSub,
      foregroundColor: onSurf,
      systemOverlayStyle: SystemUiOverlayStyle.light,
      titleTextStyle: GoogleFonts.lexend(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: onSurf,
        letterSpacing: -0.2,
      ),
    ),

    cardTheme: CardThemeData(
      color: elev1,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: borderSub),
      ),
      margin: EdgeInsets.zero,
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: green400,
        foregroundColor: const Color(0xFF052E16),
        minimumSize: const Size.fromHeight(52),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 0,
        textStyle: GoogleFonts.lexend(fontWeight: FontWeight.w600, fontSize: 15),
      ),
    ),

    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: green400,
        minimumSize: const Size.fromHeight(52),
        side: const BorderSide(color: green400),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: GoogleFonts.lexend(fontWeight: FontWeight.w600, fontSize: 15),
      ),
    ),

    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: green400,
        textStyle: GoogleFonts.lexend(fontWeight: FontWeight.w600, fontSize: 14),
      ),
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: elev1,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: borderMain),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: borderMain),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: green400, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFF87171)),
      ),
      hintStyle: GoogleFonts.lexend(fontSize: 14, color: muted),
      labelStyle: GoogleFonts.lexend(fontSize: 14, color: muted),
    ),

    chipTheme: ChipThemeData(
      backgroundColor: elev2,
      selectedColor: green900,
      labelStyle: GoogleFonts.lexend(fontSize: 13, fontWeight: FontWeight.w500),
      side: const BorderSide(color: borderMain),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    ),

    dividerTheme: const DividerThemeData(
      color: borderSub,
      thickness: 1,
      space: 1,
    ),

    listTileTheme: ListTileThemeData(
      tileColor: surf,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),

    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: surf,
      selectedItemColor: green400,
      unselectedItemColor: muted,
      elevation: 0,
      type: BottomNavigationBarType.fixed,
    ),

    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: surf,
      indicatorColor: green900,
      iconTheme: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return const IconThemeData(color: green400);
        }
        return const IconThemeData(color: muted);
      }),
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        final selected = states.contains(WidgetState.selected);
        return GoogleFonts.lexend(
          fontSize: 11,
          fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
          color: selected ? green400 : muted,
        );
      }),
    ),

    snackBarTheme: SnackBarThemeData(
      backgroundColor: elev2,
      contentTextStyle: GoogleFonts.lexend(color: onSurf),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      behavior: SnackBarBehavior.floating,
    ),

    dialogTheme: DialogThemeData(
      backgroundColor: elev1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      titleTextStyle: GoogleFonts.lexend(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: onSurf,
      ),
    ),

    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: elev1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      elevation: 0,
    ),
  );
}

ThemeData buildSphereTheme() => buildSphereLightTheme();
