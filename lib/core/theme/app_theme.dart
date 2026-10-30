import 'package:flutter/material.dart';

import 'tokens.dart';

const _brand = Color(0xFF0C7A48);
const _canvas = Color(0xFFF4F7F5);
const _ink = Color(0xFF0E1A14);

/// Police : Montserrat, embarquee (polices variables dans `assets/fonts/`,
/// declarees dans pubspec.yaml, voir README).
ThemeData buildLightTheme() {
  final scheme = ColorScheme.fromSeed(seedColor: _brand).copyWith(
    primary: _brand,
    onPrimary: Colors.white,
    surface: Colors.white,
    onSurface: _ink,
    onSurfaceVariant: SysdeTokens.light.inkMuted,
    outlineVariant: SysdeTokens.light.line,
    error: SysdeTokens.light.dangerFg,
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    fontFamily: 'Montserrat',
    scaffoldBackgroundColor: _canvas,
    extensions: const [SysdeTokens.light],
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size.fromHeight(54),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: Colors.white,
      indicatorColor: SysdeTokens.light.okBg,
      height: 72,
    ),
    navigationRailTheme: NavigationRailThemeData(
      backgroundColor: SysdeTokens.light.deep,
      indicatorColor: _brand,
      selectedIconTheme: const IconThemeData(color: Colors.white),
      unselectedIconTheme: const IconThemeData(color: Color(0xFFC9F0D8)),
      selectedLabelTextStyle: const TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.w700,
        fontSize: 12,
      ),
      unselectedLabelTextStyle: const TextStyle(
        color: Color(0xFFC9F0D8),
        fontWeight: FontWeight.w600,
        fontSize: 12,
      ),
    ),
  );
}
