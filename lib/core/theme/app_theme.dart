import 'package:flutter/material.dart';

class AppTheme {
  static const _radius = 24.0;
  static const _seed = Color(0xFF2E6673);
  static const _accent = Color(0xFFC58B55);

  static ThemeData light() {
    final base = ColorScheme.fromSeed(
      seedColor: _seed,
      secondary: _accent,
      brightness: Brightness.light,
    );
    final scheme = base.copyWith(
      surface: const Color(0xFFFDFCF9),
      surfaceContainerLowest: const Color(0xFFFFFFFF),
      surfaceContainerLow: const Color(0xFFF8F6F1),
      surfaceContainer: const Color(0xFFF1EFE9),
      surfaceContainerHigh: const Color(0xFFEAE7E0),
      surfaceContainerHighest: const Color(0xFFE2DED6),
      outline: const Color(0xFF8C918D),
      outlineVariant: const Color(0xFFD8D6CF),
    );
    return _base(scheme).copyWith(
      scaffoldBackgroundColor: const Color(0xFFF4F2ED),
      cardColor: const Color(0xFFFFFEFB),
      shadowColor: const Color(0xFF23383A).withValues(alpha: .08),
    );
  }

  static ThemeData dark() {
    final base = ColorScheme.fromSeed(
      seedColor: const Color(0xFF69A8B4),
      secondary: const Color(0xFFD8A476),
      brightness: Brightness.dark,
    );
    final scheme = base.copyWith(
      surface: const Color(0xFF151B1D),
      surfaceContainerLowest: const Color(0xFF0E1315),
      surfaceContainerLow: const Color(0xFF172023),
      surfaceContainer: const Color(0xFF1B2629),
      surfaceContainerHigh: const Color(0xFF223034),
      surfaceContainerHighest: const Color(0xFF2A3A3E),
      outline: const Color(0xFF77878A),
      outlineVariant: const Color(0xFF344448),
    );
    return _base(scheme).copyWith(
      scaffoldBackgroundColor: const Color(0xFF0F1517),
      cardColor: const Color(0xFF182124),
      shadowColor: Colors.black.withValues(alpha: .36),
    );
  }

  static ThemeData _base(ColorScheme scheme) {
    final dark = scheme.brightness == Brightness.dark;
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      visualDensity: VisualDensity.standard,
      typography: Typography.material2021(colorScheme: scheme),
      splashFactory: InkSparkle.splashFactory,
      appBarTheme: AppBarTheme(
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: scheme.onSurface,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: TextStyle(
          fontSize: 23,
          height: 1.2,
          fontWeight: FontWeight.w800,
          color: scheme.onSurface,
          letterSpacing: -.35,
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        height: 74,
        elevation: 0,
        backgroundColor: dark ? const Color(0xFF121A1C) : const Color(0xFFFFFEFB),
        indicatorColor: scheme.primaryContainer.withValues(alpha: dark ? .62 : .82),
        labelTextStyle: WidgetStateProperty.resolveWith(
          (states) => TextStyle(
            fontSize: 12,
            fontWeight: states.contains(WidgetState.selected) ? FontWeight.w800 : FontWeight.w600,
            color: states.contains(WidgetState.selected) ? scheme.primary : scheme.onSurfaceVariant,
          ),
        ),
      ),
      cardTheme: CardThemeData(
        elevation: dark ? 0 : 1,
        surfaceTintColor: Colors.transparent,
        margin: EdgeInsets.zero,
        color: dark ? const Color(0xFF182124) : const Color(0xFFFFFEFB),
        shadowColor: Colors.black.withValues(alpha: dark ? .26 : .06),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_radius),
          side: BorderSide(
            color: dark ? const Color(0xFF2A3A3E) : const Color(0xFFE2DED6),
            width: 1,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: dark ? const Color(0xFF1A2427) : const Color(0xFFFFFEFB),
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 17),
        labelStyle: TextStyle(color: scheme.onSurfaceVariant, fontWeight: FontWeight.w600),
        hintStyle: TextStyle(color: scheme.onSurfaceVariant.withValues(alpha: .72)),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: scheme.outlineVariant.withValues(alpha: .78)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: scheme.primary, width: 1.8),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: scheme.error),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(48, 52),
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 15),
          textStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(17)),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(48, 50),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          textStyle: const TextStyle(fontWeight: FontWeight.w700),
          side: BorderSide(color: scheme.outlineVariant),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(17)),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: scheme.primaryContainer,
        foregroundColor: scheme.onPrimaryContainer,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 3,
        focusElevation: 4,
        hoverElevation: 4,
      ),
      chipTheme: ChipThemeData(
        side: BorderSide(color: scheme.outlineVariant.withValues(alpha: .8)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        labelStyle: const TextStyle(fontWeight: FontWeight.w600),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: dark ? const Color(0xFF192326) : const Color(0xFFFFFEFB),
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: dark ? const Color(0xFF172023) : const Color(0xFFFFFEFB),
        surfaceTintColor: Colors.transparent,
        showDragHandle: true,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
      ),
      dividerTheme: DividerThemeData(color: scheme.outlineVariant.withValues(alpha: .55), space: 24),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: dark ? const Color(0xFF253437) : const Color(0xFF23383A),
        contentTextStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }
}
