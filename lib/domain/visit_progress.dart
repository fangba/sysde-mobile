/// Avancement d'une activite : liste de presence, puis controle, puis rapport.
/// Chaque etape n'est accessible qu'une fois la precedente terminee. Une
/// rencontre sans controle (groupe de vulgarisation) n'a que presence et rapport.
class VisitProgress {
  const VisitProgress({
    this.attendance = false,
    this.control = false,
    this.report = false,
    this.hasControl = true,
  });

  final bool attendance;
  final bool control;
  final bool report;

  /// Faux quand l'activite n'a pas d'etape de controle.
  final bool hasControl;

  /// Le controle s'ouvre quand la liste de presence est faite.
  bool get controlUnlocked => attendance;

  /// Le rapport s'ouvre quand le controle (s'il existe) est fait.
  bool get reportUnlocked => attendance && (!hasControl || control);

  int get total => hasControl ? 3 : 2;

  int get doneCount =>
      [attendance, if (hasControl) control, report].where((d) => d).length;
}
