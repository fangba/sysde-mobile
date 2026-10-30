/// Presence d'un participant au controle.
enum Attendance { present, absent }

/// Criteres d'evaluation d'un saigneur ou d'un planteur.
enum Criterion { consumption, depth, slope, wounds, cleanliness }

/// Note d'un critere.
enum Rating { good, average, poor }

/// Presence et notes d'un participant.
class ParticipantControl {
  const ParticipantControl({this.attendance, this.ratings = const {}});

  /// Null tant que la presence n'est pas renseignee.
  final Attendance? attendance;
  final Map<Criterion, Rating> ratings;

  /// Un absent n'est pas evalue : ses notes sont effacees.
  ParticipantControl withAttendance(Attendance a) => ParticipantControl(
        attendance: a,
        ratings: a == Attendance.absent ? const {} : ratings,
      );

  ParticipantControl withRating(Criterion c, Rating r) =>
      ParticipantControl(attendance: attendance, ratings: {...ratings, c: r});

  int get ratedCount => ratings.length;

  /// Termine : absent, ou present avec les cinq criteres notes.
  bool get isComplete => switch (attendance) {
        null => false,
        Attendance.absent => true,
        Attendance.present => ratings.length == Criterion.values.length,
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
