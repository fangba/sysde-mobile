import 'package:flutter_test/flutter_test.dart';
import 'package:sysde_mobile/domain/pagination.dart';
import 'package:sysde_mobile/domain/text_search.dart';

void main() {
  final items = List.generate(12, (i) => i);

  test('decoupe en pages', () {
    final p0 = paginate(items, page: 0, pageSize: 5);
    expect(p0.items, [0, 1, 2, 3, 4]);
    expect(p0.pageCount, 3);
    expect(p0.total, 12);
    expect(p0.hasPrevious, isFalse);
    expect(p0.hasNext, isTrue);

    final last = paginate(items, page: 2, pageSize: 5);
    expect(last.items, [10, 11]);
    expect(last.hasNext, isFalse);
    expect(last.hasPrevious, isTrue);
  });

  test('numero hors limites ramene dans la plage', () {
    expect(paginate(items, page: 99, pageSize: 5).page, 2);
    expect(paginate(items, page: -3, pageSize: 5).page, 0);
  });

  test('liste vide : une page vide', () {
    final p = paginate(<int>[], page: 0, pageSize: 5);
    expect(p.items, isEmpty);
    expect(p.pageCount, 1);
    expect(p.hasNext, isFalse);
  });

  test('taille exacte : pas de page en trop', () {
    expect(paginate(items, page: 0, pageSize: 12).pageCount, 1);
  });

  test('normalizeForSearch retire casse et accents', () {
    expect(normalizeForSearch('  Traoré Issa '), 'traore issa');
    expect(normalizeForSearch('ÉLÈVE'), 'eleve');
  });
}
