import 'activity.dart';
import 'report_rules.dart';

enum AttentionKind { late, today }

/// Tache du jour : en retard, ou prevue aujourd'hui (toutes categories).
class AttentionItem {
  const AttentionItem({required this.activity, required this.kind});

  final Activity activity;
  final AttentionKind kind;
}

/// Taches du jour : d'abord les retards (du plus ancien au plus recent), puis
/// les activites prevues aujourd'hui. Une activite deja effectuee n'y figure
/// pas. Les anomalies a verifier n'en font pas partie.
List<AttentionItem> attentionItems(List<Activity> activities, DateTime today) {
  final day = DateTime(today.year, today.month, today.day);
  final pending = [
    for (final a in activities)
      if (a.status != ActivityStatus.done) a,
  ];

  final late = [
    for (final a in pending)
      if (isLate(done: false, plannedOn: a.date, today: day)) a,
  ]..sort((a, b) => a.date.compareTo(b.date));

  final dueToday = [
    for (final a in pending)
      if (DateTime(a.date.year, a.date.month, a.date.day) == day) a,
  ]..sort((a, b) => a.id.compareTo(b.id));

  return [
    for (final a in late) AttentionItem(activity: a, kind: AttentionKind.late),
    for (final a in dueToday) AttentionItem(activity: a, kind: AttentionKind.today),
  ];
}
