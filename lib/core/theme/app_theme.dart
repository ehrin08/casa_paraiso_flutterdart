// Brand theme — Material 3 configuration with Casa Paraiso's identity.
//
// Uses a warm tropical wellness palette with two font families:
// - Cormorant Garamond (display/headline) for emotional, premium copy.
// - Manrope (body/navigation) for readable operational text.
//
// The theme is light-only per project requirements.
import 'package:flutter/material.dart';

/// Brand color palette — derived from the spa's tropical wellness identity.
abstract final class AppColors {
  static const cacao = Color(0xFF7A3518);   // Primary — warm reddish-brown
  static const palm = Color(0xFF2F5D45);    // Secondary — deep tropical green
  static const brass = Color(0xFFA98245);   // Tertiary — muted gold accent
  static const sand = Color(0xFFE4D4BD);    // Borders, pill backgrounds
  static const cream = Color(0xFFFBF7EF);   // Scaffold background
  static const surface = Color(0xFFFFFDF8); // Card / elevated surface
  static const ink = Color(0xFF2B211B);     // Primary text
  static const muted = Color(0xFF6F6259);   // Secondary / label text
  static const error = Color(0xFFB3261E);   // Validation errors, destructive actions
}

/// Builds the single, light-only Material 3 theme used throughout the app.
///
/// Key design decisions:
/// - ColorScheme seeded from cacao with explicit brand color overrides.
/// - Display and headline text styles use Cormorant Garamond (serif).
/// - All other text uses Manrope (sans-serif).
/// - Cards have a 20dp border radius with subtle cacao-tinted shadows.
/// - Input fields have 14dp rounded borders with sand-colored enabled state.
/// - Buttons use 14dp rounded corners and 52dp minimum height (48dp+ touch).
ThemeData buildCasaTheme() {
  final scheme = ColorScheme.fromSeed(
    seedColor: AppColors.cacao,
    brightness: Brightness.light,
    primary: AppColors.cacao,
    secondary: AppColors.palm,
    tertiary: AppColors.brass,
    surface: AppColors.surface,
    error: AppColors.error,
  );
  final base = ThemeData(colorScheme: scheme, useMaterial3: true);
  final text = base.textTheme.apply(
    bodyColor: AppColors.ink,
    displayColor: AppColors.ink,
    fontFamily: 'Manrope',
  );
  return base.copyWith(
    scaffoldBackgroundColor: AppColors.cream,
    textTheme: text.copyWith(
      // Serif font for display / headline styles (emotional / premium feel).
      displayLarge: text.displayLarge?.copyWith(
        fontFamily: 'CormorantGaramond',
        fontWeight: FontWeight.w600,
      ),
      displayMedium: text.displayMedium?.copyWith(
        fontFamily: 'CormorantGaramond',
        fontWeight: FontWeight.w600,
      ),
      headlineLarge: text.headlineLarge?.copyWith(
        fontFamily: 'CormorantGaramond',
        fontWeight: FontWeight.w600,
      ),
      headlineMedium: text.headlineMedium?.copyWith(
        fontFamily: 'CormorantGaramond',
        fontWeight: FontWeight.w600,
      ),
      headlineSmall: text.headlineSmall?.copyWith(
        fontFamily: 'CormorantGaramond',
        fontWeight: FontWeight.w600,
      ),
      titleLarge: text.titleLarge?.copyWith(fontWeight: FontWeight.w700),
    ),
    cardTheme: CardThemeData(
      color: AppColors.surface,
      elevation: 1,
      shadowColor: AppColors.cacao.withValues(alpha: .16),
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.surface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.sand),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size(48, 52),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        textStyle: const TextStyle(fontWeight: FontWeight.w700),
      ),
    ),
    navigationBarTheme: const NavigationBarThemeData(
      backgroundColor: AppColors.surface,
      indicatorColor: AppColors.sand,
      height: 72,
    ),
    dividerColor: AppColors.sand,
  );
}
