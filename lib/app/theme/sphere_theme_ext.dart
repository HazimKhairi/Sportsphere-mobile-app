import 'package:flutter/material.dart';

class SphereColorTokens {
  final ColorScheme _cs;
  const SphereColorTokens(this._cs);

  // Primary
  Color get primary => _cs.primary;
  Color get onPrimary => _cs.onPrimary;
  Color get primaryLight => _cs.primaryContainer;

  // Surfaces
  Color get background => _cs.surfaceContainer;
  Color get surface => _cs.surface;
  Color get surfaceElev1 => _cs.surfaceContainerHighest;
  Color get surfaceElev2 => _cs.surfaceContainerHigh;

  // Text
  Color get onSurface => _cs.onSurface;
  Color get onSurfaceMuted => _cs.onSurfaceVariant;
  Color get onSurfaceSubtle => _cs.onSurfaceVariant;

  // Borders
  Color get borderSubtle => _cs.outlineVariant;
  Color get border => _cs.outline;

  // Status
  Color get danger => _cs.error;
  Color get dangerLight => _cs.errorContainer;
  Color get success => _cs.primary;
  Color get successLight => _cs.primaryContainer;

  // Accents
  Color get accentBlue => _cs.secondary;
  Color get accentBluePastel => _cs.secondaryContainer;
  Color get accentPurple => _cs.tertiary;
  Color get accentPurplePastel => _cs.tertiaryContainer;
  Color get accentAmber => const Color(0xFFF59E0B);
  Color get accentAmberPastel =>
      _cs.brightness == Brightness.dark ? const Color(0xFF3D2E00) : const Color(0xFFFEF3C7);
  Color get warning => const Color(0xFFF97316);
  Color get warningLight =>
      _cs.brightness == Brightness.dark ? const Color(0xFF3D1A00) : const Color(0xFFFFEDD5);
}

extension SphereThemeX on BuildContext {
  SphereColorTokens get sc => SphereColorTokens(Theme.of(this).colorScheme);
}
