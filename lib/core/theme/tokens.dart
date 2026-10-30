import 'package:flutter/material.dart';

/// Jetons de design SysDE, alignes sur `src/styles/_tokens.scss` du web.
/// Aucune couleur en dur dans les widgets : tout passe par ces jetons.
@immutable
class SysdeTokens extends ThemeExtension<SysdeTokens> {
  const SysdeTokens({
    required this.line,
    required this.inkMuted,
    required this.brandSoft,
    required this.deep,
    required this.actionFrom,
    required this.warnBg,
    required this.warnFg,
    required this.okBg,
    required this.okFg,
    required this.neutralBg,
    required this.neutralFg,
    required this.dangerBg,
    required this.dangerFg,
    required this.visit,
    required this.training,
    required this.meeting,
  });

  final Color line;
  final Color inkMuted;
  final Color brandSoft;
  final Color deep;
  final Color actionFrom;
  final Color warnBg;
  final Color warnFg;
  final Color okBg;
  final Color okFg;
  final Color neutralBg;
  final Color neutralFg;
  final Color dangerBg;
  final Color dangerFg;
  // Couleurs de donnees (categories). Le violet reste reserve aux donnees.
  final Color visit;
  final Color training;
  final Color meeting;

  static const light = SysdeTokens(
    line: Color(0xFFE6ECE8),
    inkMuted: Color(0xFF5B6B62),
    brandSoft: Color(0xFFF1FAF4),
    deep: Color(0xFF0F3D28),
    actionFrom: Color(0xFF138553),
    warnBg: Color(0xFFFDF1D6),
    warnFg: Color(0xFF8A5D06),
    okBg: Color(0xFFDFF3E6),
    okFg: Color(0xFF14532D),
    neutralBg: Color(0xFFEEF2EF),
    neutralFg: Color(0xFF3D4C44),
    dangerBg: Color(0xFFFDE8E8),
    dangerFg: Color(0xFFB42318),
    visit: Color(0xFF0C7A48),
    training: Color(0xFF34C38F),
    meeting: Color(0xFF6D4FD1),
  );

  @override
  SysdeTokens copyWith({
    Color? line,
    Color? inkMuted,
    Color? brandSoft,
    Color? deep,
    Color? actionFrom,
    Color? warnBg,
    Color? warnFg,
    Color? okBg,
    Color? okFg,
    Color? neutralBg,
    Color? neutralFg,
    Color? dangerBg,
    Color? dangerFg,
    Color? visit,
    Color? training,
    Color? meeting,
  }) {
    return SysdeTokens(
      line: line ?? this.line,
      inkMuted: inkMuted ?? this.inkMuted,
      brandSoft: brandSoft ?? this.brandSoft,
      deep: deep ?? this.deep,
      actionFrom: actionFrom ?? this.actionFrom,
      warnBg: warnBg ?? this.warnBg,
      warnFg: warnFg ?? this.warnFg,
      okBg: okBg ?? this.okBg,
      okFg: okFg ?? this.okFg,
      neutralBg: neutralBg ?? this.neutralBg,
      neutralFg: neutralFg ?? this.neutralFg,
      dangerBg: dangerBg ?? this.dangerBg,
      dangerFg: dangerFg ?? this.dangerFg,
      visit: visit ?? this.visit,
      training: training ?? this.training,
      meeting: meeting ?? this.meeting,
    );
  }

  @override
  SysdeTokens lerp(ThemeExtension<SysdeTokens>? other, double t) {
    if (other is! SysdeTokens) return this;
    Color mix(Color a, Color b) => Color.lerp(a, b, t) ?? a;
    return SysdeTokens(
      line: mix(line, other.line),
      inkMuted: mix(inkMuted, other.inkMuted),
      brandSoft: mix(brandSoft, other.brandSoft),
      deep: mix(deep, other.deep),
      actionFrom: mix(actionFrom, other.actionFrom),
      warnBg: mix(warnBg, other.warnBg),
      warnFg: mix(warnFg, other.warnFg),
      okBg: mix(okBg, other.okBg),
      okFg: mix(okFg, other.okFg),
      neutralBg: mix(neutralBg, other.neutralBg),
      neutralFg: mix(neutralFg, other.neutralFg),
      dangerBg: mix(dangerBg, other.dangerBg),
      dangerFg: mix(dangerFg, other.dangerFg),
      visit: mix(visit, other.visit),
      training: mix(training, other.training),
      meeting: mix(meeting, other.meeting),
    );
  }
}

extension SysdeThemeContext on BuildContext {
  SysdeTokens get tokens =>
      Theme.of(this).extension<SysdeTokens>() ?? SysdeTokens.light;
  ColorScheme get scheme => Theme.of(this).colorScheme;
  TextTheme get text => Theme.of(this).textTheme;
}
