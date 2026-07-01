import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class KineticNoirTheme {
  // 1. Color Palette Definitions
  static const _primary = Color(0xFFFFC081);
  static const _primaryContainer = Color(0xFFFF9800);
  static const _surface = Color(0xFF131313); // The Foundation
  static const _tertiaryContainer = Color(0xFF00BEFD);
  
  // Tonal Layering (Level 0 - Level 2)
  static const _surfaceLowest = Color(0xFF0A0A0A); 
  static const _surfaceLow = Color(0xFF161616);
  static const _surfaceMedium = Color(0xFF1C1C1C);
  static const _surfaceHigh = Color(0xFF242424);
  static const _surfaceHighest = Color(0xFF2C2C2C);

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: _colorScheme,
      textTheme: _textTheme,
      scaffoldBackgroundColor: _surfaceLow, // Level 1: Main Canvas
      
      // 2. Component Themes
      cardTheme: _cardTheme,
      elevatedButtonTheme: _buttonTheme,
      inputDecorationTheme: _inputTheme,
      dividerTheme: const DividerThemeData(thickness: 0, color: Colors.transparent), // "No-Line" Rule
      
      // Custom Extensions for "The Kinetic Noir" specific logic
      extensions: [
        KineticEffects(
          frostedObsidian: const Color(0x992C2C2C), // 60% opacity surfaceHighest
          primaryGlow: _primary.withOpacity(0.06),
          ghostBorder: Colors.white.withOpacity(0.15),
        ),
      ],
    );
  }

  static const _colorScheme = ColorScheme.dark(
    primary: _primary,
    primaryContainer: _primaryContainer,
    onPrimary: _surface,
    surface: _surface,
    surfaceContainerLowest: _surfaceLowest,
    surfaceContainerLow: _surfaceLow,
    surfaceContainer: _surfaceMedium,
    surfaceContainerHigh: _surfaceHigh,
    surfaceContainerHighest: _surfaceHighest,
    tertiaryContainer: _tertiaryContainer,
    outlineVariant: Color(0x26FFFFFF), // 15% White for Ghost Borders
  );

  static final _textTheme = TextTheme(
    displayLarge: GoogleFonts.manrope(
      fontSize: 30,
      fontWeight: FontWeight.w800,
      letterSpacing: -1.0,
      height: 1.2,
    ),
    headlineMedium: GoogleFonts.manrope(
      fontSize: 16,
      fontWeight: FontWeight.w700,
      color: Colors.white,
    ),
    bodyMedium: GoogleFonts.inter(
      fontSize: 10,
      fontWeight: FontWeight.w400,
      height: 1.6, // Generous line height for "The Editorial Moment"
      color: Colors.white.withOpacity(0.9),
    ),
    labelMedium: GoogleFonts.inter(
      fontSize: 7,
      fontWeight: FontWeight.w500,
      color: Colors.white.withOpacity(0.6), // Subservient metadata
    ),
  );

  static final _cardTheme = CardThemeData(
    color: _surfaceMedium, // Level 2
    elevation: 0,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    margin: const EdgeInsets.symmetric(vertical: 8),
  );

  static final _buttonTheme = ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: _primaryContainer,
      foregroundColor: _surface,
      textStyle: TextStyle(fontSize:14),
      elevation: 0,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)), // lg (0.5rem)
    ),
  );

  static final _inputTheme = InputDecorationTheme(
    filled: true,
    fillColor: _surfaceHighest,
    hintStyle: GoogleFonts.inter(color: Colors.white30),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide(color: Colors.white.withOpacity(0.15)), // Ghost Border
    ),
    focusedBorder: const UnderlineInputBorder(
      borderSide: BorderSide(color: _primary, width: 2), // 2px Primary Bottom Edge
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide(color: Colors.white.withOpacity(0.15)),
    ),
  );
}

// 3. Theme Extension for Non-Standard Kinetic Elements
class KineticEffects extends ThemeExtension<KineticEffects> {
  final Color? frostedObsidian;
  final Color? primaryGlow;
  final Color? ghostBorder;

  KineticEffects({this.frostedObsidian, this.primaryGlow, this.ghostBorder});

  @override
  ThemeExtension<KineticEffects> copyWith({Color? f, Color? g, Color? b}) => 
    KineticEffects(frostedObsidian: f ?? frostedObsidian, primaryGlow: g ?? primaryGlow, ghostBorder: b ?? ghostBorder);

  @override
  ThemeExtension<KineticEffects> lerp(ThemeExtension<KineticEffects>? other, double t) {
    if (other is! KineticEffects) return this;
    return KineticEffects(
      frostedObsidian: Color.lerp(frostedObsidian, other.frostedObsidian, t),
      primaryGlow: Color.lerp(primaryGlow, other.primaryGlow, t),
      ghostBorder: Color.lerp(ghostBorder, other.ghostBorder, t),
    );
  }
}