import 'package:flutter_test/flutter_test.dart';
import 'package:sysde_mobile/domain/activity.dart';

void main() {
  test('parts en attente et terminees', () {
    const stats = CategoryStats(pending: 3, done: 9);
    expect(stats.total, 12);
    expect(stats.pendingShare, 0.25);
    expect(stats.doneShare, 0.75);
  });

  test('categorie vide : 0 % partout', () {
    const stats = CategoryStats(pending: 0, done: 0);
    expect(stats.pendingShare, 0);
    expect(stats.doneShare, 0);
  });
}
