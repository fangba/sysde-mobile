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
    this.lot,
    this.village,
    this.subjectName,
    this.rank,
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

  /// Lot (au-dessus de la section) : renseigne pour le suivi post
  /// perfectionnement, ou on choisit d'abord le lot puis la section.
  final String? lot;
  final String? subjectName;
  final int? rank;

  /// Duree en jours (regle metier) : formation initiale 20 jours, recyclage
  /// des saigneurs 3 jours ; tout le reste (perfectionnement, suivi, visites,
  /// rencontres) se fait en 1 jour.
  int get durationDays => switch (trainingType) {
        TrainingType.initial => 20,
        TrainingType.recycling => 3,
        _ => 1,
      };

  /// Derniere journee, date de debut comprise dans la duree ; null pour une
  /// activite d'un seul jour (pas de date de fin a afficher).
  DateTime? get lastDay => durationDays > 1
      ? DateTime(date.year, date.month, date.day + durationDays - 1)
      : null;
}

class MonthSummary {
  const MonthSummary({required this.planned, required this.done});

  final int planned;
  final int done;
}

/// Activites d'une categorie sur le mois : en attente (date pas encore
/// arrivee), en retard (date passee, non realisees) et terminees.
class CategoryStats {
  const CategoryStats({required this.pending, this.late = 0, required this.done});

  final int pending;
  final int late;
  final int done;

  int get total => pending + late + done;

  /// Part (0 a 1) des activites en attente. 0 si la categorie est vide.
  double get pendingShare => total == 0 ? 0 : pending / total;

  /// Part (0 a 1) des activites en retard. 0 si la categorie est vide.
  double get lateShare => total == 0 ? 0 : late / total;

  /// Part (0 a 1) des activites terminees. 0 si la categorie est vide.
  double get doneShare => total == 0 ? 0 : done / total;
}
