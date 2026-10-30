import 'package:flutter_test/flutter_test.dart';
import 'package:sysde_mobile/domain/activity.dart';
import 'package:sysde_mobile/domain/subject_group.dart';

Activity _v(
  String id,
  String plantation,
  int rank,
  ActivityStatus status, {
  String section = 'Nord',
  String village = 'Siporex',
}) {
  return Activity(
    id: id,
    category: ActivityCategory.visit,
    title: 'Visite de plantation',
    place: 'Lot 2',
    date: DateTime(2026, 10, rank),
    status: status,
    section: section,
    village: village,
    subjectName: plantation,
    rank: rank,
  );
}

void main() {
  final visits = [
    _v('1', 'Zadi', 1, ActivityStatus.todo, section: 'Sud', village: 'Bonoua'),
    _v('2', 'Ahizi', 2, ActivityStatus.todo),
    _v('3', 'Ahizi', 1, ActivityStatus.done),
  ];

  test('regroupe par plantation, ordre alphabetique, visites par rang', () {
    final groups = groupBySubject(visits);
    expect(groups.map((g) => g.name), ['Ahizi', 'Zadi']);
    expect(groups.first.visits.map((v) => v.id), ['3', '2']);
    expect(groups.first.done, 1);
    expect(groups.first.rate, 0.5);
    expect(groups.last.rate, 0);
  });

  test('filtre par section', () {
    expect(groupBySubject(visits, section: 'Sud').map((g) => g.name), ['Zadi']);
    expect(groupBySubject(visits, section: 'Est'), isEmpty);
  });

  test('recherche par nom, sans casse ni accents', () {
    expect(groupBySubject(visits, query: 'ahi').map((g) => g.name), ['Ahizi']);
    expect(groupBySubject(visits, query: '  ZADI ').map((g) => g.name), ['Zadi']);
    expect(groupBySubject(visits, query: 'xyz'), isEmpty);
    expect(
      groupBySubject(visits, section: 'Nord', query: 'zadi'),
      isEmpty,
    );
  });

  test('valeurs distinctes triees', () {
    expect(distinctValues(['Sud', null, 'Nord', 'Sud', '']), ['Nord', 'Sud']);
  });
}
