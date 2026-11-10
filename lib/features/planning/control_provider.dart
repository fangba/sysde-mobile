import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/demo_data.dart';
import '../../domain/activity.dart';
import '../../domain/control.dart';
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
