import 'meeting_type.dart';
import 'training_type.dart';
import 'visit_type.dart';

enum ActivityCategory { visit, training, meeting }

enum ActivityStatus { todo, inProgress, done }

/// Une activite du planning : une periode, une activite, un lieu
/// (lot/section, plantation pour une visite). Pas d'heures.
class Activity {
  const Activity({
    required this.id,
    required this.category,
    required this.title,
    required this.place,
    required this.date,
    required this.status,
    this.anomaly,
    this.trainingType,
    this.visitType,
    this.meetingType,
    this.section,
    this.village,
    this.subjectName,
    this.rank,
    this.endDate,
  });

  final String id;
  final ActivityCategory category;
  final String title;
  final String place;
  final DateTime date;
  final ActivityStatus status;

  /// Motif d'anomalie releve (ex. position hors secteur), sinon null.
  final String? anomaly;

  /// Type de formation ; null hors formation.
  final TrainingType? trainingType;

  /// Type de visite ; null hors visite.
  final VisitType? visitType;

  /// Type de rencontre ; null hors rencontre.
  final MeetingType? meetingType;

  /// Section, village, sujet (plantation pour une visite, saigneur pour une
  /// formation, groupe pour une rencontre), rang de l'activite pour ce sujet
  /// (1re visite, session 2...) et date de fin de la periode. Null sinon.
  final String? section;
  final String? village;
  final String? subjectName;
  final int? rank;
  final DateTime? endDate;

  /// Derniere journee a afficher. Regle metier : une visite de plantation se
  /// fait en 1 jour, donc pas de date de fin ; formation et rencontre
  /// peuvent s'etendre sur plusieurs jours.
  DateTime? get lastDay => category == ActivityCategory.visit ? null : endDate;
}

class MonthSummary {
  const MonthSummary({required this.planned, required this.done});

  final int planned;
  final int done;
}

/// Activites d'une categorie sur le mois : en attente et terminees.
class CategoryStats {
  const CategoryStats({required this.pending, required this.done});

  final int pending;
  final int done;

  int get total => pending + done;

  /// Part (0 a 1) des activites en attente. 0 si la categorie est vide.
  double get pendingShare => total == 0 ? 0 : pending / total;

  /// Part (0 a 1) des activites terminees. 0 si la categorie est vide.
  double get doneShare => total == 0 ? 0 : done / total;
}
