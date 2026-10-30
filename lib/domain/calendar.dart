import 'activity.dart';
import 'report_rules.dart';

/// Cases d'un mois, lundi en premier. Les cases avant le 1er sont les derniers
/// jours du mois precedent ; apres le dernier jour, des cases vides (null)
/// completent la derniere semaine. La longueur est un multiple de 7.
List<DateTime?> monthCells(DateTime month) {
  final first = DateTime(month.year, month.month, 1);
  final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
  final lead = first.weekday - 1;
  final cells = <DateTime?>[
    for (var i = lead; i > 0; i--) DateTime(month.year, month.month, 1 - i),
    for (var d = 1; d <= daysInMonth; d++) DateTime(month.year, month.month, d),
  ];
  while (cells.length % 7 != 0) {
    cells.add(null);
  }
  return cells;
}

/// Categories presentes un jour donne, dans l'ordre visite, formation,
/// rencontre (une seule fois chacune).
List<ActivityCategory> categoriesOnDay(Iterable<Activity> activities, DateTime day) {
  final present = {
    for (final a in activities)
      if (isSameDay(a.date, day)) a.category,
  };
  return [
    for (final c in ActivityCategory.values)
      if (present.contains(c)) c,
  ];
}
