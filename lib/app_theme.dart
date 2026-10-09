import 'package:flutter/material.dart';

/// Paleta cálida: terracota, mostaza, crema y marrón.
const Color kTerracotta = Color(0xFFC2673A);
const Color kMustard = Color(0xFFE2A546);
const Color kCream = Color(0xFFFBF5EC);
const Color kSand = Color(0xFFF4E8D6);
const Color kBrown = Color(0xFF3B2A20);
const Color kOutline = Color(0xFFE0CDB5);

/// Iconos oscuros, casi negros.
const Color kIconBlack = Color(0xFF1A1714);

ThemeData buildAppTheme() {
  final colorScheme = ColorScheme.fromSeed(
    seedColor: kTerracotta,
    brightness: Brightness.light,
  ).copyWith(
    primary: kTerracotta,
    onPrimary: Colors.white,
    secondary: kMustard,
    onSecondary: kIconBlack,
    primaryContainer: const Color(0xFFF6D5BF),
    onPrimaryContainer: kBrown,
    secondaryContainer: const Color(0xFFF7E3B5),
    onSecondaryContainer: kBrown,
    surface: kCream,
    onSurface: kBrown,
    onSurfaceVariant: const Color(0xFF3D2E24),
    outline: const Color(0xFF9C8470),
    outlineVariant: kOutline,
    error: const Color(0xFFB3261E),
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: colorScheme,
    scaffoldBackgroundColor: kCream,
    iconTheme: const IconThemeData(color: kIconBlack),
    iconButtonTheme: IconButtonThemeData(
      style: IconButton.styleFrom(foregroundColor: kIconBlack),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: kCream,
      foregroundColor: kBrown,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(
        color: kBrown,
        fontSize: 22,
        fontWeight: FontWeight.w700,
      ),
      iconTheme: IconThemeData(color: kIconBlack),
      actionsIconTheme: IconThemeData(color: kIconBlack),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: kSand,
      selectedItemColor: kIconBlack,
      unselectedItemColor: Color(0xFF5A4A3F),
      selectedLabelStyle: TextStyle(fontWeight: FontWeight.w700),
      type: BottomNavigationBarType.fixed,
      showUnselectedLabels: true,
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: kMustard,
      foregroundColor: kIconBlack,
      extendedIconLabelSpacing: 8,
    ),
    cardTheme: const CardThemeData(
      color: Colors.white,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(16)),
        side: BorderSide(color: kOutline),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: kOutline),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: kOutline),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: kTerracotta, width: 2),
      ),
    ),
    segmentedButtonTheme: SegmentedButtonThemeData(
      style: SegmentedButton.styleFrom(
        selectedBackgroundColor: kMustard,
        selectedForegroundColor: kIconBlack,
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: kTerracotta,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: kBrown,
        side: const BorderSide(color: kTerracotta),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
  );
}
