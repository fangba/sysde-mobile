import 'activity.dart';
import 'text_search.dart';

/// Les activites d'un meme sujet (plantation pour une visite, saigneur pour
/// une formation, groupe pour une rencontre), avec leur avancement.
class SubjectGroup {
  const SubjectGroup({
    required this.name,
    required this.section,
    required this.village,
    required this.visits,
  });

  final String name;
  final String section;
  final String village;

  /// Visites de la plus ancienne a la plus recente.
  final List<Activity> visits;

  int get total => visits.length;
  int get done => visits.where((v) => v.status == ActivityStatus.done).length;

  /// Part (0 a 1) des visites effectuees.
  double get rate => total == 0 ? 0 : done / total;
}

/// Regroupe les activites par sujet (ordre alphabetique). `section` garde
/// une seule section (null = toutes) ; `query` garde les plantations dont le
/// nom du sujet contient le texte, sans tenir compte de la casse ni des accents. Les
/// activites sans sujet sont ignorees.
List<SubjectGroup> groupBySubject(
  Iterable<Activity> visits, {
  String? section,
  String query = '',
}) {
  final needle = normalizeForSearch(query);
  final byName = <String, List<Activity>>{};
  for (final v in visits) {
    final name = v.subjectName;
    if (name == null) continue;
    if (section != null && v.section != section) continue;
    if (needle.isNotEmpty && !normalizeForSearch(name).contains(needle)) continue;
    byName.putIfAbsent(name, () => []).add(v);
  }
  final names = byName.keys.toList()..sort();
  return [
    for (final name in names)
      SubjectGroup(
        name: name,
        section: byName[name]!.first.section ?? '',
        village: byName[name]!.first.village ?? '',
        visits: [...byName[name]!]..sort((a, b) {
            final byRank = (a.rank ?? 0).compareTo(b.rank ?? 0);
            return byRank != 0 ? byRank : a.date.compareTo(b.date);
          }),
      ),
  ];
}

/// Valeurs distinctes triees (pour les listes de filtre).
List<String> distinctValues(Iterable<String?> values) =>
    {for (final v in values) if (v != null && v.isNotEmpty) v}.toList()..sort();
