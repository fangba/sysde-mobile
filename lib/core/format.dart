const _months = [
  'janvier', 'février', 'mars', 'avril', 'mai', 'juin',
  'juillet', 'août', 'septembre', 'octobre', 'novembre', 'décembre',
];

/// "23 octobre"
String formatDay(DateTime d) => '${d.day} ${_months[d.month - 1]}';

const _weekdays = [
  'lundi', 'mardi', 'mercredi', 'jeudi', 'vendredi', 'samedi', 'dimanche',
];

const _monthsShort = [
  'Janv.', 'Févr.', 'Mars', 'Avr.', 'Mai', 'Juin',
  'Juil.', 'Août', 'Sept.', 'Oct.', 'Nov.', 'Déc.',
];

/// "mercredi 26 août 2020"
String formatLongDate(DateTime d) =>
    '${_weekdays[d.weekday - 1]} ${d.day} ${_months[d.month - 1]} ${d.year}';

/// "Août", "Sept." : mois court avec majuscule.
String formatMonthShort(DateTime d) => _monthsShort[d.month - 1];

String _cap(String s) => s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);

/// "Mardi 27 octobre"
String formatDayLong(DateTime d) =>
    _cap('${_weekdays[d.weekday - 1]} ${d.day} ${_months[d.month - 1]}');

/// "Octobre 2026"
String formatMonthYear(DateTime d) => '${_cap(_months[d.month - 1])} ${d.year}';

/// "Jeudi 29 octobre 2026"
String formatFullDate(DateTime d) => _cap(formatLongDate(d));

String _two(int n) => n.toString().padLeft(2, '0');

String _hhmm(DateTime d) => '${_two(d.hour)}:${_two(d.minute)}';

/// Libelle de la derniere synchronisation, relatif a [now] :
/// "dernière synchro 17:42", "… hier 17:42", "… le 27 octobre à 17:42".
String formatLastSync(DateTime? at, DateTime now) {
  if (at == null) return 'jamais synchronisé';
  final day = DateTime(at.year, at.month, at.day);
  final today = DateTime(now.year, now.month, now.day);
  final gap = today.difference(day).inDays;
  if (gap <= 0) return 'dernière synchro ${_hhmm(at)}';
  if (gap == 1) return 'dernière synchro hier ${_hhmm(at)}';
  return 'dernière synchro le ${formatDay(at)} à ${_hhmm(at)}';
}
