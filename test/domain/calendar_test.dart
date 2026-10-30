import 'package:flutter_test/flutter_test.dart';
import 'package:sysde_mobile/domain/activity.dart';
import 'package:sysde_mobile/domain/calendar.dart';

Activity _a(String id, DateTime date, ActivityCategory category) => Activity(
      id: id,
      category: category,
      title: 't',
      place: 'p',
      date: date,
      status: ActivityStatus.todo,
    );

void main() {
  test('octobre 2026 : lundi en premier, jours du mois precedent avant le 1er', () {
    final cells = monthCells(DateTime(2026, 10));
    expect(cells.length, 35);
    expect(cells.length % 7, 0);
    // Le 1er octobre 2026 est un jeudi : 28, 29 et 30 septembre avant.
    expect(cells.take(3), [
      DateTime(2026, 9, 28),
      DateTime(2026, 9, 29),
      DateTime(2026, 9, 30),
    ]);
    expect(cells[3], DateTime(2026, 10, 1));
    expect(cells[33], DateTime(2026, 10, 31));
    // Case vide apres le 31.
    expect(cells.last, isNull);
  });

  test('mois commencant un lundi : aucune case avant', () {
    // Juin 2026 commence un lundi.
    final cells = monthCells(DateTime(2026, 6));
    expect(cells.first, DateTime(2026, 6, 1));
  });

  test('categories du jour : une fois chacune, ordre visite/formation/rencontre', () {
    final day = DateTime(2026, 10, 6);
    final cats = categoriesOnDay([
      _a('1', day, ActivityCategory.meeting),
      _a('2', day, ActivityCategory.visit),
      _a('3', day, ActivityCategory.visit),
      _a('4', DateTime(2026, 10, 7), ActivityCategory.training),
    ], day);
    expect(cats, [ActivityCategory.visit, ActivityCategory.meeting]);
  });
}
