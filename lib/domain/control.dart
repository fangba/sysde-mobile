/// Presence d'un participant au controle.
enum Attendance { present, absent }

/// Criteres d'evaluation d'un saigneur ou d'un planteur.
enum Criterion { consumption, depth, slope, wounds, cleanliness }

/// Note d'un critere.
enum Rating { good, average, poor }

/// Appreciation globale d'une visite de conformite.
enum Verdict { compliant, nonCompliant }

/// Presence et notes d'un participant. Pour une visite de conformite, s'y
/// ajoutent l'appreciation globale et son commentaire.
class ParticipantControl {
  const ParticipantControl({
    this.attendance,
    this.ratings = const {},
    this.verdict,
    this.comment = '',
  });

  /// Null tant que la presence n'est pas renseignee.
  final Attendance? attendance;
  final Map<Criterion, Rating> ratings;
  final Verdict? verdict;
  final String comment;

  /// Un absent n'est pas evalue : notes, appreciation et commentaire effaces.
  ParticipantControl withAttendance(Attendance a) => a == Attendance.absent
      ? const ParticipantControl(attendance: Attendance.absent)
      : ParticipantControl(
          attendance: a,
          ratings: ratings,
          verdict: verdict,
          comment: comment,
        );

  ParticipantControl withRating(Criterion c, Rating r) => ParticipantControl(
        attendance: attendance,
        ratings: {...ratings, c: r},
        verdict: verdict,
        comment: comment,
      );

  ParticipantControl withVerdict(Verdict v) => ParticipantControl(
        attendance: attendance,
        ratings: ratings,
        verdict: v,
        comment: comment,
      );

  ParticipantControl withComment(String text) => ParticipantControl(
        attendance: attendance,
        ratings: ratings,
        verdict: verdict,
        comment: text,
      );

  int get ratedCount => ratings.length;

  /// Termine : absent, ou present avec les cinq criteres notes.
  bool get isComplete => switch (attendance) {
        null => false,
        Attendance.absent => true,
        Attendance.present => ratings.length == Criterion.values.length,
      };

  /// Conformite terminee : absent, ou present avec cinq criteres notes et une
  /// appreciation globale (commentaire obligatoire si non conforme).
  bool get isConformityComplete => switch (attendance) {
        null => false,
        Attendance.absent => true,
        Attendance.present => ratings.length == Criterion.values.length &&
            verdict != null &&
            (verdict == Verdict.compliant || comment.trim().isNotEmpty),
      };
}

class ControlSummary {
  const ControlSummary({required this.present, required this.absent, required this.pending});

  final int present;
  final int absent;

  /// Presence non renseignee.
  final int pending;
}

ControlSummary summarizeControl(Iterable<ParticipantControl> items) {
  var present = 0, absent = 0, pending = 0;
  for (final c in items) {
    switch (c.attendance) {
      case Attendance.present:
        present++;
      case Attendance.absent:
        absent++;
      case null:
        pending++;
    }
  }
  return ControlSummary(present: present, absent: absent, pending: pending);
}

/// Notes relevees lors d'une visite de plantation passee : sert a la
/// previsualisation faite pendant une visite de conformite.
class VisitNotes {
  const VisitNotes({required this.rank, required this.date, required this.byParticipant});

  /// Rang de la visite pour la plantation (1re, 2e...).
  final int rank;
  final DateTime date;

  /// Presence et notes, par identifiant de participant.
  final Map<String, ParticipantControl> byParticipant;
}
