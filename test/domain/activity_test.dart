import 'package:flutter_test/flutter_test.dart';
import 'package:sysde_mobile/domain/activity.dart';

Activity _a(ActivityCategory c) => Activity(
      id: 'x',
      category: c,
      title: 't',
      place: 'p',
      date: DateTime(2026, 10, 27),
      status: ActivityStatus.todo,
      endDate: DateTime(2026, 10, 29),
    );

void main() {
  test('une visite se fait en 1 jour : pas de date de fin', () {
    expect(_a(ActivityCategory.visit).lastDay, isNull);
  });

  test('formation et rencontre gardent leur date de fin', () {
    expect(_a(ActivityCategory.training).lastDay, DateTime(2026, 10, 29));
    expect(_a(ActivityCategory.meeting).lastDay, DateTime(2026, 10, 29));
  });
}
