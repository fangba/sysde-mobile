import 'package:flutter_test/flutter_test.dart';
import 'package:sysde_mobile/domain/activity.dart';
import 'package:sysde_mobile/domain/attention.dart';

Activity _a(
  String id,
  DateTime date,
  ActivityStatus status, {
  ActivityCategory category = ActivityCategory.visit,
  String? anomaly,
}) {
  return Activity(
    id: id,
    category: category,
    title: 'Activite $id',
    place: 'Lot 2 · Plantation $id',
    date: date,
    status: status,
    anomaly: anomaly,
  );
}

void main() {
  final today = DateTime(2026, 10, 27);

  test('retards du plus ancien au plus recent, puis taches du jour', () {
    final items = attentionItems([
      _a('1', DateTime(2026, 10, 26), ActivityStatus.todo),
      _a('2', DateTime(2026, 10, 23), ActivityStatus.todo),
      _a('4', DateTime(2026, 10, 27), ActivityStatus.todo),
    ], today);

    expect(items.map((i) => i.activity.id), ['2', '1', '4']);
    expect(items.map((i) => i.kind), [
      AttentionKind.late,
      AttentionKind.late,
      AttentionKind.today,
    ]);
  });

  test('toutes categories confondues', () {
    final items = attentionItems([
      _a('v', today, ActivityStatus.todo),
      _a('f', today, ActivityStatus.inProgress, category: ActivityCategory.training),
      _a('r', DateTime(2026, 10, 20), ActivityStatus.todo, category: ActivityCategory.meeting),
    ], today);
    expect(items.map((i) => i.activity.id), ['r', 'f', 'v']);
  });

  test('une activite effectuee n apparait pas, meme prevue aujourd hui', () {
    expect(
      attentionItems([
        _a('1', today, ActivityStatus.done),
        _a('2', DateTime(2026, 10, 20), ActivityStatus.done),
      ], today),
      isEmpty,
    );
  });

  test('les anomalies et les activites a venir n en font pas partie', () {
    expect(
      attentionItems([
        _a('1', DateTime(2026, 10, 22), ActivityStatus.done, anomaly: 'Position hors secteur'),
        _a('2', DateTime(2026, 10, 28), ActivityStatus.todo),
      ], today),
      isEmpty,
    );
  });

  test('l heure de la date du jour est ignoree', () {
    final items = attentionItems([_a('1', DateTime(2026, 10, 27), ActivityStatus.todo)],
        DateTime(2026, 10, 27, 15, 30));
    expect(items.single.kind, AttentionKind.today);
  });
}
