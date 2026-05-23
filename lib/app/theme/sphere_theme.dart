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
  const cs = ColorScheme(
    brightness: Brightness.dark,
    primary: Color(0xFF4ADE80),         // green-400 — brighter for dark bg
    onPrimary: Color(0xFF052E16),       // green-950
    primaryContainer: Color(0xFF14532D), // green-900
    onPrimaryContainer: Color(0xFFBBF7D0),
    secondary: Color(0xFF60A5FA),       // blue-400
    onSecondary: Color(0xFF1E3A5F),
    secondaryContainer: Color(0xFF1E40AF),
    onSecondaryContainer: Color(0xFFBFDBFE),
    tertiary: Color(0xFFA78BFA),        // purple-400
    onTertiary: Color(0xFF2E1065),
    tertiaryContainer: Color(0xFF4C1D95),
    onTertiaryContainer: Color(0xFFEDE9FE),
    error: Color(0xFFF87171),           // red-400
    onError: Color(0xFF450A0A),
    errorContainer: Color(0xFF7F1D1D),
    onErrorContainer: Color(0xFFFECACA),
    surface: Color(0xFF1E293B),         // slate-800
    onSurface: Color(0xFFF1F5F9),       // slate-100
    surfaceContainerHighest: Color(0xFF334155), // slate-700
    surfaceContainerHigh: Color(0xFF475569),    // slate-600 — surfaceElev2 dark
    surfaceContainer: Color(0xFF0F172A),  // slate-900
    surfaceContainerLow: Color(0xFF0F172A),
    surfaceContainerLowest: Color(0xFF020617), // slate-950
    onSurfaceVariant: Color(0xFF94A3B8),  // slate-400
    outline: Color(0xFF475569),           // slate-600
    outlineVariant: Color(0xFF334155),    // slate-700
    shadow: Color(0x33000000),
    scrim: Color(0x80000000),
    inverseSurface: Color(0xFFF1F5F9),
    onInverseSurface: Color(0xFF1E293B),
    inversePrimary: Color(0xFF16A34A),
  );

  final textTheme = buildSphereTextTheme(cs);

  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: cs,
    textTheme: textTheme,
    scaffoldBackgroundColor: const Color(0xFF0F172A),
    splashFactory: InkRipple.splashFactory,

    appBarTheme: AppBarTheme(
      backgroundColor: const Color(0xFF1E293B),
      elevation: 0,
      scrolledUnderElevation: 0.5,
      shadowColor: const Color(0xFF334155),
      foregroundColor: const Color(0xFFF1F5F9),
      systemOverlayStyle: SystemUiOverlayStyle.light,
      titleTextStyle: GoogleFonts.lexend(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: const Color(0xFFF1F5F9),
        letterSpacing: -0.2,
      ),
    ),

    cardTheme: CardThemeData(
      color: const Color(0xFF1E293B),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Color(0xFF334155)),
      ),
      margin: EdgeInsets.zero,
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF4ADE80),
        foregroundColor: const Color(0xFF052E16),
        minimumSize: const Size.fromHeight(52),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 0,
        textStyle: GoogleFonts.lexend(fontWeight: FontWeight.w600, fontSize: 15),
      ),
    ),

    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: const Color(0xFF4ADE80),
        minimumSize: const Size.fromHeight(52),
        side: const BorderSide(color: Color(0xFF4ADE80)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: GoogleFonts.lexend(fontWeight: FontWeight.w600, fontSize: 15),
      ),
    ),

    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: const Color(0xFF4ADE80),
        textStyle: GoogleFonts.lexend(fontWeight: FontWeight.w600, fontSize: 14),
      ),
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFF334155),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF475569)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF475569)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF4ADE80), width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFF87171)),
      ),
      hintStyle: GoogleFonts.lexend(
        fontSize: 14,
        color: const Color(0xFF64748B),
      ),
      labelStyle: GoogleFonts.lexend(
        fontSize: 14,
        color: const Color(0xFF94A3B8),
      ),
    ),

    chipTheme: ChipThemeData(
      backgroundColor: const Color(0xFF334155),
      selectedColor: const Color(0xFF14532D),
      labelStyle: GoogleFonts.lexend(fontSize: 13, fontWeight: FontWeight.w500),
      side: const BorderSide(color: Color(0xFF475569)),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    ),

    dividerTheme: const DividerThemeData(
      color: Color(0xFF334155),
      thickness: 1,
      space: 1,
    ),

    listTileTheme: ListTileThemeData(
      tileColor: const Color(0xFF1E293B),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),

    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Color(0xFF1E293B),
      selectedItemColor: Color(0xFF4ADE80),
      unselectedItemColor: Color(0xFF94A3B8),
      elevation: 0,
      type: BottomNavigationBarType.fixed,
    ),

    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: const Color(0xFF1E293B),
      indicatorColor: const Color(0xFF14532D),
      iconTheme: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return const IconThemeData(color: Color(0xFF4ADE80));
        }
        return const IconThemeData(color: Color(0xFF94A3B8));
      }),
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        final selected = states.contains(WidgetState.selected);
        return GoogleFonts.lexend(
          fontSize: 11,
          fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
          color: selected ? const Color(0xFF4ADE80) : const Color(0xFF94A3B8),
        );
      }),
    ),

    snackBarTheme: SnackBarThemeData(
      backgroundColor: const Color(0xFF334155),
      contentTextStyle: GoogleFonts.lexend(color: const Color(0xFFF1F5F9)),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      behavior: SnackBarBehavior.floating,
    ),

    dialogTheme: DialogThemeData(
      backgroundColor: const Color(0xFF1E293B),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      titleTextStyle: GoogleFonts.lexend(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: const Color(0xFFF1F5F9),
      ),
    ),

    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: Color(0xFF1E293B),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      elevation: 0,
    ),
  );
}

ThemeData buildSphereTheme() => buildSphereLightTheme();
