import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  AppTheme._();

  // Core palette
  static const Color midnightBlue = Color(0xFF0D1B2A);
  static const Color navyBlue = Color(0xFF1B2838);
  static const Color deepNavy = Color(0xFF152238);
  static const Color silverLight = Color(0xFFC0C0C0);
  static const Color silverBright = Color(0xFFD4D4D4);
  static const Color sandGold = Color(0xFFCDB38B);
  static const Color sandLight = Color(0xFFE8D5B7);
  static const Color moonWhite = Color(0xFFF5F5F0);
  static const Color starYellow = Color(0xFFFFD700);
  static const Color cosmicPurple = Color(0xFF6B5B95);
  static const Color successGreen = Color(0xFF4A8B6F);
  static const Color errorCoral = Color(0xFFEF6461);

  // ---------------------------------------------------------------------------
  // Dark theme (default)
  // ---------------------------------------------------------------------------
  static ThemeData get darkTheme {
    final textTheme = _buildTextTheme(moonWhite, silverLight);
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: midnightBlue,
      colorScheme: const ColorScheme.dark(
        primary: silverLight,
        onPrimary: midnightBlue,
        secondary: sandGold,
        onSecondary: midnightBlue,
        tertiary: cosmicPurple,
        surface: navyBlue,
        onSurface: moonWhite,
        error: errorCoral,
        onError: moonWhite,
      ),
      textTheme: textTheme,
      cardTheme: _cardTheme(navyBlue),
      appBarTheme: _appBarTheme(Colors.transparent, moonWhite),
      elevatedButtonTheme: _elevatedButtonTheme(),
      outlinedButtonTheme: _outlinedButtonTheme(silverLight),
      textButtonTheme: _textButtonTheme(sandGold),
      floatingActionButtonTheme: _fabTheme(),
      inputDecorationTheme: _inputTheme(navyBlue, silverLight, moonWhite),
      bottomNavigationBarTheme: _bottomNavTheme(
        midnightBlue, silverLight, sandGold,
      ),
      dialogTheme: _dialogTheme(navyBlue, moonWhite),
      snackBarTheme: _snackBarTheme(deepNavy, moonWhite),
      bottomSheetTheme: _bottomSheetTheme(navyBlue),
      chipTheme: _chipTheme(deepNavy, silverLight),
      switchTheme: _switchTheme(sandGold, silverLight),
      progressIndicatorTheme: _progressTheme(sandGold, deepNavy),
      dividerTheme: _dividerTheme(deepNavy),
    );
  }

  // ---------------------------------------------------------------------------
  // Light theme
  // ---------------------------------------------------------------------------
  static ThemeData get lightTheme {
    final textTheme = _buildTextTheme(midnightBlue, navyBlue);
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: moonWhite,
      colorScheme: const ColorScheme.light(
        primary: navyBlue,
        onPrimary: moonWhite,
        secondary: sandGold,
        onSecondary: midnightBlue,
        tertiary: cosmicPurple,
        surface: Colors.white,
        onSurface: midnightBlue,
        error: errorCoral,
        onError: moonWhite,
      ),
      textTheme: textTheme,
      cardTheme: _cardTheme(Colors.white),
      appBarTheme: _appBarTheme(Colors.transparent, midnightBlue),
      elevatedButtonTheme: _elevatedButtonTheme(),
      outlinedButtonTheme: _outlinedButtonTheme(navyBlue),
      textButtonTheme: _textButtonTheme(sandGold),
      floatingActionButtonTheme: _fabTheme(),
      inputDecorationTheme: _inputTheme(Colors.white, navyBlue, midnightBlue),
      bottomNavigationBarTheme: _bottomNavTheme(
        moonWhite, navyBlue, sandGold,
      ),
      dialogTheme: _dialogTheme(Colors.white, midnightBlue),
      snackBarTheme: _snackBarTheme(navyBlue, moonWhite),
      bottomSheetTheme: _bottomSheetTheme(Colors.white),
      chipTheme: _chipTheme(moonWhite, navyBlue),
      switchTheme: _switchTheme(sandGold, navyBlue),
      progressIndicatorTheme: _progressTheme(sandGold, silverLight),
      dividerTheme: _dividerTheme(silverLight),
    );
  }

  // ---------------------------------------------------------------------------
  // Text theme — all 15 Material 3 styles
  // ---------------------------------------------------------------------------
  static TextTheme _buildTextTheme(Color primary, Color secondary) {
    final base = GoogleFonts.interTextTheme();
    return base.copyWith(
      displayLarge: base.displayLarge?.copyWith(color: primary),
      displayMedium: base.displayMedium?.copyWith(color: primary),
      displaySmall: base.displaySmall?.copyWith(color: primary),
      headlineLarge: base.headlineLarge?.copyWith(color: primary),
      headlineMedium: base.headlineMedium?.copyWith(color: primary),
      headlineSmall: base.headlineSmall?.copyWith(color: primary),
      titleLarge: base.titleLarge?.copyWith(
        color: primary, fontWeight: FontWeight.w600,
      ),
      titleMedium: base.titleMedium?.copyWith(
        color: primary, fontWeight: FontWeight.w600,
      ),
      titleSmall: base.titleSmall?.copyWith(
        color: primary, fontWeight: FontWeight.w500,
      ),
      bodyLarge: base.bodyLarge?.copyWith(color: primary),
      bodyMedium: base.bodyMedium?.copyWith(color: primary),
      bodySmall: base.bodySmall?.copyWith(color: secondary),
      labelLarge: base.labelLarge?.copyWith(
        color: primary, fontWeight: FontWeight.w600,
      ),
      labelMedium: base.labelMedium?.copyWith(color: secondary),
      labelSmall: base.labelSmall?.copyWith(color: secondary),
    );
  }

  // ---------------------------------------------------------------------------
  // Widget theme helpers
  // ---------------------------------------------------------------------------
  static CardThemeData _cardTheme(Color surface) => CardThemeData(
    color: surface,
    elevation: 0,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
  );

  static AppBarTheme _appBarTheme(Color bg, Color fg) => AppBarTheme(
    backgroundColor: bg,
    foregroundColor: fg,
    elevation: 0,
    centerTitle: true,
    scrolledUnderElevation: 0,
  );

  static ElevatedButtonThemeData _elevatedButtonTheme() =>
      ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: sandGold,
          foregroundColor: midnightBlue,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontWeight: FontWeight.w600, fontSize: 15,
          ),
        ),
      );

  static OutlinedButtonThemeData _outlinedButtonTheme(Color fg) =>
      OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: fg,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          side: BorderSide(color: fg.withValues(alpha: 0.4)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );

  static TextButtonThemeData _textButtonTheme(Color fg) => TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: fg,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
  );

  static FloatingActionButtonThemeData _fabTheme() =>
      FloatingActionButtonThemeData(
        backgroundColor: starYellow,
        foregroundColor: midnightBlue,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      );

  static InputDecorationTheme _inputTheme(
    Color fill, Color border, Color text,
  ) => InputDecorationTheme(
    filled: true,
    fillColor: fill,
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide.none,
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: border.withValues(alpha: 0.2)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: sandGold, width: 1.5),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: errorCoral),
    ),
    hintStyle: TextStyle(color: text.withValues(alpha: 0.4)),
  );

  static BottomNavigationBarThemeData _bottomNavTheme(
    Color bg, Color unselected, Color selected,
  ) => BottomNavigationBarThemeData(
    backgroundColor: bg,
    selectedItemColor: selected,
    unselectedItemColor: unselected.withValues(alpha: 0.6),
    type: BottomNavigationBarType.fixed,
    elevation: 0,
    showUnselectedLabels: true,
  );

  static DialogThemeData _dialogTheme(Color bg, Color fg) => DialogThemeData(
    backgroundColor: bg,
    titleTextStyle: TextStyle(
      color: fg, fontSize: 20, fontWeight: FontWeight.w600,
    ),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
  );

  static SnackBarThemeData _snackBarTheme(Color bg, Color fg) =>
      SnackBarThemeData(
        backgroundColor: bg,
        contentTextStyle: TextStyle(color: fg, fontSize: 14),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      );

  static BottomSheetThemeData _bottomSheetTheme(Color bg) =>
      BottomSheetThemeData(
        backgroundColor: bg,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        showDragHandle: true,
      );

  static ChipThemeData _chipTheme(Color bg, Color fg) => ChipThemeData(
    backgroundColor: bg,
    labelStyle: TextStyle(color: fg, fontSize: 13),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    side: BorderSide.none,
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
  );

  static SwitchThemeData _switchTheme(Color active, Color inactive) =>
      SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return active;
          return inactive;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return active.withValues(alpha: 0.4);
          }
          return inactive.withValues(alpha: 0.2);
        }),
      );

  static ProgressIndicatorThemeData _progressTheme(Color fg, Color bg) =>
      ProgressIndicatorThemeData(color: fg, linearTrackColor: bg);

  static DividerThemeData _dividerTheme(Color color) => DividerThemeData(
    color: color, thickness: 0.5, space: 1,
  );
}
