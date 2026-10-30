/// Regles de calcul communes avec le web (voir `sector-report.calculations.ts`).
/// Memes regles, memes cas de test : les resultats doivent etre identiques.
enum ReportStatus { upToDate, slightDelay, late }

/// Taux = realisees / prevues (0 si rien de prevu).
double completionRate(int done, int planned) =>
    planned <= 0 ? 0 : done / planned;

/// A jour >= 90 %, Leger retard >= 75 %, sinon En retard.
ReportStatus reportStatusOf(double rate) {
  if (rate >= 0.9) return ReportStatus.upToDate;
  if (rate >= 0.75) return ReportStatus.slightDelay;
  return ReportStatus.late;
}

/// En retard = non realisee et prevue avant la date du jour (jours calendaires).
bool isLate({
  required bool done,
  required DateTime plannedOn,
  required DateTime today,
}) {
  if (done) return false;
  final planned = DateTime(plannedOn.year, plannedOn.month, plannedOn.day);
  final day = DateTime(today.year, today.month, today.day);
  return planned.isBefore(day);
}

bool isSameDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;
