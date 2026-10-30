import 'package:flutter_test/flutter_test.dart';
import 'package:sysde_mobile/domain/control.dart';

void main() {
  const none = ParticipantControl();

  test('presence non renseignee : ni terminee ni notee', () {
    expect(none.isComplete, isFalse);
    expect(none.ratedCount, 0);
  });

  test('un absent est termine sans notes', () {
    final c = none.withAttendance(Attendance.absent);
    expect(c.isComplete, isTrue);
  });

  test('un present est termine quand les cinq criteres sont notes', () {
    var c = none.withAttendance(Attendance.present);
    for (final k in Criterion.values.take(4)) {
      c = c.withRating(k, Rating.good);
    }
    expect(c.isComplete, isFalse);
    c = c.withRating(Criterion.values.last, Rating.poor);
    expect(c.isComplete, isTrue);
  });

  test('passer a absent efface les notes', () {
    final c = none
        .withAttendance(Attendance.present)
        .withRating(Criterion.slope, Rating.average)
        .withAttendance(Attendance.absent);
    expect(c.ratings, isEmpty);
  });

  test('modifier une note remplace la precedente', () {
    final c = none
        .withAttendance(Attendance.present)
        .withRating(Criterion.depth, Rating.good)
        .withRating(Criterion.depth, Rating.poor);
    expect(c.ratings[Criterion.depth], Rating.poor);
    expect(c.ratedCount, 1);
  });

  test('resume : presents, absents, a renseigner', () {
    final s = summarizeControl([
      none.withAttendance(Attendance.present),
      none.withAttendance(Attendance.absent),
      none,
      none,
    ]);
    expect((s.present, s.absent, s.pending), (1, 1, 2));
  });
}
