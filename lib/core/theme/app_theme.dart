import 'package:flutter/material.dart';

class AppTheme {
  static const _radius = 24.0;
  static const _seed = Color(0xFF2C5E7A); // Calm premium blue/teal
  static const _accent = Color(0xFFD99058); // Premium bronze/gold accent

  static ThemeData light() {
    final scheme = ColorScheme.fromSeed(
      seedColor: _seed,
      secondary: _accent,
      brightness: Brightness.light,
      surface: const Color(0xFFFCFBF9),
      surfaceContainerHigh: const Color(0xFFFFFFFF),
    );
    return _base(scheme).copyWith(
      scaffoldBackgroundColor: const Color(0xFFF4F2EE),
      cardColor: Colors.white,
    );
  }

  static ThemeData dark() {
    final scheme = ColorScheme.fromSeed(
      seedColor: _seed,
      secondary: _accent,
      brightness: Brightness.dark,
      surface: const Color(0xFF14161A),
      surfaceContainerHigh: const Color(0xFF1C1F26),
    );
    return _base(scheme).copyWith(
      scaffoldBackgroundColor: const Color(0xFF0B0C0E),
      cardColor: const Color(0xFF14161A),
    );
  }

  static ThemeData _base(ColorScheme scheme) {
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      visualDensity: VisualDensity.standard,
      typography: Typography.material2021(colorScheme: scheme),
      appBarTheme: AppBarTheme(
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: scheme.onSurface,
        titleTextStyle: TextStyle(fontSize: 24, fontWeight: FontWeight.w600, color: scheme.onSurface, letterSpacing: -0.5),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_radius),
          side: BorderSide(color: scheme.outlineVariant.withValues(alpha: .3)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: scheme.surfaceContainerHigh,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: scheme.outlineVariant.withValues(alpha: 0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: scheme.primary, width: 2),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 2,
      ),
      dividerTheme: DividerThemeData(
        color: scheme.outlineVariant.withValues(alpha: 0.4),
        space: 32,
      ),
    );
  }
}
