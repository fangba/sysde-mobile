import 'package:flutter_test/flutter_test.dart';
import 'package:sysde_mobile/core/format.dart';

void main() {
  test('date complete avec majuscule', () {
    expect(formatFullDate(DateTime(2026, 10, 29)), 'Jeudi 29 octobre 2026');
  });

  group('derniere synchro', () {
    final now = DateTime(2026, 10, 29, 9, 5);

    test('jamais', () => expect(formatLastSync(null, now), 'jamais synchronisé'));

    test('aujourd\'hui : heure sur deux chiffres', () {
      expect(formatLastSync(DateTime(2026, 10, 29, 8, 7), now), 'dernière synchro 08:07');
    });

    test('hier', () {
      expect(formatLastSync(DateTime(2026, 10, 28, 17, 42), now), 'dernière synchro hier 17:42');
    });

    test('plus ancien : jour et heure', () {
      expect(
        formatLastSync(DateTime(2026, 10, 27, 17, 42), now),
        'dernière synchro le 27 octobre à 17:42',
      );
    });

    test('hier tard le soir reste « hier » apres minuit', () {
      expect(
        formatLastSync(DateTime(2026, 10, 28, 23, 59), DateTime(2026, 10, 29, 0, 1)),
        'dernière synchro hier 23:59',
      );
    });
  });
}
