import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/activity.dart';
import '../domain/meeting_type.dart';
import '../domain/plan_status.dart';
import '../domain/participant.dart';
import '../domain/training_type.dart';
import '../domain/visit_type.dart';

/// Donnees de demonstration (aucun appel reseau). Seront remplacees par la
/// base locale (drift) alimentee par la synchronisation.
final todayProvider = Provider<DateTime>((ref) => DateTime(2026, 10, 27));

/// Activites du mois par categorie (formations, rencontres, visites).
final categoryStatsProvider = Provider<Map<ActivityCategory, CategoryStats>>(
  (ref) => const {
    ActivityCategory.training: CategoryStats(pending: 0, done: 2),
    ActivityCategory.meeting: CategoryStats(pending: 1, done: 3),
    ActivityCategory.visit: CategoryStats(pending: 3, done: 9),
  },
);

/// Total du mois, deduit des categories : les chiffres restent coherents.
final monthSummaryProvider = Provider<MonthSummary>((ref) {
  final stats = ref.watch(categoryStatsProvider).values;
  return MonthSummary(
    planned: stats.fold(0, (sum, c) => sum + c.total),
    done: stats.fold(0, (sum, c) => sum + c.done),
  );
});

final activitiesProvider = Provider<List<Activity>>(
  (ref) => [
    Activity(
      id: 'a1',
      category: ActivityCategory.visit,
      title: 'Visite de plantation',
      place: 'Lot 2 · Section Nord · Plantation 4417',
      date: DateTime(2026, 10, 27),
      status: ActivityStatus.inProgress,
      visitType: VisitType.plantation,
      section: 'Nord',
      village: 'Siporex',
      subjectName: 'Ahizi Aka Mathieu',
      rank: 2,
      endDate: DateTime(2026, 11, 3),
    ),
    Activity(
      id: 'a2',
      category: ActivityCategory.visit,
      title: 'Visite de plantation',
      place: 'Lot 2 · Section Nord · Plantation 4420',
      date: DateTime(2026, 10, 27),
      status: ActivityStatus.todo,
      visitType: VisitType.plantation,
      section: 'Nord',
      village: 'Siporex',
      subjectName: 'Kouadio Yao',
      rank: 1,
      endDate: DateTime(2026, 11, 2),
    ),
    Activity(
      id: 'a3',
      category: ActivityCategory.meeting,
      title: 'Rencontre de groupe',
      place: 'Lot 2 · Section Sud · Groupe Espoir',
      date: DateTime(2026, 10, 27),
      status: ActivityStatus.done,
      meetingType: MeetingType.outreachGroup,
      section: 'Sud',
      village: 'Bonoua',
      subjectName: 'Groupe Espoir',
      rank: 2,
      endDate: DateTime(2026, 10, 27),
    ),
    Activity(
      id: 'a4',
      category: ActivityCategory.visit,
      title: 'Visite de plantation',
      place: 'Lot 2 · Section Nord · Plantation 4398',
      date: DateTime(2026, 10, 26),
      status: ActivityStatus.todo,
      visitType: VisitType.plantation,
      section: 'Nord',
      village: 'Yaokro',
      subjectName: 'Konan Brou',
      rank: 1,
      endDate: DateTime(2026, 10, 30),
    ),
    Activity(
      id: 'a5',
      category: ActivityCategory.visit,
      title: 'Visite de plantation',
      place: 'Lot 2 · Section Sud · Plantation 4430',
      date: DateTime(2026, 10, 28),
      status: ActivityStatus.todo,
      visitType: VisitType.plantation,
      section: 'Sud',
      village: 'Bonoua',
      subjectName: 'Traoré Issa',
      rank: 1,
      endDate: DateTime(2026, 11, 4),
    ),
    Activity(
      id: 'a6',
      category: ActivityCategory.training,
      title: 'Formation à la saignée',
      place: 'Lot 2 · Section Nord',
      date: DateTime(2026, 10, 30),
      status: ActivityStatus.todo,
      trainingType: TrainingType.initial,
      section: 'Nord',
      village: 'Siporex',
      subjectName: 'Kouamé Jean',
      rank: 2,
      endDate: DateTime(2026, 11, 2),
    ),
    Activity(
      id: 'a7',
      category: ActivityCategory.visit,
      title: 'Visite de plantation',
      place: 'Lot 2 · Section Nord · Plantation 4385',
      date: DateTime(2026, 10, 23),
      status: ActivityStatus.todo,
      visitType: VisitType.plantation,
      section: 'Nord',
      village: 'Yaokro',
      subjectName: 'Koffi Adjoua',
      rank: 1,
      endDate: DateTime(2026, 10, 28),
    ),
    Activity(
      id: 'a8',
      category: ActivityCategory.visit,
      title: 'Visite de plantation',
      place: 'Lot 2 · Section Sud · Plantation 4391',
      date: DateTime(2026, 10, 22),
      status: ActivityStatus.done,
      anomaly: 'Position hors secteur',
      visitType: VisitType.conformity,
      section: 'Sud',
      village: 'Bonoua',
      subjectName: 'Zadi Gnagne',
      rank: 1,
      endDate: DateTime(2026, 10, 27),
    ),
    Activity(
      id: 'a9',
      category: ActivityCategory.training,
      title: 'Perfectionnement in situ',
      place: 'Lot 2 · Section Sud',
      date: DateTime(2026, 10, 21),
      status: ActivityStatus.done,
      trainingType: TrainingType.inSitu,
      section: 'Sud',
      village: 'Bonoua',
      subjectName: 'Brou Akissi',
      rank: 1,
      endDate: DateTime(2026, 10, 22),
    ),
    Activity(
      id: 'a10',
      category: ActivityCategory.training,
      title: 'Recyclage des saigneurs',
      place: 'Lot 2 · Section Nord',
      date: DateTime(2026, 11, 3),
      status: ActivityStatus.todo,
      trainingType: TrainingType.recycling,
      section: 'Nord',
      village: 'Yaokro',
      subjectName: 'Yao Marie',
      rank: 1,
      endDate: DateTime(2026, 11, 5),
    ),
    Activity(
      id: 'a15',
      category: ActivityCategory.visit,
      title: 'Visite de plantation',
      place: 'Lot 2 · Section Nord · Plantation 4417',
      date: DateTime(2026, 10, 12),
      status: ActivityStatus.done,
      visitType: VisitType.plantation,
      section: 'Nord',
      village: 'Siporex',
      subjectName: 'Ahizi Aka Mathieu',
      rank: 1,
      endDate: DateTime(2026, 10, 17),
    ),
    Activity(
      id: 'a16',
      category: ActivityCategory.visit,
      title: 'Visite de plantation',
      place: 'Lot 2 · Section Nord · Plantation 4440',
      date: DateTime(2026, 10, 29),
      status: ActivityStatus.todo,
      visitType: VisitType.plantation,
      section: 'Nord',
      village: 'Yaokro',
      subjectName: 'Bamba Seydou',
      rank: 1,
      endDate: DateTime(2026, 11, 5),
    ),
    Activity(
      id: 'a17',
      category: ActivityCategory.visit,
      title: 'Visite de plantation',
      place: 'Lot 2 · Section Nord · Plantation 4441',
      date: DateTime(2026, 10, 30),
      status: ActivityStatus.todo,
      visitType: VisitType.plantation,
      section: 'Nord',
      village: 'Siporex',
      subjectName: 'Diallo Mariam',
      rank: 1,
      endDate: DateTime(2026, 11, 6),
    ),
    Activity(
      id: 'a18',
      category: ActivityCategory.visit,
      title: 'Visite de plantation',
      place: 'Lot 2 · Section Nord · Plantation 4442',
      date: DateTime(2026, 10, 15),
      status: ActivityStatus.done,
      visitType: VisitType.plantation,
      section: 'Nord',
      village: 'Yaokro',
      subjectName: 'Ehui Marcel',
      rank: 1,
      endDate: DateTime(2026, 10, 20),
    ),
    Activity(
      id: 'a19',
      category: ActivityCategory.training,
      title: 'Formation à la saignée',
      place: 'Lot 2 · Section Nord',
      date: DateTime(2026, 10, 10),
      status: ActivityStatus.done,
      trainingType: TrainingType.initial,
      section: 'Nord',
      village: 'Siporex',
      subjectName: 'Kouamé Jean',
      rank: 1,
      endDate: DateTime(2026, 10, 14),
    ),
    Activity(
      id: 'a20',
      category: ActivityCategory.meeting,
      title: 'Rencontre de groupe',
      place: 'Lot 2 · Section Sud · Groupe Espoir',
      date: DateTime(2026, 10, 13),
      status: ActivityStatus.done,
      meetingType: MeetingType.outreachGroup,
      section: 'Sud',
      village: 'Bonoua',
      subjectName: 'Groupe Espoir',
      rank: 1,
      endDate: DateTime(2026, 10, 13),
    ),
    Activity(
      id: 'a11',
      category: ActivityCategory.visit,
      title: 'Visite d\'intervention',
      place: 'Lot 2 · Section Nord · Plantation 4402',
      date: DateTime(2026, 10, 20),
      status: ActivityStatus.done,
      visitType: VisitType.intervention,
      section: 'Nord',
      village: 'Yaokro',
      subjectName: 'Yao Kouassi',
      rank: 1,
      endDate: DateTime(2026, 10, 25),
    ),
    Activity(
      id: 'a12',
      category: ActivityCategory.visit,
      title: 'Découverte du verger',
      place: 'Lot 2 · Section Sud · Plantation 4433',
      date: DateTime(2026, 11, 5),
      status: ActivityStatus.todo,
      visitType: VisitType.orchard,
      section: 'Sud',
      village: 'Bonoua',
      subjectName: 'Tano Amenan',
      rank: 1,
      endDate: DateTime(2026, 11, 12),
    ),
    Activity(
      id: 'a13',
      category: ActivityCategory.meeting,
      title: 'Conférence thématique',
      place: 'Lot 2 · Section Nord',
      date: DateTime(2026, 10, 19),
      status: ActivityStatus.done,
      meetingType: MeetingType.conference,
      section: 'Nord',
      village: 'Siporex',
      subjectName: 'Groupe Union',
      rank: 1,
      endDate: DateTime(2026, 10, 19),
    ),
    Activity(
      id: 'a14',
      category: ActivityCategory.meeting,
      title: 'Voyage d\'étude',
      place: 'Lot 2 · Section Sud',
      date: DateTime(2026, 11, 12),
      status: ActivityStatus.todo,
      meetingType: MeetingType.studyTrip,
      section: 'Sud',
      village: 'Bonoua',
      subjectName: 'Groupe Espoir',
      rank: 1,
      endDate: DateTime(2026, 11, 14),
    ),
  ],
);

/// Etat du planning annuel du collaborateur (demo).
final planStatusProvider = Provider<PlanStatus>((ref) => PlanStatus.validated);

final selectedActivityProvider =
    NotifierProvider<SelectedActivity, String?>(SelectedActivity.new);

/// Activite choisie dans le volet de detail (tablette).
class SelectedActivity extends Notifier<String?> {
  @override
  String? build() => null;

  void select(String? id) => state = id;
}

/// Participants d'une activite. Demonstration : les memes trois personnes pour
/// toute visite. Avec le back, ils viendront de la plantation (saigneurs et
/// planteur de la base externe).
final participantsProvider = Provider.family<List<Participant>, String>((ref, activityId) {
  final activity = ref.watch(activitiesProvider).where((a) => a.id == activityId);
  if (activity.isEmpty || activity.first.category != ActivityCategory.visit) {
    return const [];
  }
  return const [
    Participant(id: 'p1', name: 'N GUESSAN Valentin', role: ParticipantRole.tapper, phone: '78-85-55-58'),
    Participant(id: 'p2', name: 'TANOH YVES', role: ParticipantRole.tapper, phone: '78-96-36-96'),
    Participant(id: 'p3', name: 'KOUAME Lisette', role: ParticipantRole.planter, phone: '78-98-89-98'),
  ];
});
