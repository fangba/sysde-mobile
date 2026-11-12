import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/demo_data.dart';
import '../../domain/activity.dart';
import '../../domain/control.dart';
import '../../domain/participant.dart';
import '../../domain/visit_progress.dart';
import '../../domain/visit_type.dart';

String controlKey(String activityId, String participantId) => '$activityId/$participantId';

/// Presence et notes saisies, par activite et participant. Provisoire (memoire) :
/// sera enregistre dans la base locale puis envoye au serveur.
class ControlsNotifier extends Notifier<Map<String, ParticipantControl>> {
  @override
  Map<String, ParticipantControl> build() => const {};

  void setAttendance(String key, Attendance a) {
    final current = state[key] ?? const ParticipantControl();
    state = {...state, key: current.withAttendance(a)};
  }

  void setRating(String key, Criterion c, Rating r) {
    final current = state[key] ?? const ParticipantControl();
    state = {...state, key: current.withRating(c, r)};
  }

  void setVerdict(String key, Verdict v) {
    final current = state[key] ?? const ParticipantControl();
    state = {...state, key: current.withVerdict(v)};
  }

  void setComment(String key, String text) {
    final current = state[key] ?? const ParticipantControl();
    state = {...state, key: current.withComment(text)};
  }
}

final controlsProvider =
    NotifierProvider<ControlsNotifier, Map<String, ParticipantControl>>(ControlsNotifier.new);

/// Notes des visites de plantation passees sur la plantation d'une visite de
/// conformite, de la plus ancienne a la plus recente. Elles viennent des
/// controles saisis (visites de plantation du meme sujet, avant la date) et,
/// en attendant le back, de donnees de demonstration.
final conformityNotesProvider = Provider.family<List<VisitNotes>, String>((ref, activityId) {
  final activities = ref.watch(activitiesProvider);
  final current = activities.where((a) => a.id == activityId).firstOrNull;
  final subject = current?.subjectName;
  if (current == null || subject == null) return const [];
  final controls = ref.watch(controlsProvider);

  final notes = <VisitNotes>[...?demoVisitNotes[subject]];
  for (final a in activities) {
    if (a.category != ActivityCategory.visit ||
        a.visitType != VisitType.plantation ||
        a.subjectName != subject ||
        !a.date.isBefore(current.date)) {
      continue;
    }
    final prefix = '${a.id}/';
    final byPerson = {
      for (final e in controls.entries)
        if (e.key.startsWith(prefix)) e.key.substring(prefix.length): e.value,
    };
    if (byPerson.isNotEmpty) {
      notes.add(VisitNotes(rank: a.rank ?? 1, date: a.date, byParticipant: byPerson));
    }
  }
  notes.sort((x, y) => x.date.compareTo(y.date));
  return notes;
});

/// Visites dont le rapport est fait. Provisoire (memoire) tant que l'ecran du
/// rapport n'existe pas.
class ReportsNotifier extends Notifier<Set<String>> {
  @override
  Set<String> build() => const {};

  void markDone(String activityId) => state = {...state, activityId};
}

final reportsProvider = NotifierProvider<ReportsNotifier, Set<String>>(ReportsNotifier.new);

/// Avancement d'une visite : presence (tous les participants pointes), puis
/// controle (tous les presents evalues), puis rapport.
final visitProgressProvider = Provider.family<VisitProgress, String>((ref, activityId) {
  final people = ref.watch(participantsProvider(activityId));
  final controls = ref.watch(controlsProvider);
  final activity = ref.watch(activitiesProvider).where((a) => a.id == activityId).firstOrNull;
  final conformity = activity?.visitType == VisitType.conformity;
  final hasControl = activity?.meetingType?.hasControl ?? true;

  ParticipantControl of(Participant p) =>
      controls[controlKey(activityId, p.id)] ?? const ParticipantControl();

  final attendance = people.isNotEmpty && people.every((p) => of(p).attendance != null);
  final present = [
    for (final p in people)
      if (of(p).attendance == Attendance.present) of(p),
  ];
  final control = attendance &&
      present.isNotEmpty &&
      present.every((c) => conformity ? c.isConformityComplete : c.isComplete);
  return VisitProgress(
    attendance: attendance,
    control: control,
    hasControl: hasControl,
    report: ref.watch(reportsProvider).contains(activityId),
  );
});
