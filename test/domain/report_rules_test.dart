import 'package:flutter_test/flutter_test.dart';
import 'package:sysde_mobile/domain/report_rules.dart';

void main() {
  group('completionRate', () {
    test('realisees / prevues', () {
      expect(completionRate(14, 18), closeTo(0.7778, 0.0001));
    });
    test('0 si rien de prevu', () {
      expect(completionRate(0, 0), 0);
    });
  });

  group('reportStatusOf', () {
    test('90 % et plus : a jour', () {
      expect(reportStatusOf(0.9), ReportStatus.upToDate);
    });
    test('de 75 % a moins de 90 % : leger retard', () {
      expect(reportStatusOf(0.75), ReportStatus.slightDelay);
      expect(reportStatusOf(0.8999), ReportStatus.slightDelay);
    });
    test('moins de 75 % : en retard', () {
      expect(reportStatusOf(0.7499), ReportStatus.late);
    });
  });

  group('isLate', () {
    final today = DateTime(2026, 10, 27, 15, 30);
    test('prevue hier et non realisee : en retard', () {
      expect(isLate(done: false, plannedOn: DateTime(2026, 10, 26), today: today), isTrue);
    });
    test("prevue aujourd'hui : pas en retard", () {
      expect(isLate(done: false, plannedOn: DateTime(2026, 10, 27), today: today), isFalse);
    });
    test('realisee : jamais en retard', () {
      expect(isLate(done: true, plannedOn: DateTime(2026, 10, 1), today: today), isFalse);
    });
  });
}
