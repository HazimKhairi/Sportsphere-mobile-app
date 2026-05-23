import 'package:flutter/material.dart';

abstract final class SphereColors {
  // --- Brand ---
  static const primary = Color(0xFF16A34A);       // green-600 (web light mode)
  static const primaryLight = Color(0xFFDCFCE7);  // green-100 (pastel tint)
  static const onPrimary = Color(0xFFFFFFFF);

  // --- Surfaces (light/pastel) ---
  static const background = Color(0xFFF8FAFC);    // slate-50
  static const surface = Color(0xFFFFFFFF);       // white cards
  static const surfaceElev1 = Color(0xFFF1F5F9);  // slate-100
  static const surfaceElev2 = Color(0xFFE2E8F0);  // slate-200

  // --- Text ---
  static const onSurface = Color(0xFF0F172A);      // slate-900
  static const onSurfaceMuted = Color(0xFF64748B); // slate-500
  static const onSurfaceSubtle = Color(0xFF94A3B8);// slate-400

  // --- Borders ---
  static const borderSubtle = Color(0xFFE2E8F0);  // slate-200
  static const border = Color(0xFFCBD5E1);        // slate-300

  // --- Status ---
  static const danger = Color(0xFFDC2626);
  static const dangerLight = Color(0xFFFEE2E2);
  static const warning = Color(0xFFF97316);
  static const warningLight = Color(0xFFFFEDD5);
  static const success = Color(0xFF16A34A);
  static const successLight = Color(0xFFDCFCE7);

  // --- Accent pastels ---
  static const accentBlue = Color(0xFF3B82F6);
  static const accentBluePastel = Color(0xFFDBEAFE);
  static const accentPurple = Color(0xFF8B5CF6);
  static const accentPurplePastel = Color(0xFFEDE9FE);
  static const accentAmber = Color(0xFFF59E0B);
  static const accentAmberPastel = Color(0xFFFEF3C7);
}
