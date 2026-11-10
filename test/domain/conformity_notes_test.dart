import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sysde_mobile/domain/control.dart';
import 'package:sysde_mobile/features/planning/control_provider.dart';

void main() {
  test('visite de conformite : notes des visites de plantation passees, par ordre de date', () {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    final notes = c.read(conformityNotesProvider('a8'));
    expect(notes.map((n) => n.rank), [1, 2]);
    expect(notes.first.date.isBefore(notes.last.date), isTrue);
    expect(notes.last.byParticipant['p2']!.ratings[Criterion.depth], Rating.good);
    expect(notes.first.byParticipant['p3']!.attendance, Attendance.absent);
  });

  test('sans historique : aucune note', () {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    expect(c.read(conformityNotesProvider('a5')), isEmpty);
  });

  test('conformite : note globale obligatoire, commentaire obligatoire si non conforme', () {
    var c = const ParticipantControl().withAttendance(Attendance.present);
    for (final k in Criterion.values) {
      c = c.withRating(k, Rating.good);
    }
    expect(c.isConformityComplete, isFalse); // pas de note globale
    c = c.withVerdict(Verdict.compliant);
    expect(c.isConformityComplete, isTrue);
    c = c.withVerdict(Verdict.nonCompliant);
    expect(c.isConformityComplete, isFalse); // commentaire manquant
    c = c.withComment('  ');
    expect(c.isConformityComplete, isFalse);
    c = c.withComment('Entailles trop profondes');
    expect(c.isConformityComplete, isTrue);
    // Un absent efface notes, note globale et commentaire.
    c = c.withAttendance(Attendance.absent);
    expect(c.isConformityComplete, isTrue);
    expect(c.verdict, isNull);
    expect(c.comment, isEmpty);
    expect(c.ratings, isEmpty);
  });
}
