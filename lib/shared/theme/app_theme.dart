import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Design tokens matching ChampHive light (green) and dark (navy/gold) mocks.
class AppColors {
  AppColors._();

  // Light
  static const Color lightPrimary = Color(0xFF22C55E);
  static const Color lightPrimaryDark = Color(0xFF16A34A);
  static const Color lightBg = Color(0xFFF7F8FA);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightText = Color(0xFF0F172A);
  static const Color lightMuted = Color(0xFF64748B);
  static const Color lightBorder = Color(0xFFE2E8F0);

  // Dark
  static const Color darkPrimary = Color(0xFFF5C518);
  static const Color darkPrimaryDark = Color(0xFFE0B000);
  static const Color darkBg = Color(0xFF071427);
  static const Color darkSurface = Color(0xFF0E1F3D);
  static const Color darkCard = Color(0xFF13284D);
  static const Color darkText = Color(0xFFFFFFFF);
  static const Color darkMuted = Color(0xFF94A3B8);
  static const Color darkBorder = Color(0xFF1E3A5F);
  static const Color darkNavy = Color(0xFF0B1C3E);

  // Event accents (shared)
  static const Color training = Color(0xFF3B82F6);
  static const Color meeting = Color(0xFF8B5CF6);
  static const Color match = Color(0xFF22C55E);
  static const Color danger = Color(0xFFEF4444);
  static const Color badge = Color(0xFFEF4444);
}

class AppTheme {
  AppTheme._();

  static const double radius = 14;
  static const double radiusSm = 10;

  static TextTheme _buildTextTheme(TextTheme base, Color bodyColor) {
    return TextTheme(
      bodyLarge: GoogleFonts.inter(fontWeight: FontWeight.w400, color: bodyColor)
          .merge(base.bodyLarge),
      bodyMedium: GoogleFonts.inter(fontWeight: FontWeight.w400, color: bodyColor)
          .merge(base.bodyMedium),
      bodySmall: GoogleFonts.inter(fontWeight: FontWeight.w400, color: bodyColor)
          .merge(base.bodySmall),
      labelLarge: GoogleFonts.inter(fontWeight: FontWeight.w600, color: bodyColor)
          .merge(base.labelLarge),
      labelMedium: GoogleFonts.inter(fontWeight: FontWeight.w500, color: bodyColor)
          .merge(base.labelMedium),
      labelSmall: GoogleFonts.inter(fontWeight: FontWeight.w500, color: bodyColor)
          .merge(base.labelSmall),
      titleSmall: GoogleFonts.inter(fontWeight: FontWeight.w600, color: bodyColor)
          .merge(base.titleSmall),
      titleMedium: GoogleFonts.inter(fontWeight: FontWeight.w600, color: bodyColor)
          .merge(base.titleMedium),
      titleLarge: GoogleFonts.inter(fontWeight: FontWeight.w700, color: bodyColor)
          .merge(base.titleLarge),
      headlineSmall: GoogleFonts.inter(fontWeight: FontWeight.w700, color: bodyColor)
          .merge(base.headlineSmall),
      headlineMedium: GoogleFonts.poppins(fontWeight: FontWeight.w700, color: bodyColor)
          .merge(base.headlineMedium),
      headlineLarge: GoogleFonts.poppins(fontWeight: FontWeight.w700, color: bodyColor)
          .merge(base.headlineLarge),
      displaySmall: GoogleFonts.inter(fontWeight: FontWeight.w700, color: bodyColor)
          .merge(base.displaySmall),
    );
  }

  static ThemeData get light {
    final scheme = ColorScheme.light(
      primary: AppColors.lightPrimary,
      onPrimary: Colors.white,
      secondary: AppColors.lightPrimaryDark,
      surface: AppColors.lightSurface,
      onSurface: AppColors.lightText,
      error: AppColors.danger,
    );
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: scheme,
      scaffoldBackgroundColor: AppColors.lightBg,
      textTheme: _buildTextTheme(ThemeData.light().textTheme, AppColors.lightText),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.lightSurface,
        foregroundColor: AppColors.lightText,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.inter(
          fontWeight: FontWeight.w700,
          fontSize: 20,
          color: AppColors.lightText,
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.lightSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radius),
          side: const BorderSide(color: AppColors.lightBorder),
        ),
        margin: EdgeInsets.zero,
      ),
      dividerColor: AppColors.lightBorder,
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.lightSurface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusSm),
          borderSide: const BorderSide(color: AppColors.lightBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusSm),
          borderSide: const BorderSide(color: AppColors.lightBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusSm),
          borderSide: const BorderSide(color: AppColors.lightPrimary, width: 1.5),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.lightPrimary,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusSm),
          ),
          textStyle: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 16),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.lightText,
          backgroundColor: AppColors.lightSurface,
          minimumSize: const Size.fromHeight(52),
          side: const BorderSide(color: AppColors.lightBorder),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusSm),
          ),
          textStyle: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 15),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.lightPrimary,
        foregroundColor: Colors.white,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.lightSurface,
        selectedItemColor: AppColors.lightPrimary,
        unselectedItemColor: AppColors.lightMuted,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.lightSurface,
        indicatorColor: AppColors.lightPrimary.withValues(alpha: 0.12),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return GoogleFonts.inter(
            fontSize: 12,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
            color: selected ? AppColors.lightPrimary : AppColors.lightMuted,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return IconThemeData(
            color: selected ? AppColors.lightPrimary : AppColors.lightMuted,
          );
        }),
      ),
      drawerTheme: const DrawerThemeData(backgroundColor: AppColors.lightSurface),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.lightPrimary.withValues(alpha: 0.12),
        labelStyle: GoogleFonts.inter(
          color: AppColors.lightPrimaryDark,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
        side: BorderSide.none,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
    );
  }

  static ThemeData get dark {
    final scheme = ColorScheme.dark(
      primary: AppColors.darkPrimary,
      onPrimary: const Color(0xFF111827),
      secondary: AppColors.darkPrimaryDark,
      surface: AppColors.darkSurface,
      onSurface: AppColors.darkText,
      error: AppColors.danger,
    );
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: scheme,
      scaffoldBackgroundColor: AppColors.darkBg,
      textTheme: _buildTextTheme(ThemeData.dark().textTheme, AppColors.darkText),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.darkNavy,
        foregroundColor: AppColors.darkText,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.inter(
          fontWeight: FontWeight.w700,
          fontSize: 20,
          color: AppColors.darkText,
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.darkCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radius),
          side: const BorderSide(color: AppColors.darkBorder),
        ),
        margin: EdgeInsets.zero,
      ),
      dividerColor: AppColors.darkBorder,
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.darkCard,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusSm),
          borderSide: const BorderSide(color: AppColors.darkBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusSm),
          borderSide: const BorderSide(color: AppColors.darkBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusSm),
          borderSide: const BorderSide(color: AppColors.darkPrimary, width: 1.5),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.darkPrimary,
          foregroundColor: const Color(0xFF111827),
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusSm),
          ),
          textStyle: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 16),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.darkText,
          backgroundColor: AppColors.darkCard,
          minimumSize: const Size.fromHeight(52),
          side: const BorderSide(color: AppColors.darkBorder),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusSm),
          ),
          textStyle: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 15),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.darkPrimary,
        foregroundColor: Color(0xFF111827),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.darkNavy,
        selectedItemColor: AppColors.darkPrimary,
        unselectedItemColor: AppColors.darkMuted,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.darkNavy,
        indicatorColor: AppColors.darkPrimary.withValues(alpha: 0.18),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return GoogleFonts.inter(
            fontSize: 12,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
            color: selected ? AppColors.darkPrimary : AppColors.darkMuted,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return IconThemeData(
            color: selected ? AppColors.darkPrimary : AppColors.darkMuted,
          );
        }),
      ),
      drawerTheme: const DrawerThemeData(backgroundColor: AppColors.darkNavy),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.darkPrimary.withValues(alpha: 0.18),
        labelStyle: GoogleFonts.inter(
          color: AppColors.darkPrimary,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
        side: BorderSide.none,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
    );
  }
}
