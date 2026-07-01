import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:task_manager/app/theme/dark_theme.dart';

class KineticLightTheme {
  // 1. Color Palette Definitions (The "Ecru Gallery" Palette)
  static const _primary = Color(0xFFFF9800); // More saturated for visibility on light
  static const _primaryContainer = Color(0xFFFFE0B2);
  static const _surface = Color(0xFFF9F9F7); // Warm, "Paper" white foundation
  static const _tertiaryContainer = Color(0xFF0077A6); // Darker blue for light mode contrast
  
  // Tonal Layering (Level 0 - Level 2) - Architectural Greys
  static const _surfaceLowest = Color(0xFFFFFFFF); // Pure White
  static const _surfaceLow = Color(0xFFF4F4F2);   // Main Canvas
  static const _surfaceMedium = Color(0xFFEEEEEC); // Cards
  static const _surfaceHigh = Color(0xFFE4E4E1);   // Nested elements
  static const _surfaceHighest = Color(0xFFDADAD7); // Inputs/Overlays

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: _colorScheme,
      textTheme: _textTheme,
      scaffoldBackgroundColor: _surfaceLow, 
      
      // Component Themes
      cardTheme: _cardTheme,
      elevatedButtonTheme: _buttonTheme,
      inputDecorationTheme: _inputTheme,
      dividerTheme: const DividerThemeData(thickness: 0, color: Colors.transparent), 
      
      extensions: [
        KineticEffects(
          frostedObsidian: const Color(0xCCFFFFFF), // "Arctic Glass" (80% white)
          primaryGlow: _primary.withOpacity(0.08),
          ghostBorder: Colors.black.withOpacity(0.08), // Softer "Ink" border
        ),
      ],
    );
  }

  static const _colorScheme = ColorScheme.light(
    primary: _primary,
    primaryContainer: _primaryContainer,
    onPrimary: Colors.white,
    surface: _surface,
    surfaceContainerLowest: _surfaceLowest,
    surfaceContainerLow: _surfaceLow,
    surfaceContainer: _surfaceMedium,
    surfaceContainerHigh: _surfaceHigh,
    surfaceContainerHighest: _surfaceHighest,
    tertiaryContainer: _tertiaryContainer,
    outlineVariant: Color(0x14000000), // 8% Black for Ghost Borders
  );

  static final _textTheme = TextTheme(
    displayLarge: GoogleFonts.manrope(
      fontSize: 30,
      fontWeight: FontWeight.w800,
      letterSpacing: -1.0,
      height: 1.2,
      color: const Color(0xFF131313), // Deep "Ink" black
    ),
    headlineMedium: GoogleFonts.manrope(
      fontSize: 16,
      fontWeight: FontWeight.w700,
      color: const Color(0xFF131313),
    ),
    bodyMedium: GoogleFonts.inter(
      fontSize: 10,
      fontWeight: FontWeight.w400,
      height: 1.6, 
      color: const Color(0xFF131313).withOpacity(0.8),
    ),
    labelMedium: GoogleFonts.inter(
      fontSize: 7,
      fontWeight: FontWeight.w500,
      color: const Color(0xFF131313).withOpacity(0.5),
    ),
  );

  static final _cardTheme = CardThemeData(
    color: _surfaceLowest, // Level 0 for maximum "Pop" on Level 1 canvas
    elevation: 0,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
      side: BorderSide(color: Colors.black.withOpacity(0.04)), // Subtle definition
    ),
    margin: const EdgeInsets.symmetric(vertical: 8),
  );

  static final _buttonTheme = ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: _primary, // Use the punchier orange for light mode
      foregroundColor: Colors.white,
      textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
      elevation: 0,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    ),
  );

  static final _inputTheme = InputDecorationTheme(
    filled: true,
    fillColor: _surfaceMedium,
    hintStyle: GoogleFonts.inter(color: Colors.black26),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide(color: Colors.black.withOpacity(0.08)),
    ),
    focusedBorder: const UnderlineInputBorder(
      borderSide: BorderSide(color: _primary, width: 2),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide(color: Colors.black.withOpacity(0.08)),
    ),
  );
}